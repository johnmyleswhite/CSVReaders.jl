function allocate(
    ::Type{Vector{Dict}},
    nrows::Int,
    ncols::Int,
    reader::CSVReader,
)
    output = Array(Dict{UTF8String, Any}, nrows)
    for i in 1:nrows
        d = Dict{UTF8String, Any}()
        sizehint!(d, ncols)
        output[i] = d
    end
    return output
end

function available_rows(
    output::Vector{Dict{UTF8String, Any}},
    reader::CSVReader,
)
    return length(output)
end

function add_rows!(
    output::Vector{Dict{UTF8String, Any}},
    nrows::Int,
    ncols::Int,
)
    nrows_old = length(output)
    resize!(output, nrows)
    for i in (nrows_old + 1):nrows
        output[i] = Dict{UTF8String, Any}()
    end
    return
end

function fix_type!(
    output::Vector{Dict{UTF8String, Any}},
    i::Int,
    j::Int,
    code::Int,
    reader::CSVReader,
)
    colname = reader.column_names[j]
    for idx in 1:(i - 1)
        output[idx][colname] = convert(
            Nullable{code2type(code)},
            output[idx][colname]
        )
    end
    return
end

function store_null!(
    output::Vector{Dict{UTF8String, Any}},
    i::Int,
    j::Int,
    reader::CSVReader,
)
    T = code2type(reader.column_types[j])
    output[i][reader.column_names[j]] = Nullable{T}()
    return
end

function store_value!(
    output::Vector{Dict{UTF8String, Any}},
    i::Int,
    j::Int,
    reader::CSVReader,
    value::Any,
)
    output[i][reader.column_names[j]] = Nullable(value)
    return
end

function finalize(
    output::Vector{Dict{UTF8String, Any}},
    nrows::Int,
    ncols::Int,
)
    resize!(output, nrows)
    return output
end
