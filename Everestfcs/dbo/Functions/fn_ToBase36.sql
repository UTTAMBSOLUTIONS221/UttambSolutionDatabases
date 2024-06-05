
CREATE FUNCTION [dbo].[fn_ToBase36]
(
	@Number bigint
)
RETURNS Varchar(15)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @BaseString varchar(50) ='ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
			@Value varchar(50) = '',
			@Power int = 0,
			@Mod int = 0

	Set  @Power = Len(@BaseString)
	While(@Number <> 0)
	Begin
		Set @Mod = (@Number % @Power)
		Set @Number = @Number / @Power
		Set @Value =  Substring(@BaseString,@Mod + 1, 1) + @Value;
	End

	RETURN @Value
END
