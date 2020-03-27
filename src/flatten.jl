using DataFrames
using Dates

function parse_string(column_value)::String
    return column_value
end

function parse_datetime(column_value, datetime_format::DateFormat)::DateTime
    return DateTime(column_value, datetime_format)
end

function parse_unixdatetime(column_value)::DateTime
    return unix2datetime(parse(Int, column_value))
end

function parse_core_data_timestamp(column_value)::DateTime
    return unix2datetime(parse(Int, column_value)) + Month(31)
end

function parse_integer(column_value)::Integer
    return parse(Int, column_value)
end

function parse_float(column_value)::Float64
    return parse(Float64, column_value)
end

function parse_bool(column_value)::Bool
    return Bool(parse(Int, column_value))
end
