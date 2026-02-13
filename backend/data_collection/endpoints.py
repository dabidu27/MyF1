from fastapi import FastAPI, status, Response, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.encoders import jsonable_encoder
from models import Drivers, DriversWithPoints, RaceData, ConstructorsStandings
from get_data import (
    getStandingsData,
    getChampionshipStandings,
    getLastRace,
    getNextRace,
    getConstructorsChampionshipStandings,
)
from fastapi_cache import FastAPICache
from fastapi_cache.backends.redis import RedisBackend
from fastapi_limiter import FastAPILimiter
from fastapi_limiter.depends import RateLimiter
from redis import asyncio as aioredis
import json
from cache_utils import getSecondsUntilRaceFinish

generalLimiter = RateLimiter(
    times=60, seconds=60
)  # rate limiter for all endpoints => 1 request/seconds (60 requests/60 seconds)
app = FastAPI(dependencies=[generalLimiter])
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
async def startup():

    redis = aioredis.from_url(
        "redis://redis:6379", encoding="utf8", decode_responses=True
    )
    FastAPICache.init(RedisBackend(redis), prefix="f1-cache")
    await FastAPILimiter.init(redis)


@app.get(
    "/last_race/standings",
    status_code=status.HTTP_200_OK,
    response_model=list[Drivers],
)
async def getStandings(response: Response):
    cache_key = "last_race_standings_data"
    redis = FastAPICache.get_backend().redis

    cached_data = await redis.get(cache_key)

    # if data is in cache
    if cached_data:

        remaining_ttl = await redis.ttl(cache_key)
        response.headers["X-Cache"] = "HIT"
        response.headers["Cache-Control"] = f"public, max_age={remaining_ttl}"
        return json.loads(cached_data)

    # if data is not in cache
    nextRaceData = await getNextRace()
    nextRaceIso = nextRaceData[2]
    ttl_seconds = getSecondsUntilRaceFinish(nextRaceIso)

    drivers = await getStandingsData()
    driversResponse = []
    pos = 1
    for driver in drivers:
        driversResponse.append(Drivers(name=driver[0], team=driver[1], pos=str(pos)))
        pos += 1

    # save response to Redis (cache)
    await redis.set(
        cache_key, json.dumps(jsonable_encoder(driversResponse)), ex=ttl_seconds
    )

    response.headers["X-Cache"] = "MISS"
    response.headers["Cache-Control"] = f"public, max_age={ttl_seconds}"

    return driversResponse


@app.get(
    "/championship/standings",
    status_code=status.HTTP_200_OK,
    response_model=list[DriversWithPoints],
)
async def getChampionship(response: Response):

    cache_key = "drivers_standings_data"
    redis = FastAPICache.get_backend().redis

    cached_data = await redis.get(cache_key)
    if cached_data:

        remaining_ttl = await redis.ttl(cache_key)
        response.headers["X-Cache"] = "HIT"
        response.headers["Cache-Control"] = f"public, max_age={remaining_ttl}"

        return json.loads(cached_data)

    nextRaceData = await getNextRace()
    nextRaceIso = nextRaceData[2]
    ttl_seconds = getSecondsUntilRaceFinish(nextRaceIso)

    drivers = await getChampionshipStandings()
    driversResponse = []
    pos = 1
    for driver in drivers:
        driversResponse.append(
            DriversWithPoints(
                name=driver[0], team=driver[1], pos=str(pos), points=str(int(driver[2]))
            )
        )
        pos += 1

    await redis.set(
        cache_key, json.dumps(jsonable_encoder(driversResponse)), ex=ttl_seconds
    )

    response.headers["X-Cache"] = "MISS"
    response.headers["Cache-Control"] = f"public, max_age={ttl_seconds}"
    return driversResponse


@app.get(
    "/championship/constructors/standings",
    response_model=list[ConstructorsStandings],
    status_code=status.HTTP_200_OK,
)
async def getConstructorsChampionship(response: Response):

    cache_key = "constructors_standings_data"
    redis = FastAPICache.get_backend().redis
    cached_data = await redis.get(cache_key)
    if cached_data:

        remaining_ttl = await redis.ttl(cache_key)
        response.headers["X-Cache"] = "HIT"
        response.headers["Cache-Control"] = f"public, max_age={remaining_ttl}"
        return json.loads(cached_data)

    nextRaceData = await getNextRace()
    nextRaceIso = nextRaceData[2]
    ttl_seconds = getSecondsUntilRaceFinish(nextRaceIso)

    constructors = await getConstructorsChampionshipStandings()
    constructorsResponse = []
    pos = 1
    for constructor in constructors:
        constructorsResponse.append(
            ConstructorsStandings(
                name=constructor[0], points=str(constructor[1]), pos=str(pos)
            )
        )
        pos += 1

    response.headers["X-Cache"] = "MISS"
    response.headers["Cache-Control"] = f"public, max_age={ttl_seconds}"

    await redis.set(
        cache_key, json.dumps(jsonable_encoder(constructorsResponse)), ex=ttl_seconds
    )
    return constructorsResponse


@app.get("/last_race/data", response_model=RaceData, status_code=status.HTTP_200_OK)
async def fetchLastRaceData(response: Response):

    cache_key = "last_race_data"
    redis = FastAPICache.get_backend().redis
    cached_data = await redis.get(cache_key)

    if cached_data:

        remaining_ttl = await redis.ttl(cache_key)
        response.headers["X-Cache"] = "HIT"
        response.headers["Cache-Control"] = f"public, max_age={remaining_ttl}"

        return json.loads(cached_data)

    nextRaceData = await getNextRace()
    nextRaceIso = nextRaceData[2]
    ttl_seconds = getSecondsUntilRaceFinish(nextRaceIso)

    lastRaceData = await getLastRace()

    response.headers["X-Cache"] = "Miss"
    response.headers["Cache-Control"] = f"public, max_age={ttl_seconds}"
    await redis.set(
        cache_key,
        json.dumps(
            jsonable_encoder(
                RaceData(
                    name=lastRaceData[0],
                    datePretty=lastRaceData[1],
                    dateComputations=lastRaceData[2],
                    timeComputations=lastRaceData[3],
                )
            )
        ),
        ex=ttl_seconds,
    )

    return RaceData(
        name=lastRaceData[0],
        datePretty=lastRaceData[1],
        dateComputations=lastRaceData[2],
        timeComputations=lastRaceData[3],
    )


@app.get("/next_race/data", status_code=status.HTTP_200_OK, response_model=RaceData)
async def fetchNextRaceData(response: Response):

    cache_key = "next_race_data"
    redis = FastAPICache.get_backend().redis
    cached_data = await redis.get(cache_key)

    if cached_data:

        remaining_ttl = await redis.ttl(cache_key)
        response.headers["X-Cache"] = "HIT"
        response.headers["Cache-Control"] = f"public, max_age={remaining_ttl}"
        return json.loads(cached_data)

    nextRaceData = await getNextRace()
    nextRaceIso = nextRaceData[2]
    ttl_seconds = getSecondsUntilRaceFinish(nextRaceIso)

    await redis.set(
        cache_key,
        json.dumps(
            jsonable_encoder(
                RaceData(
                    name=nextRaceData[0],
                    datePretty=nextRaceData[1],
                    dateComputations=nextRaceData[2],
                    timeComputations=nextRaceData[3],
                )
            )
        ),
        ex=ttl_seconds,
    )

    return RaceData(
        name=nextRaceData[0],
        datePretty=nextRaceData[1],
        dateComputations=nextRaceData[2],
        timeComputations=nextRaceData[3],
    )
