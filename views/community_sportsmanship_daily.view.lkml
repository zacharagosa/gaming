view: community_sportsmanship_daily {
  sql_table_name: `gaming_events.community_sportsmanship_daily` ;;

  dimension_group: event {
    type: time
    timeframes: [date, week, month]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.event_date ;;
  }

  dimension: game_title {
    type: string
    sql: ${TABLE}.game_title ;;
  }

  measure: total_matches {
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.total_matches ;;
  }

  measure: total_toxic_exposed_matches {
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.toxic_exposed_matches ;;
  }

  measure: average_toxic_match_rate {
    type: average
    value_format_name: percent_2
    sql: ${TABLE}.toxic_exposed_match_rate ;;
  }

  measure: total_auto_moderation_actions {
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.auto_moderation_actions ;;
  }

  measure: average_auto_action_time_sec {
    type: average
    value_format_name: decimal_2
    sql: ${TABLE}.avg_auto_action_time_sec ;;
  }

  measure: average_honor_tier_pct {
    type: average
    value_format_name: percent_1
    sql: ${TABLE}.honor_tier_player_pct ;;
  }

  measure: average_warning_queue_pct {
    type: average
    value_format_name: percent_1
    sql: ${TABLE}.warning_queue_player_pct ;;
  }

  measure: average_suspended_tier_pct {
    type: average
    value_format_name: percent_1
    sql: ${TABLE}.suspended_tier_player_pct ;;
  }
}
