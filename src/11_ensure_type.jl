@doc """
A helper function built out of functions from the reader interface.
""" ->
function ensure_type(reader::CSVReader, output::Any, row::Int, col::Int)
    if !reader.success
        newcode = reader.current_type
        reader.column_types[col] = newcode
        fix_type!(output, row, col, newcode, reader)
    end
    return
end
