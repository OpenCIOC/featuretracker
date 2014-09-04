CREATE TABLE [dbo].[SourceType]
(
[SOURCE_ID] [int] NOT NULL IDENTITY(1, 1),
[SourceType] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SourceType] ADD CONSTRAINT [PK_SourceType] PRIMARY KEY CLUSTERED  ([SOURCE_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SourceType] ON [dbo].[SourceType] ([SourceType]) ON [PRIMARY]
GO
