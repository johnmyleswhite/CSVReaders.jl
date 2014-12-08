function store_row!(
    output::Any,
    row::Int,
    reader::CSVReader,
    rowdata::Relation,
)
    cols = length(rowdata.isnull)

    if row > available_rows(output, reader)
        add_rows!(output, ceil(Integer, 1.5 * row), cols)
    end

    for col in 1:cols
        ensure_type(reader, output, row, col)
        if rowdata.isnull[col]
            store_null!(output, row, col, reader)
        else
            store_value!(output, row, col, reader, rowdata.values[col])
        end
    end
    return
end
