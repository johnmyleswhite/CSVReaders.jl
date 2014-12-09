function allocate(
    ::Type{Vector{Any}},
    nrows::Int,
    ncols::Int,
    reader::CSVReader,
)
    return Array(Any, nrows * ncols)
end

function available_rows(output::Vector{Any}, reader::CSVReader)
    return fld(length(output), length(reader.column_names))
end

function add_rows!(output::Vector{Any}, nrows::Int, ncols::Int)
    resize!(output, nrows * ncols)
    return
end

function fix_type!(
    output::Vector{Any},
    i::Int,
    j::Int,
    code::Int,
    reader::CSVReader
)
    return
end

function store_null!(output::Vector{Any}, i::Int, j::Int, reader::CSVReader)
    output[(i - 1) * length(reader.column_types) + j] = Nullable{None}()
    return
end

function store_value!(
    output::Vector{Any},
    i::Int,
    j::Int,
    reader::CSVReader,
    value::Any,
)
    output[(i - 1) * length(reader.column_types) + j] = Nullable(value)
    return
end

function finalize(output::Vector{Any}, nrows::Int, ncols::Int)
    resize!(output, nrows * ncols)
    return output
end
