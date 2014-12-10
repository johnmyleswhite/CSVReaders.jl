# Number this so that it occurs after store_row
function store_field!(
    output::Any,
    i::Int,
    j::Int,
    reader::CSVReader,
)
    if !reader.success
        code = reader.current_type
        reader.column_types[j] = code
        fix_type!(output, i, j, code, reader)
    end

    if reader.isnull
        store_null!(output, i, j, reader)
    else
        if reader.current_type == Codes.BOOL
            store_value!(output, i, j, reader, reader.bool)
        elseif reader.current_type == Codes.INT
            # TOOD: Why is this slow? Or just a hot path?
            store_value!(output, i, j, reader, reader.int)
        elseif reader.current_type == Codes.FLOAT
            store_value!(output, i, j, reader, reader.float)
        elseif reader.current_type == Codes.STRING
            store_value!(output, i, j, reader, reader.string)
        end
    end
    return
end
