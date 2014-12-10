# TODO: Get the handling of the third right when allow_escapes = false
module TestDataChecks09
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "09_escapes.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader()
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["V"]

    nrows = 3
    ncols = 1
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    truth[1] = Any[
        Nullable("\t\r\n"),
    ]

    truth[2] = Any[
        Nullable("\\\\t"),
    ]

    truth[3] = Any[
        Nullable("\\\""),
    ]

    for i in 1:nrows
        for j in 1:ncols
            if isnull(truth[i][j])
                @test isnull(parsed[i, j])
            else
                @test get(parsed[i ,j]) == get(truth[i][j])
            end
        end
    end

    reader = CSVReaders.CSVReader(allow_escapes = false)
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["V"]

    nrows = 3
    ncols = 1
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    truth[1] = Any[
        Nullable("\\t\\r\\n"),
    ]

    truth[2] = Any[
        Nullable("\\\\\\\\t"),
    ]

    truth[3] = Any[
        Nullable("\\\\\""),
    ]

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
