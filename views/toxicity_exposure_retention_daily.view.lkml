view: toxicity_exposure_retention_daily {
  sql_table_name: `gaming_events.toxicity_exposure_retention_daily` ;;

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

  dimension: toxic_matches_exposure {
    type: number
    sql: ${TABLE}.toxic_matches_exposure ;;
  }

  measure: total_active_players {
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.active_players ;;
  }

  measure: total_d1_retained_players {
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}.d1_retained_players ;;
  }

  measure: average_d1_retention_rate {
    type: average
    value_format_name: percent_2
    sql: ${TABLE}.d1_retention_rate ;;
  }

  measure: average_7d_spend {
    type: average
    value_format_name: usd
    sql: ${TABLE}.avg_7d_spend_usd ;;
  }

  measure: total_est_daily_ltv_loss {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.est_daily_ltv_loss_usd ;;
  }
}
