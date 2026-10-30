connection: "looker-private-demo"

include: "/views/*.view.lkml"
include: "/derived_tables/*.view.lkml"
include: "/lookml_dashboards/*.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# Model Configuration
datagroup: events_raw {
  # Rebuild the gaming PDTs once a week (Mondays) instead of daily to cut BigQuery cost.
  sql_trigger: SELECT DATE_TRUNC(CURRENT_DATE(), ISOWEEK) ;;
  max_cache_age: "24 hours"
}

named_value_format: large_usd { value_format: "[>=1000000]\"$\"0.00,,\"M\";[>=1000]\"$\"0.00,\"K\";\"$\"0.00" }
named_value_format: large_number { value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.00,\"K\";0" }

# Explores
explore: events {
  persist_with: events_raw


  aggregate_table: monthly_users {
    query: {
      dimensions: [events.event_month]
      measures: [events.number_of_users]
      timezone: "America/New_York"
    }
    materialization: {
      datagroup_trigger: events_raw
    }
  }

  aggregate_table: daily_overview {
    query: {
      dimensions: [events.event_date, events.game_name]
      measures: [events.number_of_users, events.number_of_new_users, events.total_revenue]
      timezone: "America/New_York"
    }
    materialization: {
      increment_key: event_date
      datagroup_trigger: events_raw
    }
  }

  aggregate_table: revenue {
    query: {
      dimensions: [events.event_name,events.event_date,events.game_name,events.country,events.device_platform,events.install_source,events.install_group]
      measures: [events.total_revenue,events.average_revenue_per_user,events.return_on_ad_spend,events.number_of_new_users,events.number_of_users,events.cost_per_install,events.total_install_spend,events.d1_retention_rate,events.d7_retention_rate]
      timezone: "America/New_York"
    }
    materialization: {
      increment_key: event_date
      datagroup_trigger: events_raw
    }
  }

  join: session_facts {
    relationship: many_to_one
    sql_on: ${events.unique_session_id} = ${session_facts.unique_session_id} ;;
  }

  join: user_facts {
    view_label: "User Lifetime Values"
    relationship: many_to_one
    sql_on: ${events.user_id} = ${user_facts.user_id} ;;
  }

  join: top_countries {
    sql_on: ${events.country} = ${top_countries.country} ;;
    relationship: many_to_one
  }
}

explore: funnel_explorer {
  description: "Player Session Funnels"
  persist_for: "48 hours"

  always_filter: {
    filters: {
      field: event_time
      value: "30 days"
    }
    filters: {
      field: game_name
      value: "Lookerwood Farm"
    }
  }
  join: session_facts {
    sql_on: ${funnel_explorer.unique_session_id} = ${session_facts.unique_session_id} ;;
    relationship: many_to_one
  }

  join: user_facts {
    sql_on: ${funnel_explorer.user_id} = ${user_facts.user_id} ;;
    relationship: many_to_one
  }
}

explore: session_facts {
  label: "Sessions and Users"
  description: "Use this to look at a compressed view of Users and Sessions (without event level data)"
  join: user_facts {
    relationship: many_to_one
    sql_on: ${session_facts.user_id} = ${user_facts.user_id} ;;
  }

  join: lifetime_user_facts {
    sql_on: ${session_facts.user_id} = ${lifetime_user_facts.user_id} ;;
    relationship: many_to_one
  }
}

explore: level_balancing {
  description: "Are players able to progress through levels well? (last 30 days)"

  join: user_facts {
    relationship: many_to_one
    sql_on: ${level_balancing.user_id} = ${user_facts.user_id} ;;
  }
}

explore: player_safety_incidents {
  label: "Player Safety & Incidents"
  description: "Live moderation telemetry, harm vector breakdown, and incident resolution tracking"
}

explore: toxicity_exposure_retention_daily {
  label: "Toxicity Exposure & Retention Impact"
  description: "Analysis of toxic match exposure on D1 retention rates and 7-day LTV spend"
}

explore: community_sportsmanship_daily {
  label: "Community Sportsmanship & Moderation Velocity"
  description: "Community honor score distribution, auto-action rates, and response velocity"
}

explore: gaming_hybrid_search {
  label: "⚡ BigQuery Hybrid Search (Semantic + Lexical BM25)"
  description: "Interactive demo of BigQuery Hybrid Search natively combining vector similarity and BM25 lexical keyword matching with Reciprocal Rank Fusion"
}
