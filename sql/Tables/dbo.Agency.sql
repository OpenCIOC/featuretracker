CREATE TABLE [dbo].[Agency]
(
[AgencyCode] [char] (3) COLLATE Latin1_General_100_CI_AI NOT NULL,
[AgencyName] [varchar] (150) COLLATE Latin1_General_CI_AS NULL,
[Inactive] [bit] NOT NULL CONSTRAINT [DF_Agency_Inactive] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Agency] ADD CONSTRAINT [PK_Agency] PRIMARY KEY CLUSTERED  ([AgencyCode]) ON [PRIMARY]
GO
