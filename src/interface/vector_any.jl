function allocate(
    ::Type{Vector{Any}},
    rows::Int,
    cols::Int,
    reader::CSVReader,
)
    return Array(Any, rows * cols)
end

function available_rows(output::Vector{Any}, reader::CSVReader)
    return fld(length(output), length(reader.column_names))
end

function add_rows!(output::Vector{Any}, rows::Int, cols::Int)
    resize!(output, rows * cols)
    return
end

function fix_type!(
    output::Vector{Any},
    row::Int,
    col::Int,
    code::Int,
    reader::CSVReader
)
    return
end

function store_null!(
    output::Vector{Any},
    row::Int,
    col::Int,
    reader::CSVReader,
)
    output[(row - 1) * length(reader.column_types) + col] = Nullable{None}()
    return
end

function store_value!(
    output::Vector{Any},
    row::Int,
    col::Int,
    reader::CSVReader,
    value::Any,
)
    output[(row - 1) * length(reader.column_types) + col] = Nullable(value)
    return
end

function finalize(output::Vector{Any}, rows, cols)
    resize!(output, rows * cols)
    return output
end
