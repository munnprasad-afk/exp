DECLARE
  l_roles     OWA.VC_ARR;
  l_modules   OWA.VC_ARR;
  l_patterns  OWA.VC_ARR;


BEGIN

--uat
  ORDS.ENABLE_SCHEMA(
      p_enabled             => TRUE,
      p_schema              => 'EXPE_ATP_XXEXPD',
      p_url_mapping_type    => 'BASE_PATH',
      p_url_mapping_pattern => 'expe_atp_xxexpd',
      p_auto_rest_auth      => FALSE);    

  ORDS.DEFINE_MODULE(
      p_module_name    => 'xxexpd_brate_ui',
      p_base_path      => '/xxexpd_brate_ui/',
      p_items_per_page =>  25,
      p_status         => 'PUBLISHED',
      p_comments       => NULL);      


	ORDS.DEFINE_TEMPLATE(
    p_module_name => 'xxexpd_brate_ui',
    p_pattern     => 'GljeOutputString'
  );
    ORDS.DEFINE_HANDLER(
    p_module_name => 'xxexpd_brate_ui',
    p_pattern     => 'GljeOutputString',
    p_method      => 'GET',
    p_source_type => ORDS.source_type_collection_feed,
	p_items_per_page => 25,
    p_source      => q'[
	SELECT distinct
                          SEGMENT1||'.'||SEGMENT2||'.'||SEGMENT3||'.'||SEGMENT4||'.'||SEGMENT5||'.'||SEGMENT6||'.'||SEGMENT7||'.'||SEGMENT8 AS "JE_OUTPUT_STRING" 
                        FROM 
                          gl_code_combinations
	
				   ]'
  );

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'addApproval',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'addApproval',
      p_method         => 'POST',
      p_source_type    => 'plsql/block',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
    DECLARE
      l_rows NUMBER;
    BEGIN
      INSERT INTO XXEXPD_BRATE_APPROVAL_STG_T (
          orig_system_name
         ,transaction_id
         ,client_name
         ,source_name
         ,transaction_number
         ,transaction_description
         ,transaction_type
         ,transaction_date
         ,requestor_name
         ,approver_email
         ,transaction_status
         ,wf_item_type
         ,creation_date
         ,created_by
         ,line_id
         ,stmt_from_date
		 ,bank_name
         ,bank_account_name
         ,currency_code
         ,last_four_bank_acct_num
         ,line_number
         ,trx_amt

      ) VALUES (

          ''BRATE''
         ,:transaction_id
         ,''ExpediaGroup''
         ,''BrateUI''
         ,:transaction_number
         ,:transaction_description
         ,''DistApproval''
         ,SYSDATE
         ,:requestor_name
         ,'' ''
         ,''NEW''
         ,''XXDSTAPR''
         ,SYSDATE
         ,:created_by
         ,:line_id
         ,:stmt_from_date
		 ,:bank_name
         ,:bank_account_name
         ,:currency_code
         ,:last_four_bank_acct_num
         ,:line_number
         ,:trx_amt


      );

      l_rows := SQL%ROWCOUNT;
      COMMIT;

      IF l_rows = 0 THEN
        :status  := 400;
        :message := ''Insert failed — no rows inserted.'';
      ELSE
        :status  := 201;
        :message := ''Approval inserted successfully.'';
      END IF;

      :rows_inserted := l_rows;
    END;
  '
      );
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addApproval',
      p_method             => 'POST',
      p_name               => 'X-ORDS-STATUS-CODE',
      p_bind_variable_name => 'status',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);      
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addApproval',
      p_method             => 'POST',
      p_name               => 'message',
      p_bind_variable_name => 'message',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);      
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addApproval',
      p_method             => 'POST',
      p_name               => 'rows_inserted',
      p_bind_variable_name => 'rows_inserted',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);   

/*
	  
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'addDistributions',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'addDistributions',
      p_method         => 'POST',
      p_source_type    => 'plsql/block',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
    DECLARE
      l_rows NUMBER;
    BEGIN
      INSERT INTO xxexpd_ce_brt_camt53_dist_w (
        line_id,
        je_output_string,
        distribution_amt,
        status,
        creation_date,
        created_by,
        journal_description
      ) VALUES (
        :line_id,
        :je_output_string,
        :distribution_amt,
        ''W'',
        SYSDATE,
        :created_by,
        :journal_description
      );

      l_rows := SQL%ROWCOUNT;
      COMMIT;

      IF l_rows = 0 THEN
        :status  := 400;
        :message := ''Insert failed — no rows inserted.'';
      ELSE
        :status  := 201;
        :message := ''Distribution inserted successfully.'';
      END IF;

      :rows_inserted := l_rows;
    END;
  '
      );
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addDistributions',
      p_method             => 'POST',
      p_name               => 'X-ORDS-STATUS-CODE',
      p_bind_variable_name => 'status',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);      
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addDistributions',
      p_method             => 'POST',
      p_name               => 'message',
      p_bind_variable_name => 'message',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);      
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addDistributions',
      p_method             => 'POST',
      p_name               => 'rows_inserted',
      p_bind_variable_name => 'rows_inserted',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);   


	  
	*/  
	  
	  
	    ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'addDistributions',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'addDistributions',
      p_method         => 'POST',
      p_source_type    => 'plsql/block',
      p_items_per_page => 25,
      p_mimes_allowed  => 'application/json',
      p_comments       => 'Bulk Insert using body_text for array inputs',
      p_source         => 
'
    DECLARE
      l_rows NUMBER := 0;
    BEGIN
      INSERT INTO xxexpd_ce_brt_camt53_dist_w (
        line_id,
        je_output_string,
        distribution_amt,
        status,
        creation_date,
        created_by,
        journal_description
      ) 
      SELECT 
        jt.line_id,
        jt.je_output_string,
        jt.distribution_amt,
        ''W'',
        SYSDATE,
        jt.created_by,
        jt.journal_description
      FROM JSON_TABLE(:body_text, ''$[*]''
        COLUMNS (
          line_id             NUMBER         PATH ''$.line_id'',
          je_output_string    VARCHAR2(4000) PATH ''$.je_output_string'',
          distribution_amt    NUMBER         PATH ''$.distribution_amt'',
          created_by          VARCHAR2(255)  PATH ''$.created_by'',
          journal_description VARCHAR2(4000) PATH ''$.journal_description''
        )
      ) jt;

      l_rows := SQL%ROWCOUNT;
      COMMIT;

      :status        := 201;
      :message       := l_rows || '' rows inserted successfully.'';
      :rows_inserted := l_rows;

    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        :status        := 400; 
        :message       := ''Database Error: '' || SQLERRM;
        :rows_inserted := 0;
    END;
'
  );

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addDistributions',
      p_method             => 'POST',
      p_name               => 'X-ORDS-STATUS-CODE',
      p_bind_variable_name => 'status',
      p_source_type        => 'HEADER',
      p_param_type         => 'INT',
      p_access_method      => 'OUT',
      p_comments           => NULL);      

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addDistributions',
      p_method             => 'POST',
      p_name               => 'message',
      p_bind_variable_name => 'message',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);      

  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addDistributions',
      p_method             => 'POST',
      p_name               => 'rows_inserted',
      p_bind_variable_name => 'rows_inserted',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);   


	  
	  
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'addDocuments',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'addDocuments',
      p_method         => 'POST',
      p_source_type    => 'plsql/block',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
      DECLARE
        l_rows       NUMBER;
        l_blob       BLOB;
        l_clob       CLOB     := :document;
        l_chunk      VARCHAR2(32767);
        l_raw        RAW(32767);
        l_offset     INTEGER  := 1;
        l_chunk_size INTEGER  := 32700;
        l_clob_len   INTEGER;
      BEGIN
        DBMS_LOB.createtemporary(l_blob, TRUE);
        l_clob_len := DBMS_LOB.getlength(l_clob);

        WHILE l_offset <= l_clob_len LOOP
          l_chunk  := DBMS_LOB.substr(l_clob, l_chunk_size, l_offset);
          l_raw    := UTL_ENCODE.base64_decode(UTL_RAW.cast_to_raw(l_chunk));
          DBMS_LOB.writeappend(l_blob, UTL_RAW.length(l_raw), l_raw);
          l_offset := l_offset + l_chunk_size;
        END LOOP;

        INSERT INTO xxexpd_ce_brt_camt53_docs_w (
          line_id,
          document,
          status,
          creation_date,
          created_by,
          file_name
        ) VALUES (
          :line_id,
          l_blob,
          ''W'',
          SYSDATE,
          :created_by,
          :file_name
        );

        l_rows := SQL%ROWCOUNT;
        COMMIT;

        DBMS_LOB.freetemporary(l_blob);

        IF l_rows = 0 THEN
          :status  := 400;
          :message := ''Insert failed — no rows inserted.'';
        ELSE
          :status  := 201;
          :message := ''Document inserted successfully.'';
        END IF;

        :rows_inserted := l_rows;

		EXCEPTION
        WHEN OTHERS THEN
	       :status  := 500;
           :message := ''Internal Error: '' || SQLERRM;
           :rows_inserted := 0;


      END;
    '
      );
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addDocuments',
      p_method             => 'POST',
      p_name               => 'X-ORDS-STATUS-CODE',
      p_bind_variable_name => 'status',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);      
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addDocuments',
      p_method             => 'POST',
      p_name               => 'message',
      p_bind_variable_name => 'message',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);      
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addDocuments',
      p_method             => 'POST',
      p_name               => 'rows_inserted',
      p_bind_variable_name => 'rows_inserted',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);      
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'addJeRevAudit',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'addJeRevAudit',
      p_method         => 'POST',
      p_source_type    => 'plsql/block',
      p_items_per_page =>  0,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
      DECLARE
        l_rows NUMBER;
      BEGIN
        INSERT INTO XXEXPD_CE_BRT_JE_REV_AUDIT_T (
           LINE_ID  
          ,REVERSAL_REASON
          ,STATUS
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
        ) VALUES (
           :line_id          -- Fixed: Removed leading stray comma from raw code
          ,:reversal_reason
          ,:status           -- DB table column bind
          ,SYSDATE
          ,:created_by
          ,SYSDATE
          ,:created_by
        );

        l_rows := SQL%ROWCOUNT;
        COMMIT;

        IF l_rows = 0 THEN
          :status_code := 400;   -- Renamed to avoid DB column conflict
          :message     := ''Insert failed — no rows inserted.'';
        ELSE
          :status_code := 201;   -- Renamed to avoid DB column conflict
          :message     := ''Approval inserted successfully.'';
        END IF;

        :rows_inserted := l_rows;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK;
          :status_code   := 500;
          :message       := ''Internal Server Error: '' || SQLERRM;
          :rows_inserted := 0;
      END;
    '
      );
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addJeRevAudit',
      p_method             => 'POST',
      p_name               => 'X-ORDS-STATUS-CODE',
      p_bind_variable_name => 'status_code',
      p_source_type        => 'HEADER',
      p_param_type         => 'INT',
      p_access_method      => 'OUT',
      p_comments           => NULL);      
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addJeRevAudit',
      p_method             => 'POST',
      p_name               => 'message',
      p_bind_variable_name => 'message',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);      
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addJeRevAudit',
      p_method             => 'POST',
      p_name               => 'rows_inserted',
      p_bind_variable_name => 'rows_inserted',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'INT',
      p_access_method      => 'OUT',
      p_comments           => NULL);      
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'addReversalDocuments',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'addReversalDocuments',
      p_method         => 'POST',
      p_source_type    => 'plsql/block',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
      DECLARE
        l_rows       NUMBER;
        l_blob       BLOB;
        l_clob       CLOB     := :document;
        l_chunk      VARCHAR2(32767);
        l_raw        RAW(32767);
        l_offset     INTEGER  := 1;
        l_chunk_size INTEGER  := 32700;
        l_clob_len   INTEGER;
      BEGIN
        DBMS_LOB.createtemporary(l_blob, TRUE);
        l_clob_len := DBMS_LOB.getlength(l_clob);

        WHILE l_offset <= l_clob_len LOOP
          l_chunk  := DBMS_LOB.substr(l_clob, l_chunk_size, l_offset);
          l_raw    := UTL_ENCODE.base64_decode(UTL_RAW.cast_to_raw(l_chunk));
          DBMS_LOB.writeappend(l_blob, UTL_RAW.length(l_raw), l_raw);
          l_offset := l_offset + l_chunk_size;
        END LOOP;

        INSERT INTO XXEXPD_CE_BRT_JE_REV_DOCS_T (
          line_id,
          document,
          status,
          creation_date,
          created_by,
          file_name
        ) VALUES (
          :line_id,
          l_blob,
          ''W'',
          SYSDATE,
          :created_by,
          :file_name
        );

        l_rows := SQL%ROWCOUNT;
        COMMIT;

        DBMS_LOB.freetemporary(l_blob);

        IF l_rows = 0 THEN
          :status  := 400;
          :message := ''Insert failed — no rows inserted.'';
        ELSE
          :status  := 201;
          :message := ''Document inserted successfully.'';
        END IF;

        :rows_inserted := l_rows;

		EXCEPTION
      WHEN OTHERS THEN
        :status  := 500;
        :message := ''Internal Error: '' || SQLERRM;
        :rows_inserted := 0;

      END;
    '
      );
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addReversalDocuments',
      p_method             => 'POST',
      p_name               => 'X-ORDS-STATUS-CODE',
      p_bind_variable_name => 'status',
      p_source_type        => 'HEADER',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);      
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addReversalDocuments',
      p_method             => 'POST',
      p_name               => 'message',
      p_bind_variable_name => 'message',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);      
  ORDS.DEFINE_PARAMETER(
      p_module_name        => 'xxexpd_brate_ui',
      p_pattern            => 'addReversalDocuments',
      p_method             => 'POST',
      p_name               => 'rows_inserted',
      p_bind_variable_name => 'rows_inserted',
      p_source_type        => 'RESPONSE',
      p_param_type         => 'STRING',
      p_access_method      => 'OUT',
      p_comments           => NULL);      
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'awaitingDistribution',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'awaitingDistribution',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
      SELECT DISTINCT
          AWAIT_DISTRIBUTION_ID,
          LINE_ID,
          JE_OUTPUT_STRING,
          DISTRIBUTION_AMT,
          STATUS,
		  JOURNAL_DESCRIPTION
      FROM XXEXPD_CE_BRT_CAMT53_DIST_W
      WHERE  LINE_ID = :line_id
      AND  STATUS IN  (''W'', ''S'')
      ORDER BY AWAIT_DISTRIBUTION_ID
    '
      );
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'bankAccountName',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'bankAccountName',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'SELECT DISTINCT BANK_ACCOUNT_NAME FROM CE_BANK_ACCOUNTS order by BANK_ACCOUNT_NAME'
      );
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'bankAccountNumber',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'bankAccountNumber',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'SELECT DISTINCT bank_account_num FROM xxexpd_ce_brt_camt53_hdr_t ORDER BY bank_account_num'
      );
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'bankName',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'bankName',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'select distinct tag as "BANK_NAME" from FND_Lookup_VALUES 
		WHERE 1=1
        and lookup_type = ''EXPD_BANK_SHORT_NAME''
        and LANGUAGE=''US''
        and ENABLED_FLAG=''Y''
        order by tag'
      );
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'classification',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'classification',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'select distinct description as "classification" from FND_Lookup_VALUES 
WHERE 1=1
and lookup_type = ''XXEXPD_CE_BRATE_ACT_KEY_VALUES''
and LANGUAGE=''US''
and ENABLED_FLAG=''Y''
and TAG = ''1''
order by Description'
      );
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'discardDistribution',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'discardDistribution',
      p_method         => 'DELETE',
      p_source_type    => 'plsql/block',
      p_items_per_page =>  0,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
      BEGIN
        DELETE FROM XXEXPD_CE_BRT_CAMT53_DIST_W
        WHERE LINE_ID = :line_id
        AND STATUS IN  (''W'', ''S'');

        COMMIT;
      END;
    '
      );
  -- ORDS.DEFINE_TEMPLATE(
      -- p_module_name    => 'xxexpd_brate_ui',
      -- p_pattern        => 'distributionData',
      -- p_priority       => 0,
      -- p_etag_type      => 'HASH',
      -- p_etag_query     => NULL,
      -- p_comments       => NULL);
  -- ORDS.DEFINE_HANDLER(
      -- p_module_name    => 'xxexpd_brate_ui',
      -- p_pattern        => 'distributionData',
      -- p_method         => 'GET',
      -- p_source_type    => 'json/collection',
      -- p_items_per_page =>  25,
      -- p_mimes_allowed  => '',
      -- p_comments       => NULL,
      -- p_source         => 
-- '
      -- SELECT DISTINCT
          -- DISTRIBUTION_ID,
          -- LINE_ID,
          -- RULE_GL_CCID,
          -- JE_OUTPUT_STRING,
          -- DISTRIBUTION_AMT,
          -- STATUS,
          -- CREATION_DATE,
          -- CREATED_BY,
          -- JOURNAL_DESCRIPTION,
          -- OFFSET_LEDGER_ID,
          -- OFFSET_DR_CCID,
          -- OFFSET_CR_CCID
      -- FROM XXEXPD_CE_BRT_CAMT53_DIST_T
      -- WHERE LINE_ID = :line_id and STATUS  IN (''Y'')
      -- ORDER BY DISTRIBUTION_ID
    -- '
      -- );
	  
	  
	    ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'distributionData',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);

  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'distributionData',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page => 25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
      SELECT DISTINCT
          dist.DISTRIBUTION_ID     as "DISTRIBUTION_ID",
          dist.LINE_ID             as "LINE_ID",
          dist.RULE_GL_CCID        as "RULE_GL_CCID",
          dist.JE_OUTPUT_STRING    as "JE_OUTPUT_STRING",
          dist.DISTRIBUTION_AMT    as "DISTRIBUTION_AMT",
          dist.STATUS              as "STATUS",
          dist.CREATION_DATE       as "CREATION_DATE",
          fnduser.user_name        as "CREATED_BY",
          dist.JOURNAL_DESCRIPTION as "JOURNAL_DESCRIPTION",
          gl.name                  as "OFFSET_LEDGER_ID",
          dist.OFFSET_DR_CCID      as "OFFSET_DR_CCID",
          dist.OFFSET_CR_CCID      as "OFFSET_CR_CCID"
      FROM 
          XXEXPD_CE_BRT_CAMT53_DIST_T dist,
          expe_atp_xxexpd.fnd_user    fnduser,
          expe_Atp_xxexpd.gl_ledgers  gl
      WHERE 1=1
        AND dist.CREATED_BY       = fnduser.user_id(+)
        AND dist.OFFSET_LEDGER_ID = gl.ledger_id(+)
        AND dist.LINE_ID          = :line_id
        AND dist.STATUS          IN (''Y'')
      ORDER BY dist.DISTRIBUTION_ID
'

  );
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'getDocument',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'getDocument',
      p_method         => 'GET',
      p_source_type    => 'json/query;type=single',
      p_items_per_page =>  0,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
      SELECT
          awaiting_doc_id,
          file_name,
          apex_web_service.blob2clobbase64(document) document_base64
      FROM xxexpd_ce_brt_camt53_docs_w
      WHERE awaiting_doc_id = :awaiting_doc_id
    '
      );
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'getDocument/:awaiting_doc_id',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'getDocument/:awaiting_doc_id',
      p_method         => 'GET',
      p_source_type    => 'json/query;type=single',
      p_items_per_page =>  0,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
      SELECT
          awaiting_doc_id,
          file_name,
          apex_web_service.blob2clobbase64(document) document_base64
      FROM xxexpd_ce_brt_camt53_docs_w
      WHERE awaiting_doc_id = :awaiting_doc_id
    '
      );
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'getReversalDocuments',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'getReversalDocuments',
      p_method         => 'GET',
      p_source_type    => 'json/query;type=single',
      p_items_per_page =>  0,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
      SELECT
          document_id,
          file_name,
          apex_web_service.blob2clobbase64(document) document_base64
      FROM XXEXPD_CE_BRT_JE_REV_DOCS_T
      WHERE document_id = :document_id
    '
      );
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'getTransactionId',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'getTransactionId',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
      select distinct LINE_ID||TO_CHAR(CREATION_DATE, ''YYYYMMDDHH24MISS'') as TransactionId
from XXEXPD_CE_BRT_CAMT53_DIST_W
where line_id= :line_id
    '
      );
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'glStatus',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'glStatus',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
      SELECT DISTINCT  
        CASE NVL(sent_to_gl, ''N'') 
          WHEN ''I'' THEN ''Enriched'' 
          WHEN ''Y'' THEN ''Journal Created'' 
          ELSE ''Not Enriched'' 
        END AS "STATUS" 
      FROM xxexpd_ce_brt_camt53_lines_t
    '
      );
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'hdr_data',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'hdr_data',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  0,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'SELECT * FROM XXEXPD_CE_BRT_CAMT53_HDR_T'
      );
	  
	  /*--------HDRLINEDATA---------*/  
	
	
	ORDS.DEFINE_TEMPLATE(
    p_module_name => 'xxexpd_brate_ui',
    p_pattern     => 'hdrlinedata'
  );
    ORDS.DEFINE_HANDLER(
    p_module_name => 'xxexpd_brate_ui',
    p_pattern     => 'hdrlinedata',
    p_method      => 'GET',
    p_source_type => ORDS.source_type_collection_feed,
	p_items_per_page => 25,
    p_source      => q'[
	   SELECT
	  BrateStmtHeaderEO.stmt_from_date
	 ,cba.bank_account_name
	 ,BrateStmtHeaderEO.bank_account_num
	 ,BrateStmtHeaderEO.account_currency_code 
	 ,BrateStmtLinesEO.entry_amt
	 ,BrateStmtLinesEO.Classification 
	 ,BrateStmtLinesEO.je_grouping 
	 ,NULL AS "Distributions"
	 ,BrateStmtLinesEO.je_reversal_status
     ,BrateStmtLinesEO.reversal_reason
	 ,NULL AS "Awaiting_Distributions"
	 ,BrateStmtLinesEO.entry_cr_db_ind  AS "Transaction_Type"
     ,BrateStmtLinesEO.entry_domain_code               
     ,BrateStmtLinesEO.entry_family_code                 
     ,BrateStmtLinesEO.entry_subfamily_code              
     ,BrateStmtLinesEO.entry_bai_code
     ,BrateStmtLinesEO.trx_acct_svcr_ref AS "Customer_Reference"
     ,BrateStmtLinesEO.trx_unstruct_remi_info AS "Description"	 
	 ,BrateStmtHeaderEO.statement_number
	 ,gll.name    AS "ledger_name"
     ,BrateStmtLinesEO.rule_def_id         
     ,BrateStmtLinesEO.classify_rule_name         
     ,BrateStmtLinesEO.classify_rule_version         
     ,BrateStmtLinesEO.je_rule_id         
     ,BrateStmtLinesEO.je_rule_name         
     ,BrateStmtLinesEO.je_rule_version 
     ,BrateStmtLinesEO.record_status_flag	 
	 ,gcc_cash.concatenated_segments AS "Cash_GL_Account"
     ,(select CASE NVL(segment8,'00000') WHEN '00000' THEN segment1 ELSE segment8 END cc from gl_code_combinations_kfv where code_combination_id = cba.asset_code_combination_id) AS "Company_Code" 
	 ,(select segment2 from gl_code_combinations_kfv where code_combination_id = cba.asset_code_combination_id) AS "GL_Account"	
	 ,NULL AS "Bank_Transfer"
	 ,NULL AS "Offset_Account_Number"
	 ,gll_off.name AS "Offset_Ledger_Name"
	 ,off_cr.concatenated_segments AS "Offset_cr_account" 
	 ,off_dr.concatenated_segments AS "Offset_dr_account"
	 ,BrateStmtHeaderEO.file_name
	 ,BrateStmtHeaderEO.error_message AS "hdr_message"
	 ,BrateStmtLinesEO.error_message AS "line_message" 
	 ,CASE NVL(BrateStmtLinesEO.sent_to_gl,'N') WHEN 'I' THEN 'Enriched' WHEN 'Y' THEN 'Journal Created' ELSE 'Not Enriched' END  AS "GL_Status" 
	 ,BrateStmtLinesEO.sent_to_ce
	 ,BrateStmtLinesEO.line_number
	 ,BrateStmtLinesEO.recon_status
	 ,NULL AS "Reconciliation_Reference"
     ,BrateStmtLinesEO.attribute13 AS "recon_amount"   
     ,BrateStmtLinesEO.attribute7 AS "exchange_currency"   
     ,BrateStmtLinesEO.exchange_rate_date   
     ,BrateStmtLinesEO.exchange_rate   
     ,BrateStmtLinesEO.attribute6 AS "exchange_amount" 
	 ,BrateStmtHeaderEO.control_begin_balance
	 ,BrateStmtHeaderEO.control_end_balance
	 ,BrateStmtHeaderEO.trx_cred_ent_no
	 ,BrateStmtHeaderEO.trx_deb_ent_no
	 ,BrateStmtLinesEO.manual_override	 
	 ,BrateStmtHeaderEO.header_id         
     ,BrateStmtHeaderEO.bank_name                                            	                    
     ,BrateStmtHeaderEO.trx_entry_no     	 
     ,BrateStmtLinesEO.line_id                                                                    
     ,BrateStmtLinesEO.trx_instr_id                                                                                          
     ,BrateStmtLinesEO.bank_trx_number       
	 ,BrateStmtLinesEO.transfer_flag         
     ,BrateStmtLinesEO.attribute15                     
     ,gcc_gl.concatenated_segments  gcc_gl                                                            
             
                         
    FROM xxexpd_ce_brt_camt53_hdr_t    BrateStmtHeaderEO,         
       xxexpd_ce_brt_camt53_lines_t  BrateStmtLinesEO,         
       gl_code_combinations_kfv      gcc_cash,         
       gl_code_combinations_kfv      gcc_gl,         
       gl_code_combinations_kfv      off_cr,         
       gl_code_combinations_kfv      off_dr,          
       ce_bank_accounts              cba,         
       gl_ledgers                    gll,         
       gl_ledgers               gll_off         
 WHERE     1 = 1    
   

AND BrateStmtLinesEO.bank_cash_ccid = gcc_cash.code_combination_id(+)         
AND BrateStmtLinesEO.rule_gl_ccid = gcc_gl.code_combination_id(+)         
AND BrateStmtLinesEO.offset_cr_ccid = off_cr.code_combination_id(+)         
AND BrateStmtLinesEO.offset_dr_ccid = off_dr.code_combination_id(+)               
AND BrateStmtHeaderEO.header_id = BrateStmtLinesEO.header_id(+)         
--AND BrateStmtHeaderEO.bank_account_num = cba.bank_account_num(+)     
AND BrateStmtHeaderEO.bank_account_id = cba.bank_account_id(+)     
AND BrateStmtLinesEO.bank_ledger_id=gll.ledger_id(+)         
AND BrateStmtLinesEO.offset_ledger_id=gll_off.ledger_id(+)
AND BrateStmtLinesEO.line_id is not null


AND (NULLIF(:p_bank_account_name_alt, 'undefined') IS NULL OR UPPER(cba.bank_account_name) LIKE '%' ||  UPPER(NULLIF(:p_bank_account_name_alt, 'undefined')) || '%')
AND (NULLIF(:p_bank_name, 'undefined') IS NULL OR :p_bank_name = 'ALL'  OR UPPER(BrateStmtHeaderEO.bank_name) LIKE '%' ||  UPPER(NULLIF(:p_bank_name, 'undefined'))   || '%')
AND (NULLIF(:p_amount_currency, 'undefined') IS NULL OR UPPER(BrateStmtHeaderEO.account_currency_code) LIKE '%' ||  UPPER(NULLIF(:p_amount_currency, 'undefined')) || '%')
AND (NULLIF(:p_classification, 'undefined') IS NULL OR UPPER(BrateStmtLinesEO.Classification) LIKE '%' ||  UPPER(NULLIF(:p_classification, 'undefined')) || '%')
AND (NULLIF(:p_classification_rule_name, 'undefined') IS NULL OR UPPER(BrateStmtLinesEO.classify_rule_name) LIKE '%' ||  UPPER(NULLIF(:p_classification_rule_name, 'undefined')) || '%')
AND (NULLIF(:p_exchange_currency, 'undefined') IS NULL OR UPPER(BrateStmtLinesEO.attribute7) LIKE '%' ||  UPPER(NULLIF(:p_exchange_currency, 'undefined')) || '%')
AND (NULLIF(:p_file_name, 'undefined') IS NULL OR UPPER(BrateStmtHeaderEO.file_name) LIKE '%' ||  UPPER(NULLIF(:p_file_name, 'undefined')) || '%')
AND (NULLIF(:p_gl_flag, 'undefined') IS NULL OR UPPER(BrateStmtLinesEO.sent_to_gl) LIKE '%' ||  UPPER(NULLIF(:p_gl_flag, 'undefined')) || '%')
AND (NULLIF(:p_header_message, 'undefined') IS NULL OR UPPER(BrateStmtHeaderEO.error_message) LIKE '%' ||  UPPER(NULLIF(:p_header_message, 'undefined')) || '%')
AND (NULLIF(:p_je_group, 'undefined') IS NULL OR UPPER(BrateStmtLinesEO.je_grouping) LIKE '%' ||  UPPER(NULLIF(:p_je_group, 'undefined')) || '%')
AND (NULLIF(:p_je_reversal_reason, 'undefined') IS NULL OR UPPER(BrateStmtLinesEO.reversal_reason) LIKE '%' ||  UPPER(NULLIF(:p_je_reversal_reason, 'undefined')) || '%')
AND (NULLIF(:p_je_reversal_status, 'undefined') IS NULL OR UPPER(BrateStmtLinesEO.je_reversal_status) LIKE '%' ||  UPPER(NULLIF(:p_je_reversal_status, 'undefined')) || '%')
AND (NULLIF(:p_journalization_rule_name, 'undefined') IS NULL OR UPPER(BrateStmtLinesEO.je_rule_name) LIKE '%' ||  UPPER(NULLIF(:p_journalization_rule_name, 'undefined')) || '%')
AND (NULLIF(:p_ledger_name, 'undefined') IS NULL OR UPPER(gll.name) LIKE '%' ||  UPPER(NULLIF(:p_ledger_name, 'undefined')) || '%')
AND (NULLIF(:p_line_message, 'undefined') IS NULL OR UPPER(BrateStmtLinesEO.error_message) LIKE '%' ||  UPPER(NULLIF(:p_line_message, 'undefined')) || '%')
AND (NULLIF(:p_offset_ledger, 'undefined') IS NULL OR UPPER(gll_off.name) LIKE '%' ||  UPPER(NULLIF(:p_offset_ledger, 'undefined')) || '%')
AND (NULLIF(:p_reconciliation_status, 'undefined') IS NULL OR UPPER(BrateStmtLinesEO.recon_status) LIKE '%' ||  UPPER(NULLIF(:p_reconciliation_status, 'undefined')) || '%')
AND (NULLIF(:p_transaction_type, 'undefined') IS NULL OR UPPER(BrateStmtLinesEO.entry_cr_db_ind) LIKE '%' ||  UPPER(NULLIF(:p_transaction_type, 'undefined')) || '%')
AND (NULLIF(:p_bank_account_num, 'undefined') IS NULL OR BrateStmtHeaderEO.bank_account_num = NULLIF(:p_bank_account_num, 'undefined'))
AND (NULLIF(:p_gl_status, 'undefined') IS NULL OR (CASE NVL(BrateStmtLinesEO.sent_to_gl,'N') WHEN 'I' THEN 'Enriched' WHEN 'Y' THEN 'Journal Created' ELSE 'Not Enriched' END) = NULLIF(:p_gl_status, 'undefined'))
AND (NULLIF(:p_bai_code, 'undefined') IS NULL OR BrateStmtLinesEO.entry_bai_code = NULLIF(:p_bai_code, 'undefined'))
AND (NULLIF(:p_cash_gl_account, 'undefined') IS NULL OR gcc_cash.concatenated_segments = NULLIF(:p_cash_gl_account, 'undefined'))
AND (NULLIF(:p_customer_reference, 'undefined') IS NULL OR BrateStmtLinesEO.trx_acct_svcr_ref = NULLIF(:p_customer_reference, 'undefined'))
AND (NULLIF(:p_description, 'undefined') IS NULL OR UPPER(BrateStmtLinesEO.trx_unstruct_remi_info) LIKE '%' || UPPER(NULLIF(:p_description, 'undefined')) || '%')
AND (NULLIF(:p_domain_code, 'undefined') IS NULL OR BrateStmtLinesEO.entry_domain_code = NULLIF(:p_domain_code, 'undefined'))
AND (NULLIF(:p_family_code, 'undefined') IS NULL OR BrateStmtLinesEO.entry_family_code = NULLIF(:p_family_code, 'undefined'))
AND (NULLIF(:p_manual_override, 'undefined') IS NULL OR BrateStmtLinesEO.manual_override = NULLIF(:p_manual_override, 'undefined'))
AND (NULLIF(:p_offset_ic_credit, 'undefined') IS NULL OR off_cr.concatenated_segments  = NULLIF(:p_offset_ic_credit, 'undefined')) 
AND (NULLIF(:p_offset_ic_debit, 'undefined') IS NULL OR off_dr.concatenated_segments = NULLIF(:p_offset_ic_debit, 'undefined'))
AND (NULLIF(:p_oracle_ce_transfer, 'undefined') IS NULL OR BrateStmtLinesEO.sent_to_ce = NULLIF(:p_oracle_ce_transfer, 'undefined'))
AND (NULLIF(:p_statement_number, 'undefined') IS NULL OR BrateStmtHeaderEO.statement_number = NULLIF(:p_statement_number, 'undefined'))
AND (NULLIF(:p_sub_family_code, 'undefined') IS NULL OR BrateStmtLinesEO.entry_subfamily_code = NULLIF(:p_sub_family_code, 'undefined'))
AND (NULLIF(:p_amount, 'undefined') IS NULL OR BrateStmtLinesEO.entry_amt = TO_NUMBER(NULLIF(:p_amount, 'undefined')))            
AND (NULLIF(:p_classification_rule_id, 'undefined') IS NULL OR BrateStmtLinesEO.rule_def_id = TO_NUMBER(NULLIF(:p_classification_rule_id, 'undefined')))
AND (NULLIF(:p_classification_rule_version, 'undefined') IS NULL OR BrateStmtLinesEO.classify_rule_version = TO_NUMBER(NULLIF(:p_classification_rule_version, 'undefined')))
AND (NULLIF(:p_closing_balance, 'undefined') IS NULL OR BrateStmtHeaderEO.control_end_balance = TO_NUMBER(NULLIF(:p_closing_balance, 'undefined')))
AND (NULLIF(:p_exchange_amount, 'undefined') IS NULL OR BrateStmtLinesEO.attribute13 = NULLIF(:p_exchange_amount, 'undefined'))
AND (NULLIF(:p_exchange_rate, 'undefined') IS NULL OR BrateStmtLinesEO.exchange_rate = TO_NUMBER(NULLIF(:p_exchange_rate, 'undefined')))
AND (NULLIF(:p_header_id, 'undefined') IS NULL OR BrateStmtHeaderEO.header_id = TO_NUMBER(NULLIF(:p_header_id, 'undefined')))
AND (NULLIF(:p_journalization_rule_id, 'undefined') IS NULL OR BrateStmtLinesEO.je_rule_id = TO_NUMBER(NULLIF(:p_journalization_rule_id, 'undefined')))
AND (NULLIF(:p_journalization_rule_version, 'undefined') IS NULL OR BrateStmtLinesEO.je_rule_version = TO_NUMBER(NULLIF(:p_journalization_rule_version, 'undefined')))
AND (NULLIF(:p_last_updated_by, 'undefined') IS NULL OR BrateStmtLinesEO.LAST_UPDATED_BY = TO_NUMBER(NULLIF(:p_last_updated_by, 'undefined')))
AND (NULLIF(:p_line_number, 'undefined') IS NULL OR BrateStmtLinesEO.line_number = TO_NUMBER(NULLIF(:p_line_number, 'undefined')))
AND (NULLIF(:p_line_id, 'undefined') IS NULL OR BrateStmtLinesEO.line_id = TO_NUMBER(NULLIF(:p_line_id, 'undefined')))
AND (NULLIF(:p_number_of_credit_entries, 'undefined') IS NULL OR BrateStmtHeaderEO.trx_cred_ent_no = TO_NUMBER(NULLIF(:p_number_of_credit_entries, 'undefined')))
AND (NULLIF(:p_number_of_debit_entries, 'undefined') IS NULL OR BrateStmtHeaderEO.trx_deb_ent_no = TO_NUMBER(NULLIF(:p_number_of_debit_entries, 'undefined')))
AND (NULLIF(:p_opening_balance, 'undefined') IS NULL OR BrateStmtHeaderEO.control_begin_balance = TO_NUMBER(NULLIF(:p_opening_balance, 'undefined')))
AND (NULLIF(:p_reconciled_amount, 'undefined') IS NULL OR BrateStmtLinesEO.attribute13 = NULLIF(:p_reconciled_amount, 'undefined'))
AND (NULLIF(:p_trx_entry_no, 'undefined') IS NULL OR BrateStmtHeaderEO.trx_entry_no = TO_NUMBER(NULLIF(:p_trx_entry_no, 'undefined')))
AND (NULLIF(:p_stmt_date_from, 'undefined') IS NULL OR BrateStmtHeaderEO.stmt_from_date >= TO_DATE(NULLIF(:p_stmt_date_from, 'undefined'), 'YYYY-MM-DD'))
AND (NULLIF(:p_stmt_date_to, 'undefined') IS NULL OR BrateStmtHeaderEO.stmt_from_date <= TO_DATE(NULLIF(:p_stmt_date_to, 'undefined'), 'YYYY-MM-DD'))  
AND (NULLIF(:p_exchange_rate_date, 'undefined') IS NULL OR BrateStmtLinesEO.exchange_rate_date = TO_DATE(NULLIF(:p_exchange_rate_date, 'undefined'), 'YYYY-MM-DD'))
AND (NULLIF(:p_last_update_date, 'undefined') IS NULL OR BrateStmtLinesEO.LAST_UPDATE_DATE = TO_DATE(NULLIF(:p_last_update_date, 'undefined'), 'YYYY-MM-DD'))
AND (NULLIF(:p_company_code, 'undefined') IS NULL OR (SELECT CASE NVL(segment8,'00000') WHEN '00000' THEN segment1 ELSE segment8 END FROM gl_code_combinations_kfv WHERE code_combination_id = cba.asset_code_combination_id) = NULLIF(:p_company_code, 'undefined'))
AND (NULLIF(:p_gl_account, 'undefined') IS NULL OR (SELECT segment2 FROM gl_code_combinations_kfv WHERE code_combination_id = cba.asset_code_combination_id) = NULLIF(:p_gl_account, 'undefined'))

		

ORDER BY BrateStmtLinesEO.CREATION_DATE DESC,
         BrateStmtHeaderEO.CREATION_DATE DESC,
         BrateStmtLinesEO.LAST_UPDATE_DATE DESC,
         BrateStmtHeaderEO.LAST_UPDATE_DATE DESC	  
		   
		   ]'
  );
  
	
	/*---HDRLINEDATA--------*/


	
	
	/*------HDRLINEDATA GLCODE---------*/
	/*
	
		ORDS.DEFINE_TEMPLATE(
    p_module_name => 'xxexpd_brate_ui',
    p_pattern     => 'hdrlinedata'
  );
    ORDS.DEFINE_HANDLER(
    p_module_name => 'xxexpd_brate_ui',
    p_pattern     => 'hdrlinedata',
    p_method      => 'GET',
    p_source_type => ORDS.source_type_collection_feed,
	p_items_per_page => 25,
    p_source      => q'[
	  SELECT
	  BrateStmtHeaderEO.stmt_from_date
	 ,cba.bank_account_name
	 ,BrateStmtHeaderEO.bank_account_num
	 ,BrateStmtHeaderEO.account_currency_code 
	 ,BrateStmtLinesEO.entry_amt
	 ,BrateStmtLinesEO.Classification 
	 ,BrateStmtLinesEO.je_grouping 
	 ,NULL AS "Distributions"
	 ,BrateStmtLinesEO.je_reversal_status
     ,BrateStmtLinesEO.reversal_reason
	 ,NULL AS "Awaiting_Distributions"
	 ,BrateStmtLinesEO.entry_cr_db_ind  AS "Transaction_Type"
     ,BrateStmtLinesEO.entry_domain_code               
     ,BrateStmtLinesEO.entry_family_code                 
     ,BrateStmtLinesEO.entry_subfamily_code              
     ,BrateStmtLinesEO.entry_bai_code
     ,BrateStmtLinesEO.trx_acct_svcr_ref AS "Customer_Reference"
     ,BrateStmtLinesEO.trx_unstruct_remi_info AS "Description"	 
	 ,BrateStmtHeaderEO.statement_number
	 ,gll.name    AS "ledger_name"
     ,BrateStmtLinesEO.rule_def_id         
     ,BrateStmtLinesEO.classify_rule_name         
     ,BrateStmtLinesEO.classify_rule_version         
     ,BrateStmtLinesEO.je_rule_id         
     ,BrateStmtLinesEO.je_rule_name         
     ,BrateStmtLinesEO.je_rule_version 
     ,BrateStmtLinesEO.record_status_flag
    ,CONCAT(gcc_cash.segment1,'.' ,gcc_cash.segment2,'.' , gcc_cash.segment3,'.' , gcc_cash.segment4,'.' , gcc_cash.segment5,'.' , gcc_cash.segment6,'.' , gcc_cash.segment7,'.' , gcc_cash.segment8,'.' , gcc_cash.segment9,'.' , gcc_cash.segment10) AS "Cash_GL_Account"	 
     ,(select CASE NVL(segment8,'00000') WHEN '00000' THEN segment1 ELSE segment8 END cc from GL_CODE_COMBINATIONS where code_combination_id = cba.asset_code_combination_id) AS "Company_Code" 
	 ,(select segment2 from GL_CODE_COMBINATIONS where code_combination_id = cba.asset_code_combination_id) AS "GL_Account"	
	 ,NULL AS "Bank_Transfer"
	 ,NULL AS "Offset_Account_Number"
	 ,gll_off.name AS "Offset_Ledger_Name"
    CONCAT(off_cr.segment1,'.' ,off_cr.segment2,'.' , off_cr.segment3,'.' , off_cr.segment4,'.' , off_cr.segment5,'.' , off_cr.segment6,'.' , off_cr.segment7,'.' , off_cr.segment8,'.' , off_cr.segment9,'.' , off_cr.segment10) AS "Offset_cr_account", 
    CONCAT(off_dr.segment1,'.' ,off_dr.segment2,'.' , off_dr.segment3,'.' , off_dr.segment4,'.' , off_dr.segment5,'.' , off_dr.segment6,'.' , off_dr.segment7,'.' , off_dr.segment8,'.' , off_dr.segment9,'.' , off_dr.segment10) AS "Offset_dr_account",
	 ,BrateStmtHeaderEO.file_name
	 ,BrateStmtHeaderEO.error_message AS "hdr_message"
	 ,BrateStmtLinesEO.error_message AS "line_message" 
	 ,CASE NVL(BrateStmtLinesEO.sent_to_gl,'N') WHEN 'I' THEN 'Enriched' WHEN 'Y' THEN 'Journal Created' ELSE 'Not Enriched' END  AS "GL_Status" 
	 ,BrateStmtLinesEO.sent_to_ce
	 ,BrateStmtLinesEO.line_number
	 ,BrateStmtLinesEO.recon_status
	 ,NULL AS "Reconciliation_Reference"
     ,BrateStmtLinesEO.attribute13 AS "recon_amount"   
     ,BrateStmtLinesEO.attribute7 AS "exchange_currency"   
     ,BrateStmtLinesEO.exchange_rate_date   
     ,BrateStmtLinesEO.exchange_rate   
     ,BrateStmtLinesEO.attribute6 AS "exchange_amount" 
	 ,BrateStmtHeaderEO.control_begin_balance
	 ,BrateStmtHeaderEO.control_end_balance
	 ,BrateStmtHeaderEO.trx_cred_ent_no
	 ,BrateStmtHeaderEO.trx_deb_ent_no
	 ,BrateStmtLinesEO.manual_override	 
	 ,BrateStmtHeaderEO.header_id         
     ,BrateStmtHeaderEO.bank_name                                            	                    
     ,BrateStmtHeaderEO.trx_entry_no     	 
     ,BrateStmtLinesEO.line_id                                                                    
     ,BrateStmtLinesEO.trx_instr_id                                                                                          
     ,BrateStmtLinesEO.bank_trx_number       
	 ,BrateStmtLinesEO.transfer_flag         
     ,BrateStmtLinesEO.attribute15   
    ,CONCAT(gcc_gl.segment1,'.' ,gcc_gl.segment2,'.' , gcc_gl.segment3,'.' , gcc_gl.segment4,'.' , gcc_gl.segment5,'.' , gcc_gl.segment6,'.' , gcc_gl.segment7,'.' , gcc_gl.segment8,'.' , gcc_gl.segment9,'.' , gcc_gl.segment10) AS "gcc_gl"   	                                                           
             
                         
    FROM xxexpd_ce_brt_camt53_hdr_t    BrateStmtHeaderEO,         
       xxexpd_ce_brt_camt53_lines_t  BrateStmtLinesEO,         
       GL_CODE_COMBINATIONS      gcc_cash,         
       GL_CODE_COMBINATIONS      gcc_gl,         
       GL_CODE_COMBINATIONS      off_cr,         
       GL_CODE_COMBINATIONS      off_dr,          
       ce_bank_accounts              cba,         
       gl_ledgers                    gll,         
       gl_ledgers               gll_off         
 WHERE     1 = 1    

       AND BrateStmtLinesEO.bank_cash_ccid = gcc_cash.code_combination_id(+)         
       AND BrateStmtLinesEO.rule_gl_ccid = gcc_gl.code_combination_id(+)         
       AND BrateStmtLinesEO.offset_cr_ccid = off_cr.code_combination_id(+)         
       AND BrateStmtLinesEO.offset_dr_ccid = off_dr.code_combination_id(+)               
       AND BrateStmtHeaderEO.header_id = BrateStmtLinesEO.header_id(+)         
       AND BrateStmtHeaderEO.bank_account_num = cba.bank_account_num(+)         
       AND BrateStmtLinesEO.bank_ledger_id=gll.ledger_id(+)         
       AND BrateStmtLinesEO.offset_ledger_id=gll_off.ledger_id(+)
	   AND BrateStmtLinesEO.line_id  is not null
	   
	   
       AND  (:p_bank_account_name_alt IS NULL 
		OR :p_bank_account_name_alt = 'undefined'
          OR UPPER(cba.bank_account_name) = UPPER(:p_bank_account_name_alt))
        
        AND (:p_bank_account_num IS NULL
		OR :p_bank_account_num = 'undefined'		
          OR BrateStmtHeaderEO.bank_account_num = :p_bank_account_num)
        
        AND (:p_bank_name IS NULL 
				OR :p_bank_name = 'undefined'
          OR UPPER(BrateStmtHeaderEO.bank_name) = UPPER(:p_bank_name))
        
        AND (:p_stmt_date_from IS NULL 
				OR :p_stmt_date_from = 'undefined'
          OR BrateStmtHeaderEO.STMT_CREATION_DATE >= TO_DATE(:p_stmt_date_from,'YYYY-MM-DD'))
        
        AND (:p_stmt_date_to IS NULL 
				OR :p_stmt_date_to = 'undefined'
          OR BrateStmtHeaderEO.STMT_CREATION_DATE <= TO_DATE(:p_stmt_date_to,'YYYY-MM-DD'))
		  
		  
		AND (:p_gl_status IS NULL
		       OR  :p_gl_status = 'undefined'
		    OR (CASE NVL(BrateStmtLinesEO.sent_to_gl,'N') WHEN 'I' THEN 'Enriched' WHEN 'Y' THEN 'Journal Created' ELSE 'Not Enriched' END)	=:p_gl_status
		
		)  

ORDER BY BrateStmtLinesEO.CREATION_DATE DESC,
         BrateStmtHeaderEO.CREATION_DATE DESC,
         BrateStmtLinesEO.LAST_UPDATE_DATE DESC,
         BrateStmtHeaderEO.LAST_UPDATE_DATE DESC	  
		   
		   ]'
  );
  

	
	
	/*-----------HDRLINEDATA GLCODE---------------
	  
	  ---*/
	  
	  
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'jeGrouping',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'jeGrouping',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'select distinct description as "je_grouping" from FND_Lookup_VALUES 
WHERE 1=1
and lookup_type = ''XXEXPD_CE_BRATE_ACT_KEY_VALUES''
and LANGUAGE=''US''
and ENABLED_FLAG=''Y''
and TAG = ''2''
order by Description'
      );
	  
	  
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'jeOutputString',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'jeOutputString',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'select distinct JE_OUTPUT_STRING from XXEXPD_CE_BRT_CAMT53_DIST_T'
      );
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'listDocuments',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'listDocuments',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
      SELECT
        awaiting_doc_id,
        line_id,
        status,
        file_name,
        creation_date,
        created_by
      FROM xxexpd_ce_brt_camt53_docs_w
	   WHERE line_id = :line_id and status!=''R''
      ORDER BY file_name
    '
      );
	    ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'listApprovedDocuments',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'listApprovedDocuments',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
      SELECT
        awaiting_doc_id,
        line_id,
        status,
        file_name,
        creation_date,
        created_by
      FROM xxexpd_ce_brt_camt53_docs_w
      WHERE line_id = :line_id and status=''A''
      ORDER BY file_name
    '
      );
  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'listReversalDocuments',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'listReversalDocuments',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
      SELECT
        document_id,
        line_id,
        case when (status=''S'') then ''Submitted''
       when (status=''W'') then ''Awaiting Approval'' end as "status",
        file_name,
        creation_date,
        created_by
      FROM XXEXPD_CE_BRT_JE_REV_DOCS_T
      WHERE line_id = :line_id and status!=''R''
      ORDER BY file_name
    '
      );
	  

  ORDS.DEFINE_TEMPLATE(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'receivedistwdata',
      p_priority       => 0,
      p_etag_type      => 'HASH',
      p_etag_query     => NULL,
      p_comments       => NULL);
  ORDS.DEFINE_HANDLER(
      p_module_name    => 'xxexpd_brate_ui',
      p_pattern        => 'receivedistwdata',
      p_method         => 'GET',
      p_source_type    => 'json/collection',
      p_items_per_page =>  25,
      p_mimes_allowed  => '',
      p_comments       => NULL,
      p_source         => 
'
      select distinct LINE_ID||TO_CHAR(CREATION_DATE, ''YYYYMMDDHH24MISS'') as transactionid
from XXEXPD_CE_BRT_CAMT53_DIST_W
where line_id= :line_id
    '
      );
	  
	  
	
ORDS.DEFINE_TEMPLATE(
    p_module_name    => 'xxexpd_brate_ui',
    p_pattern        => 'updateJeClassification/:line_id',
    p_priority       => 0,
    p_etag_type      => 'HASH',
    p_etag_query     => NULL,
    p_comments       => NULL);

ORDS.DEFINE_HANDLER(
    p_module_name    => 'xxexpd_brate_ui',
    p_pattern        => 'updateJeClassification/:line_id',
    p_method         => 'PATCH',
    p_source_type    => 'plsql/block',
    p_items_per_page =>  0,
    p_mimes_allowed  => 'application/json',
    p_comments       => NULL,
    p_source         => 
'
    DECLARE
      l_rows NUMBER;
    BEGIN
      UPDATE xxexpd_ce_brt_camt53_lines_t
      SET    classification   = :classification,
             je_grouping      = :je_grouping,
             last_update_date = SYSDATE
      WHERE  line_id = :line_id;

      l_rows := SQL%ROWCOUNT;

      IF l_rows = 0 THEN
        :status       := 404;
        :message      := ''No record found for line_id '' || :line_id;
      ELSE
        :status       := 200;
        :message      := ''SUCCESS'';
      END IF;

      :rows_updated := l_rows;
    END;
  '
    );

ORDS.DEFINE_PARAMETER(
    p_module_name        => 'xxexpd_brate_ui',
    p_pattern            => 'updateJeClassification/:line_id',
    p_method             => 'PATCH',
    p_name               => 'X-ORDS-STATUS-CODE',
    p_bind_variable_name => 'status',
    p_source_type        => 'HEADER',
    p_param_type         => 'STRING',
    p_access_method      => 'OUT',
    p_comments           => NULL);      

ORDS.DEFINE_PARAMETER(
    p_module_name        => 'xxexpd_brate_ui',
    p_pattern            => 'updateJeClassification/:line_id',
    p_method             => 'PATCH',
    p_name               => 'message',
    p_bind_variable_name => 'message',
    p_source_type        => 'RESPONSE',
    p_param_type         => 'STRING',
    p_access_method      => 'OUT',
    p_comments           => NULL);      

ORDS.DEFINE_PARAMETER(
    p_module_name        => 'xxexpd_brate_ui',
    p_pattern            => 'updateJeClassification/:line_id',
    p_method             => 'PATCH',
    p_name               => 'rows_updated',
    p_bind_variable_name => 'rows_updated',
    p_source_type        => 'RESPONSE',
    p_param_type         => 'STRING',
    p_access_method      => 'OUT',
    p_comments           => NULL);

  ORDS.CREATE_ROLE(p_role_name  => 'Expd expe_atp_xxexpd Administrator');

  l_roles(1)   := 'Expd expe_atp_xxexpd Administrator';
  l_modules(1) := 'xxexpd_brate_ui';
  l_patterns(1):= '/expe_atp_xxexpd/*';

  ORDS.DEFINE_PRIVILEGE(
      p_privilege_name => 'expd.expe_atp_xxexpd',
      p_roles          => l_roles,
      p_patterns       => l_patterns,
      p_modules        => l_modules,
      p_label          => 'xxexpd_brate_ui Privilege',
      p_description    => 'xxexpd_brate_ui data endpoints',
      p_comments       => NULL);  


  COMMIT; 
END;