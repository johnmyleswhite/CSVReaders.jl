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
function readheader(io::IO, reader::CSVReader)
    column_names = Array(UTF8String, 0)
    reader.contained_comment = true
    while isempty(column_names) && reader.contained_comment
        reader.eor = false
        while !reader.eor
            readfield(io, reader, Codes.STRING)

            if reader.isnull
                push!(column_names, "UnnamedColumn")
            else
                if !(isempty(reader.main) && reader.contained_comment)
                    push!(column_names, reader.string)
                end
            end
        end
    end

    return column_names
end
