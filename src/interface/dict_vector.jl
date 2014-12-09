function allocate(
    ::Type{Dict{Vector}},
    nrows::Int,
    ncols::Int,
    reader::CSVReader,
)
    output = Dict()
    sizehint(output, ncols)
    for j in 1:ncols
        T = code2type(reader.column_types[j])
        colname = reader.column_names[j]
        col = Array(Nullable{T}, nrows)
        output[colname] = col
    end
    return output
end

# TODO: Clean this up
function available_rows(output::Dict, reader::CSVReader)
    for col in values(output)
        return length(col)
    end
end

function add_rows!(output::Dict, nrows::Int, ncols::Int)
    for col in values(output)
        resize!(col, nrows)
    end
    return
end

function fix_type!(output::Dict, i::Int, j::Int, code::Int, reader::CSVReader)
    colname = reader.column_names[j]
    oldcol = output[colname]
    nrows = length(oldcol)
    if code == Codes.FLOAT
        newcol = Array(Nullable{Float64}, nrows)
        for idx in 1:(i - 1)
            if isnull(oldcol[idx])
                newcol[idx] = Nullable{Float64}()
            else
                newcol[idx] = Nullable(float64(oldcol[idx]))
            end
        end
    elseif code == Codes.BOOL
        newcol = Array(Nullable{Bool}, nrows)
        for idx in 1:(i - 1)
            if isnull(oldcolumn[idx])
                newcol[idx] = Nullable{Bool}()
            else
                newcol[idx] = Nullable(bool(oldcol[idx]))
            end
        end
        output[col] = newcolumn
    elseif code == Codes.STRING
        newcol = Array(Nullable{UTF8String}, nrows)
        for idx in 1:(row - 1)
            if isnull(oldcolumn[idx])
                newcol[idx] = Nullable{UTF8String}()
            else
                newcol[idx] = Nullable{UTF8String}(string(oldcol[idx]))
            end

        end
    end
    output[colname] = newcol
    return
end

function store_null!(output::Dict, i::Int, j::Int, reader::CSVReader)
    colname = reader.column_names[j]
    col = output[colname]
    col[i] = Nullable{eltype(col)}()
    return
end

function store_value!(
    output::Dict,
    i::Int,
    j::Int,
    reader::CSVReader,
    value::Any,
)
    colname = reader.column_names[j]
    output[colname][i] = Nullable(value)
    return
end

function finalize(output::Dict, nrows::Int, ncols::Int)
    for col in values(output)
        resize!(col, nrows)
    end
    return output
end
