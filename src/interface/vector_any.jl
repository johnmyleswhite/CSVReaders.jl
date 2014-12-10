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
    ncols = length(reader.column_types)
    nrows = fld(length(output), ncols)
    if code == Codes.INT
        for row_idx in 1:(i - 1)
            idx = (row_idx - 1) * ncols + j
            if isnull(output[idx])
                output[idx] = Nullable{Int}()
            else
                output[idx] = Nullable{Int}(int(get(output[idx])))
            end
        end
    elseif code == Codes.FLOAT
        for row_idx in 1:(i - 1)
            idx = (row_idx - 1) * ncols + j
            if isnull(output[idx])
                output[idx] = Nullable{Float64}()
            else
                output[idx] = Nullable{Float64}(float64(get(output[idx])))
            end
        end
    elseif code == Codes.STRING
        for row_idx in 1:(i - 1)
            idx = (row_idx - 1) * ncols + j
            if isnull(output[idx])
                output[idx] = Nullable{UTF8String}()
            else
                output[idx] = Nullable{UTF8String}(
                    convert(UTF8String, string(get(output[idx])))
                )
            end
        end
    end
    return
end

function store_null!(output::Vector{Any}, i::Int, j::Int, reader::CSVReader)
    ncols = length(reader.column_types)
    T = code2type(reader.column_types[j])
    output[(i - 1) * ncols + j] = Nullable{T}()
    return
end

function store_value!(
    output::Vector{Any},
    i::Int,
    j::Int,
    reader::CSVReader,
    value::Any,
)
    ncols = length(reader.column_types)
    code = reader.column_types[j]
    T = code2type(code)
    if code == Codes.String
        output[(i - 1) * ncols + j] = Nullable{T}(
            convert(UTF8String, string(value))
        )
    else
        output[(i - 1) * ncols + j] = Nullable{T}(convert(T, value))
    end
    return
end

function finalize(output::Vector{Any}, nrows::Int, ncols::Int)
    resize!(output, nrows * ncols)
    return output
end
