--EXEC  CalculateEMI @LoanAmount= 2000000,@InterestRate =14,@LoanPeriodInYears =2,@StartPaymentDate='2023-12-05 00:00:00.000',@PaymentFrequency=52;

CREATE PROCEDURE CalculateEMI
(
    @LoanAmount DECIMAL(18, 2),
    @InterestRate DECIMAL(5, 2),
    @LoanPeriodInYears INT,
    @StartPaymentDate DATE,
    @PaymentFrequency INT 
)
AS
BEGIN
    -- Create a temporary table to store the payment schedule
    CREATE TABLE #TempPaymentSchedule
    (
        PaymentDate DATE,
        PaymentAmount DECIMAL(18, 2),
        PrincipalPaid DECIMAL(18, 2),
        InterestPaid DECIMAL(18, 2),
        RemainingBalance DECIMAL(18, 2)
    );

    DECLARE @P DECIMAL(18, 2) = @LoanAmount;
    DECLARE @r DECIMAL(18, 6) = (@InterestRate / 100) / @PaymentFrequency;  -- Monthly or Weekly
    DECLARE @n INT = @LoanPeriodInYears * @PaymentFrequency;  -- Total number of payments

    -- Calculate EMI
    DECLARE @EMI DECIMAL(18, 2);
    SET @EMI = @P * (@r * POWER(1 + @r, @n)) / (POWER(1 + @r, @n) - 1);

    -- Calculate remaining balance for each payment
    DECLARE @Balance DECIMAL(18, 2) = @P;
    
    -- Insert the initial payment into the temporary table
    INSERT INTO #TempPaymentSchedule (PaymentDate, PaymentAmount, PrincipalPaid, InterestPaid, RemainingBalance)
    VALUES (@StartPaymentDate, @EMI, 0, 0, @P);

    DECLARE @i INT = 1;

    WHILE @i < @n
    BEGIN
        -- Calculate the interest component for this payment
        DECLARE @InterestPaid DECIMAL(18, 2) = @Balance * @r;
        
        -- Calculate the principal component for this payment
        DECLARE @PrincipalPaid DECIMAL(18, 2) = @EMI - @InterestPaid;

        -- Ensure the remaining balance doesn't go negative
        IF (@Balance - @PrincipalPaid) < 0
        BEGIN
            SET @PrincipalPaid = @Balance;
            SET @InterestPaid = @EMI - @PrincipalPaid;
        END

        -- Calculate the remaining balance after this payment
        SET @Balance = @Balance - @PrincipalPaid;

        -- Insert the payment record into the temporary table
        INSERT INTO #TempPaymentSchedule (PaymentDate, PaymentAmount, PrincipalPaid, InterestPaid, RemainingBalance)
        VALUES (DATEADD(WEEK, @i, @StartPaymentDate), @EMI, @PrincipalPaid, @InterestPaid, @Balance);

        SET @i = @i + 1;
    END

    -- Ensure the last entry doesn't have a negative remaining balance
    UPDATE #TempPaymentSchedule
    SET RemainingBalance = 0
    WHERE RemainingBalance < 0;

    -- Select the payment schedule from the temporary table
    SELECT * FROM #TempPaymentSchedule;

    -- Clean up the temporary table
    DROP TABLE #TempPaymentSchedule;
END
                                                                        