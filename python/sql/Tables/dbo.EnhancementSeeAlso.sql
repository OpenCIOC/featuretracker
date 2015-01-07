CREATE TABLE [dbo].[EnhancementSeeAlso]
(
[ENHANCEMENT_ID] [int] NOT NULL,
[SEE_ALSO_ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EnhancementSeeAlso] ADD CONSTRAINT [PK_EnhancementSeeAlso] PRIMARY KEY CLUSTERED  ([ENHANCEMENT_ID], [SEE_ALSO_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EnhancementSeeAlso] ADD CONSTRAINT [FK_EnhancementSeeAlso_Enhancement] FOREIGN KEY ([ENHANCEMENT_ID]) REFERENCES [dbo].[Enhancement] ([ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[EnhancementSeeAlso] ADD CONSTRAINT [FK_EnhancementSeeAlso_Enhancement_SA] FOREIGN KEY ([SEE_ALSO_ID]) REFERENCES [dbo].[Enhancement] ([ID])
GO
