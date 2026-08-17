import os
from datetime import date

from fastapi import FastAPI, Query
from fastapi.staticfiles import StaticFiles
from sqlalchemy import create_engine, text

DB_URL = (
    f"postgresql+psycopg2://{os.environ['WAREHOUSE_USER']}"
    f":{os.environ['WAREHOUSE_PASSWORD']}"
    f"@{os.environ.get('WAREHOUSE_HOST', 'warehouse')}"
    f":{os.environ.get('WAREHOUSE_PORT', '5432')}"
    f"/{os.environ.get('WAREHOUSE_DB', 'bikeshare')}"
)

engine = create_engine(DB_URL, pool_pre_ping=True)

app = FastAPI(title="Cap Bikeshare")

LOCAL_TZ = "America/New_York"


def rows(sql: str, **params):
    with engine.connect() as c:
        result = c.execute(text(sql), params)
        cols = result.keys()
        return [dict(zip(cols, r)) for r in result.fetchall()]


@app.get("/api/range")
def date_range():
    """Earliest and latest trip, so the UI can bound its own filters."""
    return rows(
        f"""
        select
            min(start_time at time zone :tz)::date as min_date,
            max(start_time at time zone :tz)::date as max_date,
            count(*) as trips
        from gold."FCT_TRIPS"
        """,
        tz=LOCAL_TZ,
    )[0]


@app.get("/api/kpis")
def kpis(start: date = Query(None), end: date = Query(None)):
    return rows(
        f"""
        with scoped as (
            select * from gold."FCT_TRIPS"
            where (:start is null or (start_time at time zone :tz)::date >= :start)
              and (:end   is null or (start_time at time zone :tz)::date <= :end)
        )
        select
            count(*) as trips,
            count(*) filter (where rider_type = 'member') as member_trips,
            round(avg(extract(epoch from (end_time - start_time)) / 60)::numeric, 1)
                as avg_minutes,
            count(distinct start_stn_id) as stations_used
        from scoped
        """,
        tz=LOCAL_TZ,
        start=start,
        end=end,
    )[0]


@app.get("/api/hourly")
def hourly(start: date = Query(None), end: date = Query(None)):
    """Departures per hour of local time, split by rider type."""
    return rows(
        f"""
        select
            extract(hour from (start_time at time zone :tz))::int as hour,
            count(*) filter (where rider_type = 'member') as member,
            count(*) filter (where rider_type = 'casual') as casual
        from gold."FCT_TRIPS"
        where (:start is null or (start_time at time zone :tz)::date >= :start)
          and (:end   is null or (start_time at time zone :tz)::date <= :end)
        group by 1
        order by 1
        """,
        tz=LOCAL_TZ,
        start=start,
        end=end,
    )


@app.get("/api/daily")
def daily(start: date = Query(None), end: date = Query(None)):
    """Trips per day, annotated with holiday context from DIM_DATE."""
    return rows(
        f"""
        with t as (
            select (start_time at time zone :tz)::date as d, count(*) as trips
            from gold."FCT_TRIPS"
            where (:start is null or (start_time at time zone :tz)::date >= :start)
              and (:end   is null or (start_time at time zone :tz)::date <= :end)
            group by 1
        )
        select
            t.d               as day,
            t.trips           as trips,
            coalesce(dd."Is_holiday", 0)   as is_holiday,
            coalesce(dd."Long_weekend", 0) as long_weekend,
            dd."Holiday"      as holiday_names,
            dd."Country"      as holiday_countries
        from t
        left join gold."DIM_DATE" dd
               on dd."Date"::date = t.d
        order by t.d
        """,
        tz=LOCAL_TZ,
        start=start,
        end=end,
    )


@app.get("/api/stations")
def stations(limit: int = 10, start: date = Query(None), end: date = Query(None)):
    return rows(
        f"""
        select
            s.stn_id,
            s.stn_name,
            s.lat,
            s.lng,
            count(*) as departures
        from gold."FCT_TRIPS" f
        join gold."DIM_STATIONS" s on s.stn_id = f.start_stn_id
        where (:start is null or (f.start_time at time zone :tz)::date >= :start)
          and (:end   is null or (f.start_time at time zone :tz)::date <= :end)
        group by 1, 2, 3, 4
        order by departures desc
        limit :limit
        """,
        tz=LOCAL_TZ,
        start=start,
        end=end,
        limit=limit,
    )


@app.get("/api/bike_mix")
def bike_mix(start: date = Query(None), end: date = Query(None)):
    return rows(
        f"""
        select rideable_type, count(*) as trips
        from gold."FCT_TRIPS"
        where (:start is null or (start_time at time zone :tz)::date >= :start)
          and (:end   is null or (start_time at time zone :tz)::date <= :end)
        group by 1
        order by 2 desc
        """,
        tz=LOCAL_TZ,
        start=start,
        end=end,
    )


@app.get("/api/holiday_effect")
def holiday_effect():
    """Average daily volume on holidays vs ordinary days."""
    return rows(
        f"""
        with t as (
            select (start_time at time zone :tz)::date as d, count(*) as trips
            from gold."FCT_TRIPS"
            group by 1
        )
        select
            case when coalesce(dd."Is_holiday", 0) = 1 then 'Holiday' else 'Ordinary' end
                as day_kind,
            round(avg(t.trips)::numeric, 0) as avg_trips,
            count(*) as days
        from t
        left join gold."DIM_DATE" dd on dd."Date"::date = t.d
        group by 1
        """,
        tz=LOCAL_TZ,
    )


@app.get("/health")
def health():
    try:
        rows("select 1 as ok")
        return {"status": "ok"}
    except Exception as e:
        return {"status": "error", "detail": str(e)}


# Serve the dashboard last so /api routes take precedence.
app.mount("/", StaticFiles(directory="static", html=True), name="static")
