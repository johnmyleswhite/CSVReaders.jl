function allocate(::Type{Dict}, rows::Int, cols::Int, reader::CSVReader)
    output = Dict()
    sizehint(output, cols)
    for j in 1:cols
        T = code2type(reader.column_types[j])
        column = Array(Nullable{T}, rows)
        output[reader.column_names[j]] = column
    end
    return output
end

function available_rows(output::Dict, reader::CSVReader)
    for column in values(output)
        return length(column)
    end
end

function add_rows!(output::Dict, rows::Int, cols::Int)
    for column in values(output)
        resize!(column, rows)
    end
    return
end

function fix_type!(
    output::Dict,
    row::Int,
    col::Int,
    code::Int,
    reader::CSVReader
)
    colname = reader.column_names[col]
    oldcolumn = output[colname]
    nrows = length(oldcolumn)
    if code == Codes.FLOAT
        newcolumn = Array(Nullable{Float64}, nrows)
        for i in 1:(row - 1)
            if isnull(oldcolumn[i])
                newcolumn[i] = Nullable{Float64}()
            else
                newcolumn[i] = Nullable(float64(oldcolumn[i]))
            end
        end
    elseif code == Codes.BOOL
        newcolumn = Array(Nullable{Bool}, nrows)
        for i in 1:(row - 1)
            if isnull(oldcolumn[i])
                newcolumn[i] = Nullable{Bool}()
            else
                newcolumn[i] = Nullable(bool(oldcolumn[i]))
            end
        end
        output[col] = newcolumn
    elseif code == Codes.STRING
        newcolumn = Array(Nullable{UTF8String}, nrows)
        for i in 1:(row - 1)
            if isnull(oldcolumn[i])
                newcolumn[i] = Nullable{UTF8String}()
            else
                newcolumn[i] = Nullable{UTF8String}(string(oldcolumn[i]))
            end

        end
    end
    output[colname] = newcolumn
    return
end

function store_null!(output::Dict, row::Int, col::Int, reader::CSVReader)
    column = output[reader.column_names[col]]
    column[row] = eltype(column)()
    return
end

function store_value!(
    output::Dict,
    row::Int,
    col::Int,
    reader::CSVReader,
    value::Any,
)
    output[reader.column_names[col]][row] = Nullable(value)
    return
end

function finalize(output::Dict, rows, cols)
    for column in values(output)
        resize!(column, rows)
    end
    return output
end
