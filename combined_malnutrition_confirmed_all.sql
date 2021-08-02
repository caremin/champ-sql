CREATE OR REPLACE VIEW public.combined_malnutrition_confirmed_all
AS SELECT screening.hhmem_uuid,
    cp.hhmem_name AS patient_name,
        CASE
            WHEN cp.hhmem_status_upd IS NULL THEN cp.hhmem_status
            ELSE concat(cp.hhmem_status, ' - ', cp.hhmem_status_upd)
        END AS hhmem_status,
    recent.stage_recent,
    recent.outcome_recent,
    recent.treatment_recent,
    recent.rhu_recent,
    recent.last_report_days,
    frtyeight.outcome_48hr,
    screening.outcome_screening,
    recent.report_date_recent,
    frtyeight.report_date_48hr,
    frtyeight.rhu_date_48hr,
    screening.report_date_screeing,
    screening.weight_screening,
    frtyeight.weight_rhu,
    recent.weight_recent,
    frtyeight.height_rhu,
    frtyeight.zscore_rhu,
    recent.zscore_wfa_recent,
    cmr.mal_screening,
    cmr.mal_48hfollowup,
    cmr.mal_2wfollowup,
    cmr.mal_discharge,
    cmr.screening_status_previous,
    cp.area_name,
    cp.cluster_name,
    cp.minicluster_name,
    cp.branch_name,
    cp.community_name,
    cp.chc_name,
    cp.hh_name,
    screening.treatment_screening,
    frtyeight.treatment_48hr,
    screening.rhu_ref_screening,
    frtyeight.targetweight_rhu,
    round((CURRENT_DATE - cp.hhmem_dob::date)::numeric / 365.0, 1) AS patient_current_age,
    cp.hhmem_gender AS patient_gender
   FROM ( SELECT DISTINCT ON (cm.hhmem_uuid) cm.hhmem_uuid,
            cm.report_date AS report_date_screeing,
            cm.malnutr_chweight AS weight_screening,
            cm.updated_status AS outcome_screening,
            cm.rhu_treatment AS treatment_screening,
            cm.rhu_attendance AS rhu_ref_screening
           FROM combined_malnutrition cm
          WHERE cm.malnutr_stage = 'screening'::text
          ORDER BY cm.hhmem_uuid, cm.report_date DESC) screening
     LEFT JOIN ( SELECT DISTINCT ON (cm.hhmem_uuid) cm.hhmem_uuid,
            cm.report_date AS report_date_48hr,
            cm.rhu_date AS rhu_date_48hr,
            cm.malnutr_chweight AS weight_rhu,
            cm.malnutr_chheight AS height_rhu,
            cm.malnutr_zscore AS zscore_rhu,
            cm.malnutr_targetweight AS targetweight_rhu,
                CASE
                    WHEN cm.updated_status = 'unknown'::text THEN 'Did not Attend RHU (Unknown)'::text
                    ELSE cm.updated_status
                END AS outcome_48hr,
            cm.rhu_treatment AS treatment_48hr
           FROM combined_malnutrition cm
          WHERE cm.malnutr_stage = 'malnutrition_followup_48h'::text
          ORDER BY cm.hhmem_uuid, cm.report_date DESC) frtyeight ON screening.hhmem_uuid = frtyeight.hhmem_uuid
     LEFT JOIN ( SELECT DISTINCT ON (cm.hhmem_uuid) cm.hhmem_uuid,
            cm.report_date AS report_date_recent,
            cm.malnutr_stage AS stage_recent,
            cm.rhu_attendance AS rhu_recent,
            cm.malnutr_chweight AS weight_recent,
            cm.malnutr_zscore AS zscore_wfa_recent,
            cm.updated_status AS outcome_recent,
            cm.rhu_treatment AS treatment_recent,
            cm.days_since_report AS last_report_days
           FROM combined_malnutrition cm
          WHERE cm.malnutr_stage <> 'malnutrition_with_issues_followup'::text
          ORDER BY cm.hhmem_uuid, cm.report_date DESC) recent ON screening.hhmem_uuid = recent.hhmem_uuid
     LEFT JOIN contactview_participants cp ON screening.hhmem_uuid = cp.hhmem_uuid
     LEFT JOIN combined_malnutrtion_reportcnt cmr ON screening.hhmem_uuid = cmr.hhmem_uuid;