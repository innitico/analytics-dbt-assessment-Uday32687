with providers as (
    select id,customer_id,first_name,last_name,degrees from {{ ref('providers')}}
),

addresses as (
    select id, street, rank from {{ ref('addresses')}}
),

provider_addresses as (
    select provider_id, address_id
    from {{ ref('provider_addresses')}}
),

joined_addresses as (
    select pa.provider_id,
    --object_construct('id',a.id,'street',a.street,'rank',rank) as address_object
    --struct_pack(id := a.id, street:= a.street, rank := a.rank ) as address_object
    json_object('id', a.id, 'street',a.street,'rank',rank) as address_object
    from provider_addresses pa
    join addresses a
    on pa.address_id = a.id
),

addresses_agg as (
    select provider_id,
    array_agg(cast(address_object as varchar)) as addresses
    from joined_addresses
    group by provider_id
),

final as (
    select p.id,
    p.customer_id,
    p.first_name, p. last_name, p.degrees,
    coalesce(a.addresses,[]) as addresses
    from providers p
    left join addresses_agg a
    on p.id = a.provider_id
)

select * from final