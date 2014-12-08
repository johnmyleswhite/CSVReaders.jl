#
# Correctness Tests
#

fatalerrors = length(ARGS) > 0 && ARGS[1] == "-f"
quiet = length(ARGS) > 0 && ARGS[1] == "-q"
anyerrors = false

using Base.Test
using CSVReaders

my_tests = [
    "01_codes.jl",
    "02_csv_reader.jl",
    "03_process_escape.jl",
    "04_get_bytes.jl",
    "05_parsers.jl",
    "06_get_value.jl",
    "07_readfield.jl",
    "08_readheader.jl",
    "09_skiprow.jl",
    "10_readrow.jl",
    "11_ensure_type.jl",
    "12_store_field.jl",
    "13_store_row.jl",
    "14_readnrows.jl",
    "15_readall.jl",
]

println("Running tests:")

for my_test in my_tests
    try
        include(my_test)
        println("\t\033[1m\033[32mPASSED\033[0m: $(my_test)")
    catch e
        anyerrors = true
        println("\t\033[1m\033[31mFAILED\033[0m: $(my_test)")
        if fatalerrors
            rethrow(e)
        elseif !quiet
            showerror(STDOUT, e, backtrace())
            println()
        end
    end
end

if anyerrors
    throw("Tests failed")
end
