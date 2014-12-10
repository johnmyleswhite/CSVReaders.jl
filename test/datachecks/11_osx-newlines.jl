module TestDataChecks11
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "11_osx-newlines.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader(newline = "\n")
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["A", "B", "C", "D", "E"]

    nrows = 5
    ncols = 5
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    truth[1] = Any[
        Nullable{Int}(1),
        Nullable{Int}(2),
        Nullable{Float64}(3.1),
        Nullable{Bool}(true),
        Nullable{UTF8String}(convert(UTF8String, "X")),
    ]

    truth[2] = Any[
        Nullable{Int}(3),
        Nullable{Int}(4),
        Nullable{Float64}(2.3),
        Nullable{Bool}(false),
        Nullable{UTF8String}(convert(UTF8String, "Y")),
    ]

    truth[3] = Any[
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Float64}(),
        Nullable{Bool}(),
        Nullable{UTF8String}(),
    ]

    truth[4] = Any[
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Float64}(),
        Nullable{Bool}(),
        Nullable{UTF8String}(),
    ]

    truth[5] = Any[
        Nullable{Int}(),
        Nullable{Int}(),
        Nullable{Float64}(),
        Nullable{Bool}(),
        Nullable{UTF8String}(convert(UTF8String, "")),
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
