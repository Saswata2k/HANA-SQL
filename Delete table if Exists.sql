               CREATE PROCEDURE "SM_STE"."PROC_CATG_INFERS"(IN DATA VARCHAR(4999),OUT FINAL_TABLE OUTPUT_T)
LANGUAGE SQLSCRIPT AS 
BEGIN
      DECLARE QUERY VARCHAR(4999);
      DECLARE QR VARCHAR(4999);
      DECLARE INSERT_QR VARCHAR(4999);
       DECLARE Created INTEGER;
       --Check for existing TEMP_TABLE and drop if it exists
                                           Created := 0;
                                           SELECT COUNT(*) INTO Created FROM tables WHERE
                                           SCHEMA_NAME ='SM_STE' AND
                                           TABLE_NAME='TEMP_TABLE' and IS_TEMPORARY = 'TRUE';
                                           IF (:Created > 0) THEN
                                             DROP TABLE "SM_STE"."TEMP_TABLE";
                                           END IF;
                                            --Temporary table to store data 
                                           CREATE GLOBAL TEMPORARY TABLE "SM_STE"."TEMP_TABLE" LIKE "SM_STE"."DATA_DEMO";
            INSERT_QR:='INSERT INTO "SM_STE"."TEMP_TABLE" VALUES (10,'''||:DATA||''')';
            EXEC INSERT_QR;
           DELETE FROM "SM_STE"."LDA_D_DOCTOPICDIST_PEQP_TEST_TBL" WHERE "DOCUMENTID" = '10';
            --INPUT PARAMETERS USING VARUABLES
            IP_TEMP_TBL=SELECT * FROM "SM_STE"."TEMP_TABLE";
            IP_PEQP_TRAIN=SELECT * FROM "SM_STE"."LDA_D_PARAMETERS_PEQP_TRAIN_TBL";
            IP_TOPIC_PEQP=SELECT * FROM "SM_STE"."LDA_D_TOPICWORDDIST_PEQP_TRAIN_TBL";
            IP_DICT_PEQP=SELECT * FROM "SM_STE"."LDA_D_DICTIONARY_PEQP_TRAIN_TBL";
            IP_GEN_INFO_PEQP=SELECT * FROM "SM_STE"."LDA_D_GENERALINFO_PEQP_TRAIN_TBL";
        --CALL THE PROCEDURE
       CALL SM_STE.PAL_LDAINFERENCE(:IP_TEMP_TBL, :IP_PEQP_TRAIN, :IP_TOPIC_PEQP,
       :IP_DICT_PEQP,:IP_GEN_INFO_PEQP ,:OUTPUT_TABLE) ;
       INSERT INTO "SM_STE"."LDA_D_DOCTOPICDIST_PEQP_TEST_TBL" SELECT * FROM :OUTPUT_TABLE;
       FINAL_TABLE= select  TOP 3 t1."DOCUMENTID",
                                   t1."TOPICID",
                                       t1."PROBABILITY",
                                       t2."FREQUENCY",
                                       t2."Category"
from "SM_STE"."LDA_D_DOCTOPICDIST_PEQP_TEST_TBL" as t1 INNER join "SM_STE"."LDA_D_MAP_PEQP_TBL" as t2 on t1."TOPICID" = t2."TOPICID" 
 GROUP BY   t2."Category" ,t1."PROBABILITY" ,t2."FREQUENCY",t1."DOCUMENTID",t1."TOPICID"
  having t1."DOCUMENTID" = '10'
ORDER BY t1. "PROBABILITY" DESC ,t2."FREQUENCY" DESC;
END;
