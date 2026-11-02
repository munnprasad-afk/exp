-- xxexpd_brate_ui : hdrlinedata GET handler only
-- 02-Nov-2026: total_records; exchange_amount filter fix; negative search (:p_<name>_op = NE)
BEGIN

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
     -- 02-Nov-2026: total filtered row count for UI ribbon (Total Records / Page x of y)
     ,COUNT(*) OVER () AS "total_records"
             
                         
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


-- 02-Nov-2026: negative search. Each filter :p_<name> takes an optional :p_<name>_op.
--              'NE' = not equal (rows with NULL in that column are kept); anything else = original match.
--              Statement date range uses :p_stmt_date_op ('NE' = not between).
--              Original filter lines are kept commented after this handler.
AND (NULLIF(:p_bank_account_name_alt, 'undefined') IS NULL OR (NVL(:p_bank_account_name_alt_op, 'EQ') <> 'NE' AND UPPER(cba.bank_account_name) LIKE '%' ||  UPPER(NULLIF(:p_bank_account_name_alt, 'undefined')) || '%') OR (:p_bank_account_name_alt_op = 'NE' AND (UPPER(cba.bank_account_name) IS NULL OR UPPER(cba.bank_account_name) <> UPPER(NULLIF(:p_bank_account_name_alt, 'undefined')))))
AND (NULLIF(:p_bank_name, 'undefined') IS NULL OR :p_bank_name = 'ALL' OR (NVL(:p_bank_name_op, 'EQ') <> 'NE' AND UPPER(BrateStmtHeaderEO.bank_name) LIKE '%' ||  UPPER(NULLIF(:p_bank_name, 'undefined'))   || '%') OR (:p_bank_name_op = 'NE' AND (UPPER(BrateStmtHeaderEO.bank_name) IS NULL OR UPPER(BrateStmtHeaderEO.bank_name) <> UPPER(NULLIF(:p_bank_name, 'undefined')))))
AND (NULLIF(:p_amount_currency, 'undefined') IS NULL OR (NVL(:p_amount_currency_op, 'EQ') <> 'NE' AND UPPER(BrateStmtHeaderEO.account_currency_code) LIKE '%' ||  UPPER(NULLIF(:p_amount_currency, 'undefined')) || '%') OR (:p_amount_currency_op = 'NE' AND (UPPER(BrateStmtHeaderEO.account_currency_code) IS NULL OR UPPER(BrateStmtHeaderEO.account_currency_code) <> UPPER(NULLIF(:p_amount_currency, 'undefined')))))
AND (NULLIF(:p_classification, 'undefined') IS NULL OR (NVL(:p_classification_op, 'EQ') <> 'NE' AND UPPER(BrateStmtLinesEO.Classification) LIKE '%' ||  UPPER(NULLIF(:p_classification, 'undefined')) || '%') OR (:p_classification_op = 'NE' AND (UPPER(BrateStmtLinesEO.Classification) IS NULL OR UPPER(BrateStmtLinesEO.Classification) <> UPPER(NULLIF(:p_classification, 'undefined')))))
AND (NULLIF(:p_classification_rule_name, 'undefined') IS NULL OR (NVL(:p_classification_rule_name_op, 'EQ') <> 'NE' AND UPPER(BrateStmtLinesEO.classify_rule_name) LIKE '%' ||  UPPER(NULLIF(:p_classification_rule_name, 'undefined')) || '%') OR (:p_classification_rule_name_op = 'NE' AND (UPPER(BrateStmtLinesEO.classify_rule_name) IS NULL OR UPPER(BrateStmtLinesEO.classify_rule_name) <> UPPER(NULLIF(:p_classification_rule_name, 'undefined')))))
AND (NULLIF(:p_exchange_currency, 'undefined') IS NULL OR (NVL(:p_exchange_currency_op, 'EQ') <> 'NE' AND UPPER(BrateStmtLinesEO.attribute7) LIKE '%' ||  UPPER(NULLIF(:p_exchange_currency, 'undefined')) || '%') OR (:p_exchange_currency_op = 'NE' AND (UPPER(BrateStmtLinesEO.attribute7) IS NULL OR UPPER(BrateStmtLinesEO.attribute7) <> UPPER(NULLIF(:p_exchange_currency, 'undefined')))))
AND (NULLIF(:p_file_name, 'undefined') IS NULL OR (NVL(:p_file_name_op, 'EQ') <> 'NE' AND UPPER(BrateStmtHeaderEO.file_name) LIKE '%' ||  UPPER(NULLIF(:p_file_name, 'undefined')) || '%') OR (:p_file_name_op = 'NE' AND (UPPER(BrateStmtHeaderEO.file_name) IS NULL OR UPPER(BrateStmtHeaderEO.file_name) <> UPPER(NULLIF(:p_file_name, 'undefined')))))
AND (NULLIF(:p_gl_flag, 'undefined') IS NULL OR (NVL(:p_gl_flag_op, 'EQ') <> 'NE' AND UPPER(BrateStmtLinesEO.sent_to_gl) LIKE '%' ||  UPPER(NULLIF(:p_gl_flag, 'undefined')) || '%') OR (:p_gl_flag_op = 'NE' AND (UPPER(BrateStmtLinesEO.sent_to_gl) IS NULL OR UPPER(BrateStmtLinesEO.sent_to_gl) <> UPPER(NULLIF(:p_gl_flag, 'undefined')))))
AND (NULLIF(:p_header_message, 'undefined') IS NULL OR (NVL(:p_header_message_op, 'EQ') <> 'NE' AND UPPER(BrateStmtHeaderEO.error_message) LIKE '%' ||  UPPER(NULLIF(:p_header_message, 'undefined')) || '%') OR (:p_header_message_op = 'NE' AND (UPPER(BrateStmtHeaderEO.error_message) IS NULL OR UPPER(BrateStmtHeaderEO.error_message) <> UPPER(NULLIF(:p_header_message, 'undefined')))))
AND (NULLIF(:p_je_group, 'undefined') IS NULL OR (NVL(:p_je_group_op, 'EQ') <> 'NE' AND UPPER(BrateStmtLinesEO.je_grouping) LIKE '%' ||  UPPER(NULLIF(:p_je_group, 'undefined')) || '%') OR (:p_je_group_op = 'NE' AND (UPPER(BrateStmtLinesEO.je_grouping) IS NULL OR UPPER(BrateStmtLinesEO.je_grouping) <> UPPER(NULLIF(:p_je_group, 'undefined')))))
AND (NULLIF(:p_je_reversal_reason, 'undefined') IS NULL OR (NVL(:p_je_reversal_reason_op, 'EQ') <> 'NE' AND UPPER(BrateStmtLinesEO.reversal_reason) LIKE '%' ||  UPPER(NULLIF(:p_je_reversal_reason, 'undefined')) || '%') OR (:p_je_reversal_reason_op = 'NE' AND (UPPER(BrateStmtLinesEO.reversal_reason) IS NULL OR UPPER(BrateStmtLinesEO.reversal_reason) <> UPPER(NULLIF(:p_je_reversal_reason, 'undefined')))))
AND (NULLIF(:p_je_reversal_status, 'undefined') IS NULL OR (NVL(:p_je_reversal_status_op, 'EQ') <> 'NE' AND UPPER(BrateStmtLinesEO.je_reversal_status) LIKE '%' ||  UPPER(NULLIF(:p_je_reversal_status, 'undefined')) || '%') OR (:p_je_reversal_status_op = 'NE' AND (UPPER(BrateStmtLinesEO.je_reversal_status) IS NULL OR UPPER(BrateStmtLinesEO.je_reversal_status) <> UPPER(NULLIF(:p_je_reversal_status, 'undefined')))))
AND (NULLIF(:p_journalization_rule_name, 'undefined') IS NULL OR (NVL(:p_journalization_rule_name_op, 'EQ') <> 'NE' AND UPPER(BrateStmtLinesEO.je_rule_name) LIKE '%' ||  UPPER(NULLIF(:p_journalization_rule_name, 'undefined')) || '%') OR (:p_journalization_rule_name_op = 'NE' AND (UPPER(BrateStmtLinesEO.je_rule_name) IS NULL OR UPPER(BrateStmtLinesEO.je_rule_name) <> UPPER(NULLIF(:p_journalization_rule_name, 'undefined')))))
AND (NULLIF(:p_ledger_name, 'undefined') IS NULL OR (NVL(:p_ledger_name_op, 'EQ') <> 'NE' AND UPPER(gll.name) LIKE '%' ||  UPPER(NULLIF(:p_ledger_name, 'undefined')) || '%') OR (:p_ledger_name_op = 'NE' AND (UPPER(gll.name) IS NULL OR UPPER(gll.name) <> UPPER(NULLIF(:p_ledger_name, 'undefined')))))
AND (NULLIF(:p_line_message, 'undefined') IS NULL OR (NVL(:p_line_message_op, 'EQ') <> 'NE' AND UPPER(BrateStmtLinesEO.error_message) LIKE '%' ||  UPPER(NULLIF(:p_line_message, 'undefined')) || '%') OR (:p_line_message_op = 'NE' AND (UPPER(BrateStmtLinesEO.error_message) IS NULL OR UPPER(BrateStmtLinesEO.error_message) <> UPPER(NULLIF(:p_line_message, 'undefined')))))
AND (NULLIF(:p_offset_ledger, 'undefined') IS NULL OR (NVL(:p_offset_ledger_op, 'EQ') <> 'NE' AND UPPER(gll_off.name) LIKE '%' ||  UPPER(NULLIF(:p_offset_ledger, 'undefined')) || '%') OR (:p_offset_ledger_op = 'NE' AND (UPPER(gll_off.name) IS NULL OR UPPER(gll_off.name) <> UPPER(NULLIF(:p_offset_ledger, 'undefined')))))
AND (NULLIF(:p_reconciliation_status, 'undefined') IS NULL OR (NVL(:p_reconciliation_status_op, 'EQ') <> 'NE' AND UPPER(BrateStmtLinesEO.recon_status) LIKE '%' ||  UPPER(NULLIF(:p_reconciliation_status, 'undefined')) || '%') OR (:p_reconciliation_status_op = 'NE' AND (UPPER(BrateStmtLinesEO.recon_status) IS NULL OR UPPER(BrateStmtLinesEO.recon_status) <> UPPER(NULLIF(:p_reconciliation_status, 'undefined')))))
AND (NULLIF(:p_transaction_type, 'undefined') IS NULL OR (NVL(:p_transaction_type_op, 'EQ') <> 'NE' AND UPPER(BrateStmtLinesEO.entry_cr_db_ind) LIKE '%' ||  UPPER(NULLIF(:p_transaction_type, 'undefined')) || '%') OR (:p_transaction_type_op = 'NE' AND (UPPER(BrateStmtLinesEO.entry_cr_db_ind) IS NULL OR UPPER(BrateStmtLinesEO.entry_cr_db_ind) <> UPPER(NULLIF(:p_transaction_type, 'undefined')))))
AND (NULLIF(:p_bank_account_num, 'undefined') IS NULL OR (NVL(:p_bank_account_num_op, 'EQ') <> 'NE' AND BrateStmtHeaderEO.bank_account_num = NULLIF(:p_bank_account_num, 'undefined')) OR (:p_bank_account_num_op = 'NE' AND (BrateStmtHeaderEO.bank_account_num IS NULL OR BrateStmtHeaderEO.bank_account_num <> NULLIF(:p_bank_account_num, 'undefined'))))
AND (NULLIF(:p_gl_status, 'undefined') IS NULL OR (NVL(:p_gl_status_op, 'EQ') <> 'NE' AND (CASE NVL(BrateStmtLinesEO.sent_to_gl,'N') WHEN 'I' THEN 'Enriched' WHEN 'Y' THEN 'Journal Created' ELSE 'Not Enriched' END) = NULLIF(:p_gl_status, 'undefined')) OR (:p_gl_status_op = 'NE' AND ((CASE NVL(BrateStmtLinesEO.sent_to_gl,'N') WHEN 'I' THEN 'Enriched' WHEN 'Y' THEN 'Journal Created' ELSE 'Not Enriched' END) IS NULL OR (CASE NVL(BrateStmtLinesEO.sent_to_gl,'N') WHEN 'I' THEN 'Enriched' WHEN 'Y' THEN 'Journal Created' ELSE 'Not Enriched' END) <> NULLIF(:p_gl_status, 'undefined'))))
AND (NULLIF(:p_bai_code, 'undefined') IS NULL OR (NVL(:p_bai_code_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.entry_bai_code = NULLIF(:p_bai_code, 'undefined')) OR (:p_bai_code_op = 'NE' AND (BrateStmtLinesEO.entry_bai_code IS NULL OR BrateStmtLinesEO.entry_bai_code <> NULLIF(:p_bai_code, 'undefined'))))
AND (NULLIF(:p_cash_gl_account, 'undefined') IS NULL OR (NVL(:p_cash_gl_account_op, 'EQ') <> 'NE' AND gcc_cash.concatenated_segments = NULLIF(:p_cash_gl_account, 'undefined')) OR (:p_cash_gl_account_op = 'NE' AND (gcc_cash.concatenated_segments IS NULL OR gcc_cash.concatenated_segments <> NULLIF(:p_cash_gl_account, 'undefined'))))
AND (NULLIF(:p_customer_reference, 'undefined') IS NULL OR (NVL(:p_customer_reference_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.trx_acct_svcr_ref = NULLIF(:p_customer_reference, 'undefined')) OR (:p_customer_reference_op = 'NE' AND (BrateStmtLinesEO.trx_acct_svcr_ref IS NULL OR BrateStmtLinesEO.trx_acct_svcr_ref <> NULLIF(:p_customer_reference, 'undefined'))))
AND (NULLIF(:p_description, 'undefined') IS NULL OR (NVL(:p_description_op, 'EQ') <> 'NE' AND UPPER(BrateStmtLinesEO.trx_unstruct_remi_info) LIKE '%' || UPPER(NULLIF(:p_description, 'undefined')) || '%') OR (:p_description_op = 'NE' AND (UPPER(BrateStmtLinesEO.trx_unstruct_remi_info) IS NULL OR UPPER(BrateStmtLinesEO.trx_unstruct_remi_info) <> UPPER(NULLIF(:p_description, 'undefined')))))
AND (NULLIF(:p_domain_code, 'undefined') IS NULL OR (NVL(:p_domain_code_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.entry_domain_code = NULLIF(:p_domain_code, 'undefined')) OR (:p_domain_code_op = 'NE' AND (BrateStmtLinesEO.entry_domain_code IS NULL OR BrateStmtLinesEO.entry_domain_code <> NULLIF(:p_domain_code, 'undefined'))))
AND (NULLIF(:p_family_code, 'undefined') IS NULL OR (NVL(:p_family_code_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.entry_family_code = NULLIF(:p_family_code, 'undefined')) OR (:p_family_code_op = 'NE' AND (BrateStmtLinesEO.entry_family_code IS NULL OR BrateStmtLinesEO.entry_family_code <> NULLIF(:p_family_code, 'undefined'))))
AND (NULLIF(:p_manual_override, 'undefined') IS NULL OR (NVL(:p_manual_override_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.manual_override = NULLIF(:p_manual_override, 'undefined')) OR (:p_manual_override_op = 'NE' AND (BrateStmtLinesEO.manual_override IS NULL OR BrateStmtLinesEO.manual_override <> NULLIF(:p_manual_override, 'undefined'))))
AND (NULLIF(:p_offset_ic_credit, 'undefined') IS NULL OR (NVL(:p_offset_ic_credit_op, 'EQ') <> 'NE' AND off_cr.concatenated_segments  = NULLIF(:p_offset_ic_credit, 'undefined')) OR (:p_offset_ic_credit_op = 'NE' AND (off_cr.concatenated_segments IS NULL OR off_cr.concatenated_segments <> NULLIF(:p_offset_ic_credit, 'undefined'))))
AND (NULLIF(:p_offset_ic_debit, 'undefined') IS NULL OR (NVL(:p_offset_ic_debit_op, 'EQ') <> 'NE' AND off_dr.concatenated_segments = NULLIF(:p_offset_ic_debit, 'undefined')) OR (:p_offset_ic_debit_op = 'NE' AND (off_dr.concatenated_segments IS NULL OR off_dr.concatenated_segments <> NULLIF(:p_offset_ic_debit, 'undefined'))))
AND (NULLIF(:p_oracle_ce_transfer, 'undefined') IS NULL OR (NVL(:p_oracle_ce_transfer_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.sent_to_ce = NULLIF(:p_oracle_ce_transfer, 'undefined')) OR (:p_oracle_ce_transfer_op = 'NE' AND (BrateStmtLinesEO.sent_to_ce IS NULL OR BrateStmtLinesEO.sent_to_ce <> NULLIF(:p_oracle_ce_transfer, 'undefined'))))
AND (NULLIF(:p_statement_number, 'undefined') IS NULL OR (NVL(:p_statement_number_op, 'EQ') <> 'NE' AND BrateStmtHeaderEO.statement_number = NULLIF(:p_statement_number, 'undefined')) OR (:p_statement_number_op = 'NE' AND (BrateStmtHeaderEO.statement_number IS NULL OR BrateStmtHeaderEO.statement_number <> NULLIF(:p_statement_number, 'undefined'))))
AND (NULLIF(:p_sub_family_code, 'undefined') IS NULL OR (NVL(:p_sub_family_code_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.entry_subfamily_code = NULLIF(:p_sub_family_code, 'undefined')) OR (:p_sub_family_code_op = 'NE' AND (BrateStmtLinesEO.entry_subfamily_code IS NULL OR BrateStmtLinesEO.entry_subfamily_code <> NULLIF(:p_sub_family_code, 'undefined'))))
AND (NULLIF(:p_amount, 'undefined') IS NULL OR (NVL(:p_amount_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.entry_amt = TO_NUMBER(NULLIF(:p_amount, 'undefined'))) OR (:p_amount_op = 'NE' AND (BrateStmtLinesEO.entry_amt IS NULL OR BrateStmtLinesEO.entry_amt <> TO_NUMBER(NULLIF(:p_amount, 'undefined')))))
AND (NULLIF(:p_classification_rule_id, 'undefined') IS NULL OR (NVL(:p_classification_rule_id_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.rule_def_id = TO_NUMBER(NULLIF(:p_classification_rule_id, 'undefined'))) OR (:p_classification_rule_id_op = 'NE' AND (BrateStmtLinesEO.rule_def_id IS NULL OR BrateStmtLinesEO.rule_def_id <> TO_NUMBER(NULLIF(:p_classification_rule_id, 'undefined')))))
AND (NULLIF(:p_classification_rule_version, 'undefined') IS NULL OR (NVL(:p_classification_rule_version_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.classify_rule_version = TO_NUMBER(NULLIF(:p_classification_rule_version, 'undefined'))) OR (:p_classification_rule_version_op = 'NE' AND (BrateStmtLinesEO.classify_rule_version IS NULL OR BrateStmtLinesEO.classify_rule_version <> TO_NUMBER(NULLIF(:p_classification_rule_version, 'undefined')))))
AND (NULLIF(:p_closing_balance, 'undefined') IS NULL OR (NVL(:p_closing_balance_op, 'EQ') <> 'NE' AND BrateStmtHeaderEO.control_end_balance = TO_NUMBER(NULLIF(:p_closing_balance, 'undefined'))) OR (:p_closing_balance_op = 'NE' AND (BrateStmtHeaderEO.control_end_balance IS NULL OR BrateStmtHeaderEO.control_end_balance <> TO_NUMBER(NULLIF(:p_closing_balance, 'undefined')))))
-- 02-Nov-2026: exchange_amount maps to attribute6, not attribute13
-- AND (NULLIF(:p_exchange_amount, 'undefined') IS NULL OR BrateStmtLinesEO.attribute13 = NULLIF(:p_exchange_amount, 'undefined'))
AND (NULLIF(:p_exchange_amount, 'undefined') IS NULL OR (NVL(:p_exchange_amount_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.attribute6 = NULLIF(:p_exchange_amount, 'undefined')) OR (:p_exchange_amount_op = 'NE' AND (BrateStmtLinesEO.attribute6 IS NULL OR BrateStmtLinesEO.attribute6 <> NULLIF(:p_exchange_amount, 'undefined'))))
AND (NULLIF(:p_exchange_rate, 'undefined') IS NULL OR (NVL(:p_exchange_rate_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.exchange_rate = TO_NUMBER(NULLIF(:p_exchange_rate, 'undefined'))) OR (:p_exchange_rate_op = 'NE' AND (BrateStmtLinesEO.exchange_rate IS NULL OR BrateStmtLinesEO.exchange_rate <> TO_NUMBER(NULLIF(:p_exchange_rate, 'undefined')))))
AND (NULLIF(:p_header_id, 'undefined') IS NULL OR (NVL(:p_header_id_op, 'EQ') <> 'NE' AND BrateStmtHeaderEO.header_id = TO_NUMBER(NULLIF(:p_header_id, 'undefined'))) OR (:p_header_id_op = 'NE' AND (BrateStmtHeaderEO.header_id IS NULL OR BrateStmtHeaderEO.header_id <> TO_NUMBER(NULLIF(:p_header_id, 'undefined')))))
AND (NULLIF(:p_journalization_rule_id, 'undefined') IS NULL OR (NVL(:p_journalization_rule_id_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.je_rule_id = TO_NUMBER(NULLIF(:p_journalization_rule_id, 'undefined'))) OR (:p_journalization_rule_id_op = 'NE' AND (BrateStmtLinesEO.je_rule_id IS NULL OR BrateStmtLinesEO.je_rule_id <> TO_NUMBER(NULLIF(:p_journalization_rule_id, 'undefined')))))
AND (NULLIF(:p_journalization_rule_version, 'undefined') IS NULL OR (NVL(:p_journalization_rule_version_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.je_rule_version = TO_NUMBER(NULLIF(:p_journalization_rule_version, 'undefined'))) OR (:p_journalization_rule_version_op = 'NE' AND (BrateStmtLinesEO.je_rule_version IS NULL OR BrateStmtLinesEO.je_rule_version <> TO_NUMBER(NULLIF(:p_journalization_rule_version, 'undefined')))))
AND (NULLIF(:p_last_updated_by, 'undefined') IS NULL OR (NVL(:p_last_updated_by_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.LAST_UPDATED_BY = TO_NUMBER(NULLIF(:p_last_updated_by, 'undefined'))) OR (:p_last_updated_by_op = 'NE' AND (BrateStmtLinesEO.LAST_UPDATED_BY IS NULL OR BrateStmtLinesEO.LAST_UPDATED_BY <> TO_NUMBER(NULLIF(:p_last_updated_by, 'undefined')))))
AND (NULLIF(:p_line_number, 'undefined') IS NULL OR (NVL(:p_line_number_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.line_number = TO_NUMBER(NULLIF(:p_line_number, 'undefined'))) OR (:p_line_number_op = 'NE' AND (BrateStmtLinesEO.line_number IS NULL OR BrateStmtLinesEO.line_number <> TO_NUMBER(NULLIF(:p_line_number, 'undefined')))))
AND (NULLIF(:p_line_id, 'undefined') IS NULL OR (NVL(:p_line_id_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.line_id = TO_NUMBER(NULLIF(:p_line_id, 'undefined'))) OR (:p_line_id_op = 'NE' AND (BrateStmtLinesEO.line_id IS NULL OR BrateStmtLinesEO.line_id <> TO_NUMBER(NULLIF(:p_line_id, 'undefined')))))
AND (NULLIF(:p_number_of_credit_entries, 'undefined') IS NULL OR (NVL(:p_number_of_credit_entries_op, 'EQ') <> 'NE' AND BrateStmtHeaderEO.trx_cred_ent_no = TO_NUMBER(NULLIF(:p_number_of_credit_entries, 'undefined'))) OR (:p_number_of_credit_entries_op = 'NE' AND (BrateStmtHeaderEO.trx_cred_ent_no IS NULL OR BrateStmtHeaderEO.trx_cred_ent_no <> TO_NUMBER(NULLIF(:p_number_of_credit_entries, 'undefined')))))
AND (NULLIF(:p_number_of_debit_entries, 'undefined') IS NULL OR (NVL(:p_number_of_debit_entries_op, 'EQ') <> 'NE' AND BrateStmtHeaderEO.trx_deb_ent_no = TO_NUMBER(NULLIF(:p_number_of_debit_entries, 'undefined'))) OR (:p_number_of_debit_entries_op = 'NE' AND (BrateStmtHeaderEO.trx_deb_ent_no IS NULL OR BrateStmtHeaderEO.trx_deb_ent_no <> TO_NUMBER(NULLIF(:p_number_of_debit_entries, 'undefined')))))
AND (NULLIF(:p_opening_balance, 'undefined') IS NULL OR (NVL(:p_opening_balance_op, 'EQ') <> 'NE' AND BrateStmtHeaderEO.control_begin_balance = TO_NUMBER(NULLIF(:p_opening_balance, 'undefined'))) OR (:p_opening_balance_op = 'NE' AND (BrateStmtHeaderEO.control_begin_balance IS NULL OR BrateStmtHeaderEO.control_begin_balance <> TO_NUMBER(NULLIF(:p_opening_balance, 'undefined')))))
AND (NULLIF(:p_reconciled_amount, 'undefined') IS NULL OR (NVL(:p_reconciled_amount_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.attribute13 = NULLIF(:p_reconciled_amount, 'undefined')) OR (:p_reconciled_amount_op = 'NE' AND (BrateStmtLinesEO.attribute13 IS NULL OR BrateStmtLinesEO.attribute13 <> NULLIF(:p_reconciled_amount, 'undefined'))))
AND (NULLIF(:p_trx_entry_no, 'undefined') IS NULL OR (NVL(:p_trx_entry_no_op, 'EQ') <> 'NE' AND BrateStmtHeaderEO.trx_entry_no = TO_NUMBER(NULLIF(:p_trx_entry_no, 'undefined'))) OR (:p_trx_entry_no_op = 'NE' AND (BrateStmtHeaderEO.trx_entry_no IS NULL OR BrateStmtHeaderEO.trx_entry_no <> TO_NUMBER(NULLIF(:p_trx_entry_no, 'undefined')))))
AND (NVL(:p_stmt_date_op, 'EQ') = 'NE' OR NULLIF(:p_stmt_date_from, 'undefined') IS NULL OR BrateStmtHeaderEO.stmt_from_date >= TO_DATE(NULLIF(:p_stmt_date_from, 'undefined'), 'YYYY-MM-DD'))
AND (NVL(:p_stmt_date_op, 'EQ') = 'NE' OR NULLIF(:p_stmt_date_to, 'undefined') IS NULL OR BrateStmtHeaderEO.stmt_from_date <= TO_DATE(NULLIF(:p_stmt_date_to, 'undefined'), 'YYYY-MM-DD'))
AND (NVL(:p_stmt_date_op, 'EQ') <> 'NE'
     OR (NULLIF(:p_stmt_date_from, 'undefined') IS NULL AND NULLIF(:p_stmt_date_to, 'undefined') IS NULL)
     OR BrateStmtHeaderEO.stmt_from_date IS NULL
     OR (NULLIF(:p_stmt_date_from, 'undefined') IS NOT NULL AND BrateStmtHeaderEO.stmt_from_date < TO_DATE(NULLIF(:p_stmt_date_from, 'undefined'), 'YYYY-MM-DD'))
     OR (NULLIF(:p_stmt_date_to, 'undefined') IS NOT NULL AND BrateStmtHeaderEO.stmt_from_date > TO_DATE(NULLIF(:p_stmt_date_to, 'undefined'), 'YYYY-MM-DD')))
AND (NULLIF(:p_exchange_rate_date, 'undefined') IS NULL OR (NVL(:p_exchange_rate_date_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.exchange_rate_date = TO_DATE(NULLIF(:p_exchange_rate_date, 'undefined'), 'YYYY-MM-DD')) OR (:p_exchange_rate_date_op = 'NE' AND (BrateStmtLinesEO.exchange_rate_date IS NULL OR BrateStmtLinesEO.exchange_rate_date <> TO_DATE(NULLIF(:p_exchange_rate_date, 'undefined'), 'YYYY-MM-DD'))))
AND (NULLIF(:p_last_update_date, 'undefined') IS NULL OR (NVL(:p_last_update_date_op, 'EQ') <> 'NE' AND BrateStmtLinesEO.LAST_UPDATE_DATE = TO_DATE(NULLIF(:p_last_update_date, 'undefined'), 'YYYY-MM-DD')) OR (:p_last_update_date_op = 'NE' AND (BrateStmtLinesEO.LAST_UPDATE_DATE IS NULL OR BrateStmtLinesEO.LAST_UPDATE_DATE <> TO_DATE(NULLIF(:p_last_update_date, 'undefined'), 'YYYY-MM-DD'))))
AND (NULLIF(:p_company_code, 'undefined') IS NULL OR (NVL(:p_company_code_op, 'EQ') <> 'NE' AND (SELECT CASE NVL(segment8,'00000') WHEN '00000' THEN segment1 ELSE segment8 END FROM gl_code_combinations_kfv WHERE code_combination_id = cba.asset_code_combination_id) = NULLIF(:p_company_code, 'undefined')) OR (:p_company_code_op = 'NE' AND ((SELECT CASE NVL(segment8,'00000') WHEN '00000' THEN segment1 ELSE segment8 END FROM gl_code_combinations_kfv WHERE code_combination_id = cba.asset_code_combination_id) IS NULL OR (SELECT CASE NVL(segment8,'00000') WHEN '00000' THEN segment1 ELSE segment8 END FROM gl_code_combinations_kfv WHERE code_combination_id = cba.asset_code_combination_id) <> NULLIF(:p_company_code, 'undefined'))))
AND (NULLIF(:p_gl_account, 'undefined') IS NULL OR (NVL(:p_gl_account_op, 'EQ') <> 'NE' AND (SELECT segment2 FROM gl_code_combinations_kfv WHERE code_combination_id = cba.asset_code_combination_id) = NULLIF(:p_gl_account, 'undefined')) OR (:p_gl_account_op = 'NE' AND ((SELECT segment2 FROM gl_code_combinations_kfv WHERE code_combination_id = cba.asset_code_combination_id) IS NULL OR (SELECT segment2 FROM gl_code_combinations_kfv WHERE code_combination_id = cba.asset_code_combination_id) <> NULLIF(:p_gl_account, 'undefined'))))

		

ORDER BY BrateStmtLinesEO.CREATION_DATE DESC,
         BrateStmtHeaderEO.CREATION_DATE DESC,
         BrateStmtLinesEO.LAST_UPDATE_DATE DESC,
         BrateStmtHeaderEO.LAST_UPDATE_DATE DESC	  
		   
		   ]'
  );

  /* 02-Nov-2026: original hdrlinedata filter lines (before negative search) - kept for rollback

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
-- 02-Nov-2026: exchange_amount maps to attribute6, not attribute13
-- AND (NULLIF(:p_exchange_amount, 'undefined') IS NULL OR BrateStmtLinesEO.attribute13 = NULLIF(:p_exchange_amount, 'undefined'))
AND (NULLIF(:p_exchange_amount, 'undefined') IS NULL OR BrateStmtLinesEO.attribute6 = NULLIF(:p_exchange_amount, 'undefined'))
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
  */
  
	
	/*---HDRLINEDATA--------*/

  COMMIT;
END;
/
