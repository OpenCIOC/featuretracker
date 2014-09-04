SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[sp_Enhancement_Update]
	@ID int OUTPUT,
	@MODIFIED_BY varchar(50),
	@Title nvarchar(255),
	@BasicDescription nvarchar(max),
	@AdditionalNotes nvarchar(max),
	@SYS_ESTIMATE int,
	@SYS_FUNDER int,
	@SYS_PRIORITY int,
	@SYS_STATUS int,
	@SYS_SOURCETYPE int,
	@SourceDetail nvarchar(150),
	@ModuleIDList varchar(max),
	@KeywordIDList varchar(max),
	@ReleaseIDList varchar(max),
	@SeeAlsoIDList varchar(max),
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 1.1
	Checked by: KL
	Checked on: 23-Jul-2012
	Action: IN PROGRESS
*/

DECLARE @Error int
SET @Error = 0

IF @ID IS NOT NULL AND NOT EXISTS(SELECT * FROM Enhancement WHERE ID=@ID) BEGIN
	SET @ErrMsg = 'Unknown Enhancement.'
END ELSE IF @Title IS NULL BEGIN
	SET @ErrMsg = 'Title is a required field.'
END ELSE IF EXISTS(SELECT * FROM Enhancement WHERE Title=@Title AND (@ID IS NULL OR ID<>@ID)) BEGIN
	SET @ErrMsg = 'Title is already in use.'
END ELSE IF @SYS_ESTIMATE IS NULL BEGIN
	SET @ErrMsg = 'Estimate is a required field.'
END ELSE IF NOT EXISTS(SELECT * FROM Estimate WHERE ESTIMATE_ID=@SYS_ESTIMATE) BEGIN
	SET @ErrMsg = 'Unknown Estimate type.'
END ELSE IF @SYS_FUNDER IS NOT NULL AND NOT EXISTS(SELECT * FROM Funder WHERE FUNDER_ID=@SYS_FUNDER) BEGIN
	SET @ErrMsg = 'Unknown Funder type.'
END ELSE IF @SYS_PRIORITY IS NULL BEGIN
	SET @ErrMsg = 'Priority is a required field.'
END ELSE IF NOT EXISTS(SELECT * FROM Priority WHERE PRIORITY_ID=@SYS_PRIORITY) BEGIN
	SET @ErrMsg = 'Unknown Priority type.'
END ELSE BEGIN
	IF @ID IS NOT NULL BEGIN
		UPDATE Enhancement SET
			MODIFIED_BY			= @MODIFIED_BY,
			MODIFIED_DATE		= GETDATE(),
			Title				= @Title,
			BasicDescription	= @BasicDescription,
			AdditionalNotes		= @AdditionalNotes,
			SYS_ESTIMATE		= @SYS_ESTIMATE,
			SYS_FUNDER			= @SYS_FUNDER,
			SYS_PRIORITY		= @SYS_PRIORITY,
			SYS_STATUS			= @SYS_STATUS,
			SYS_SOURCETYPE		= @SYS_SOURCETYPE,
			SourceDetail		= @SourceDetail
		WHERE ID=@ID
		
	END ELSE BEGIN
		INSERT INTO Enhancement (
			CREATED_BY,
			CREATED_DATE,
			MODIFIED_BY,
			MODIFIED_DATE,
			Title,
			BasicDescription,
			AdditionalNotes,
			SYS_ESTIMATE,
			SYS_FUNDER,
			SYS_PRIORITY,
			SYS_STATUS,
			SYS_SOURCETYPE,
			SourceDetail
		) VALUES (
			@MODIFIED_BY,
			GETDATE(),
			@MODIFIED_BY,
			GETDATE(),
			@Title,
			@BasicDescription,
			@AdditionalNotes,
			@SYS_ESTIMATE,
			@SYS_FUNDER,
			@SYS_PRIORITY,
			@SYS_STATUS,
			@SYS_SOURCETYPE,
			@SourceDetail
		)
		
		SET @ID = SCOPE_IDENTITY()
	END
	
	IF @ID IS NOT NULL BEGIN
		MERGE INTO EnhancementKeyword dst
		USING (SELECT DISTINCT k.KEYWORD_ID 
				FROM Keyword k 
				INNER JOIN dbo.fn_ParseIntIDList(@KeywordIDList, ',') i
					ON k.KEYWORD_ID=i.ItemID) src
		ON dst.ENHANCEMENT_ID=@ID AND dst.KEYWORD_ID=src.KEYWORD_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ENHANCEMENT_ID, KEYWORD_ID)
				VALUES (@ID, src.KEYWORD_ID)
		WHEN NOT MATCHED BY SOURCE AND dst.ENHANCEMENT_ID=@ID THEN
			DELETE
			
			;
			
		MERGE INTO EnhancementModule dst
		USING (SELECT DISTINCT m.MODULE_ID
				FROM Module m 
				INNER JOIN dbo.fn_ParseVarCharIDList(@ModuleIDList, ',') i
					ON m.MODULE_ID=i.ItemID) src
		ON dst.ENHANCEMENT_ID=@ID AND dst.MODULE_ID=src.MODULE_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ENHANCEMENT_ID, MODULE_ID)
				VALUES (@ID, src.MODULE_ID)
		WHEN NOT MATCHED BY SOURCE AND dst.ENHANCEMENT_ID=@ID THEN
			DELETE
			
			;
			
		MERGE INTO EnhancementRelease dst
		USING (SELECT DISTINCT r.RELEASE_ID 
				FROM Release r 
				INNER JOIN dbo.fn_ParseIntIDList(@ReleaseIDList, ',') i
					ON r.RELEASE_ID=i.ItemID) src
		ON dst.ENHANCEMENT_ID=@ID AND dst.RELEASE_ID=src.RELEASE_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ENHANCEMENT_ID, RELEASE_ID)
				VALUES (@ID, src.RELEASE_ID)
		WHEN NOT MATCHED BY SOURCE AND dst.ENHANCEMENT_ID=@ID THEN
			DELETE
			
			;
			
		MERGE INTO EnhancementSeeAlso dst
		USING (SELECT DISTINCT e.ID AS SEE_ALSO_ID
				FROM Enhancement e 
				INNER JOIN dbo.fn_ParseIntIDList(@SeeAlsoIDList, ',') i
					ON e.ID=i.ItemID
					WHERE e.ID<>@ID) src
		ON dst.ENHANCEMENT_ID=@ID AND dst.SEE_ALSO_ID=src.SEE_ALSO_ID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ENHANCEMENT_ID, SEE_ALSO_ID)
				VALUES (@ID, src.SEE_ALSO_ID)
		WHEN NOT MATCHED BY SOURCE AND dst.ENHANCEMENT_ID=@ID THEN
			DELETE
			
			;
	END
END
	

RETURN @Error
SET NOCOUNT OFF


GO
GRANT EXECUTE ON  [dbo].[sp_Enhancement_Update] TO [web_user_role]
GO
