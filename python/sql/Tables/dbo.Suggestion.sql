CREATE TABLE [dbo].[Suggestion]
(
[SUGGEST_ID] [int] NOT NULL IDENTITY(1, 1),
[DateSuggested] [smalldatetime] NULL CONSTRAINT [DF_Suggestion_DateSuggested] DEFAULT (getdate()),
[USER_ID] [int] NOT NULL,
[Suggestion] [nvarchar] (max) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Suggestion] ADD CONSTRAINT [PK_Suggestion] PRIMARY KEY CLUSTERED  ([SUGGEST_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Suggestion] ADD CONSTRAINT [FK_Suggestion_UserAccount] FOREIGN KEY ([USER_ID]) REFERENCES [dbo].[UserAccount] ([USER_ID])
GO
