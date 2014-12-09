function allocate{T}(
    ::Type{Vector{T}},
    nrows::Int,
    ncols::Int,
    reader::CSVReader,
)
    return Array(T, nrows * ncols)
end

function available_rows{T}(output::Vector{T}, reader::CSVReader)
    return fld(length(output), length(reader.column_names))
end

function add_rows!{T}(output::Vector{T}, nrows::Int, ncols::Int)
    resize!(output, nrows * ncols)
    return
end

function fix_type!{T}(
    output::Vector{T},
    i::Int,
    j::Int,
    code::Int,
    reader::CSVReader
)
    if code > type2code(T)
        error(
            @sprintf(
                "%s cannot store a value of type %s",
                typeof(output),
                code2type(code),
            )
        )
    end
end

function store_null!{T}(
    output::Vector{T},
    i::Int,
    j::Int,
    reader::CSVReader,
)
    error(@sprintf("%s cannot store null values", typeof(output)))
end

function store_value!{T}(
    output::Vector{T},
    i::Int,
    j::Int,
    reader::CSVReader,
    value::Any,
)
    output[(i - 1) * length(reader.column_types) + j] = value
    return
end

function finalize{T}(output::Vector{T}, nrows::Int, ncols::Int)
    resize!(output, nrows * ncols)
    return output
end
