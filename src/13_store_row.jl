function store_row!(
    output::Any,
    i::Int,
    reader::CSVReader,
    row::Relation,
)
    ncols = length(row.isnull)

    if i > available_rows(output, reader)
        add_rows!(output, ceil(Integer, 1.5 * i), ncols)
    end

    for j in 1:ncols
        if row.isnull[j]
            store_null!(output, i, j, reader)
        else
            # TODO: Why is this slow?
            store_value!(output, i, j, reader, row.values[j])
        end
    end
    return
end
