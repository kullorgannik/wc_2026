-- sqlfluff:rules:disable=dbt0116
with source_data as (
    select * from {{ source('wc_data', 'worldcup') }}
),

-- Goals scored by team1 (home team context for goals1 array)
team1_goals as (
    select
        m.team1 as home_team,
        m.team2 as away_team,
        g1.name as goal_scorer,
        m.team1 as player_team,
        g1.minute as goal_minute
    from source_data
    cross join unnest(source_data.matches) as m
    cross join unnest(m.goals1) as g1
),

-- Goals scored by team2 (away team context for goals2 array)
team2_goals as (
    select
        m.team1 as home_team,
        m.team2 as away_team,
        g2.name as goal_scorer,
        m.team2 as player_team,
        g2.minute as goal_minute
    from source_data
    cross join unnest(source_data.matches) as m
    cross join unnest(m.goals2) as g2
),

-- Union of all goals scored in the matches
final as (
    select * from team1_goals
    union all
    select * from team2_goals
)

select
    home_team,
    away_team,
    goal_scorer,
    player_team,
    goal_minute
from final