function allocate(
    ::Type{Vector{Dict}},
    rows::Int,
    cols::Int,
    reader::CSVReader
)
    output = Array(Dict, rows)
    sizehint(output, cols)
    for row in 1:rows
        d = Dict()
        sizehint(d, cols)
        output[row] = d
    end
    return output
end

function available_rows(output::Vector{Dict}, reader::CSVReader)
    return length(output)
end

function add_rows!(output::Vector{Dict}, rows::Int, cols::Int)
    rows_old = length(output)
    resize!(output, rows)
    for row in (rows_old + 1):rows
        output[row] = Dict()
    end
    return
end

function fix_type!(
    output::Vector{Dict},
    row::Int,
    col::Int,
    code::Int,
    reader::CSVReader
)
    return
end

function store_null!(
    output::Vector{Dict},
    row::Int,
    col::Int,
    reader::CSVReader,
)
    output[row][reader.column_names[col]] = Nullable{Int}()
    return
end

function store_value!(
    output::Vector{Dict},
    row::Int,
    col::Int,
    reader::CSVReader,
    value::Any,
)
    output[row][reader.column_names[col]] = Nullable(value)
    return
end

function finalize(output::Vector{Dict}, rows, cols)
    resize!(output, rows)
    return output
end
