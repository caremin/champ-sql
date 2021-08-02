CREATE OR REPLACE VIEW public.combined_malnutrition_confirmed
AS SELECT combined.hhmem_uuid,
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
    combined.updated_status AS confirmed_updated_status,
    recent.days_since_report AS recent_days_since,
    recent.updated_status AS recent_updated_status,
    recent.rhu_treatment AS recent_treatment,
    combined.days_since_report AS confirmed_days_since,
    combined.report_uuid AS confirmed_report,
    combined.report_date AS confirmed_date,
    combined.malnutr_stage AS confirmed_source,
    combined.rhu_attendance AS confirmed_rhuattend,
    combined.rhu_date AS confirmed_rhu_date,
    combined.malnutr_chweight AS confirmed_chweight,
    combined.malnutr_chheight AS confirmed_chheight,
    combined.malnutr_zscore AS confirmed_zscore,
    combined.malnutr_status AS confirmed_status,
    combined.rhu_treatment AS confirmed_treatment,
    recent.report_uuid AS recent_report,
    recent.report_date AS recent_date,
    recent.malnutr_stage AS recent_source,
    recent.rhu_attendance AS recent_rhu_attend,
    recent.rhu_date AS recent_rhu_date,
    recent.malnutr_chweight AS recent_chweight,
    recent.malnutr_chheight AS recent_chheight,
    recent.malnutr_zscore AS recent_zscore,
    recent.malnutr_status AS recent_status
   FROM ( SELECT DISTINCT ON (cm.hhmem_uuid) cm.report_uuid,
            cm.report_date,
            cm.malnutr_stage,
            cm.hhmem_uuid,
            cm.rhu_attendance,
            cm.rhu_date,
            cm.malnutr_chweight,
            cm.malnutr_chheight,
            cm.malnutr_zscore,
            cm.malnutr_status,
            cm.updated_status,
            cm.rhu_treatment,
            cm.days_since_report
           FROM combined_malnutrition cm
          WHERE cm.updated_status = 'SAM - Confirmed by RHU (Severely wasted)'::text OR cm.updated_status = 'MAM - Confirmed by RHU (Moderately wasted)'::text
          ORDER BY cm.hhmem_uuid, cm.report_date DESC) combined
     LEFT JOIN ( SELECT DISTINCT ON (cm.hhmem_uuid) cm.report_uuid,
            cm.report_date,
            cm.malnutr_stage,
            cm.hhmem_uuid,
            cm.rhu_attendance,
            cm.rhu_date,
            cm.malnutr_chweight,
            cm.malnutr_chheight,
            cm.malnutr_zscore,
            cm.malnutr_status,
            cm.updated_status,
            cm.rhu_treatment,
            cm.days_since_report
           FROM combined_malnutrition cm
          WHERE cm.malnutr_stage <> 'malnutrition_with_issues_followup'::text
          ORDER BY cm.hhmem_uuid, cm.report_date DESC) recent ON recent.hhmem_uuid = combined.hhmem_uuid
     LEFT JOIN ( SELECT cm.hhmem_uuid,
            count(*) AS total_reports
           FROM combined_malnutrition cm
          GROUP BY cm.hhmem_uuid) total_reports ON total_reports.hhmem_uuid = combined.hhmem_uuid
     LEFT JOIN contactview_participants cp ON cp.hhmem_uuid = combined.hhmem_uuid
     LEFT JOIN raw_contacts rc ON (rc.doc ->> '_id'::text) = cp.chc_uuid
  WHERE cp.area_name <> 'Test Base'::text;