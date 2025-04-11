with providers as (
    select id as provider_id,
    first_name,
    string_split(degrees, ',') as degree_array
    from {{ ref('providers')}}
),

flattened_degrees as (
    select provider_id,
    first_name,
    unnest(degree_array) as degree
    from providers
),

cleaned_degrees as (
    select provider_id, first_name,
    trim(degree) as degree
    from flattened_degrees
),

joined_with_types as (
    select f.provider_id, f.first_name,
    dt.ptui,
    dt.rank
    from cleaned_degrees f
    join {{ ref('degree_types')}} dt
    on upper(f.degree) = upper(dt.degree)
),

ranked_degrees as (
    select *,
    row_number() over (partition by provider_id order by rank asc) as rn
    from joined_with_types
),

final as (
    select provider_id,
    first_name,
    ptui
    from ranked_degrees
    where rn = 1
)

select * from final