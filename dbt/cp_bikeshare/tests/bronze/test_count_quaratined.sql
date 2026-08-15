with counts as (
    select
        (select count(*) from {{ ref('QUARANTINE') }}) as quarantined,
        (select count(*) from {{ source('bronze', 'trips') }}) as total
)
select * from counts
where quarantined > 0.50 * total