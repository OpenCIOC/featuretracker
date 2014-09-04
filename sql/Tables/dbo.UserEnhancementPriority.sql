CREATE TABLE [dbo].[UserEnhancementPriority]
(
[USER_ID] [int] NOT NULL,
[ENHANCEMENT_ID] [int] NOT NULL,
[PRIORITY_ID] [smallint] NOT NULL,
[InPriorityOrder] [smallint] NOT NULL CONSTRAINT [DF_UserEnhancementPriority_InPriorityOrder] DEFAULT ((32767))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserEnhancementPriority] ADD CONSTRAINT [PK_UserEnhancementPriority_1] PRIMARY KEY CLUSTERED  ([USER_ID], [ENHANCEMENT_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserEnhancementPriority] ADD CONSTRAINT [FK_UserEnhancementPriority_Enhancement] FOREIGN KEY ([ENHANCEMENT_ID]) REFERENCES [dbo].[Enhancement] ([ID]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[UserEnhancementPriority] ADD CONSTRAINT [FK_UserEnhancementPriority_Priority] FOREIGN KEY ([PRIORITY_ID]) REFERENCES [dbo].[Priority] ([PRIORITY_ID])
GO
ALTER TABLE [dbo].[UserEnhancementPriority] ADD CONSTRAINT [FK_UserEnhancementPriority_User] FOREIGN KEY ([USER_ID]) REFERENCES [dbo].[UserAccount] ([USER_ID])
GO
