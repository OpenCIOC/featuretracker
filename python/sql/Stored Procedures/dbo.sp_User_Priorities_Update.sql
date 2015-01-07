SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_User_Priorities_Update]
	@UserEmail [varchar](60),
	@Data [xml],
	@ErrMsg [nvarchar](500) OUTPUT
WITH EXECUTE AS CALLER
AS
SET NOCOUNT ON

/*
	Checked for Release: 1.1
	Checked by: KL
	Checked on: 23-Jul-2012
	Action: NO ACTION REQUIRED
*/

DECLARE @USER_ID int
SELECT @USER_ID=u.[USER_ID] FROM UserAccount u WHERE u.Email=@UserEmail

IF @USER_ID IS NULL BEGIN
	SET @ErrMsg = 'No user'
	RETURN 1
END

DECLARE @PrioritiesTable TABLE (
	PRIORITY_ID int NULL
)

DECLARE @EnhancementPriorityTable TABLE (
	PRIORITY_ID int NULL,
	ENHANCEMENT_ID int NULL, 
	InPriorityOrder smallint NULL
)

INSERT INTO @PrioritiesTable
SELECT DISTINCT N.value('@id', 'int') AS PRIORITY_ID
FROM @Data.nodes('//priority') AS T(N)

INSERT INTO @EnhancementPriorityTable
SELECT N.value('@id', 'int') AS PRIORITY_ID,
	iq.*
FROM @Data.nodes('//priority') as T(N) CROSS APPLY 
	( SELECT 
		D.value('@id', 'int') AS ENHANCEMENT_ID,
		D.value('@cnt', 'smallint') AS InPriorityOrder
			FROM N.nodes('enh') AS T2(D) ) iq 


DELETE p FROM @PrioritiesTable p
WHERE PRIORITY_ID IS NULL OR NOT EXISTS(SELECT * FROM Priority WHERE p.PRIORITY_ID=PRIORITY_ID)

DELETE e FROM @EnhancementPriorityTable e
WHERE (PRIORITY_ID IS NULL
	OR ENHANCEMENT_ID IS NULL 
	OR NOT EXISTS(SELECT * FROM Enhancement WHERE e.ENHANCEMENT_ID=ENHANCEMENT_ID)
	OR NOT EXISTS(SELECT * FROM @PrioritiesTable WHERE e.PRIORITY_ID=PRIORITY_ID)
	)
	
MERGE INTO UserEnhancementPriority dst
USING @EnhancementPriorityTable src
	ON dst.[USER_ID]=@USER_ID AND dst.ENHANCEMENT_ID=src.ENHANCEMENT_ID 
WHEN MATCHED THEN
	UPDATE SET PRIORITY_ID=src.PRIORITY_ID, InPriorityOrder=src.InPriorityOrder
	
WHEN NOT MATCHED BY TARGET THEN
	INSERT ([USER_ID], ENHANCEMENT_ID, PRIORITY_ID, InPriorityOrder) 
		VALUES (@USER_ID, src.ENHANCEMENT_ID, src.PRIORITY_ID, src.InPriorityOrder)
	
WHEN NOT MATCHED BY SOURCE
		AND dst.[USER_ID]=@USER_ID
		AND EXISTS(SELECT * FROM @PrioritiesTable WHERE PRIORITY_ID=dst.PRIORITY_ID)
		AND NOT EXISTS(SELECT * FROM Enhancement e WHERE ID=dst.ENHANCEMENT_ID AND e.SYS_STATUS IN (SELECT STATUS_ID FROM [Status] WHERE CanRank=0))
			THEN
	DELETE
	;

SET NOCOUNT OFF
GO
GRANT EXECUTE ON  [dbo].[sp_User_Priorities_Update] TO [web_user_role]
GO
