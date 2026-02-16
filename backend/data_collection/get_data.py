import fastf1 as f1
import pandas as pd
import asyncio
from fastf1.ergast import Ergast
from datetime import datetime, timezone
from tenacity import retry, stop_after_attempt, wait_exponential

f1.Cache.enable_cache("fastf1_cache")


async def getStandingsData():

    return await asyncio.to_thread(_loadStandings)


async def getChampionshipStandings():
    return await asyncio.to_thread(_loadChampionshipStandings)


async def getLastRace():
    return await asyncio.to_thread(_getLastRace)


async def getNextRace():
    return await asyncio.to_thread(_getNextRace)


async def getConstructorsChampionshipStandings():
    return await asyncio.to_thread(_loadConstructorsChampionshipStandings)


async def getNextQuali():
    return await asyncio.to_thread(_getNextQuali)


@retry(stop=stop_after_attempt(3), wait=wait_exponential(min=1, max=5))
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

    standings = session.results[["FullName", "TeamName"]]

    drivers = [
        (row.FullName, row.TeamName) for row in standings.itertuples(index=False)
    ]

    return drivers


@retry(stop=stop_after_attempt(3), wait=wait_exponential(min=1, max=5))
def _loadChampionshipStandings():

    ergast = Ergast()
    standings = ergast.get_driver_standings(season=2025)
    standings_df = standings.content[0][
        ["givenName", "familyName", "constructorNames", "points"]
    ]
    # print(standings_df[["position", "givenName", "familyName", "constructorNames"]])
    drivers = [
        (
            f"{row.givenName} {row.familyName}",
            row.constructorNames[0],
            row.points,
        )
        for row in standings_df.itertuples(index=False)
    ]

    return drivers


@retry(stop=stop_after_attempt(3), wait=wait_exponential(min=1, max=5))
def _loadConstructorsChampionshipStandings():

    ergast = Ergast()
    standings = ergast.get_constructor_standings(season=2025)
    standings_df = standings.content[0][["points", "constructorName"]]
    teams = [
        (row.constructorName, int(row.points))
        for row in standings_df.itertuples(index=False)
    ]

    return teams


@retry(stop=stop_after_attempt(3), wait=wait_exponential(min=1, max=5))
def _getLastRace():

    ergast = Ergast()
    races = ergast.get_race_schedule(season=2026)
    races["raceDate"] = pd.to_datetime(races["raceDate"], utc=True)
    now = datetime.now(timezone.utc)
    past_races = races[races["raceDate"] <= now]
    if past_races.empty:
        races = ergast.get_race_schedule(season=2025)
        races["raceDate"] = pd.to_datetime(races["raceDate"], utc=True)
        now = datetime.now(timezone.utc)
        past_races = races[races["raceDate"] <= now]

    past_races = past_races.sort_values("raceDate", ascending=False)
    date = past_races.iloc[0]["raceDate"]
    date_str = date.strftime("%d %B %Y")
    date_computations = date.strftime("%Y-%m-%d")
    time = past_races.iloc[0]["raceTime"]
    time_computations = time.strftime("%H:%M:%S")
    name = past_races.iloc[0]["raceName"]
    return (name, date_str, date_computations, time_computations)


@retry(stop=stop_after_attempt(3), wait=wait_exponential(min=1, max=5))
def _getNextRace():

    ergast = Ergast()
    races = ergast.get_race_schedule(season=2026)
    races["raceDate"] = pd.to_datetime(races["raceDate"], utc=True)
    now = datetime.now(timezone.utc)
    next_races = races[races["raceDate"] >= now]
    next_races = next_races.sort_values("raceDate", ascending=True)
    date = next_races.iloc[0]["raceDate"]
    date_str = date.strftime("%d %B %Y")
    date_computations = date.strftime("%Y-%m-%d")
    time = next_races.iloc[0]["raceTime"]
    time_computations = time.strftime("%H:%M:%S")
    name = next_races.iloc[0]["raceName"]
    return (name, date_str, date_computations, time_computations)


@retry(stop=stop_after_attempt(3), wait=wait_exponential(min=1, max=5))
def _getNextQuali():
    ergast = Ergast()
    races = ergast.get_race_schedule(season=2026)
    quali = races[["season", "round", "raceName", "qualifyingDate", "qualifyingTime"]]
    quali["qualifyingDate"] = pd.to_datetime(quali["qualifyingDate"], utc=True)
    now = datetime.now(timezone.utc)
    futureQualis = quali[quali["qualifyingDate"] >= now]
    futureQualis = futureQualis.sort_values("qualifyingDate", ascending=True)
    date = futureQualis.iloc[0]["qualifyingDate"]
    date_str = date.strftime("%d %B %Y")
    date_computations = date.strftime("%Y-%m-%d")
    time = futureQualis.iloc[0]["qualifyingTime"]
    time_computations = time.strftime("%H:%M:%S")
    name = futureQualis.iloc[0]["racename"]
    return (name, date_str, date_computations, time_computations)
