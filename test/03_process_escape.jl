module TestProcessEscape
    using Base.Test
    using CSVReaders

    reader = CSVReaders.CSVReader()

    for (input_char, result_char) in (
        ('\\', '\\'),
        ('\'', '\''),
        ('"', '"'),
        ('n', '\n'),
        ('t', '\t'),
        ('r', '\r'),
        ('a', '\a'),
        ('b', '\b'),
        ('f', '\f'),
        ('v', '\v'),
    )
        input = convert(Uint8, input_char)
        result = convert(Uint8, result_char)
        CSVReaders.process_escape!(reader, input)
        @test reader.main == [result]
        empty!(reader.main)
    end

    @test_throws(
        Exception,
        CSVReaders.process_escape!(reader, convert(Uint8, 'x'))
    )
end
