CREATE OR REPLACE VIEW public.reportview_cmami_followup_upd
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,inputs,user,parent,_id}'::text[] AS comm_uuid,
    reports.doc #>> '{fields,patient_gender}'::text[] AS patient_gender,
    reports.doc #>> '{fields,inputs,contact,date_of_birth}'::text[] AS patient_birthdate,
    reports.doc #>> '{fields,patient_age_in_months}'::text[] AS age_in_months,
    reports.doc #>> '{fields,patient_age_in_years}'::text[] AS age_in_years,
    reports.doc #>> '{fields,infant_danger_signs,has_danger_signs}'::text[] AS infant_danger_sign,
    reports.doc #>> '{fields,g_continue,continue}'::text[] AS continue_followup,
        CASE
            WHEN (reports.doc #>> '{fields,g_infant_weight,infant_weight}'::text[]) = ''::text THEN NULL::double precision
            ELSE (reports.doc #>> '{fields,g_infant_weight,infant_weight}'::text[])::double precision
        END AS infant_weight,
        CASE
            WHEN (reports.doc #>> '{fields,g_infant_weight,wfa_score}'::text[]) = ''::text THEN NULL::double precision
            ELSE (reports.doc #>> '{fields,g_infant_weight,wfa_score}'::text[])::double precision
        END AS infant_wfa_score,
    reports.doc #>> '{fields,g_infant_weight,wfa_classification}'::text[] AS infant_wfa_class,
    reports.doc #>> '{fields,rescheduled_date}'::text[] AS resched_date,
    reports.doc #>> '{fields,infant_danger_signs,has_danger_signs}'::text[] AS infant_danger_signs,
    reports.doc #>> '{fields,intitial_assessment,other_food}'::text[] AS infant_in_ast_food,
    reports.doc #>> '{fields,intitial_assessment,breastfeeding}'::text[] AS infant_int_as_breastfeeding,
    reports.doc #>> '{fields,g_breastfeeding_issues,breastfeeding_issues}'::text[] AS breastfeeding_issues,
    reports.doc #>> '{fields,g_postnatal_visits,attended_postnatal_visits}'::text[] AS attended_postnatal,
    reports.doc #>> '{fields,postnatal_visits_referral_2,postnatal_visits_referral_given}'::text[] AS postnatal_visit_referral,
    reports.doc #>> '{fields,danger_signs_referral_2,danger_signs_referral_given}'::text[] AS danger_signs_referral_given,
    reports.doc #>> '{fields,infant_weight_referral_2,infant_weight_referral_given}'::text[] AS infant_weight_referral_given,
    reports.doc #>> '{fields,breastfeeding_referral_2,breastfeeding_referral_given}'::text[] AS breastfeeding_referral_given,
    reports.doc #>> '{fields,imm_referral_2,imm_referral_given}'::text[] AS imm_referral_given,
    reports.doc #>> '{fields,g_imm,imm_done}'::text[] AS imm_done
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'cmami_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;