CREATE TABLE [dbo].[EnhancementKeyword]
(
[ENHANCEMENT_ID] [int] NOT NULL,
[KEYWORD_ID] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_EnhancementKeyword_SRCH] ON [dbo].[EnhancementKeyword] 
FOR INSERT, UPDATE AS

SET NOCOUNT ON

/* Update Name Index */
UPDATE e
	SET SRCH_Keyword = dbo.fn_EnhancementToKeyword(e.ID)
	FROM 	Enhancement e
	INNER JOIN Inserted i
		ON e.ID=i.ENHANCEMENT_ID

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[EnhancementKeyword] ADD CONSTRAINT [PK_EnhancementKeyword] PRIMARY KEY CLUSTERED  ([ENHANCEMENT_ID], [KEYWORD_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EnhancementKeyword] ADD CONSTRAINT [FK_EnhancementKeyword_Enhancement] FOREIGN KEY ([ENHANCEMENT_ID]) REFERENCES [dbo].[Enhancement] ([ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[EnhancementKeyword] ADD CONSTRAINT [FK_EnhancementKeyword_Keyword] FOREIGN KEY ([KEYWORD_ID]) REFERENCES [dbo].[Keyword] ([KEYWORD_ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
