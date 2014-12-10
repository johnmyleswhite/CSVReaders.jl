@doc """
A helper function built out of functions from the reader interface.
""" ->
function ensure_type(reader::CSVReader, output::Any, i::Int, j::Int)
    # TODO: Delete this function
    if !reader.success
        newcode = reader.current_type
        reader.column_types[j] = newcode
        fix_type!(output, i, j, newcode, reader)
    end
    return
end
