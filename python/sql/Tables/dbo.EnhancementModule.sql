CREATE TABLE [dbo].[EnhancementModule]
(
[ENHANCEMENT_ID] [int] NOT NULL,
[MODULE_ID] [char] (1) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EnhancementModule] ADD CONSTRAINT [PK_EnhancementModule] PRIMARY KEY CLUSTERED  ([ENHANCEMENT_ID], [MODULE_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EnhancementModule] ADD CONSTRAINT [FK_EnhancementModule_Enhancement] FOREIGN KEY ([ENHANCEMENT_ID]) REFERENCES [dbo].[Enhancement] ([ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[EnhancementModule] ADD CONSTRAINT [FK_EnhancementModule_EnhancementModule] FOREIGN KEY ([MODULE_ID]) REFERENCES [dbo].[Module] ([MODULE_ID]) ON UPDATE CASCADE
GO
