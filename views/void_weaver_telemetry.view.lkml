explore: void_weaver_telemetry {}
view: void_weaver_telemetry {
  sql_table_name: `aragosalooker.gaming_events.void_weaver_telemetry` ;;

  dimension_group: etl_tstamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.ETL_Tstamp_Time ;;
  }
  dimension: event_details {
    type: string
    sql: ${TABLE}.Event_Details ;;
  }
  dimension: event_name {
    type: string
    sql: ${TABLE}.Event_Name ;;
  }
  dimension: int64_field_0 {
    type: number
    sql: ${TABLE}.int64_field_0 ;;
  }
  measure: count {
    type: count
    drill_fields: [event_name]
  }
}
