module TestReadall
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "02_movies.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader()
    io = open(path, "r")
    output1 = readall(Dict{Vector}, io, reader, sizehint)
    close(io)

    reader = CSVReaders.CSVReader()
    io = open(path, "r")
    output2 = readall(Vector{Dict}, io, reader, sizehint)
    close(io)

    reader = CSVReaders.CSVReader()
    io = open(path, "r")
    output3 = readall(Vector{Any}, io, reader, sizehint)
    close(io)
end
