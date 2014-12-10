module TestDataChecks22
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "22_quoted-commas.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader()
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["C1", "C2", "C3", "C4", "C5"]

    nrows = 2
    ncols = 5
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    truth[1] = Any[
        Nullable(convert(UTF8String, "a")),
        Nullable(convert(UTF8String, "b")),
        Nullable(convert(UTF8String, "c,d")),
        Nullable(1.0),
        Nullable(1),
    ]

    truth[2] = Any[
        Nullable(convert(UTF8String, "a")),
        Nullable(convert(UTF8String, "b")),
        Nullable(convert(UTF8String, "")),
        Nullable{Float64}(),
        Nullable{Int}(),
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
