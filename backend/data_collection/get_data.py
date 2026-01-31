import fastf1 as f1
import pandas as pd
import asyncio
from fastf1.ergast import Ergast
from datetime import datetime, timezone

f1.Cache.enable_cache("fastf1_cache")


async def getStandingsData():

    return await asyncio.to_thread(_loadStandings)


async def getChampionshipStandings():
    return await asyncio.to_thread(_loadChampionshipStandings)


async def getLastRace():
    return await asyncio.to_thread(_getLastRace)


async def getNextRace():
    return await asyncio.to_thread(_getNextRace)


def _loadStandings():

    ergast = Ergast()
    races = ergast.get_race_schedule(season=2025)
    races["raceDate"] = pd.to_datetime(races["raceDate"], utc=True)
    now = datetime.now(timezone.utc)
    past_races = races[races["raceDate"] <= now]
    past_races = past_races.sort_values("raceDate", ascending=False)
    round = past_races.iloc[0]["round"]
    name = past_races.iloc[0]["raceName"]

    session = f1.get_session(2025, round, "Race")
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
        ["givenName", "familyName", "constructorNames", "points"]
    ]
    # print(standings_df[["position", "givenName", "familyName", "constructorNames"]])
    driver1 = (
        f"{standings_df.iloc[0, 0]} {standings_df.iloc[0, 1]}",
        standings_df.iloc[0, 2][0],
        standings_df.iloc[0, 3],
    )
    driver2 = (
        f"{standings_df.iloc[1, 0]} {standings_df.iloc[1, 1]}",
        standings_df.iloc[1, 2][0],
        standings_df.iloc[1, 3],
    )
    driver3 = (
        f"{standings_df.iloc[2, 0]} {standings_df.iloc[2, 1]}",
        standings_df.iloc[2, 2][0],
        standings_df.iloc[2, 3],
    )

    return [driver1, driver2, driver3]


def _getLastRace():

    ergast = Ergast()
    races = ergast.get_race_schedule(season=2025)
    races["raceDate"] = pd.to_datetime(races["raceDate"], utc=True)
    now = datetime.now(timezone.utc)
    past_races = races[races["raceDate"] <= now]
    past_races = past_races.sort_values("raceDate", ascending=False)
    date = past_races.iloc[0]["raceDate"]
    date_str = date.strftime("%d %B %Y")
    name = past_races.iloc[0]["raceName"]
    return (name, date_str)


def _getNextRace():

    ergast = Ergast()
    races = ergast.get_race_schedule(season=2026)
    races["raceDate"] = pd.to_datetime(races["raceDate"], utc=True)
    now = datetime.now(timezone.utc)
    next_races = races[races["raceDate"] >= now]
    next_races = next_races.sort_values("raceDate", ascending=True)
    date = next_races.iloc[0]["raceDate"]
    date_str = date.strftime("%d %B %Y")
    name = next_races.iloc[0]["raceName"]
    return (name, date_str)
