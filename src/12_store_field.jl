function store_field!(
    output::Any,
    row::Int,
    col::Int,
    reader::CSVReader,
)
    ensure_type(reader, output, row, col)

    if reader.isnull
        store_null!(output, row, col, reader)
    else
        if reader.current_type == Codes.INT
            store_value!(output, row, col, reader, reader.int)
        elseif reader.current_type == Codes.FLOAT
            store_value!(output, row, col, reader, reader.float)
        elseif reader.current_type == Codes.BOOL
            store_value!(output, row, col, reader, reader.bool)
        elseif reader.current_type == Codes.STRING
            store_value!(output, row, col, reader, reader.string)
        end
    end
    return
end
