SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_DateString](
	@Date smalldatetime
)
RETURNS nvarchar(25) WITH EXECUTE AS CALLER
AS 
BEGIN
DECLARE	@returnStr nvarchar(25)

IF @Date IS NOT NULL BEGIN
	SET @returnStr = CONVERT(varchar,@Date,106)
END
RETURN @returnStr
END

GO
