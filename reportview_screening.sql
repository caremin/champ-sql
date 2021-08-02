CREATE OR REPLACE VIEW public.reportview_screening
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_gender}'::text[] AS patient_gender,
    reports.doc #>> '{fields,g_child,g_danger_signs,g_ask,child_has_danger_signs}'::text[] AS child_danger_yn,
    reports.doc #>> '{fields,g_child,g_danger_signs,g_ask,child_danger_signs}'::text[] AS child_danger_list,
    reports.doc #>> '{fields,g_child,g_danger_signs,g_referral_1,child_danger_signs_referral_given}'::text[] AS child_danger_rhuref,
        CASE
            WHEN (reports.doc #>> '{fields,g_child,g_malnutrition,g_child_weight,child_weight}'::text[]) = ''::text THEN NULL::double precision
            ELSE (reports.doc #>> '{fields,g_child,g_malnutrition,g_child_weight,child_weight}'::text[])::double precision
        END AS malnutr_chwight,
        CASE
            WHEN (reports.doc #>> '{fields,g_child,g_malnutrition,g_child_weight,wfa_score}'::text[]) = ''::text THEN NULL::double precision
            ELSE (reports.doc #>> '{fields,g_child,g_malnutrition,g_child_weight,wfa_score}'::text[])::double precision
        END AS malnutr_zscore,
    reports.doc #>> '{fields,g_child,g_malnutrition,g_child_weight,wfa_classification}'::text[] AS malnutr_status,
    reports.doc #>> '{fields,g_child,g_malnutrition,malnutrition_referral_2,malnutrition_referral_given}'::text[] AS malnutr_rhuref,
    reports.doc #>> '{fields,g_child,g_imci,imci_signs}'::text[] AS child_icmi_all,
    reports.doc #>> '{fields,g_child,g_imci,cough_signs}'::text[] AS child_icmi_cough,
    reports.doc #>> '{fields,g_child,g_imci,diarrhea_signs}'::text[] AS child_icmi_diarrhea,
    reports.doc #>> '{fields,g_child,g_imci,fever_signs}'::text[] AS child_icmi_fever,
    reports.doc #>> '{fields,g_child,g_imci,ear_signs}'::text[] AS child_icmi_ear,
    reports.doc #>> '{fields,g_child,g_imci,g_referral_2,imci_referral_given}'::text[] AS child_icmi_rhuref,
    reports.doc #>> '{fields,g_child,g_deworming,dewormed}'::text[] AS child_dewormed_yesno,
        CASE
            WHEN (reports.doc #>> '{fields,g_child,g_deworming,deworm_date}'::text[]) = ''::text THEN NULL::text
            ELSE reports.doc #>> '{fields,g_child,g_deworming,deworm_date}'::text[]
        END::date AS child_dewormed_ondate,
    reports.doc #>> '{fields,g_child,g_vita,received_vita}'::text[] AS child_vita_yesno,
        CASE
            WHEN (reports.doc #>> '{fields,g_child,g_vita,vita_date}'::text[]) = ''::text THEN NULL::text
            ELSE reports.doc #>> '{fields,g_child,g_vita,vita_date}'::text[]
        END::date AS child_vita_dategiven,
    reports.doc #>> '{fields,g_child,g_referral_3,supp_referral_given}'::text[] AS child_general_rhuref,
    reports.doc #>> '{fields,g_child,g_imm,imm_9m_done}'::text[] AS child_imm_9mo,
    reports.doc #>> '{fields,g_child,g_imm,imm_12m_done}'::text[] AS child_imm_12mo,
    reports.doc #>> '{fields,g_child,g_referral_4,imm_referral_given}'::text[] AS child_imm_rhuref,
    reports.doc #>> '{fields,g_tb,tb_previous}'::text[] AS tb_past_yn,
        CASE
            WHEN (reports.doc #>> '{fields,g_tb,treatment_start_date}'::text[]) = ''::text THEN NULL::text
            ELSE reports.doc #>> '{fields,g_tb,treatment_start_date}'::text[]
        END::date AS tb_past_treat_start,
        CASE
            WHEN (reports.doc #>> '{fields,g_tb,treatment_complete}'::text[]) = ''::text THEN NULL::text
            ELSE reports.doc #>> '{fields,g_tb,treatment_complete}'::text[]
        END AS tb_past_treat_complete,
    reports.doc #>> '{fields,g_tb,tb_diagnosis}'::text[] AS tb_past_diagnosis,
    reports.doc #>> '{fields,g_tb,treatment_incomplete_reason}'::text[] AS tb_past_diag_incomplete,
    reports.doc #>> '{fields,g_tb,tb_danger_signs}'::text[] AS tb_danger_list,
    reports.doc #>> '{fields,g_tb,cough_duration}'::text[] AS tb_danger_cough_len,
    reports.doc #>> '{fields,g_tb,relationship}'::text[] AS tb_danger_relationship,
    reports.doc #>> '{fields,g_tb,tb_risks}'::text[] AS tb_danger_highrisk,
    reports.doc #>> '{fields,g_tb,tb_risk_signs}'::text[] AS tb_danger_symptoms,
    reports.doc #>> '{fields,g_tb,g_referral,tb_referral_given}'::text[] AS tb_rhuref,
    reports.doc #>> '{fields,g_fp,fp_screening,using_fp}'::text[] AS fp_yesno,
    reports.doc #>> '{fields,g_fp,fp_screening_1,fp_types}'::text[] AS fp_method_current,
    reports.doc #>> '{fields,g_fp,fp_screening_1,anyissues}'::text[] AS fp_issues,
    reports.doc #>> '{fields,g_fp,fp_screening_1,issues}'::text[] AS fp_issues_details,
    reports.doc #>> '{fields,g_fp,fp_screening_3,fp_rhu_given}'::text[] AS fp_rhuref_1,
    reports.doc #>> '{fields,g_fp,fp_screening_4_1,fp_interest}'::text[] AS fp_method_interest,
    reports.doc #>> '{fields,g_fp,fp_screening_4_1,other_fp}'::text[] AS fp_interest_oth,
    reports.doc #>> '{fields,g_fp,fp_screening_4_2,preferred_fp}'::text[] AS fp_method_perferred,
    reports.doc #>> '{fields,g_fp,fp_screening_4_3,fp_rhu_given_again}'::text[] AS fp_rhuref_2,
    reports.doc #>> '{fields,g_pregnancy,pregnancy_details,pregnant}'::text[] AS preg_details_yn,
        CASE
            WHEN (reports.doc #>> '{fields,g_pregnancy,pregnancy_details_1,lmp_date}'::text[]) = ''::text THEN NULL::text
            ELSE reports.doc #>> '{fields,g_pregnancy,pregnancy_details_1,lmp_date}'::text[]
        END::date AS preg_details_lmp,
    to_date(
        CASE
            WHEN (reports.doc #>> '{fields,g_pregnancy,pregnancy_details_1,edd_calculated}'::text[]) = ''::text THEN NULL::text
            ELSE reports.doc #>> '{fields,g_pregnancy,pregnancy_details_1,edd_calculated}'::text[]
        END, 'DD-MM-YYYY'::text) AS preg_details_edd,
    (reports.doc #>> '{fields,g_pregnancy,pregnancy_details_1,pregnancy_age}'::text[])::integer AS preg_datails_totalmths,
    reports.doc #>> '{fields,g_pregnancy,pregnancy_details_1,planned}'::text[] AS preg_details_planned,
    reports.doc #>> '{fields,g_pregnancy,pregnancy_details_2,birth_place}'::text[] AS preg_details_birthplace,
    reports.doc #>> '{fields,g_pregnancy,pregnancy_details_2,other_birth_place}'::text[] AS preg_details_birthplace_oth,
    (reports.doc #>> '{fields,g_pregnancy,history,previous_children}'::text[])::integer AS preg_history_prevnum,
    reports.doc #>> '{fields,g_pregnancy,history,birth_place_before}'::text[] AS preg_history_prevbirthplace,
    (reports.doc #>> '{fields,g_pregnancy,check_up,visits_required}'::text[])::integer AS preg_checkup_prenat_visitsreq,
    (reports.doc #>> '{fields,g_pregnancy,check_up,num_prenatal_visit}'::text[])::integer AS preg_checkup_prenat_visitsattend,
    reports.doc #>> '{fields,g_pregnancy,check_up,next_visit}'::text[] AS preg_checkup_prenat_visitnext,
    reports.doc #>> '{fields,g_pregnancy,check_up_3,rhu_referral}'::text[] AS preg_checkup_rhuref,
    reports.doc #>> '{fields,g_pregnancy,danger_signs_2,any_signs}'::text[] AS preg_danger_yn,
    reports.doc #>> '{fields,g_pregnancy,danger_signs_2,signs}'::text[] AS preg_danger_list,
    reports.doc #>> '{fields,g_pregnancy,danger_signs_4,rhu_given}'::text[] AS preg_danger_rhuref,
    reports.doc #>> '{fields,g_pregnancy,micronutrient_1,any_micronutrient}'::text[] AS preg_micronutrient_yn
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'screening'::text;