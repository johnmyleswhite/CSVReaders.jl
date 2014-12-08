module TestReadHeader
    using Base.Test
    using CSVReaders

    io = open(joinpath("test", "data", "scaling", "movies.csv"), "r")

    reader = CSVReaders.CSVReader()

    column_names = CSVReaders.readheader(io, reader)

    @test column_names == UTF8String[
        "",
        "title",
        "year",
        "length",
        "budget",
        "rating",
        "votes",
        "r1",
        "r2",
        "r3",
        "r4",
        "r5",
        "r6",
        "r7",
        "r8",
        "r9",
        "r10",
        "mpaa",
        "Action",
        "Animation",
        "Comedy",
        "Drama",
        "Documentary",
        "Romance",
        "Short",
    ]

    close(io)

    # Now with a skipped column
    io = open(joinpath("test", "data", "scaling", "movies.csv"), "r")

    reader = CSVReaders.CSVReader(skip_cols = [1])

    column_names = CSVReaders.readheader(io, reader)

    @test column_names == UTF8String[
        "title",
        "year",
        "length",
        "budget",
        "rating",
        "votes",
        "r1",
        "r2",
        "r3",
        "r4",
        "r5",
        "r6",
        "r7",
        "r8",
        "r9",
        "r10",
        "mpaa",
        "Action",
        "Animation",
        "Comedy",
        "Drama",
        "Documentary",
        "Romance",
        "Short",
    ]

    close(io)
end
