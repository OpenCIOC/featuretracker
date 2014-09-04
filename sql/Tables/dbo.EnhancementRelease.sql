CREATE TABLE [dbo].[EnhancementRelease]
(
[ENHANCEMENT_ID] [int] NOT NULL,
[RELEASE_ID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EnhancementRelease] ADD CONSTRAINT [PK_EnhancementRelease] PRIMARY KEY CLUSTERED  ([ENHANCEMENT_ID], [RELEASE_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EnhancementRelease] ADD CONSTRAINT [FK_EnhancementRelease_Enhancement] FOREIGN KEY ([ENHANCEMENT_ID]) REFERENCES [dbo].[Enhancement] ([ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[EnhancementRelease] ADD CONSTRAINT [FK_EnhancementRelease_Release] FOREIGN KEY ([RELEASE_ID]) REFERENCES [dbo].[Release] ([RELEASE_ID])
GO
