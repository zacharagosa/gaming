view: player_safety_incidents {
  sql_table_name: `gaming_events.player_safety_incidents` ;;

  dimension: incident_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.incident_id ;;
  }

  dimension_group: timestamp {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.timestamp ;;
  }

  dimension: game_title {
    type: string
    sql: ${TABLE}.game_title ;;
  }

  dimension: harm_vector {
    type: string
    sql: ${TABLE}.harm_vector ;;
  }

  dimension: incident_type {
    type: string
    sql: ${TABLE}.incident_type ;;
  }

  dimension: severity {
    type: string
    sql: ${TABLE}.severity ;;
  }

  dimension: automated_action {
    type: string
    sql: ${TABLE}.automated_action ;;
  }

  dimension: ai_model_confidence {
    type: number
    value_format_name: percent_2
    sql: ${TABLE}.ai_model_confidence ;;
  }

  dimension: resolution_status {
    type: string
    sql: ${TABLE}.resolution_status ;;
  }

  dimension: player_id {
    type: string
    sql: ${TABLE}.player_id ;;
  }

  dimension: reporter_id {
    type: string
    sql: ${TABLE}.reporter_id ;;
  }

  measure: count {
    type: count
    drill_fields: [incident_id, timestamp_date, game_title, harm_vector, severity, automated_action]
  }

  measure: critical_incidents_count {
    type: count
    filters: [severity: "CRITICAL"]
  }

  measure: resolved_incidents_count {
    type: count
    filters: [resolution_status: "RESOLVED"]
  }

  measure: average_ai_confidence {
    type: average
    value_format_name: percent_2
    sql: ${TABLE}.ai_model_confidence ;;
  }
}
