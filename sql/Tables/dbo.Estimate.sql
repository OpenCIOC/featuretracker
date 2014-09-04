CREATE TABLE [dbo].[Estimate]
(
[ESTIMATE_ID] [smallint] NOT NULL IDENTITY(1, 1),
[EstimateCode] [varchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[HrsLow] [smallint] NULL,
[HrsHigh] [smallint] NULL,
[CostLow] [decimal] (10, 2) NULL,
[CostHigh] [decimal] (10, 2) NULL,
[CostAvg] [decimal] (10, 2) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_Estimate_u] ON [dbo].[Estimate] 
FOR INSERT, UPDATE AS
SET NOCOUNT ON

DECLARE @Rate decimal
SET @Rate=70.0

IF  UPDATE(HrsLow) OR UPDATE(HrsHigh) BEGIN
	
	UPDATE e SET
		EstimateCode = CAST(ISNULL(e.HrsLow,0) AS varchar) + '-' + CAST(ISNULL(e.HrsHigh,0) AS varchar) + ' h',
		CostLow=ISNULL(e.HrsLow,0)*@Rate,
		CostHigh=ISNULL(e.HrsHigh,0)*@Rate,
		CostAvg=(ISNULL(e.HrsLow,0)+ISNULL(e.HrsHigh,0))*@Rate/2
	FROM Estimate e
	INNER JOIN Inserted i
		ON i.ESTIMATE_ID=e.ESTIMATE_ID
	WHERE e.HrsHigh IS NOT NULL OR e.HrsLow IS NOT NULL
	
END

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[Estimate] ADD CONSTRAINT [PK_Estimate] PRIMARY KEY CLUSTERED  ([ESTIMATE_ID]) ON [PRIMARY]
GO
