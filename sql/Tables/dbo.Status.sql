CREATE TABLE [dbo].[Status]
(
[STATUS_ID] [smallint] NOT NULL IDENTITY(1, 1),
[StatusCode] [varchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[StatusName] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[ShowByDefault] [bit] NOT NULL CONSTRAINT [DF_Status_ShowByDefault] DEFAULT ((1)),
[CanRank] [bit] NOT NULL CONSTRAINT [DF_Status_CanRank] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Status] ADD CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED  ([STATUS_ID]) ON [PRIMARY]
GO
