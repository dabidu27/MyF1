from datetime import datetime, timedelta, timezone


def getSecondsUntilRaceFinish(nextRaceIso):

    try:

        if "T" in nextRaceIso:
            # if a full timestamp: "2026-03-02T15:00:00Z"
            raceStart = datetime.fromisoformat(nextRaceIso.replace("Z", "+00:00"))
        else:
            # if just a date: "2026-03-02", must orce full datetime
            raceStart = datetime.fromisoformat(nextRaceIso).replace(
                hour=14, minute=0, second=0, tzinfo=timezone.utc
            )

        raceFinish = raceStart + timedelta(hours=2, minutes=30)

        now = datetime.now(timezone.utc)
        remaining = (raceFinish - now).total_seconds()

        return int(remaining)

    except Exception as e:
        print(f"TTL Calculation Error: {e}")
        return 3600
