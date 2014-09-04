CREATE TABLE [dbo].[UserAccount]
(
[USER_ID] [int] NOT NULL IDENTITY(1, 1),
[Email] [varchar] (50) COLLATE Latin1_General_100_CI_AI NOT NULL,
[MEMBER_ID] [int] NULL,
[Agency] [char] (3) COLLATE Latin1_General_100_CI_AI NULL,
[OrgName] [varchar] (150) COLLATE Latin1_General_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[LastName] [varchar] (50) COLLATE Latin1_General_100_CI_AI NULL,
[PasswordHashRepeat] [int] NOT NULL,
[PasswordHashSalt] [char] (44) COLLATE Latin1_General_100_CS_AI NOT NULL,
[PasswordHash] [char] (44) COLLATE Latin1_General_100_CS_AI NOT NULL,
[Inactive] [bit] NOT NULL CONSTRAINT [DF_User_Inactive] DEFAULT ((0)),
[NotCounted] [bit] NOT NULL CONSTRAINT [DF_UserAccount_NotCounted] DEFAULT ((0)),
[TechAdmin] [bit] NOT NULL CONSTRAINT [DF_UserAccount_TechAdmin] DEFAULT ((0)),
[EmailOnNew] [bit] NOT NULL CONSTRAINT [DF_UserAccount_EmailOnNew] DEFAULT ((0)),
[EmailOnUpdate] [bit] NOT NULL CONSTRAINT [DF_UserAccount_EmailOnUpdate] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserAccount] ADD CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED  ([USER_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_User] ON [dbo].[UserAccount] ([Email]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserAccount] ADD CONSTRAINT [FK_UserAccount_Agency] FOREIGN KEY ([Agency]) REFERENCES [dbo].[Agency] ([AgencyCode]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[UserAccount] ADD CONSTRAINT [FK_User_Member] FOREIGN KEY ([MEMBER_ID]) REFERENCES [dbo].[Member] ([MEMBER_ID])
GO
