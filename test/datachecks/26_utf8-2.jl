# TODO: Check parsing of at least rows 1-3, 501-503, 998-1000
module TestDataChecks26
    using Base.Test
    using CSVReaders

    path = joinpath("test", "data", "26_utf8-2.csv")
    sizehint = filesize(path)

    reader = CSVReaders.CSVReader()
    io = open(path, "r")
    output = readall(Vector{Any}, io, reader, sizehint)
    close(io)

    @test reader.column_names == [
        "AssignmentId",
        "SubmitTime",
        "WorkTimeInSeconds",
        "DemographicsQ1Gender",
        "DemographicsQ2age",
        "DemographicsQ3education",
        "DemographicsQ4income",
        "DemographicsQ5marritalstatus",
        "DemographicsQ6Children",
        "DemographicsQ7hhsize",
        "DemographicsQ10race",
        "DemographicsQ9state",
        "DemographicsQ8country",
        "EngagementQ7mturkhits",
        "EngagementQ4tenure",
        "EngagementQ5mturkincome",
        "EngagementQ6mturktime",
        "EngagementQ1reasons",
        "MotivationFruitful",
        "MotivationEntertainment",
        "MotivationKilltime",
        "MotivationPrimaryIncome",
        "MotivationSeondaryIncome",
        "MotivationUnemployed",
        "EngagementQ2recession",
        "EngagementQ3participation",
        "EngagementQ1comment",
        "EngagementFeedback",
    ]

    nrows = 1000
    ncols = 28
    @test length(output) == nrows * ncols
    parsed = transpose(reshape(output, ncols, nrows))

    truth = Array(Any, nrows)

    truth[1] = Any[
        Nullable(convert(UTF8String, "NYHZYE9RABEZ74ZTEY80ZZSZP1ZSAG7ZV8M3T330")),
        Nullable(convert(UTF8String, "Tue Feb 02 09:14:38 GMT 2010")),
        Nullable(57),
        Nullable(convert(UTF8String, "Female")),
        Nullable(1991),
        Nullable(convert(UTF8String, "Some college, no degree")),
        Nullable(convert(UTF8String, "\$100,000 - \$149,999")),
        Nullable(convert(UTF8String, "single")),
        Nullable(convert(UTF8String, "No")),
        Nullable(convert(UTF8String, "5+")),
        Nullable(convert(UTF8String, "White")),
        Nullable{UTF8String}(),
        Nullable(convert(UTF8String, "Canada")),
        Nullable(convert(UTF8String, "Less than 1 HIT per week")),
        Nullable(convert(UTF8String, "3-6 months")),
        Nullable(convert(UTF8String, "Less than \$1 per week")),
        Nullable(convert(UTF8String, "Less than 1 hour per week")),
        Nullable(convert(UTF8String, "fruitful|killtime")),
        Nullable(true),
        Nullable(false),
        Nullable(true),
        Nullable(false),
        Nullable(false),
        Nullable(false),
        Nullable(convert(UTF8String, "I started working on MTurk after the recession but the recession has nothing to do with my decision")),
        Nullable(convert(UTF8String, "I was not active before the recession.")),
        Nullable{UTF8String}(),
        Nullable{UTF8String}(),
    ]

    truth[1000] = Any[
        Nullable("NYHZYE9RABEZ74ZTEY80AZWZ034EGXR03Q5SFXYZ"),
        Nullable("Wed Feb 03 07:50:17 GMT 2010"),
        Nullable(2606),
        Nullable("Male"),
        Nullable(1986),
        Nullable("Bachelors degree"),
        Nullable("\$25,000 - \$39,499"),
        Nullable("single"),
        Nullable("No"),
        Nullable("4"),
        Nullable("Asian"),
        Nullable(""),
        Nullable("India"),
        Nullable("100-200 HITs per week"),
        Nullable("6-12 months"),
        Nullable("\$20-\$50 per week"),
        Nullable("8-20 hours per week"),
        Nullable("fruitful|secondary_income|entertainment"),
        Nullable(true),
        Nullable(true),
        Nullable(false),
        Nullable(false),
        Nullable(true),
        Nullable(false),
        Nullable("I started working on MTurk after the recession but the recession has nothing to do with my decision"),
        Nullable("I work more on MTurk after the recession."),
        Nullable("for enjoy and earn extra money"),
        Nullable("no"),
    ]

    for i in [1, 1000]
        for j in 1:ncols
            if isnull(truth[i][j])
                @test isnull(parsed[i, j])
            else
                @test get(parsed[i ,j]) == get(truth[i][j])
            end
        end
    end
end
