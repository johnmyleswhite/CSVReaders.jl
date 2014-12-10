module TestDataChecks04
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "04_comments-1.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader()
    io = open(path, "r")
    names = CSVReaders.readheader(io, reader)
    close(io)

    reader = CSVReaders.CSVReader()
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["A", "B", "C", "D"]

    nrows = 5
    ncols = 4
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    for i in 1:nrows
        truth[i] = Any[
            Nullable(1),
            Nullable(2),
            Nullable(3),
            Nullable(4),
        ]
    end

    for i in 1:nrows
        for j in 1:ncols
            if isnull(truth[i][j])
                @test isnull(parsed[i, j])
            else
                @test get(parsed[i ,j]) == get(truth[i][j])
            end
        end
    end
end
