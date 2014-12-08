module CSVReaders
    # Core functionality
    include("01_codes.jl")
    include("02_csv_reader.jl")
    include("03_process_escape.jl")
    include("04_get_bytes.jl")
    include("05_parsers.jl")
    include("06_get_value.jl")
    include("07_readfield.jl")
    include("08_readheader.jl")
    include("09_skiprow.jl")
    include("10_readrow.jl")
    include("11_ensure_type.jl")
    include("12_store_field.jl")
    include("13_store_row.jl")
    include("14_readnrows.jl")
    include("15_readall.jl")

    # Output data structures
    include(joinpath("interface", "dict_vector.jl"))
    include(joinpath("interface", "vector_dict.jl"))
    include(joinpath("interface", "vector_nullable.jl"))
    include(joinpath("interface", "vector_any.jl"))
end
