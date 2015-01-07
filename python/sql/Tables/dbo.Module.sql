CREATE TABLE [dbo].[Module]
(
[MODULE_ID] [char] (1) COLLATE Latin1_General_CI_AS NOT NULL,
[ModuleCode] [varchar] (20) COLLATE Latin1_General_CI_AS NOT NULL,
[ModuleName] [nvarchar] (50) COLLATE Latin1_General_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Module] ADD CONSTRAINT [PK_Module] PRIMARY KEY CLUSTERED  ([MODULE_ID]) ON [PRIMARY]
GO
