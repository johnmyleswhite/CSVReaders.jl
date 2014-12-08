module TestParsers
    using Base.Test
    using CSVReaders

    function test_parsenull(seed::Integer, iterations::Integer)
        srand(seed)

        sentinels = Vector{Uint8}[
            convert(Vector{Uint8}, "NA"),
            convert(Vector{Uint8}, "N/A"),
            convert(Vector{Uint8}, "NULL"),
        ]

        # Generate permutations of sentinels and test accuracy
        for bytes in sentinels
            @test CSVReaders.parsenull(bytes, sentinels) === true
        end

        # Test that random strings do not match
        for len in [2, 3, 4]
            for iteration in 1:iterations
                s = randstring(len)
                bytes = convert(Vector{Uint8}, s)
                if !in(bytes, sentinels)
                    @test CSVReaders.parsenull(bytes, sentinels) === false
                else
                    @test CSVReaders.parsenull(bytes, sentinels) === true
                end
            end
        end
    end

    test_parsenull(1, 100_000)

    function test_parseint(seed::Integer, iterations::Integer)
        srand(seed)
        for iteration in 1:iterations
            # Generate random Int's
            n = rand(Int)

            # Turn their ASCII string representations into Vector{Uint8}
            s = string(n)
            bytes = Uint8[]
            for chr in s
                push!(bytes, chr)
            end

            # Test if parsed bytes recover original value exactly w/o warnings
            parsed_n, success = parseint(bytes)
            @test n === parsed_n
            @test success === true
        end
    end

    test_parseint(1, 100_000)


    function test_parsefloat(seed::Integer, iterations::Integer)
        srand(seed)
        for iteration in 1:iterations
            # Generate random Float64 values "uniformly"
            x = reinterpret(Float64, rand(Int))

            # Turn their ASCII string representations into Vector{Uint8}
            s = string(x)
            bytes = Uint8[]
            for chr in s
                push!(bytes, chr)
            end

            # Test if parsed bytes recover original value exactly w/o warnings
            parsed_x, success = parsefloat(bytes)

            # Deal with NaN specially
            if isnan(x) && isnan(parsed_x) && success
                continue
            end

            @test x === parsed_x
            @test success === true
        end
    end

    test_parsefloat(1, 100_000)

    function test_parsebool(seed::Integer, iterations::Integer)
        srand(seed)

        trues = Vector{Uint8}[
            convert(Vector{Uint8}, "true"),
            convert(Vector{Uint8}, "TRUE"),
        ]

        falses = Vector{Uint8}[
            convert(Vector{Uint8}, "false"),
            convert(Vector{Uint8}, "FALSE"),
        ]

        # Generate permutations of true sentinels and test accuracy
        for bytes in trues
            @test CSVReaders.parsebool(bytes, trues, falses) === (true, true)
        end

        # Generate permutations of false sentinels and test accuracy
        for bytes in falses
            @test CSVReaders.parsebool(bytes, trues, falses) === (false, true)
        end

        # Test that random strings do not match
        for len in [3, 4, 5]
            for iteration in 1:iterations
                bytes = convert(Vector{Uint8}, randstring(len))
                if in(bytes, trues)
                    @test CSVReaders.parsebool(bytes, trues, falses) === (
                        true, true
                    )
                elseif in(bytes, falses)
                    @test CSVReaders.parsebool(bytes, trues, falses) === (
                        false, true
                    )
                else
                    @test CSVReaders.parsebool(bytes, trues, falses) === (
                        false, false
                    )
                end
            end
        end
    end

    test_parsebool(1, 100_000)

    function test_parsestring(seed::Integer, iterations::Integer)
        srand(seed)

        # Test that random strings do not match
        for len in [2, 3, 4]
            for iteration in 1:iterations
                bytes = convert(Vector{Uint8}, randstring(len))
                @test CSVReaders.parsestring(bytes) == bytestring(bytes)
            end
        end
    end

    test_parsestring(1, 100_000)
end
