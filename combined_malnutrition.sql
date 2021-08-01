CREATE OR REPLACE VIEW public.combined_malnutrition
AS SELECT screening.report_uuid,
    screening.report_date,
    screening.which_report AS malnutr_stage,
    screening.hhmem_uuid,
    screening.malnutr_rhuref AS rhu_attendance,
    NULL::date AS rhu_date,
    screening.malnutr_chwight AS malnutr_chweight,
    NULL::double precision AS malnutr_chheight,
    screening.malnutr_zscore,
    screening.malnutr_status,
        CASE
            WHEN screening.malnutr_status = 'unknown'::text THEN 'Unknown - Wrong Encoding'::text
            WHEN screening.malnutr_status = 'underweight'::text THEN 'MAM - Suspected (Moderately wasted)'::text
            WHEN screening.malnutr_status = 'severely_underweight'::text THEN 'SAM - Suspected (Severely wasted)'::text
            WHEN screening.malnutr_status = 'normal'::text THEN 'Not Wasted - Suspected'::text
            ELSE 'unknown'::text
        END AS updated_status,
        CASE
            WHEN screening.malnutr_rhuref = 'yes'::text THEN 'Referred to RHU - Requires 48hr Follow-up'::text
            WHEN screening.malnutr_rhuref = 'no'::text THEN 'Suspected Malnourished but No RHU Referral'::text
            ELSE 'No Treatment Needed - Not Suspected Malnourished'::text
        END AS rhu_treatment,
    date_part('day'::text, CURRENT_DATE::timestamp with time zone - screening.report_date) AS days_since_report,
    NULL::double precision AS malnutr_targetweight
   FROM reportview_screening screening
  WHERE screening.malnutr_status IS NOT NULL
UNION ALL
 SELECT report.report_uuid,
    report.report_date,
    report.which_report AS malnutr_stage,
    report.hhmem_uuid,
    report.visitrhu_continue_yes AS rhu_attendance,
    report.rhu_date_attendance::date AS rhu_date,
    report.continue_weight::double precision AS malnutr_chweight,
    report.continue_height::double precision AS malnutr_chheight,
        CASE
            WHEN report.wfh_score = ''::text THEN NULL::double precision
            ELSE report.wfh_score::double precision
        END AS malnutr_zscore,
    report.wfh_class AS malnutr_status,
        CASE
            WHEN report.wfh_class = 'normal'::text THEN 'Not Wasted - Confirmed'::text
            WHEN report.continue_followup = 'no'::text THEN 'Unknown - Follow-up Rescheduled'::text
            WHEN report.rhu_done_visitation = 'yes'::text AND report.wfh_class = 'unknown'::text THEN 'Unknown - Wrong Encoding'::text
            WHEN report.wfh_class = 'severely_wasted'::text THEN 'SAM - Confirmed by RHU (Severely wasted)'::text
            WHEN report.wfh_class = 'wasted'::text THEN 'MAM - Confirmed by RHU (Moderately wasted)'::text
            WHEN report.visitrhu_continue_yes = 'no'::text THEN 'Unknown - Did not Attend RHU'::text
            ELSE 'unknown'::text
        END AS updated_status,
        CASE
            WHEN report.rhu_done_visitation = 'yes'::text AND (report.wfh_class = 'severely_wasted'::text OR report.wfh_class = 'wasted'::text) THEN 'Requires Follow-up (2wks) to confirm treatment enrollment to RHU'::text
            WHEN report.rhu_done_visitation = 'no'::text THEN 'Requires Follow-up - Need RHU Confirmation'::text
            ELSE 'Requires Discharge - RHU Confirmed Not Malnourished'::text
        END AS rhu_treatment,
    date_part('day'::text, CURRENT_DATE::timestamp with time zone - report.report_date) AS days_since_report,
        CASE
            WHEN report.target_weight = ''::text THEN NULL::double precision
            ELSE report.target_weight::double precision
        END AS malnutr_targetweight
   FROM reportview_malnutrition_48h report
UNION ALL
 SELECT report.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((report.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    report.doc ->> 'form'::text AS malnutr_stage,
    report.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    report.doc #>> '{fields,g_followup,attending_rhu}'::text[] AS rhu_attendance,
    to_date(
        CASE
            WHEN (report.doc #>> '{fields,visit_date_format}'::text[]) = ''::text THEN NULL::text
            ELSE report.doc #>> '{fields,visit_date_format}'::text[]
        END, 'DD-MM-YYYY'::text) AS rhu_date,
    (report.doc #>> '{fields,g_followup,weight}'::text[])::double precision AS malnutr_chweight,
    NULL::double precision AS malnutr_chheight,
    (report.doc #>> '{fields,g_followup,wfa_score}'::text[])::double precision AS malnutr_zscore,
    report.doc #>> '{fields,g_followup,wfa_class}'::text[] AS malnutr_status,
        CASE
            WHEN (report.doc #>> '{fields,g_followup,wfa_class}'::text[]) = 'unknown'::text THEN 'Unknown - Wrong Encoding'::text
            WHEN (report.doc #>> '{fields,g_followup,wfa_class}'::text[]) = 'normal'::text THEN 'Not Wasted - Suspected'::text
            WHEN (report.doc #>> '{fields,g_followup,wfa_class}'::text[]) = 'malnourished'::text THEN 'MAM - Suspected (Moderately wasted)'::text
            WHEN (report.doc #>> '{fields,g_followup,wfa_class}'::text[]) = 'severely_malnourished'::text THEN 'SAM - Suspected (Severely wasted)'::text
            ELSE 'unknown'::text
        END AS updated_status,
        CASE
            WHEN (report.doc #>> '{fields,g_followup,wfa_class}'::text[]) = 'normal'::text AND (report.doc #>> '{fields,g_followup,attending_rhu}'::text[]) = 'yes'::text THEN 'Possibly done with Treatment, Normal and attending RHU'::text
            WHEN (report.doc #>> '{fields,g_followup,attending_rhu}'::text[]) = 'yes'::text AND (report.doc #>> '{fields,g_followup,compliant}'::text[]) = 'yes'::text AND (report.doc #>> '{fields,g_followup,issues}'::text[]) = 'yes'::text THEN 'Treatment Compliant, but experiencing issues'::text
            WHEN (report.doc #>> '{fields,g_followup,attending_rhu}'::text[]) = 'yes'::text AND (report.doc #>> '{fields,g_followup,compliant}'::text[]) = 'yes'::text AND (report.doc #>> '{fields,g_followup,issues}'::text[]) = 'no'::text THEN 'Treatment Compliant'::text
            WHEN (report.doc #>> '{fields,g_followup,attending_rhu}'::text[]) = 'yes'::text AND (report.doc #>> '{fields,g_followup,compliant}'::text[]) = 'no'::text AND (report.doc #>> '{fields,g_followup,issues}'::text[]) = 'no'::text THEN 'Attended RHU, but not treatment compliant'::text
            WHEN (report.doc #>> '{fields,g_followup,attending_rhu}'::text[]) = 'yes'::text AND (report.doc #>> '{fields,g_followup,compliant}'::text[]) = 'no'::text AND (report.doc #>> '{fields,g_followup,issues}'::text[]) = 'yes'::text THEN 'Attended RHU, but not treatment compliant and experiencing issues'::text
            WHEN (report.doc #>> '{fields,g_followup,attending_rhu}'::text[]) = 'no'::text THEN 'Possible dropout did not attend RHU requires immediate intervention'::text
            ELSE 'Maybe Done - Not Malnourished'::text
        END AS rhu_treatment,
    date_part('day'::text, CURRENT_DATE::timestamp with time zone - to_timestamp((((report.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) AS days_since_report,
    NULL::double precision AS malnutr_targetweight
   FROM raw_reports report
  WHERE (report.doc ->> 'form'::text) = 'malnutrition_followup_every_2w'::text
UNION ALL
 SELECT report.report_uuid,
    report.report_date,
    report.which_report AS malnutr_stage,
    report.hhmem_uuid,
    report.visit_rhu AS rhu_attendance,
    report.date_visitation::date AS rhu_date,
    NULL::double precision AS malnutr_chweight,
    NULL::double precision AS malnutr_chheight,
    NULL::double precision AS malnutr_zscore,
    report.final_diagnosis AS malnutr_status,
    'No Status Update - Issues Report'::text AS updated_status,
        CASE
            WHEN report.resolved_issues = 'no'::text THEN 'RHU visit - Issues Remain'::text
            WHEN report.resolved_issues = 'yes'::text THEN 'RHU visit - Issues Resolved'::text
            WHEN report.visit_rhu = 'no'::text THEN 'Did not attend RHU'::text
            WHEN report.continue_followup = 'no'::text THEN 'Issues follow-up not completed'::text
            ELSE NULL::text
        END AS rhu_treatment,
    date_part('day'::text, CURRENT_DATE::timestamp with time zone - report.report_date) AS days_since_report,
    NULL::double precision AS malnutr_targetweight
   FROM reportview_malnutrition_with_issues_followup report
UNION ALL
 SELECT report.report_uuid,
    report.report_date,
    report.which_report AS malnutr_stage,
    report.hhmem_uuid,
    NULL::text AS rhu_attendance,
    report.discharge_date::date AS rhu_date,
    report.weight::double precision AS malnutr_chweight,
    NULL::double precision AS malnutr_chheight,
    report.wfa_score::double precision AS malnutr_zscore,
    report.wfa_class AS malnutr_status,
        CASE
            WHEN report.wfa_class = 'unknown'::text THEN 'Unknown - Wrong Encoding'::text
            WHEN report.wfa_class = 'underweight'::text THEN 'MAM - Suspected (Moderately wasted)'::text
            WHEN report.wfa_class = 'severely_underweight'::text THEN 'SAM - Suspected (Severely wasted)'::text
            WHEN report.wfa_class = 'normal'::text THEN 'Not Wasted - Suspected'::text
            ELSE 'Discharged'::text
        END AS updated_status,
        CASE
            WHEN report.wfa_class = 'normal'::text THEN 'Discharged - Suspected Normal'::text
            WHEN report.wfa_class = 'underweight'::text THEN 'Discharged - Suspected MAM (Suggested Follow-up)'::text
            WHEN report.wfa_class = 'severely_underweight'::text THEN 'Discharged - Suspected SAM (Suggested Follow-up)'::text
            ELSE 'Discharged'::text
        END AS rhu_treatment,
    date_part('day'::text, CURRENT_DATE::timestamp with time zone - report.report_date) AS days_since_report,
    NULL::double precision AS malnutr_targetweight
   FROM reportview_malnutrition_discharge report;