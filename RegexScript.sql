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
--
DROP PROCEDURE "SM_STE"."PROC_REGEX_CLEAN";
--
CREATE PROCEDURE "SM_STE"."PROC_REGEX_CLEAN"
LANGUAGE SQLSCRIPT AS
BEGIN
	DECLARE REG_EXP varchar(4999);
	DECLARE CURSOR CUR_REGEX FOR SELECT EXPRESSION FROM REGEX;
    FOR R1 AS CUR_REGEX DO 
    	UPDATE "SM_STE"."PEQP_DATA_SCRUB" SET "Textlog Details" =REPLACE_REGEXPR(:R1.EXPRESSION IN "Textlog Details"
    	WITH '' OCCURRENCE ALL) ;
    END FOR;
END;

call "SM_STE"."PROC_REGEX_CLEAN" ;


