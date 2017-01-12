
SELECT * FROM "SIA_ROLE_MAINT2"."T_PEQP_ZINC" WHERE CATEGORY NOT LIKE 'IMIS_PEQP_NOTEB';
DROP TABLE "SIA_ROLE_MAINT2"."T_PEQP_ZINC";
--Join table
CREATE COLUMN TABLE "SIA_ROLE_MAINT2"."T_PEQP_ZINC"("ID" NVARCHAR(100),"TEXT" NVARCHAR(2000),"CATEGORY" NVARCHAR(100),
													PRIMARY KEY ("ID"));
INSERT INTO "SIA_ROLE_MAINT2"."T_PEQP_ZINC"("ID", "TEXT", "CATEGORY")
SELECT "OBJECT_GUID","TEXT","SIA_ROLE_MAINT2"."T_ZINC_DESCRIPTION"."CATEGORY_ID"  from "SIA_ROLE_MAINT2"."T_PEQP_D" INNER
JOIN "SIA_ROLE_MAINT2"."T_ZINC_DESCRIPTION" ON 
"SIA_ROLE_MAINT2"."T_ZINC_DESCRIPTION"."OBJECT_GUID"="SIA_ROLE_MAINT2"."T_PEQP_D"."ID";
  
  select * from #IMIS_PEQP_MOBIL_ANDRD;
  SELECT * FROM #AB;
 drop table #IMIS_PEQP_NOTEB;
 --Procedure for splitting categories
 CALL "SIA_ROLE_MAINT2"."PROC_SPLIT_CATEGORY"('IMIS_PEQP_NOTEB,IMIS_PEQP_MOBIL_ANDRD,');
 DROP PROCEDURE "SIA_ROLE_MAINT2"."PROC_SPLIT_CATEGORY";
 CREATE PROCEDURE "SIA_ROLE_MAINT2"."PROC_SPLIT_CATEGORY"(IN CAT_DATA VARCHAR(4999))
 LANGUAGE SQLSCRIPT AS
 BEGIN
		DECLARE _TEXT NVARCHAR(100);
		DECLARE SPLITTED VARCHAR(4999);
		DECLARE CREATE_QR VARCHAR(4999);
		DECLARE INSERT_QR VARCHAR(4999);
		DECLARE INDEX INTEGER;
		_TEXT := :CAT_DATA;
		INDEX := 1;
		WHILE LOCATE(:_TEXT,',') > 0 DO
		SPLITTED:= SUBSTR_BEFORE(:_TEXT,',');
		CREATE_QR:='CREATE LOCAL TEMPORARY TABLE #'||:SPLITTED||'(ID NVARCHAR(500),TEXT NVARCHAR(500))';
    	EXEC CREATE_QR;
    	INSERT_QR:='INSERT INTO #'||:SPLITTED||' SELECT "ID","TEXT" FROM "SIA_ROLE_MAINT2"."T_PEQP_ZINC" 
    	    	    	    	    	WHERE "CATEGORY"='''||:SPLITTED||''';';
		_TEXT := SUBSTR_AFTER(:_TEXT,',');
		EXEC INSERT_QR;
		INDEX := :INDEX + 1;
		END WHILE;	
 END;
