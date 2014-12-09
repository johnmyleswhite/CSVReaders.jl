CSVReaders.jl
=============

# Introduction

CSVReaders is a beta package designed to provide a standardized API for reading
CSV files into arbitrary Julia data structures. In order to add support for
a new data structure, users must implement a standard set of functions. For
example implementations, see the `src/interface` directory.

The package has several design goals:

* Expose CSV files as a stream of values that can be read in from IO in batches
  of N rows
* Allow CSV files to be read during exactly one pass through the data
* Use the minimum amount of memory required to perform parsing
* Make it possible to read data from CSV files into arbitrary data structures
* Make it possible to skip irrelevant columns while reading CSV files
* Make it easier to provide informative error messages when parsing fails
* Demonstrate that an abstract protocol for reading CSV files can be compiled
  into high-performance code for arbitary data structures

# For Users: Reading in Data

In the demo below, we show how to read the contents of a CSV file into a
Dict-of-Vectors and a Vector-of-Dicts:

```julia
using CSVReaders

path = Pkg.dir("CSVReaders", "test", "data", "scaling", "movies.csv")
sizehint = filesize(path)

reader = CSVReaders.CSVReader()
io = open(path, "r")
output = readall(Dict{Vector}, io, reader, sizehint)
close(io)

reader = CSVReaders.CSVReader()
io = open(path, "r")
output = readall(Vector{Dict}, io, reader, sizehint)
close(io)
```

In the demo below, we show how to read the contents of a CSV file into a
`Vector{Any}`. To get a matrix, you will want to call both `reshape` and
`transpose`:

```julia
using CSVReaders

path = Pkg.dir("CSVReaders", "test", "data", "scaling", "movies.csv")
sizehint = filesize(path)

reader = CSVReaders.CSVReader()
io = open(path, "r")
output = readall(Vector{Any}, io, reader, sizehint)
close(io)

ncols = length(reader.column_names)
nrows = fld(length(output), ncols)
transpose(reshape(output, ncols, nrows))
```

In the demo below, we show how to read the contents of a CSV file into a
`Vector{Float64}` or a `Vector{Nullable{Float64}}`. Which output structure is
appropriate depends on the possibility of null values being found in the
input CSV file:

```julia
using CSVReaders

path = Pkg.dir("CSVReaders", "test", "data", "numeric", "float.csv")
sizehint = filesize(path)

reader = CSVReaders.CSVReader()
io = open(path, "r")
output = readall(Vector{Float64}, io, reader, sizehint)
close(io)

reader = CSVReaders.CSVReader()
io = open(path, "r")
output = readall(Vector{Nullable{Float64}}, io, reader, sizehint)
close(io)
```

# For Developers: Parser Interface

To support reading data from CSV files into a new data structure, you need
to implement seven functions:

**(1) `allocate(::Type{T}, nrows::Int, ncols::Int, reader::CSVReader)`**

Allocate an initial version of your data structure (or some intermediate)
that provides space for representing `nrows` rows and `ncols` columns.

**(2) `available_rows(output::T, reader::CSVReader)`**

Compute the number of rows that can be stored inside of the currently allocated
copy of the data structure. Used to determine if more rows need to be added.

**(3) `add_rows!(output::T, nrows::Int, ncols::Int)`**

Resize the data structure so that there is space to store `nrows` rows and
`ncols` columns.

**(4) `fix_type!(output::T, i::Int, j::Int, code::Int, reader::CSVReader)`**

If online type inference determines that column `j` in the data source is of
a "larger" type than can currently being stored in the output data structure,
this function will be called so that the data structure can be modified to
provide support for that "larger" type. All values occurring before row `i`
will be converted up to the new type, which is specified by a numeric code.

**(5) `store_null!(output::T, i::Int, j::Int, reader::CSVReader)`**

Store a null value in the output data structure at row `i` and column `j`.
Should be configured to error out if the output data structure cannot represent
null values.

**(6) `store_value!(output::T, i::Int, j::Int, reader::CSVReader, value::Any)`**

Store a non-null value in the output data structure at row `i` and column `j`.

**(7) `finalize(output::T, nrows::Int, ncols::Int)`**

Finalize the output data structure before returning it to the end-user. Often
this step simply involves de-allocating space for rows that were not present
in the input data source.

After implementing these seven functions for a data structure, it should be
possible to call `readall` as shown in the examples.

# Warnings

At present, the draft reader is about 50% slower than the current DataFrames
reader. Because the new reader provides functionality not found in DataFrames,
it may not be possible to substantially improve on this.

The API is subject to substantial change until the package is listed in
METADATA.
