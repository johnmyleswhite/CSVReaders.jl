function allocate(
    ::Type{Vector{Dict}},
    nrows::Int,
    ncols::Int,
    reader::CSVReader,
)
    output = Array(Dict, nrows)
    for i in 1:nrows
        d = Dict()
        sizehint!(d, ncols)
        output[i] = d
    end
    return output
end

available_rows(output::Vector{Dict}, reader::CSVReader) = length(output)

function add_rows!(output::Vector{Dict}, nrows::Int, ncols::Int)
    nrows_old = length(output)
    resize!(output, nrows)
    for i in (nrows_old + 1):nrows
        output[i] = Dict()
    end
    return
end

# TODO: Patch up types here
function fix_type!(
    output::Vector{Dict},
    i::Int,
    j::Int,
    code::Int,
    reader::CSVReader,
)
    return
end

function store_null!(
    output::Vector{Dict},
    i::Int,
    j::Int,
    reader::CSVReader,
)
    output[i][reader.column_names[j]] = Nullable{None}()
    return
end

function store_value!(
    output::Vector{Dict},
    i::Int,
    j::Int,
    reader::CSVReader,
    value::Any,
)
    output[i][reader.column_names[j]] = Nullable(value)
    return
end

function finalize(output::Vector{Dict}, nrows::Int, ncols::Int)
    resize!(output, nrows)
    return output
end
