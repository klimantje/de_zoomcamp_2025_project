{%macro string_to_timestamp(column_name) %}

    COALESCE(PARSE_TIMESTAMP('%d/%m/%Y %H:%M', {{ column_name }}),PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', {{ column_name }}) )

{%endmacro %}