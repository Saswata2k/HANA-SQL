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
--Procedure to clear data using regex table records both RegEx & Strings
CALL "SM_STE"."PROC_REGEX_CLEAN"('PEQP_DATA_SCRUB','Textlog Details','RG');
DROP PROCEDURE "SM_STE"."PROC_REGEX_CLEAN";
--Create Statement for the procedure
--Input parameters: TableName,ColumnName and a flag which determines whether to filter data 
--with substring replacement/regex replacement or both
CREATE PROCEDURE "SM_STE"."PROC_REGEX_CLEAN"(IN TABLENAME VARCHAR(4999),IN COLUMNNAME VARCHAR(4999),
					     IN FLAG VARCHAR(2))
LANGUAGE SQLSCRIPT AS
BEGIN
   --Declare two different cursors for both substring and regex types
   DECLARE CURSOR CUR_SUBSTR FOR SELECT EXPRESSION FROM REGEX WHERE TYPE='SS';
   DECLARE CURSOR CUR_REGEX FOR SELECT EXPRESSION FROM REGEX WHERE TYPE='RG';
   --Declare two different temporary variables to store the dynamic SQL
   DECLARE TEMP_SS varchar(1000);	
   DECLARE TEMP_RG varchar(1000);	
   --Declare an empty string in such a way so that it won't affect the dynamic SQL (Simple '' not working)
   DECLARE REPLACESTR VARCHAR(6):='''''';	
   --If the incoming flag is of type substring it will execute the substring replace 
   IF :FLAG='SS'
   THEN
    FOR S1 AS CUR_SUBSTR DO 
        --Store the dynamic SQL in temporary variable TEMP_SS
	TEMP_SS:='UPDATE '||:TABLENAME||' SET '||:COLUMNNAME||' =REPLACE( '
	||:COLUMNNAME||','''||:S1.EXPRESSION||''' ,'||:REPLACESTR||')';  
    EXEC TEMP_SS;
    END FOR;
   --If the incoming flag is of type regex it will execute the regex replace 
   ELSEIF FLAG='RG'
   THEN
    FOR R1 AS CUR_REGEX DO 
        --Store the dynamic SQL in temporary variable TEMP_RG
    	TEMP_RG:='UPDATE '||:TABLENAME||' SET '||:COLUMNNAME||'=REPLACE_REGEXPR('''
    	||:R1.EXPRESSION|| ''' IN '||:COLUMNNAME||' WITH '||:REPLACESTR||' OCCURRENCE ALL)';
    	EXEC TEMP_RG;
    END FOR;
  ELSE
   --If the incoming flag is empty or any other character , it will execute both the substrings and regex replace methods
    FOR S1 AS CUR_SUBSTR DO 
	TEMP_SS:='UPDATE '||:TABLENAME||' SET '||:COLUMNNAME||' =REPLACE( '
	||:COLUMNNAME||','''||:S1.EXPRESSION||''' ,'||:REPLACESTR||')';  
    	EXEC TEMP_SS;
    END FOR;
    FOR R1 AS CUR_REGEX DO 
    	TEMP_RG:='UPDATE '||:TABLENAME||' SET '||:COLUMNNAME||'=REPLACE_REGEXPR('''
    	||:R1.EXPRESSION|| ''' IN '||:COLUMNNAME||' WITH '||:REPLACESTR||' OCCURRENCE ALL)';
    	EXEC TEMP_RG;
    END FOR;    
  END IF;
END;
-------------------------------------------------

--Table with Source/Target strings
DROP TABLE "SM_STE"."TAB_STRINGS";
CREATE TABLE "SM_STE"."TAB_STRINGS"(ID INTEGER,SOURCE VARCHAR(4999),TARGET VARCHAR(4999));
INSERT INTO "SM_STE"."TAB_STRINGS" VALUES(1,'CTS','COGNIZANT');
INSERT INTO "SM_STE"."TAB_STRINGS" VALUES(2,'TATA CONSULTANCY SERVICES','TCS');
SELECT * FROM "SM_STE"."TAB_STRINGS";

--Procedure for altering strings
DROP PROCEDURE "SM_STE"."PROC_ALTER_STRINGS";
--Create procedure statement 
--Input parameters: TableName,ColumnName and a flag which states whether to replace occurrence of target strings
--with source strings or vice versa
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
