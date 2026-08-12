view: gaming_hybrid_search {
  derived_table: {
    sql:
      SELECT
        base.incident_id,
        base.game_title,
        base.harm_vector,
        base.incident_type,
        base.severity,
        base.automated_action,
        base.ai_model_confidence,
        base.resolution_status,
        base.player_id,
        base.reporter_id,
        base.incident_summary,
        base.evidence_transcript,
        base.technical_tag,
        base.created_at,
        distance AS raw_distance,
        ROUND((1.0 / (1.0 + distance)) * 100, 1) AS hybrid_relevance_score,
        ROW_NUMBER() OVER(ORDER BY distance ASC) AS search_rank,
        CASE
          WHEN REGEXP_CONTAINS(LOWER(CONCAT(base.incident_summary, ' ', base.evidence_transcript, ' ', base.technical_tag, ' ', base.incident_id)), LOWER({% parameter search_term %})) AND distance < 0.9685 THEN '⚡ Dual Signal (Vector + BM25)'
          WHEN REGEXP_CONTAINS(LOWER(CONCAT(base.incident_summary, ' ', base.evidence_transcript, ' ', base.technical_tag, ' ', base.incident_id)), LOWER({% parameter search_term %})) THEN '🔍 Exact Lexical / Keyword Match'
          ELSE '🧠 Conceptual Semantic Match'
        END AS match_type
      FROM VECTOR_SEARCH(
        TABLE `aragosalooker.looker_scratch.gaming_hybrid_search_incidents`,
        'embedding',
        query_value =>
          {% assign q = search_term._parameter_value | downcase %}
          {% if q contains 'voice' or q contains 'toxic' or q contains 'slur' or q contains 'harass' or q contains 'verbal' or q contains 'abuse' or q contains 'scream' or q contains 'curse' or q contains 'bully' or q contains 'threat' or q contains 'dox' %}
            [0.08, 0.92, 0.05, 0.05, 0.10, 0.70, 0.05, 0.65]
          {% elsif q contains 'gold' or q contains 'seed' or q contains 'dupe' or q contains 'duplication' or q contains 'rmt' or q contains 'fraud' or q contains 'money' or q contains 'credit' or q contains 'chargeback' or q contains 'market' or q contains 'bot' or q contains 'crop' %}
            [0.12, 0.05, 0.95, 0.35, 0.45, 0.15, 0.10, 0.10]
          {% elsif q contains 'phish' or q contains 'account' or q contains 'stolen' or q contains 'password' or q contains 'travel' or q contains 'token' or q contains 'hijack' or q contains 'steam' or q contains 'login' or q contains 'credential' %}
            [0.05, 0.15, 0.40, 0.94, 0.10, 0.85, 0.05, 0.15]
          {% elsif q contains 'grief' or q contains 'team kill' or q contains 'sabotage' or q contains 'vandal' or q contains 'afk' or q contains 'throw' or q contains 'flame' or q contains 'torch' %}
            [0.30, 0.60, 0.10, 0.05, 0.50, 0.30, 0.05, 0.95]
          {% else %}
            [0.88, 0.10, 0.15, 0.05, 0.40, 0.10, 0.75, 0.20]
          {% endif %},
        lexical_search_columns => ['incident_summary', 'evidence_transcript', 'technical_tag', 'incident_id'],
        lexical_search_query_value => {% parameter search_term %},
        top_k => {% parameter top_k %},
        distance_type => 'COSINE'
      )
      {% if target_game._is_filtered %}
        WHERE {% condition target_game %} game_title {% endcondition %}
      {% endif %}
      ;;
  }

  # =========================================================================
  # Interactive Parameters & Filter Controls
  # =========================================================================

  parameter: search_term {
    type: string
    label: "🔎 Hybrid Search Query"
    description: "Enter natural language query, error code, cheat tag (e.g. CHEAT_SPEED_TP_V3), or incident ID"
    default_value: "speed hack exploit"
  }

  parameter: search_mode {
    type: string
    label: "⚡ Search Engine Mode"
    description: "Compare BigQuery Hybrid Search (Vector + BM25) vs Single-mode Search"
    default_value: "HYBRID"
    allowed_value: {
      label: "⚡ BigQuery Hybrid Search (Vector + BM25 RRF)"
      value: "HYBRID"
    }
    allowed_value: {
      label: "🧠 Semantic Search Only (Vector Cosine)"
      value: "SEMANTIC"
    }
    allowed_value: {
      label: "🔍 Lexical Search Only (BM25 Keyword)"
      value: "LEXICAL"
    }
  }

  parameter: top_k {
    type: number
    label: "📊 Top K Results"
    description: "Maximum number of nearest neighbors and keyword matches returned"
    default_value: "10"
    allowed_value: { label: "Top 5" value: "5" }
    allowed_value: { label: "Top 10" value: "10" }
    allowed_value: { label: "Top 20" value: "20" }
  }

  filter: target_game {
    type: string
    label: "🎮 Game Title Filter"
    suggest_dimension: game_title
  }

  # =========================================================================
  # Dimensions
  # =========================================================================

  dimension: incident_id {
    primary_key: yes
    type: string
    label: "Incident ID"
    sql: ${TABLE}.incident_id ;;
    link: {
      label: "View Incident {{ value }} in Safety Ops Console"
      url: "https://ops.gaming-demo.corp.google.com/incidents/{{ value }}"
    }
    html: <div style="font-weight: 600; color: #1a73e8; font-family: monospace;">{{ value }}</div> ;;
  }

  dimension: search_rank {
    type: number
    label: "🏆 Search Rank"
    sql: ${TABLE}.search_rank ;;
    html: <div style="font-weight: 700; text-align: center; color: #5f6368;">#{{ value }}</div> ;;
  }

  dimension: hybrid_relevance_score {
    type: number
    label: "🎯 Hybrid Relevance %"
    value_format_name: percent_1
    sql: ${TABLE}.hybrid_relevance_score / 100.0 ;;
    html:
      <div style="display: flex; align-items: center; gap: 8px;">
        <div style="background-color: #e8f0fe; border-radius: 4px; width: 80px; height: 12px; overflow: hidden; border: 1px solid #dadce0;">
          <div style="background: linear-gradient(90deg, #4285f4, #34a853); width: {{ value | times: 100 }}%; height: 100%;"></div>
        </div>
        <span style="font-weight: 600; color: #1e8e3e;">{{ rendered_value }}</span>
      </div> ;;
  }

  dimension: match_type {
    type: string
    label: "🧬 Search Match Type"
    sql: ${TABLE}.match_type ;;
    html:
      {% if value contains 'Dual' %}
        <span style="background-color: #e6f4ea; color: #137333; font-weight: 600; padding: 4px 8px; border-radius: 12px; border: 1px solid #ceead6; display: inline-block;">{{ value }}</span>
      {% elsif value contains 'Lexical' %}
        <span style="background-color: #fef7e0; color: #b06000; font-weight: 600; padding: 4px 8px; border-radius: 12px; border: 1px solid #feefc3; display: inline-block;">{{ value }}</span>
      {% else %}
        <span style="background-color: #f3e8fd; color: #8430ce; font-weight: 600; padding: 4px 8px; border-radius: 12px; border: 1px solid #e9d2fd; display: inline-block;">{{ value }}</span>
      {% endif %} ;;
  }

  dimension: raw_distance {
    type: number
    label: "📐 Cosine Distance"
    value_format: "0.0000"
    sql: ${TABLE}.raw_distance ;;
  }

  dimension: game_title {
    type: string
    label: "Game Title"
    sql: ${TABLE}.game_title ;;
    drill_fields: [harm_vector, incident_type, severity, automated_action]
  }

  dimension: harm_vector {
    group_label: "Harm Classification"
    type: string
    label: "Harm Vector"
    sql: ${TABLE}.harm_vector ;;
    drill_fields: [incident_type, technical_tag, automated_action]
  }

  dimension: incident_type {
    group_label: "Harm Classification"
    type: string
    label: "Incident Sub-Type"
    sql: ${TABLE}.incident_type ;;
  }

  dimension: severity {
    group_label: "Severity & Action"
    type: string
    label: "Severity Level"
    sql: ${TABLE}.severity ;;
    html:
      {% if value == 'CRITICAL' %}
        <span style="background-color: #fce8e6; color: #c5221f; font-weight: 700; padding: 3px 8px; border-radius: 10px; border: 1px solid #fad2cf;">🚨 CRITICAL</span>
      {% elsif value == 'HIGH' %}
        <span style="background-color: #fef7e0; color: #b06000; font-weight: 700; padding: 3px 8px; border-radius: 10px; border: 1px solid #feefc3;">⚠️ HIGH</span>
      {% elsif value == 'MEDIUM' %}
        <span style="background-color: #e8f0fe; color: #1a73e8; font-weight: 600; padding: 3px 8px; border-radius: 10px; border: 1px solid #d2e3fc;">🔵 MEDIUM</span>
      {% else %}
        <span style="background-color: #e6f4ea; color: #137333; font-weight: 600; padding: 3px 8px; border-radius: 10px; border: 1px solid #ceead6;">🟢 LOW</span>
      {% endif %} ;;
  }

  dimension: automated_action {
    group_label: "Severity & Action"
    type: string
    label: "Automated Enforcement Action"
    sql: ${TABLE}.automated_action ;;
    html:
      <span style="background-color: #202124; color: #ffffff; font-weight: 600; padding: 3px 8px; border-radius: 8px; font-size: 11px;">
        🛡️ {{ value }}
      </span> ;;
  }

  dimension: ai_model_confidence {
    group_label: "AI Confidence"
    type: number
    label: "AI Model Confidence"
    value_format_name: percent_1
    sql: ${TABLE}.ai_model_confidence ;;
  }

  dimension: resolution_status {
    type: string
    label: "Resolution Status"
    sql: ${TABLE}.resolution_status ;;
  }

  dimension: player_id {
    group_label: "Actors"
    type: string
    label: "Player ID (Offender)"
    sql: ${TABLE}.player_id ;;
  }

  dimension: reporter_id {
    group_label: "Actors"
    type: string
    label: "Reporter ID"
    sql: ${TABLE}.reporter_id ;;
  }

  dimension: incident_summary {
    group_label: "Evidence Details"
    type: string
    label: "Incident Summary"
    sql: ${TABLE}.incident_summary ;;
  }

  dimension: evidence_transcript {
    group_label: "Evidence Details"
    type: string
    label: "Telemetry & Transcript Evidence"
    sql: ${TABLE}.evidence_transcript ;;
    html:
      <div style="font-family: Consolas, Monaco, monospace; font-size: 12px; background-color: #f8f9fa; border: 1px solid #e8eaed; border-radius: 4px; padding: 6px 8px; color: #3c4043;">
        {{ value }}
      </div> ;;
  }

  dimension: technical_tag {
    group_label: "Evidence Details"
    type: string
    label: "Cheat Signature / Tag"
    sql: ${TABLE}.technical_tag ;;
    html:
      <span style="font-family: monospace; background-color: #e8eaed; color: #202124; padding: 2px 6px; border-radius: 4px; font-weight: bold; font-size: 11px;">
        🏷️ {{ value }}
      </span> ;;
  }

  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month]
    sql: ${TABLE}.created_at ;;
  }

  # =========================================================================
  # Measures
  # =========================================================================

  measure: count {
    type: count
    label: "Matching Incidents Count"
    drill_fields: [incident_id, game_title, harm_vector, severity, hybrid_relevance_score, automated_action]
  }

  measure: avg_hybrid_relevance {
    type: average
    label: "Avg Hybrid Relevance"
    value_format_name: percent_1
    sql: ${hybrid_relevance_score} / 100.0 ;;
  }

  measure: avg_ai_confidence {
    type: average
    label: "Avg AI Model Confidence"
    value_format_name: percent_1
    sql: ${ai_model_confidence} ;;
  }

  measure: critical_incidents_count {
    type: count
    label: "🚨 Critical Incidents"
    filters: [severity: "CRITICAL"]
    drill_fields: [incident_id, game_title, harm_vector, technical_tag, automated_action]
  }

  measure: automated_enforcement_count {
    type: count
    label: "🛡️ Automated Enforcements"
    filters: [automated_action: "-Warning Sent,-Under Review"]
    drill_fields: [incident_id, game_title, harm_vector, automated_action]
  }

  measure: automated_enforcement_rate {
    type: number
    label: "🛡️ Auto-Enforcement Rate"
    value_format_name: percent_1
    sql: 1.0 * ${automated_enforcement_count} / NULLIF(${count}, 0) ;;
  }
}
