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
    "16_randomized.jl",
    "datachecks/01_floats.jl",
    "datachecks/02_movies.jl",
    "datachecks/03_blanklines.jl",
    "datachecks/04_comments-1.jl",
    "datachecks/05_comments-2.jl",
    "datachecks/06_commas-in-fields.jl",
    "datachecks/07_periods-in-fields.jl",
    "datachecks/08_types.jl",
    # "datachecks/09_escapes.jl",
    "datachecks/10_os9-newlines.jl",
    "datachecks/11_osx-newlines.jl",
    # "datachecks/12_windows-newlines.jl",
    "datachecks/13_os9-newlines-in-fields.jl",
    "datachecks/14_osx-newlines-in-fields.jl",
    # "datachecks/15_windows-newlines-in-fields.jl",
    "datachecks/16_padding-1.jl",
    "datachecks/17_padding-2.jl",
    "datachecks/18_padding-3.jl",
    "datachecks/19_empty.jl",
    "datachecks/20_escaping.jl",
    "datachecks/21_mixed-quotemarks.jl",
    "datachecks/22_quoted-commas.jl",
    "datachecks/23_quoted-whitespace.jl",
    "datachecks/24_single-quotemarks.jl",
    "datachecks/25_utf8-1.jl",
    "datachecks/26_utf8-2.jl",
    "datachecks/27_type-inference-1.jl",
    "datachecks/28_type-inference-2.jl",
    "datachecks/29_type-inference-3.jl",
    # "datachecks/30_complex-osx.jl",
    # "datachecks/31_complex-windows.jl",
    "datachecks/32_skip-bottom.jl",
    "datachecks/33_skip-front.jl",
    "datachecks/34_sample-data.jl",
    "datachecks/35_sample-data.jl",
    "datachecks/36_sample-data.jl",
    # "datachecks/37_sample-data-white.jl",
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
