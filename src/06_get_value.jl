@doc """
# Description

Parse a value from a sequence of bytes that was accumulated via `get_bytes!`.

This function works entirely through side effects. In particular, it will:
* Set the `success` code
* Set the `isnull` code
* Set the `current_type` code
* (Possibly) set a value in the `int`, `float`, `bool` or `string` fields

A user should check, in order:
* `success(reader)`
* `isnull(reader)`
* `current_type(reader)`:
* `int(reader)` | `float(reader)` | `bool(reader)` | `string(reader)`

If the success field is false, you should assume that your output container
may need to have its type changed to handle the set value. If the isnull
field is true, you should be prepared to handle a null value. Otherwise, use
`current_type` to determine whether you should read from `int`, `float`,
`bool`, or `string`.

# Arguments

* `reader::CSVReader`: A CSVReader object
* `expected_type::Int`: The code that should initiate parsing

# Returns

* `Void`
""" ->
function get_value!(reader::CSVReader, expected_type::Int)
    # TODO: Try recursion on !success rather than fallthrough as a possible
    # performance hack
    bytes = reader.main

    parsed_type = expected_type

    if parsenull(bytes, reader.nulls)
        reader.success = true
        reader.isnull = true
        reader.current_type = expected_type
        return
    end

    if length(bytes) == 0
        if reader.contained_quote
            parsed_type = Codes.STRING
        else
            if expected_type != Codes.STRING
                reader.success = true
                reader.isnull = true
                reader.current_type = expected_type
                return
            end
        end
    end

    if parsed_type == Codes.INT
        intval, succeeded = parseint(bytes)
        if !succeeded
            parsed_type = Codes.FLOAT
        else
            reader.success = parsed_type == expected_type
            reader.isnull = false
            reader.current_type = Codes.INT
            reader.int = intval
            return
        end
    end

    if parsed_type == Codes.FLOAT
        floatval, succeeded = parsefloat(bytes)
        if !succeeded
            parsed_type = Codes.BOOL
        else
            reader.success = parsed_type == expected_type
            reader.isnull = false
            reader.current_type = Codes.FLOAT
            reader.float = floatval
            return
        end
    end

    if parsed_type == Codes.BOOL
        boolval, succeeded = parsebool(bytes, reader.trues, reader.falses)
        if !succeeded
            parsed_type = Codes.STRING
        else
            reader.success = parsed_type == expected_type
            reader.isnull = false
            reader.current_type = Codes.BOOL
            reader.bool = boolval
            return
        end
    end

    if parsed_type == Codes.STRING
        stringval = parsestring(bytes)
        reader.success = parsed_type == expected_type
        reader.isnull = false
        reader.current_type = Codes.STRING
        reader.string = stringval
        return
    end

    return
end
