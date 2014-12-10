@doc """
# Description

Represent a single row of a relation (as in the relational model)

# Fields

* `isnull::BitVector`: Is the value at the ith index null?
* `values::Vector{Any}`: The value at the ith index.
""" ->
immutable Relation
    isnull::BitVector
    values::Vector{Any}
end

@doc """
# Description

Read the entire header line of a CSV input from an IO stream. Assumes that
all of the fields are strings, which should hold for a header line.

Insert the name `UnnamedColumn` for any column that had an empty name.

# Arguments

* `io::IO`: An IO stream from which bytes will be read.
* `reader::CSVReader`: A CSVReader object that will allow each field to be read.

# Returns

* `column_names::Vector{UTF8String}`: The names of all columns.
""" ->
function readrow(io::IO, reader::CSVReader, row::Relation)
    # TODO: Rename this getrow
    if reader.eof
        empty!(row.isnull)
        empty!(row.values)
        return 0
    end

    bytes = 0
    col = 1
    reader.eor = false
    while !reader.eor
        if length(reader.column_types) < col
            bytes += readfield(io, reader, Codes.BOOL)
            resize!(reader.column_types, col)
            resize!(row.isnull, col)
            resize!(row.values, col)
        else
            bytes += readfield(io, reader, reader.column_types[col])
        end

        reader.column_types[col] = reader.current_type

        if reader.isnull
            row.isnull[col] = true
        else
            row.isnull[col] = false
            if reader.current_type == Codes.BOOL
                row.values[col] = reader.bool
            elseif reader.current_type == Codes.INT
                row.values[col] = reader.int
            elseif reader.current_type == Codes.FLOAT
                row.values[col] = reader.float
            elseif reader.current_type == Codes.STRING
                row.values[col] = reader.string
            end
        end

        col += 1
    end

    return bytes
end
