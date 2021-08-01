CREATE OR REPLACE VIEW public.combined_imci_confirmed
AS SELECT confirmed.hhmem_uuid,
    cp.area_name AS base_name,
    cp.branch_name,
    cp.community_name AS sg_community_name,
    cp.hh_name,
    cp.hhmem_name AS patient_name,
    round((CURRENT_DATE - cp.hhmem_dob::date)::numeric / 365.0, 1) AS patient_current_age,
    cp.chc_uuid,
    rc.doc ->> 'patient_id'::text AS chc_icm_id,
    rc.doc ->> 'name'::text AS chc_name,
    cp.community_uuid,
    total_reports.total_reports AS count_reports,
        CASE
            WHEN confirmed.report_uuid = recent.report_uuid THEN 'Requires Immediate Attention No Update in Case'::text
            ELSE 'Updates to Case'::text
        END AS case_status,
    confirmed.updated_status AS confirmed_updated_status,
    confirmed.updated_treatment AS confirmed_updated_treatment,
    recent.updated_status AS recent_updated_status,
    recent.updated_treatment AS recent_updated_treatment,
    confirmed.report_date AS confirmed_report_date,
    confirmed.stage AS confirmed_stage,
    confirmed.rhu_attendance AS confirmed_rhu_attend,
    confirmed.symptoms_imci AS confirmed_imci_symptoms,
    confirmed.symptoms_danger AS confirmed_danger_symptoms,
    confirmed.rhu_diagnosis AS confirmed_rhu_diagnosis,
    confirmed.rhu_treatment AS confirmed_rhu_treatment,
    recent.report_date AS recent_report_date,
    recent.stage AS recent_stage,
    recent.rhu_attendance AS recent_rhu_attend,
    recent.symptoms_imci AS recent_imci_symptoms,
    recent.symptoms_danger AS recent_danger_symptoms,
    confirmed.days_since_report
   FROM ( SELECT DISTINCT ON (cm.hhmem_uuid) cm.report_uuid,
            cm.report_date,
            cm.stage,
            cm.hhmem_uuid,
            cm.rhu_attendance,
            cm.symptoms_imci,
            cm.rhuref_imci,
            cm.symptoms_danger,
            cm.rhuref_danger,
            cm.rhu_diagnosis,
            cm.rhu_treatment,
            cm.rhu_symptoms_status,
            cm.rhu_treatment_status,
            cm.updated_status,
            cm.updated_treatment,
            cm.days_since_report
           FROM combined_imci cm
          WHERE (cm.rhuref_imci = 'yes'::text OR cm.rhuref_danger = 'yes'::text OR cm.symptoms_danger IS NOT NULL) AND cm.stage = 'screening'::text
          ORDER BY cm.hhmem_uuid, cm.report_date DESC) confirmed
     LEFT JOIN ( SELECT DISTINCT ON (cm.hhmem_uuid) cm.report_uuid,
            cm.report_date,
            cm.stage,
            cm.hhmem_uuid,
            cm.rhu_attendance,
            cm.symptoms_imci,
            cm.rhuref_imci,
            cm.symptoms_danger,
            cm.rhuref_danger,
            cm.rhu_diagnosis,
            cm.rhu_treatment,
            cm.rhu_symptoms_status,
            cm.rhu_treatment_status,
            cm.updated_status,
            cm.updated_treatment,
            cm.days_since_report
           FROM combined_imci cm
          ORDER BY cm.hhmem_uuid, cm.report_date DESC) recent ON recent.hhmem_uuid = confirmed.hhmem_uuid
     LEFT JOIN ( SELECT cm.hhmem_uuid,
            count(*) AS total_reports
           FROM combined_malnutrition cm
          GROUP BY cm.hhmem_uuid) total_reports ON total_reports.hhmem_uuid = confirmed.hhmem_uuid
     LEFT JOIN contactview_participants cp ON cp.hhmem_uuid = confirmed.hhmem_uuid
     LEFT JOIN raw_contacts rc ON (rc.doc ->> '_id'::text) = cp.chc_uuid
  WHERE cp.area_name <> 'Test Base'::text;