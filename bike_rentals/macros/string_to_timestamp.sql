{%macro string_to_timestamp(column_name) %}

    try_strptime( {{ column_name }} , ['%d/%m/%Y %H:%M:%S', '%m/%d/%Y %H:%M', '%Y-%m-%d %H:%M:%S'])

{%endmacro %}