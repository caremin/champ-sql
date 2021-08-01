CREATE OR REPLACE VIEW public.combined_imci_upd
AS SELECT screening.report_uuid,
    screening.report_date,
    screening.which_report AS stage,
    screening.hhmem_uuid,
    screening.child_continue AS continue_update,
    'not applicable'::text AS rhu_attendance,
    screening.child_danger_yn AS gendanger_yn,
    screening.child_danger_list AS gendanger_symptoms,
    screening.child_dewormed_yesno AS dewormed_yn,
    screening.child_vita_yesno AS vita_yn,
    screening.child_icmi_all AS imci_general_all,
        CASE
            WHEN screening.child_icmi_cough IS NOT NULL AND screening.child_icmi_cough <> ''::text THEN 'yes'::text
            WHEN screening.child_icmi_diarrhea IS NOT NULL AND screening.child_icmi_diarrhea <> ''::text THEN 'yes'::text
            WHEN screening.child_icmi_ear IS NOT NULL AND screening.child_icmi_ear <> ''::text THEN 'yes'::text
            WHEN screening.child_icmi_fever IS NOT NULL AND screening.child_icmi_fever <> ''::text THEN 'yes'::text
            WHEN screening.child_icmi_all = ''::text THEN NULL::text
            WHEN screening.child_icmi_all IS NULL THEN NULL::text
            ELSE 'no'::text
        END AS imci_danger_yn,
    screening.child_icmi_cough AS imci_danger_cough,
    screening.child_icmi_diarrhea AS imci_danger_diarrhea,
    screening.child_icmi_ear AS imci_danger_ear,
    screening.child_icmi_fever AS imci_danger_fever,
    screening.child_icmi_rhuref AS rhuref_imci,
    screening.child_danger_rhuref AS rhuref_danger,
    screening.child_imm_rhuref AS rhuref_imm,
    screening.malnutr_status AS suspected_malnutr_status,
    screening.malnutr_rhuref AS rhuref_malnutrition,
        CASE
            WHEN screening.child_icmi_rhuref = 'yes'::text THEN 1
            ELSE 0
        END +
        CASE
            WHEN screening.child_danger_rhuref = 'yes'::text THEN 1
            ELSE 0
        END +
        CASE
            WHEN screening.child_imm_rhuref = 'yes'::text THEN 1
            ELSE 0
        END AS imci_rhuref_cnt,
    NULL::text AS rhu_diagnosis,
    NULL::text AS rhu_treatment,
    NULL::text AS rhu_symptoms_status,
    NULL::text AS rhu_treatment_status,
    NULL::text AS followup_appt,
    NULL::date AS followup_date,
        CASE
            WHEN screening.child_danger_yn = 'yes'::text AND screening.child_icmi_all <> ''::text AND
            CASE
                WHEN screening.child_icmi_cough IS NOT NULL AND screening.child_icmi_cough <> ''::text THEN 'yes'::text
                WHEN screening.child_icmi_diarrhea IS NOT NULL AND screening.child_icmi_diarrhea <> ''::text THEN 'yes'::text
                WHEN screening.child_icmi_ear IS NOT NULL AND screening.child_icmi_ear <> ''::text THEN 'yes'::text
                WHEN screening.child_icmi_fever IS NOT NULL AND screening.child_icmi_fever <> ''::text THEN 'yes'::text
                ELSE 'no'::text
            END = 'yes'::text THEN 'General Danger & ICMI Danger Signs'::text
            WHEN screening.child_danger_yn = 'yes'::text AND screening.child_icmi_all = ''::text THEN 'General Danger Signs Only'::text
            WHEN screening.child_danger_yn = 'yes'::text AND screening.child_icmi_all <> ''::text AND
            CASE
                WHEN screening.child_icmi_cough IS NOT NULL AND screening.child_icmi_cough <> ''::text THEN 'yes'::text
                WHEN screening.child_icmi_diarrhea IS NOT NULL AND screening.child_icmi_diarrhea <> ''::text THEN 'yes'::text
                WHEN screening.child_icmi_ear IS NOT NULL AND screening.child_icmi_ear <> ''::text THEN 'yes'::text
                WHEN screening.child_icmi_fever IS NOT NULL AND screening.child_icmi_fever <> ''::text THEN 'yes'::text
                ELSE 'no'::text
            END = 'no'::text THEN 'General Danger & ICMI Only'::text
            WHEN screening.child_icmi_all <> ''::text AND screening.child_danger_yn = 'no'::text AND
            CASE
                WHEN screening.child_icmi_cough IS NOT NULL AND screening.child_icmi_cough <> ''::text THEN 'yes'::text
                WHEN screening.child_icmi_diarrhea IS NOT NULL AND screening.child_icmi_diarrhea <> ''::text THEN 'yes'::text
                WHEN screening.child_icmi_ear IS NOT NULL AND screening.child_icmi_ear <> ''::text THEN 'yes'::text
                WHEN screening.child_icmi_fever IS NOT NULL AND screening.child_icmi_fever <> ''::text THEN 'yes'::text
                ELSE 'no'::text
            END = 'yes'::text THEN 'IMCI Danger Signs'::text
            WHEN screening.child_icmi_all <> ''::text AND screening.child_danger_yn = 'no'::text AND
            CASE
                WHEN screening.child_icmi_cough IS NOT NULL AND screening.child_icmi_cough <> ''::text THEN 'yes'::text
                WHEN screening.child_icmi_diarrhea IS NOT NULL AND screening.child_icmi_diarrhea <> ''::text THEN 'yes'::text
                WHEN screening.child_icmi_ear IS NOT NULL AND screening.child_icmi_ear <> ''::text THEN 'yes'::text
                WHEN screening.child_icmi_fever IS NOT NULL AND screening.child_icmi_fever <> ''::text THEN 'yes'::text
                ELSE 'no'::text
            END = 'no'::text THEN 'IMCI Only'::text
            WHEN screening.child_icmi_all = ''::text AND screening.child_danger_yn = 'no'::text AND (screening.child_dewormed_yesno = 'no'::text OR screening.child_vita_yesno = 'no'::text OR screening.child_imm_9mo = 'no'::text OR screening.child_imm_12mo = 'no'::text) THEN 'No Danger Signs but missing VitA, Deworm and/or Imm'::text
            WHEN screening.child_icmi_all = ''::text THEN 'No IMCI or General Danger Signs Observed'::text
            ELSE ''::text
        END AS updated_status,
        CASE
            WHEN (screening.child_icmi_rhuref = 'yes'::text OR screening.child_danger_rhuref = 'yes'::text OR screening.child_imm_rhuref = 'yes'::text) AND screening.malnutr_rhuref = 'no'::text THEN 'Gen/IMCI Treatment Ongoing - RHU Referral'::text
            WHEN (screening.child_icmi_rhuref = 'yes'::text OR screening.child_danger_rhuref = 'yes'::text OR screening.child_imm_rhuref = 'yes'::text) AND screening.malnutr_rhuref = 'yes'::text THEN 'Gen/IMCI Treament Ongoing - RHU Referral'::text
            WHEN (screening.child_icmi_rhuref = 'yes'::text OR screening.child_danger_rhuref = 'yes'::text OR screening.child_imm_rhuref = 'yes'::text) AND screening.malnutr_rhuref IS NULL THEN 'Gen/IMCI Treatment Ongoing - RHU Referral'::text
            WHEN (screening.child_icmi_rhuref = 'no'::text OR screening.child_danger_rhuref = 'no'::text OR screening.child_imm_rhuref = 'no'::text) AND screening.malnutr_rhuref = 'yes'::text THEN 'Gen/IMCI Treatment Stopped - but Given Malnutrition Referral'::text
            WHEN (screening.child_icmi_rhuref = 'no'::text OR screening.child_danger_rhuref = 'no'::text OR screening.child_imm_rhuref = 'no'::text) AND (screening.malnutr_rhuref = 'no'::text OR screening.malnutr_rhuref IS NULL) THEN 'All Treatment Stopped - Refused/Not Given Referral'::text
            ELSE 'No Referral to RHU'::text
        END AS updated_treatment,
    date_part('day'::text, CURRENT_DATE::timestamp with time zone - screening.report_date) AS days_since_report
   FROM reportview_screening_upd screening
  WHERE (screening.child_danger_yn = 'yes'::text OR screening.child_icmi_all <> ''::text OR screening.child_dewormed_yesno = 'no'::text OR screening.child_imm_9mo = 'no'::text OR screening.child_imm_12mo = 'no'::text) AND (screening.child_danger_rhuref IS NOT NULL OR screening.child_icmi_rhuref IS NOT NULL OR screening.child_imm_rhuref IS NOT NULL) AND screening.child_continue = 'yes'::text
UNION ALL
 SELECT report.report_uuid,
    report.report_date,
    report.which_report AS stage,
    report.hhmem_uuid,
    NULL::text AS continue_update,
    report.rhu_visit AS rhu_attendance,
    NULL::text AS gendanger_yn,
    NULL::text AS gendanger_symptoms,
    NULL::text AS dewormed_yn,
    NULL::text AS vita_yn,
    report.imci_signs AS imci_general_all,
    report.imci_danger_signs AS imci_danger_yn,
    report.cough_signs_status AS imci_danger_cough,
    report.diarrhea_signs_status AS imci_danger_diarrhea,
    report.ear_signs_status AS imci_danger_ear,
    report.fever_signs_status AS imci_danger_fever,
    report.imci_referral AS rhuref_imci,
    NULL::text AS rhuref_danger,
    NULL::text AS rhuref_imm,
    NULL::text AS suspected_malnutr_status,
    NULL::text AS rhuref_malnutrition,
    NULL::integer AS imci_rhuref_cnt,
    report.rhuvisit_yes_diagnosis AS rhu_diagnosis,
    report.rhuvisit_yes_treatment AS rhu_treatment,
    report.appt_symptom_state AS rhu_symptoms_status,
    report.appt_treatment_state AS rhu_treatment_status,
    report.appointment_req AS followup_appt,
    report.appt_req_date::date AS followup_date,
        CASE
            WHEN report.imci_signs <> ''::text AND report.imci_danger_signs = 'yes'::text THEN 'IMCI with Danger Signs'::text
            WHEN report.imci_signs <> ''::text AND report.imci_danger_signs = 'no'::text THEN 'IMCI Only'::text
            WHEN report.imci_signs = ''::text THEN 'No IMCI Signs Observed'::text
            ELSE 'Other'::text
        END AS updated_status,
        CASE
            WHEN report.appt_symptom_state = 'resolved'::text AND report.appt_treatment_state = 'complete'::text AND report.imci_signs = ''::text AND report.imci_danger_signs = 'no'::text AND (report.appointment_req = 'no'::text OR report.appointment_req = 'yes'::text AND report.appt_req_date::date = report.report_date::date) THEN 'Treatment Likely Complete - Attended RHU, No Appt Scheduled (Discharge)'::text
            WHEN report.appt_symptom_state = 'resolved'::text AND report.appt_treatment_state = 'complete'::text AND report.imci_signs = ''::text AND report.imci_danger_signs = 'no'::text AND report.appointment_req = 'yes'::text THEN 'Treatment Almost Completed - Attended RHU, Appt Scheduled'::text
            WHEN report.appt_symptom_state = 'resolved'::text AND report.appt_treatment_state = 'complete'::text AND report.imci_signs <> ''::text AND report.imci_danger_signs = 'yes'::text AND report.appointment_req = 'no'::text THEN 'Treatment Requires Followup - Attended RHU, No Appt Scheduled'::text
            WHEN report.appt_symptom_state = 'resolved'::text AND report.appt_treatment_state = 'complete'::text AND report.imci_signs <> ''::text AND report.imci_danger_signs = 'yes'::text AND report.appointment_req = 'yes'::text THEN 'Treatment Ongoing - Attended RHU, Appt Scheduled'::text
            WHEN report.appt_symptom_state = 'ongoing'::text OR report.appt_treatment_state = 'ongoing'::text AND report.imci_signs <> ''::text AND report.imci_danger_signs = 'yes'::text AND report.appt_req_date::date = report.report_date::date THEN 'Treatment Ongoing - Attended RHU, No Appt Scheduled'::text
            WHEN report.appt_symptom_state = 'ongoing'::text OR report.appt_treatment_state = 'ongoing'::text AND report.imci_signs <> ''::text AND report.appointment_req = 'yes'::text THEN 'Treatment Ongoing - Attended RHU, Appt Scheduled'::text
            WHEN report.appt_symptom_state = 'ongoing'::text OR report.appt_treatment_state = 'ongoing'::text AND report.imci_signs <> ''::text AND report.appointment_req = 'no'::text THEN 'Treatment Ongoing - Attended RHU, No Appt Scheduled'::text
            WHEN report.rhu_visit = 'no'::text THEN 'Unknown - No RHU Visit'::text
            ELSE 'Unknown'::text
        END AS updated_treatment,
    date_part('day'::text, CURRENT_DATE::timestamp with time zone - report.report_date) AS days_since_report
   FROM reportview_imci_followup_48h report
UNION ALL
 SELECT report.report_uuid,
    report.report_date,
    report.which_report AS stage,
    report.hhmem_uuid,
    report.cont_followup AS continue_update,
    NULL::text AS rhu_attendance,
    NULL::text AS gendanger_yn,
    NULL::text AS gendanger_symptoms,
    NULL::text AS dewormed_yn,
    NULL::text AS vita_yn,
    report.imci_signs AS imci_general_all,
        CASE
            WHEN report.cough_signs_status IS NOT NULL AND report.cough_signs_status <> ''::text THEN 'yes'::text
            WHEN report.diarrhea_signs_status IS NOT NULL AND report.diarrhea_signs_status <> ''::text THEN 'yes'::text
            WHEN report.ear_signs_status IS NOT NULL AND report.ear_signs_status <> ''::text THEN 'yes'::text
            WHEN report.fever_signs_status IS NOT NULL AND report.fever_signs_status <> ''::text THEN 'yes'::text
            ELSE 'no'::text
        END AS imci_danger_yn,
    report.cough_signs_status AS imci_danger_cough,
    report.diarrhea_signs_status AS imci_danger_diarrhea,
    report.ear_signs_status AS imci_danger_ear,
    report.fever_signs_status AS imci_danger_fever,
    report.imci_referral AS rhuref_imci,
    NULL::text AS rhuref_danger,
    NULL::text AS rhuref_imm,
    NULL::text AS suspected_malnutr_status,
    NULL::text AS rhuref_malnutrition,
    NULL::integer AS imci_rhuref_cnt,
    NULL::text AS rhu_diagnosis,
    NULL::text AS rhu_treatment,
    report.symptom_state AS rhu_symptoms_status,
    report.treatment_state AS rhu_treatment_status,
    NULL::text AS followup_appt,
    report.imci_dangersign_followupdate::date AS followup_date,
        CASE
            WHEN report.imci_signs <> ''::text AND
            CASE
                WHEN report.cough_signs_status IS NOT NULL AND report.cough_signs_status <> ''::text THEN 'yes'::text
                WHEN report.diarrhea_signs_status IS NOT NULL AND report.diarrhea_signs_status <> ''::text THEN 'yes'::text
                WHEN report.ear_signs_status IS NOT NULL AND report.ear_signs_status <> ''::text THEN 'yes'::text
                WHEN report.fever_signs_status IS NOT NULL AND report.fever_signs_status <> ''::text THEN 'yes'::text
                ELSE 'no'::text
            END = 'yes'::text THEN 'IMCI with Danger Signs'::text
            WHEN report.imci_signs <> ''::text AND
            CASE
                WHEN report.cough_signs_status IS NOT NULL AND report.cough_signs_status <> ''::text THEN 'yes'::text
                WHEN report.diarrhea_signs_status IS NOT NULL AND report.diarrhea_signs_status <> ''::text THEN 'yes'::text
                WHEN report.ear_signs_status IS NOT NULL AND report.ear_signs_status <> ''::text THEN 'yes'::text
                WHEN report.fever_signs_status IS NOT NULL AND report.fever_signs_status <> ''::text THEN 'yes'::text
                ELSE 'no'::text
            END = 'no'::text THEN 'IMCI Only'::text
            WHEN report.imci_signs = ''::text THEN 'No IMCI Signs Observed'::text
            WHEN report.cont_followup = 'no'::text THEN 'Unknown - Not Asked'::text
            ELSE 'Other'::text
        END AS updated_status,
        CASE
            WHEN report.imci_signs = ''::text THEN 'Treatment Likely Complete - Requires Discharge'::text
            WHEN report.imci_signs <> ''::text AND report.imci_referral = 'no'::text THEN 'Treatment Requires Followup - No RHU Referral'::text
            WHEN report.imci_signs <> ''::text AND report.imci_referral = 'yes'::text THEN 'Treatment Ongoing - Referred to RHU'::text
            WHEN report.imci_signs <> ''::text AND report.imci_referral IS NULL THEN 'Treatment Ongoing - Home Monitoring Only'::text
            WHEN report.cont_followup = 'no'::text THEN 'Unknown - No Followup Completed'::text
            ELSE 'Unknown'::text
        END AS updated_treatment,
    date_part('day'::text, CURRENT_DATE::timestamp with time zone - report.report_date) AS days_since_report
   FROM reportview_imci_followup_weekly report
UNION ALL
 SELECT report.report_uuid,
    report.report_date,
    report.which_report AS stage,
    report.hhmem_uuid,
    'yes'::text AS continue_update,
    NULL::text AS rhu_attendance,
    NULL::text AS gendanger_yn,
    NULL::text AS gendanger_symptoms,
    NULL::text AS dewormed_yn,
    NULL::text AS vita_yn,
    NULL::text AS imci_general_all,
    NULL::text AS imci_danger_yn,
    NULL::text AS imci_danger_cough,
    NULL::text AS imci_danger_diarrhea,
    NULL::text AS imci_danger_ear,
    NULL::text AS imci_danger_fever,
    NULL::text AS rhuref_imci,
    NULL::text AS rhuref_danger,
    NULL::text AS rhuref_imm,
    NULL::text AS suspected_malnutr_status,
    NULL::text AS rhuref_malnutrition,
    NULL::integer AS imci_rhuref_cnt,
    NULL::text AS rhu_diagnosis,
    NULL::text AS rhu_treatment,
    'resolved'::text AS rhu_symptoms_status,
    'discharged'::text AS rhu_treatment_status,
    'no'::text AS followup_appt,
    report.date_resolved::date AS followup_date,
    'Recovered'::text AS updated_status,
    'Discharged'::text AS updated_treatment,
    date_part('day'::text, CURRENT_DATE::timestamp with time zone - report.report_date) AS days_since_report
   FROM reportview_imci_recovery report;