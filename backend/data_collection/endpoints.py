from fastapi import FastAPI, status
from fastapi.middleware.cors import CORSMiddleware
from models import Drivers
from get_data import getStandingsData, getChampionshipStandings


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
    response_model=list[Drivers],
)
async def getChampionship():

    drivers = await getChampionshipStandings()
    driversResponse = []
    pos = 1
    for driver in drivers:
        driversResponse.append(Drivers(name=driver[0], team=driver[1], pos=str(pos)))
        pos += 1

    return driversResponse
