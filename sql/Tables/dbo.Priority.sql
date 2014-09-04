CREATE TABLE [dbo].[Priority]
(
[PRIORITY_ID] [smallint] NOT NULL IDENTITY(1, 1),
[PriorityCode] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[PriorityName] [varchar] (50) COLLATE Latin1_General_CI_AS NOT NULL,
[Weight] [smallint] NOT NULL CONSTRAINT [DF_Priority_Weight] DEFAULT ((0)),
[TitleForeColour] [char] (6) COLLATE Latin1_General_CI_AS NOT NULL,
[TitleBackColour] [char] (6) COLLATE Latin1_General_CI_AS NOT NULL,
[ListBackColour] [char] (6) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Priority] ADD CONSTRAINT [PK_Priority] PRIMARY KEY CLUSTERED  ([PRIORITY_ID]) ON [PRIMARY]
GO
