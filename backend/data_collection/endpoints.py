from fastapi import FastAPI, status
from fastapi.middleware.cors import CORSMiddleware
from models import Drivers, DriversWithPoints, RaceData
from get_data import (
    getStandingsData,
    getChampionshipStandings,
    getLastRace,
    getNextRace,
)


app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get(
    "/last_race/standings", status_code=status.HTTP_200_OK, response_model=list[Drivers]
)
async def getStandings():

    drivers = await getStandingsData()
    driversResponse = []
    pos = 1
    for driver in drivers:
        driversResponse.append(Drivers(name=driver[0], team=driver[1], pos=str(pos)))
        pos += 1

    return driversResponse


@app.get(
    "/championship/standings",
    status_code=status.HTTP_200_OK,
    response_model=list[DriversWithPoints],
)
async def getChampionship():

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

    return driversResponse


@app.get("/last_race/data", response_model=RaceData, status_code=status.HTTP_200_OK)
async def fetchLastRaceData():

    lastRaceData = await getLastRace()
    return RaceData(name=lastRaceData[0], date=lastRaceData[1])


@app.get("/next_race/data", status_code=status.HTTP_200_OK, response_model=RaceData)
async def fetchNextRaceData():

    nextRaceData = await getNextRace()
    return RaceData(name=nextRaceData[0], date=nextRaceData[1])
