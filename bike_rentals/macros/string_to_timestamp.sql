{% macro string_to_timestamp(column_name) %}
    CASE
        WHEN REGEXP_CONTAINS({{ column_name }}, r"\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}") THEN PARSE_TIMESTAMP("%Y-%m-%d %H:%M:%S", {{ column_name }})
        WHEN REGEXP_CONTAINS({{ column_name }}, r"\d{4}-\d{2}-\d{2} \d{2}:\d{2}") THEN PARSE_TIMESTAMP("%Y-%m-%d %H:%M", {{ column_name }})
        WHEN REGEXP_CONTAINS({{ column_name }}, r"\d{2}/\d{2}/\d{4} \d{2}:\d{2}") THEN PARSE_TIMESTAMP("%d/%m/%Y %H:%M", {{ column_name }})
        WHEN REGEXP_CONTAINS({{ column_name }}, r"\d{4}/\d{2}/\d{2}") THEN PARSE_TIMESTAMP("%Y/%m/%d", {{ column_name }})
        ELSE NULL
    END
{% endmacro %}
