SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_gender}'::text[] AS patient_gender,
    reports.doc #>> '{fields,g_followup,wfa_class}'::text[] AS malnutr_status,
    reports.doc #>> '{fields,patient_age_in_months}'::text[] as patient_age
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'malnutrition_followup_every_2w'::text;



 	