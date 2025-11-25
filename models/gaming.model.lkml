connection: "looker-private-demo"

include: "/views/*.view.lkml"
include: "/derived_tables/*.view.lkml"
include: "/lookml_dashboards/*.dashboard.lookml"   # include a LookML dashboard called my_dashboard

# Model Configuration
datagroup: events_raw { sql_trigger:  SELECT CURRENT_DATE()  ;;
  max_cache_age: "24 hours"
}
named_value_format: large_usd { value_format: "[>=1000000]\"$\"0.00,,\"M\";[>=1000]\"$\"0.00,\"K\";\"$\"0.00" }
named_value_format: large_number { value_format: "[>=1000000]0.00,,\"M\";[>=1000]0.00,\"K\";0" }

# Explores
explore: events {

  persist_with: events_raw

  aggregate_table: revenue {
    query: {
      dimensions: [events.event_name,events.event_date,events.game_name,events.country,events.device_platform,events.install_source,events.install_group]
      measures: [events.total_revenue,events.average_revenue_per_user,events.return_on_ad_spend,events.number_of_new_users,events.number_of_users,events.cost_per_install,events.total_install_spend,events.d1_retention_rate,events.d7_retention_rate]
    }
    materialization: {
      increment_key: event_date
      datagroup_trigger: events_raw
    }
  }

  always_filter: {
    filters: {
      field: event_date
      value: "last 7 days"
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
