module TestReadall
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "scaling", "movies.csv")
    sizehint = filesize(path)

    for itr in 1:2
        gc()
        reader = CSVReaders.CSVReader()
        io = open(path, "r")
        @time output = readall(Dict, io, reader, sizehint)
        close(io)

        gc()
        reader = CSVReaders.CSVReader()
        io = open(path, "r")
        @time output = readall(Vector{Dict}, io, reader, sizehint)
        close(io)

        gc()
        reader = CSVReaders.CSVReader()
        io = open(path, "r")
        @time output = readall(Vector{Any}, io, reader, sizehint)
        close(io)
    end
end
