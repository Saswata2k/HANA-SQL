--* Data prep
-- clean up of scrub set 
DROP TABLE "SM_STE"."PEQP_DATA_SCRUB";
-- create scrub table 
CREATE COLUMN TABLE "SM_STE"."PEQP_DATA_SCRUB" LIKE "SM_STE"."PEQP_DATA";
--copy data from original table 
INSERT INTO "SM_STE"."PEQP_DATA_SCRUB"
select * from "SM_STE"."PEQP_DATA" ;

--------------------------------------------------------------------------------------------------------
--RegEx Table
drop table REGEX;
CREATE TABLE RegEx (ID INTEGER,TYPE VARCHAR(2),EXPRESSION VARCHAR(4999));
--values insert 
INSERT INTO REGEX VALUES(1,'SS','^^^');
INSERT INTO REGEX VALUES(2,'RG','C[1234567890][1234567890][1234567890][1234567890][1234567890][1234567890][1234567890]');
INSERT INTO REGEX VALUES(3,'RG','D[1234567890][1234567890][1234567890][1234567890][1234567890][1234567890]');
INSERT INTO REGEX VALUES(4,'RG','I[1234567890][1234567890][1234567890][1234567890][1234567890][1234567890]');
INSERT INTO REGEX VALUES(5,'RG','ITSM_BTC   Your ticket was automatically set to the next status defined for the respective ticket type (Service provided, Solution proposed,  Change implemented), because it has been on status Author action for more than 30 days.    If your issue still persists, please reopen the ticket using the respective reject button. We will review your response and  continue to work on your case upon receiving your reply.    Best regards, Your ITdirect Support');
INSERT INTO REGEX VALUES(6,'RG','Details [1234567890][1234567890].[1234567890][1234567890].[12][290][1234567890][1234567890]          [1234567890][1234567890]:[1234567890][1234567890]:[1234567890][1234567890]');
INSERT INTO REGEX VALUES(7,'SS','Best Regards,');
INSERT INTO REGEX VALUES(9,'SS','Regards,');
INSERT INTO REGEX VALUES(10,'SS','Thanks and best regards,');
INSERT INTO REGEX VALUES(11,'SS','Thanks and Best Regards,');
INSERT INTO REGEX VALUES(12,'SS','Hi');
INSERT INTO REGEX VALUES(13,'SS','Hello');
INSERT INTO REGEX VALUES(14,'SS','Hi,');
INSERT INTO REGEX VALUES(16,'RG','[1234567890][1234567890].[1234567890][1234567890].[12][290][1234567890][1234567890]          [1234567890][1234567890]:[1234567890][1234567890]:[1234567890][1234567890]');


SELECT * FROM REGEX;
------------------------------------------------------------------------------------------------------------
--Procedure to clear data using regex table records
DROP PROCEDURE "SM_STE"."PROC_REGEX_CLEAN";
--Create Statement
CREATE PROCEDURE "SM_STE"."PROC_REGEX_CLEAN"
LANGUAGE SQLSCRIPT AS
BEGIN	
	DECLARE CURSOR CUR_SUBSTR FOR SELECT EXPRESSION FROM REGEX WHERE TYPE='SS';
	DECLARE CURSOR CUR_REGEX FOR SELECT EXPRESSION FROM REGEX WHERE TYPE='RG';
    FOR S1 AS CUR_SUBSTR DO 
    	UPDATE "SM_STE"."PEQP_DATA_SCRUB" SET "Textlog Details" =REPLACE_REGEXPR(:S1.EXPRESSION IN "Textlog Details"
    	WITH '' OCCURRENCE ALL) ;
    END FOR;
    FOR R1 AS CUR_REGEX DO 
    	UPDATE "SM_STE"."PEQP_DATA_SCRUB" SET "Textlog Details" =REPLACE_REGEXPR(:R1.EXPRESSION IN "Textlog Details"
    	WITH '' OCCURRENCE ALL) ;
    END FOR;
END;
--Call Procedure
call "SM_STE"."PROC_REGEX_CLEAN" ;

--Table with Source/Target strings
DROP TABLE "SM_STE"."TAB_STRINGS";
CREATE TABLE "SM_STE"."TAB_STRINGS"(ID INTEGER,SOURCE VARCHAR(4999),TARGET VARCHAR(4999));
INSERT INTO "SM_STE"."TAB_STRINGS" VALUES(1,'CTS','COGNIZANT');
INSERT INTO "SM_STE"."TAB_STRINGS" VALUES(2,'TATA CONSULTANCY SERVICES','TCS');
SELECT * FROM "SM_STE"."TAB_STRINGS";

--Procedure for altering strings
DROP PROCEDURE "SM_STE"."PROC_ALTER_STRINGS";
CREATE PROCEDURE "SM_STE"."PROC_ALTER_STRINGS"(IN TABLENAME VARCHAR(4999),IN COLUMNNAME VARCHAR(4999)
,IN FLAG VARCHAR(2))
LANGUAGE SQLSCRIPT AS
BEGIN
	--check whether the incoming flag is 'RT'/'T'
	IF :FLAG='RT'
	THEN
    	  DECLARE CURSOR CUR_STRING FOR SELECT * FROM TAB_STRINGS;
	  FOR C1 AS CUR_STRING DO 
	  --Create a temporary string and store the dynamic SQL inside temp 
	  DECLARE TEMP_RT VARCHAR(1000);
	  TEMP_RT:='UPDATE '||:TABLENAME||' SET '||:COLUMNNAME||
		' = REPLACE('||:COLUMNNAME||' , '''||:C1.SOURCE||''' , '''||:C1.TARGET||''')';
	  --Execute the temporary variable
  	  EXEC TEMP_RT;
  	  END FOR;
	ELSE
	  DECLARE CURSOR CUR_STRING FOR SELECT SOURCE,TARGET FROM TAB_STRINGS;
	  FOR C1 AS CUR_STRING DO 
	  --Create a temporary string and store the dynamic SQL inside temp 
	  DECLARE TEMP_T VARCHAR(1000);
	  TEMP_T:='UPDATE '||:TABLENAME||' SET '||:COLUMNNAME||
	  ' = REPLACE('||:COLUMNNAME||' , '''||:C1.TARGET||''' , '''||:C1.SOURCE||''')';
  	  EXEC TEMP_T;
	  END FOR;
	END IF;
END;
CALL "SM_STE"."PROC_ALTER_STRINGS"( 'PEQP_DATA_SCRUB','Textlog Details','RT');

----------------------------------------------------------
--Special characters should not be inserted inside the regex table as it will cause the procedure to fail
--Use this procedure instead
CALL "SM_STE"."PROC_CHARACTER_REPLACE"('^','');
--Replace Procedure
DROP PROCEDURE "SM_STE"."PROC_CHARACTER_REPLACE";
CREATE PROCEDURE "SM_STE"."PROC_CHARACTER_REPLACE"(IN NEWSTR VARCHAR(4999),IN OLDSTR VARCHAR(4999))
LANGUAGE SQLSCRIPT AS
BEGIN
	UPDATE "SM_STE"."PEQP_DATA_SCRUB" SET "Textlog Details" =REPLACE("Textlog Details",NEWSTR,OLDSTR);
END;




