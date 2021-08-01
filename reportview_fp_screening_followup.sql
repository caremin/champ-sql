CREATE OR REPLACE VIEW public.reportview_fp_screening_followup
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{fields,patient_id}'::text[] AS patient_id,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_gender}'::text[] AS patient_gender,
    reports.doc #>> '{fields,patient_age_in_months}'::text[] AS patient_age_months,
    reports.doc #>> '{fields,patient_age_in_years}'::text[] AS patient_age_years,
    reports.doc #>> '{fields,fp_screening,fp_interest}'::text[] AS interested_in_fp,
    reports.doc #>> '{fields,fp_screening,other_fp}'::text[] AS fp_specify_other,
    reports.doc #>> '{fields,fp_screening_1,preferred_fp}'::text[] AS preferred_fp,
    reports.doc #>> '{fields,fp_screening_3,referral}'::text[] AS rhu_referral_given,
    to_date(
        CASE
            WHEN (reports.doc #>> '{fields,fp_screening_3,referral_followup}'::text[]) = ''::text THEN NULL::text
            ELSE reports.doc #>> '{fields,fp_screening_3,referral_followup}'::text[]
        END, 'DD-MM-YYYY'::text) AS referral_followup
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'fp_screening_followup'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;