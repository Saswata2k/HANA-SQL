DROP PROCEDURE SPLIT_TEST;

CREATE PROCEDURE SPLIT_TEST(TEXT nvarchar(100))

AS

BEGIN

  declare _items nvarchar(100) ARRAY;

  declare _text nvarchar(100);

  declare _index integer;

  _text := :TEXT;

  _index := 1;

  WHILE LOCATE(:_text,',') > 0 DO

  _items[:_index] := SUBSTR_BEFORE(:_text,',');

  _text := SUBSTR_AFTER(:_text,',');

  _index := :_index + 1;

  END WHILE;

  _items[:_index] := :_text;

  rst = UNNEST(:_items) AS ("items");

  SELECT * FROM :rst;

END;

CALL SPLIT_TEST('A,B,C,E,F')
