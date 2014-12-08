@doc """
# Description

Skip the contents of an entire line of a CSV input from an IO stream. Assumes
that the IO stream is currently at the start of a line. If not, will read
as far as necessary to get to the end of the line.

# Arguments

* `io::IO`: An IO stream from which bytes will be read.
* `reader::CSVReader`: A CSVReader object that will allow each field to be read.

# Returns

* `Void`
""" ->
function skiprow(io::IO, reader::CSVReader)
    reader.eor = false
    while !reader.eor
        get_bytes!(io, reader)
    end
    return
end
