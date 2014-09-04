CREATE TABLE [dbo].[Release]
(
[RELEASE_ID] [smallint] NOT NULL IDENTITY(1, 1),
[ReleaseName] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Release] ADD CONSTRAINT [PK_Release] PRIMARY KEY CLUSTERED  ([RELEASE_ID]) ON [PRIMARY]
GO
