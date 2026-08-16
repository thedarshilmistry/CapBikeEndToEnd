{{ config(materialized='table', schema='silver') }}

{% set snap_metres = 50 %}

with q as (

    select * from {{ ref('QUARANTINE') }}

),

nearest_start as (

    select
        c.ride_id,
        n.stn_id,
        round((n.dist * 111000)::numeric, 0) as metres

    from (
        select ride_id, start_lat, start_lng
        from q
        where start_station_id is null
          and start_lat is not null
          and start_lng is not null
    ) c

    cross join lateral (
        select
            d.stn_id,
            sqrt(
                power(c.start_lat - d.lat, 2)
                + power((c.start_lng - d.lng) * 0.778, 2)
            ) as dist
        from {{ ref('DIM_STATIONS') }} d
        order by dist
        limit 1
    ) n

),

nearest_end as (

    select
        c.ride_id,
        n.stn_id,
        round((n.dist * 111000)::numeric, 0) as metres

    from (
        select ride_id, end_lat, end_lng
        from q
        where end_station_id is null
          and end_lat is not null
          and end_lng is not null
    ) c

    cross join lateral (
        select
            d.stn_id,
            sqrt(
                power(c.end_lat - d.lat, 2)
                + power((c.end_lng - d.lng) * 0.778, 2)
            ) as dist
        from {{ ref('DIM_STATIONS') }} d
        order by dist
        limit 1
    ) n

)

select
    q.*,

    -- repaired identifiers: original where present, snapped where close enough
    coalesce(
        q.start_station_id,
        case when ns.metres <= {{ snap_metres }} then ns.stn_id end
    ) as start_stn_id_repaired,

    coalesce(
        q.end_station_id,
        case when ne.metres <= {{ snap_metres }} then ne.stn_id end
    ) as end_stn_id_repaired,

    -- provenance: was this identifier measured or inferred?
    coalesce(q.start_station_id is null and ns.metres <= {{ snap_metres }}, false)
        as start_stn_imputed,

    coalesce(q.end_station_id is null and ne.metres <= {{ snap_metres }}, false)
        as end_stn_imputed,

    ns.metres as start_snap_m,
    ne.metres as end_snap_m

from q
left join nearest_start ns on ns.ride_id = q.ride_id
left join nearest_end   ne on ne.ride_id = q.ride_id

where ns.metres is not null or ne.metres is not null