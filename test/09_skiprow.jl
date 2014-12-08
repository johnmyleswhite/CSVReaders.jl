module TestSkipRow
    using Base.Test
    using CSVReaders

    io = open(joinpath("test", "data", "scaling", "movies.csv"), "r")

    reader = CSVReaders.CSVReader()
    CSVReaders.skiprow(io, reader)

    column_names = CSVReaders.readheader(io, reader)

    @test column_names == UTF8String[
        "1",
        "\$",
        "1971",
        "121",
        "UnnamedColumn",
        "6.4",
        "348",
        "4.5",
        "4.5",
        "4.5",
        "4.5",
        "14.5",
        "24.5",
        "24.5",
        "14.5",
        "4.5",
        "4.5",
        "",
        "0",
        "0",
        "1",
        "1",
        "0",
        "0",
        "0",
    ]

    close(io)

    io = open(joinpath("test", "data", "scaling", "movies.csv"), "r")

    reader = CSVReaders.CSVReader()

    CSVReaders.readheader(io, reader)

    row = 0
    finished = false
    while !finished
        CSVReaders.skiprow(io, reader)
        if reader.eof
            finished = true
        else
            row += 1
        end
    end

    close(io)

    @test row == 58788
end
