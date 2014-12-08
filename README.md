CSVReaders.jl
=============

CSVReaders is a beta package designed to provide a standardized API for reading
CSV files into arbitrary Julia data structures. In order to add support for
a new data structure, users must implement a standard set of functions. For
example implementations, see the `src/interface` directory.

In the demo below, you can see how one might read the contents of a CSV file
into either a Dict-of-Vectors or a Vector-of-Dicts:

```julia
using CSVReaders

path = Pkg.dir("CSVReaders", "test", "data", "scaling", "movies.csv")
sizehint = filesize(path)

reader = CSVReaders.CSVReader()
io = open(path, "r")
output = readall(Dict, io, reader, sizehint)
close(io)

reader = CSVReaders.CSVReader()
io = open(path, "r")
output = readall(Vector{Dict}, io, reader, sizehint)
close(io)
```
