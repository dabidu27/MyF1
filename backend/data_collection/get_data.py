import fastf1 as f1
import pandas as pd
import asyncio
from fastf1.ergast import Ergast

f1.Cache.enable_cache("fastf1_cache")


async def getStandingsData():

    return await asyncio.to_thread(_loadStandings)


async def getChampionshipStandings():
    return await asyncio.to_thread(_loadChampionshipStandings)


def _loadStandings():

    session = f1.get_session(2025, "Abu Dhabi", "Race")
    session.load()

    top3 = session.results[:3][["FullName", "TeamName"]]
    driver1 = (top3.iloc[0, 0], top3.iloc[0, 1])
    driver2 = (top3.iloc[1, 0], top3.iloc[1, 1])
    driver3 = (top3.iloc[2, 0], top3.iloc[2, 1])

    return [driver1, driver2, driver3]


def _loadChampionshipStandings():

    ergast = Ergast()
    standings = ergast.get_driver_standings(season=2025)
    standings_df = standings.content[0][:3][
        ["givenName", "familyName", "constructorNames"]
    ]
    # print(standings_df[["position", "givenName", "familyName", "constructorNames"]])
    driver1 = (
        f"{standings_df.iloc[0, 0]} {standings_df.iloc[0, 1]}",
        standings_df.iloc[0, 2][0],
    )
    driver2 = (
        f"{standings_df.iloc[1, 0]} {standings_df.iloc[1, 1]}",
        standings_df.iloc[1, 2][0],
    )
    driver3 = (
        f"{standings_df.iloc[2, 0]} {standings_df.iloc[2, 1]}",
        standings_df.iloc[2, 2][0],
    )

    return [driver1, driver2, driver3]
