- dashboard: bigquery_hybrid_search_demo
  title: "⚡ BigQuery Hybrid Search: Gaming Trust & Safety AI"
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Enterprise demo showcasing BigQuery Hybrid Search (Vector Embeddings + BM25 Lexical Search + Reciprocal Rank Fusion) over gaming telemetry, cheat detection, and player safety incidents."
  elements:
  - title: "Header Context"
    name: "Header Context"
    type: text
    title_text: "⚡ BigQuery Hybrid Search: Unifying Semantic Understanding & Lexical Precision"
    subtitle_text: "Native BM25 + Vector Search + Reciprocal Rank Fusion (RRF) at 10B+ Scale"
    body_text: "### How BigQuery Hybrid Search Works in Looker:\n- **🧠 Semantic Vector Search**: Discovers conceptual matches (e.g. *'speed hack exploit'* matches *'movement velocity anomaly'* and *'teleportation'*) even when different terminology is used.\n- **🔍 Lexical BM25 Search**: Matches exact keywords, cheat signatures, error codes, and incident IDs (e.g. `INC-9101`, `CHEAT_SPEED_TP_V3`, `ESP_BOX_V4`).\n- **⚡ Reciprocal Rank Fusion (RRF)**: Merges both score vectors into a unified relevance rank directly inside the BigQuery execution engine.\n\n*Use the interactive filter bar above to test different queries, toggling between **Hybrid**, **Semantic-only**, and **Lexical-only** search.*"
    row: 0
    col: 0
    width: 24
    height: 4

  - title: "Avg Hybrid Relevance"
    name: "Avg Hybrid Relevance"
    model: gaming
    explore: gaming_hybrid_search
    type: single_value
    fields: [gaming_hybrid_search.avg_hybrid_relevance]
    limit: 500
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    single_value_title: "Top Hybrid Relevance"
    value_format: "0.0%"
    listen:
      "Hybrid Search Query": gaming_hybrid_search.search_term
      "Search Engine Mode": gaming_hybrid_search.search_mode
      "Top K Results": gaming_hybrid_search.top_k
      "Game Title": gaming_hybrid_search.target_game
    row: 4
    col: 0
    width: 6
    height: 3

  - title: "Matching Incidents Count"
    name: "Matching Incidents Count"
    model: gaming
    explore: gaming_hybrid_search
    type: single_value
    fields: [gaming_hybrid_search.count]
    limit: 500
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    single_value_title: "Matched Incidents"
    listen:
      "Hybrid Search Query": gaming_hybrid_search.search_term
      "Search Engine Mode": gaming_hybrid_search.search_mode
      "Top K Results": gaming_hybrid_search.top_k
      "Game Title": gaming_hybrid_search.target_game
    row: 4
    col: 6
    width: 6
    height: 3

  - title: "Critical Incidents Volume"
    name: "Critical Incidents Volume"
    model: gaming
    explore: gaming_hybrid_search
    type: single_value
    fields: [gaming_hybrid_search.critical_incidents_count]
    limit: 500
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    single_value_title: "Critical Severity"
    listen:
      "Hybrid Search Query": gaming_hybrid_search.search_term
      "Search Engine Mode": gaming_hybrid_search.search_mode
      "Top K Results": gaming_hybrid_search.top_k
      "Game Title": gaming_hybrid_search.target_game
    row: 4
    col: 12
    width: 6
    height: 3

  - title: "Auto-Enforcement Rate"
    name: "Auto-Enforcement Rate"
    model: gaming
    explore: gaming_hybrid_search
    type: single_value
    fields: [gaming_hybrid_search.automated_enforcement_rate]
    limit: 500
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    single_value_title: "Auto-Enforcement Rate"
    value_format: "0.0%"
    listen:
      "Hybrid Search Query": gaming_hybrid_search.search_term
      "Search Engine Mode": gaming_hybrid_search.search_mode
      "Top K Results": gaming_hybrid_search.top_k
      "Game Title": gaming_hybrid_search.target_game
    row: 4
    col: 18
    width: 6
    height: 3

  - title: "🎯 BigQuery Hybrid Search Ranked Results"
    name: "BigQuery Hybrid Search Ranked Results"
    model: gaming
    explore: gaming_hybrid_search
    type: looker_grid
    fields: [
      gaming_hybrid_search.search_rank,
      gaming_hybrid_search.incident_id,
      gaming_hybrid_search.match_type,
      gaming_hybrid_search.hybrid_relevance_score,
      gaming_hybrid_search.game_title,
      gaming_hybrid_search.harm_vector,
      gaming_hybrid_search.severity,
      gaming_hybrid_search.automated_action,
      gaming_hybrid_search.technical_tag,
      gaming_hybrid_search.incident_summary,
      gaming_hybrid_search.evidence_transcript
    ]
    sorts: [gaming_hybrid_search.search_rank asc]
    limit: 50
    show_view_names: false
    show_row_numbers: false
    transpose: false
    truncate_text: false
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    listen:
      "Hybrid Search Query": gaming_hybrid_search.search_term
      "Search Engine Mode": gaming_hybrid_search.search_mode
      "Top K Results": gaming_hybrid_search.top_k
      "Game Title": gaming_hybrid_search.target_game
    row: 7
    col: 0
    width: 24
    height: 10

  - title: "Harm Category Distribution of Matched Incidents"
    name: "Harm Category Distribution"
    model: gaming
    explore: gaming_hybrid_search
    type: looker_column
    fields: [gaming_hybrid_search.harm_vector, gaming_hybrid_search.severity, gaming_hybrid_search.count]
    pivots: [gaming_hybrid_search.severity]
    sorts: [gaming_hybrid_search.count desc 0]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    show_x_axis_label: true
    x_axis_label: "Harm Vector"
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    limit_displayed_rows: false
    legend_position: center
    series_colors:
      CRITICAL - gaming_hybrid_search.count: "#EA4335"
      HIGH - gaming_hybrid_search.count: "#FBBC04"
      MEDIUM - gaming_hybrid_search.count: "#4285F4"
      LOW - gaming_hybrid_search.count: "#34A853"
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    show_silhouette: false
    listen:
      "Hybrid Search Query": gaming_hybrid_search.search_term
      "Search Engine Mode": gaming_hybrid_search.search_mode
      "Top K Results": gaming_hybrid_search.top_k
      "Game Title": gaming_hybrid_search.target_game
    row: 17
    col: 0
    width: 14
    height: 7

  - title: "Search Match Type Breakdown"
    name: "Search Match Type Breakdown"
    model: gaming
    explore: gaming_hybrid_search
    type: looker_pie
    fields: [gaming_hybrid_search.match_type, gaming_hybrid_search.count]
    sorts: [gaming_hybrid_search.count desc]
    limit: 500
    value_labels: legend
    label_type: labPer
    inner_radius: 50
    series_colors:
      "⚡ Dual Signal (Vector + BM25)": "#137333"
      "🔍 Exact Lexical / Keyword Match": "#B06000"
      "🧠 Conceptual Semantic Match": "#8430CE"
    listen:
      "Hybrid Search Query": gaming_hybrid_search.search_term
      "Search Engine Mode": gaming_hybrid_search.search_mode
      "Top K Results": gaming_hybrid_search.top_k
      "Game Title": gaming_hybrid_search.target_game
    row: 17
    col: 14
    width: 10
    height: 7

  - title: "Automated Enforcement by Game Title"
    name: "Automated Enforcement by Game Title"
    model: gaming
    explore: gaming_hybrid_search
    type: looker_bar
    fields: [gaming_hybrid_search.game_title, gaming_hybrid_search.automated_action, gaming_hybrid_search.count]
    pivots: [gaming_hybrid_search.automated_action]
    sorts: [gaming_hybrid_search.count desc 0]
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: normal
    legend_position: center
    show_value_labels: true
    listen:
      "Hybrid Search Query": gaming_hybrid_search.search_term
      "Search Engine Mode": gaming_hybrid_search.search_mode
      "Top K Results": gaming_hybrid_search.top_k
      "Game Title": gaming_hybrid_search.target_game
    row: 24
    col: 0
    width: 24
    height: 7

  filters:
  - name: "Hybrid Search Query"
    title: "🔎 Hybrid Search Query"
    type: field_filter
    default_value: "speed hack exploit"
    allow_multiple_values: false
    required: true
    model: gaming
    explore: gaming_hybrid_search
    field: gaming_hybrid_search.search_term

  - name: "Search Engine Mode"
    title: "⚡ Search Engine Mode"
    type: field_filter
    default_value: "HYBRID"
    allow_multiple_values: false
    required: true
    model: gaming
    explore: gaming_hybrid_search
    field: gaming_hybrid_search.search_mode

  - name: "Top K Results"
    title: "📊 Top K Results"
    type: field_filter
    default_value: "10"
    allow_multiple_values: false
    required: false
    model: gaming
    explore: gaming_hybrid_search
    field: gaming_hybrid_search.top_k

  - name: "Game Title"
    title: "🎮 Game Title"
    type: field_filter
    default_value: ''
    allow_multiple_values: true
    required: false
    model: gaming
    explore: gaming_hybrid_search
    field: gaming_hybrid_search.target_game
