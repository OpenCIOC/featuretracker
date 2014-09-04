CREATE TABLE [dbo].[Enhancement]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[CREATED_DATE] [smalldatetime] NOT NULL CONSTRAINT [DF_Enhancement_CREATED_DATE] DEFAULT (getdate()),
[CREATED_BY] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[MODIFIED_DATE] [smalldatetime] NULL CONSTRAINT [DF_Enhancement_MODIFIED_DATE] DEFAULT (getdate()),
[MODIFIED_BY] [varchar] (50) COLLATE Latin1_General_CI_AS NULL,
[Title] [nvarchar] (255) COLLATE Latin1_General_CI_AS NOT NULL,
[BasicDescription] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[AdditionalNotes] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[SYS_ESTIMATE] [smallint] NOT NULL CONSTRAINT [DF_Enhancement_SYS_ESTIMATE] DEFAULT ((0)),
[SYS_FUNDER] [int] NULL,
[SYS_PRIORITY] [smallint] NOT NULL,
[SYS_STATUS] [smallint] NOT NULL,
[SYS_SOURCETYPE] [int] NULL,
[SourceDetail] [nvarchar] (150) COLLATE Latin1_General_CI_AS NULL,
[SRCH_Anywhere] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL,
[SRCH_Keyword] [nvarchar] (max) COLLATE Latin1_General_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[tr_Enhancement_SRCH] ON [dbo].[Enhancement] 
FOR INSERT, UPDATE AS

SET NOCOUNT ON

/* Update Name Index */
IF UPDATE(Title)
	OR UPDATE(BasicDescription)
	OR UPDATE(AdditionalNotes)
	OR UPDATE(SRCH_Keyword)
BEGIN
	UPDATE e
		SET SRCH_Anywhere = e.Title + ' ; ' + ISNULL(e.BasicDescription,'') + ' ; ' + ISNULL(e.AdditionalNotes,'') + ' ; ' + ISNULL(e.SRCH_Keyword,'')
	FROM 	Enhancement e
	INNER JOIN Inserted i
		ON e.ID=i.ID
END

SET NOCOUNT OFF
GO
ALTER TABLE [dbo].[Enhancement] ADD CONSTRAINT [PK_Enhancement] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Enhancement_IDSYSSTATUS] ON [dbo].[Enhancement] ([ID], [SYS_STATUS]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Enhancement] ADD CONSTRAINT [FK_Enhancement_Estimate] FOREIGN KEY ([SYS_ESTIMATE]) REFERENCES [dbo].[Estimate] ([ESTIMATE_ID]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Enhancement] ADD CONSTRAINT [FK_Enhancement_Funder] FOREIGN KEY ([SYS_FUNDER]) REFERENCES [dbo].[Funder] ([FUNDER_ID]) ON DELETE SET NULL ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Enhancement] ADD CONSTRAINT [FK_Enhancement_Priority] FOREIGN KEY ([SYS_PRIORITY]) REFERENCES [dbo].[Priority] ([PRIORITY_ID]) ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[Enhancement] ADD CONSTRAINT [FK_Enhancement_SourceType] FOREIGN KEY ([SYS_SOURCETYPE]) REFERENCES [dbo].[SourceType] ([SOURCE_ID])
GO
ALTER TABLE [dbo].[Enhancement] ADD CONSTRAINT [FK_Enhancement_Status] FOREIGN KEY ([SYS_STATUS]) REFERENCES [dbo].[Status] ([STATUS_ID]) ON UPDATE CASCADE
GO
GRANT SELECT ON  [dbo].[Enhancement] TO [web_user_role]
GO
CREATE FULLTEXT INDEX ON [dbo].[Enhancement] KEY INDEX [PK_Enhancement] ON [FTEnhancement]
GO
ALTER FULLTEXT INDEX ON [dbo].[Enhancement] ADD ([SRCH_Anywhere] LANGUAGE 1033)
GO
ALTER FULLTEXT INDEX ON [dbo].[Enhancement] ADD ([SRCH_Keyword] LANGUAGE 0)
GO
