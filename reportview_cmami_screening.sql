CREATE OR REPLACE VIEW public.reportview_cmami_screening
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_gender}'::text[] AS patient_gender,
    reports.doc #>> '{fields,inputs,contact,date_of_birth}'::text[] AS patient_birthdate,
    reports.doc #>> '{fields,patient_age_in_days}'::text[] AS patient_age_days,
    reports.doc #>> '{fields,patient_age_in_weeks}'::text[] AS patient_age_weeks,
    reports.doc #>> '{fields,inputs,contact,parent,parent,contact,chw_name}'::text[] AS chw_name,
    reports.doc #>> '{fields,inputs,contact,parent,parent,contact,phone}'::text[] AS chw_contact,
    reports.doc #>> '{fields,data,__imm_done}'::text[] AS immunization,
        CASE
            WHEN (reports.doc #>> '{fields,data,__wfa_score}'::text[]) = ''::text THEN NULL::double precision
            ELSE (reports.doc #>> '{fields,data,__wfa_score}'::text[])::double precision
        END AS wfa_score,
    reports.doc #>> '{fields,data,__wfa_classification}'::text[] AS wfa_class,
    reports.doc #>> '{fields,data,__consent_given}'::text[] AS consent_child_screening,
    reports.doc #>> '{fields,data,__infant_weight}'::text[] AS infant_weight,
    reports.doc #>> '{fields,data,__has_danger_signs}'::text[] AS danger_signs,
    reports.doc #>> '{fields,infant_danger_signs,danger_signs}'::text[] as specific_danger_signs,
    reports.doc #>> '{fields,data,__breastfeeding_issues}'::text[] AS breastfeeding_issues,
    reports.doc #>> '{fields,data,__issues_followup_date}'::text[] AS cmami_followup_date,
    reports.doc #>> '{fields,data,g_postnatal_visits,attended_postnatal_visits}'::text[] AS postnatal_visitation,
    reports.doc #>> '{fields,intitial_assessment,other_food}'::text[] AS init_assesstment_food,
    reports.doc #>> '{fields,intitial_assessment,breastfeeding}'::text[] AS init_assessment_breastfeeding,
    reports.doc #>> '{fields,data,__danger_signs_followup_date}'::text[] AS cmami_dangersign_followup,
    reports.doc #>> '{fields,g_introduction,consent}'::text[] AS ch_consent
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'cmami_screening'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;