function allocate{T}(
    ::Type{Vector{Nullable{T}}},
    rows::Int,
    cols::Int,
    reader::CSVReader,
)
    return Array(Nullable{T}, rows * cols)
end

function available_rows{T}(output::Vector{Nullable{T}}, reader::CSVReader)
    return fld(length(output), length(reader.column_names))
end

function add_rows!{T}(output::Vector{Nullable{T}}, rows::Int, cols::Int)
    resize!(output, rows * cols)
    return
end

function fix_type!{T}(
    output::Vector{Nullable{T}},
    row::Int,
    col::Int,
    code::Int,
    reader::CSVReader
)
    return
end

function store_null!{T}(
    output::Vector{Nullable{T}},
    row::Int,
    col::Int,
    reader::CSVReader,
)
    output[(row - 1) * length(reader.column_types) + col] = Nullable{T}()
    return
end

function store_value!{T}(
    output::Vector{Nullable{T}},
    row::Int,
    col::Int,
    reader::CSVReader,
    value::Any,
)
    output[(row - 1) * length(reader.column_types) + col] = Nullable{T}(value)
    return
end

function finalize{T}(output::Vector{Nullable{T}}, rows, cols)
    resize!(output, rows * cols)
    return output
end
