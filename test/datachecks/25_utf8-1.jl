module TestDataChecks25
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "25_utf8-1.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader()
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == ["Nombre", "Señores", "Señoras"]

    nrows = 1
    ncols = 3
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    truth[1] = Any[
        Nullable(convert(UTF8String, "Güerín")),
        Nullable(convert(UTF8String, "Sí")),
        Nullable(convert(UTF8String, "No")),
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
