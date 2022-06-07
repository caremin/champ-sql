CREATE OR REPLACE VIEW public.reportview_health_facility_2w
AS SELECT reports.doc ->> '_id'::text AS report_uuid,
    to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision) AS report_date,
    reports.doc ->> 'form'::text AS which_report,
    reports.doc #>> '{fields,patient_uuid}'::text[] AS hhmem_uuid,
    reports.doc #>> '{contact,parent,_id}'::text[] AS hh_uuid,
    reports.doc #>> '{contact,_id}'::text[] AS chc_uuid,
    reports.doc #>> '{fields,patient_gender}'::text[] AS patient_gender,
    reports.doc #>> '{fields,patient_age_in_days}'::text[] AS patient_age_in_days,
    reports.doc #>> '{fields,g_information,latest_hf_visit_date}'::text[] AS latest_hf_visited_date,
    reports.doc #>> '{fields,g_information,latest_height}'::text[] AS latest_height,
    reports.doc #>> '{fields,g_information,latest_weight}'::text[] AS latest_weight,
    reports.doc #>> '{fields,g_information,zscore_computation}'::text[] AS latest_zscore,
        CASE
            WHEN (reports.doc #>> '{fields,g_information,zscore_classification}'::text[]) = 'unknown'::text THEN 'Unknown'::text
            WHEN (reports.doc #>> '{fields,g_information,zscore_classification}'::text[]) = 'normal'::text THEN 'Normal'::text
            WHEN (reports.doc #>> '{fields,g_information,zscore_classification}'::text[]) = 'wasted'::text THEN 'Wasted'::text
            WHEN (reports.doc #>> '{fields,g_information,zscore_classification}'::text[]) = 'severely_wasted'::text THEN 'Severely Wasted'::text
            ELSE reports.doc #>> '{fields,g_information,zscore_classification}'::text[]
        END AS latest_zscore_classification,
    reports.doc #>> '{fields,g_confirmation,g_visited_ask,visit_health_facility}'::text[] AS has_visit_health_facility,
        CASE
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_ask,reason_no_rhu}'::text[]) = 'rhu_hh_recovered'::text THEN 'Household member or child already recovered'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_ask,reason_no_rhu}'::text[]) = 'rhu_hh_death'::text THEN 'Household member / child passed away (Please submit a mute form)'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_ask,reason_no_rhu}'::text[]) = 'rhu_believe_not_needed'::text THEN 'Household member did not believe it was necessary to go to the RHU/Health Center'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_ask,reason_no_rhu}'::text[]) = 'rhu_staff'::text THEN 'No RHU/Health Center staff, RHU/Health Center closed, or RHU/Health Center has own schedule for delivering services'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_ask,reason_no_rhu}'::text[]) = 'rhu_supplies'::text THEN 'No RHU/Health Center supplies / medicines available'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_ask,reason_no_rhu}'::text[]) = 'rhu_covid_restrictions'::text THEN 'Covid restrictions / lockdown'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_ask,reason_no_rhu}'::text[]) = 'rhu_covid_concerns'::text THEN 'Concerns about catching Covid'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_ask,reason_no_rhu}'::text[]) = 'rhu_emergency'::text THEN 'Family or Health Emergency (Household member was sick)'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_ask,reason_no_rhu}'::text[]) = 'rhu_accompany'::text THEN 'No one to accompany child to RHU/Health Center / no one to take care of child(ren) while household member attends the RHU/Health Center'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_ask,reason_no_rhu}'::text[]) = 'rhu_travel'::text THEN 'Travel to the RHU/Health Center takes too much time, too difficult, or too far'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_ask,reason_no_rhu}'::text[]) = 'rhu_transportation'::text THEN 'Transportation to the RHU/Health Center is too expensive or unavailable'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_ask,reason_no_rhu}'::text[]) = 'rhu_work'::text THEN 'No money or needed to work'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_ask,reason_no_rhu}'::text[]) = 'rhu_weather'::text THEN 'Weather (e.g. raining)'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_ask,reason_no_rhu}'::text[]) = 'rhu_oth'::text THEN 'Other'::text
            ELSE reports.doc #>> '{fields,g_confirmation,g_visited_ask,reason_no_rhu}'::text[]
        END AS not_visited_hf,
    reports.doc #>> '{fields,g_confirmation,g_visited_ask,rhu_oth_reason_other}'::text[] AS reason_not_visited_hf,
    reports.doc #>> '{fields,g_confirmation,g_visited_info,visited_date}'::text[] AS recent_hf_visit_date,
        CASE
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_info,facility_type}'::text[]) = 'RHU'::text THEN 'Rural Health Unit'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_info,facility_type}'::text[]) = 'BHS'::text THEN 'Barangay Health Station'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_info,facility_type}'::text[]) = 'HC'::text THEN 'Health Center'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_visited_info,facility_type}'::text[]) = 'Private'::text THEN 'Private'::text
            ELSE reports.doc #>> '{fields,g_confirmation,g_visited_info,facility_type}'::text[]
        END AS types_of_hf_visited,
    reports.doc #>> '{fields,g_confirmation,g_visited_info,hf_providing_treatment}'::text[] AS hf_providing_treatment,
        CASE
            WHEN (reports.doc #>> '{fields,g_confirmation,g_treatment_type,treatment_maln}'::text[]) = 'treatment_maln_none'::text THEN 'No Treatment'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_treatment_type,treatment_maln}'::text[]) = 'treatment_maln_rutf'::text THEN 'RUTF '::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_treatment_type,treatment_maln}'::text[]) = 'treatment_maln_rusf'::text THEN 'RUSF'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_treatment_type,treatment_maln}'::text[]) = 'treatment_maln_sup_feed'::text THEN 'Home Management (Supplementary feeding)'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_treatment_type,treatment_maln}'::text[]) = 'treatment_maln_oth'::text THEN 'Other'::text
            ELSE reports.doc #>> '{fields,g_confirmation,g_treatment_type,treatment_maln}'::text[]
        END AS maln_treatment_type,
    reports.doc #>> '{fields,g_confirmation,g_treatment_type,treatment_maln_other}'::text[] AS other_maln_treatment_type,
    reports.doc #>> '{fields,g_confirmation,g_treatment_type,child_compliant}'::text[] AS child_compliant,
    reports.doc #>> '{fields,g_confirmation,updated_weight_by_hf}'::text[] AS weight_updated_by_hf,
    reports.doc #>> '{fields,g_confirmation,g_weight_measurement,hf_weight_updated}'::text[] AS hf_weight_update,
    reports.doc #>> '{fields,g_confirmation,g_weight_measurement,hf_weight}'::text[] AS chc_weight_update,
    reports.doc #>> '{fields,g_confirmation,g_hf_followup,hf_followup_30days}'::text[] AS hf_followup_30days,
        CASE
            WHEN (reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list}'::text[]) = 'attend30days_hh_cured'::text THEN 'Health facility discharged child has cured (normal)'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list}'::text[]) = 'attend30days_hh_death'::text THEN 'Household member / child passed away (Please submit a mute form)'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list}'::text[]) = 'attend30days_believe_not_needed'::text THEN 'Household member did not believe it was necessary to go to the Health Facility'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list}'::text[]) = 'attend30days_staff'::text THEN 'No Health Facility staff, Health Facility closed, or Health Facility has own schedule for delivering services'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list}'::text[]) = 'attend30days_supplies'::text THEN 'No Health Facility supplies / medicines available'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list}'::text[]) = 'attend30days_covid_restrictions'::text THEN 'Covid restrictions / lockdown'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list}'::text[]) = 'attend30days_covid_concerns'::text THEN 'Concerns about catching Covid'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list}'::text[]) = 'attend30days_emergency'::text THEN 'Family or Health Emergency (Household member was sick)'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list}'::text[]) = 'attend30days_accompany'::text THEN 'No one to accompany child to Health Facility / no one to take care of child(ren) while household member attends the Health Facility'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list}'::text[]) = 'attend30days_travel'::text THEN 'Travel to the Health Facility takes too much time, too difficult, or too far'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list}'::text[]) = 'attend30days_transportation'::text THEN 'Transportation to the Health Facility is too expensive or unavailable'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list}'::text[]) = 'attend30days_work'::text THEN 'No money or needed to work'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list}'::text[]) = 'attend30days_weather'::text THEN 'Weather (e.g. raining)'::text
            WHEN (reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list}'::text[]) = 'attend30days_oth'::text THEN 'Other'::text
            ELSE reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list}'::text[]
        END AS not_attend_30days_hf,
    reports.doc #>> '{fields,g_confirmation,g_hf_followup,attend_30days_no_reason_list_other}'::text[] AS not_attend_30days_hf_otherreason,
    reports.doc #>> '{fields,g_height_information,g_lastest_information_height,previous_height}'::text[] AS previous_height,
    reports.doc #>> '{fields,g_height_information,g_hf_followup_height,height_correction}'::text[] AS height_need_correction,
        CASE
            WHEN (reports.doc #>> '{fields,g_height_information,g_hf_followup_height,correct_height_reason_list}'::text[]) = 'height_error'::text THEN 'Child height has a MAJOR error'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_hf_followup_height,correct_height_reason_list}'::text[]) = 'height_1m_update'::text THEN 'If the child is under 1 year old, and one month passed since last height measurement'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_hf_followup_height,correct_height_reason_list}'::text[]) = 'height_4m_update'::text THEN 'If the child is between 1-5 years old, and four months have passed since last height measurement'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_hf_followup_height,correct_height_reason_list}'::text[]) = 'height_hf_update'::text THEN 'The last height measurement was taken by the CHC, and the health facility has provided an updated height measurement'::text
            ELSE reports.doc #>> '{fields,g_height_information,g_hf_followup_height,correct_height_reason_list}'::text[]
        END AS reason_for_updating_height,
    reports.doc #>> '{fields,g_height_information,g_hf_followup_height_blank,height_update_from_hf}'::text[] AS received_hf_height_update,
    reports.doc #>> '{fields,g_height_information,height_measurement_stadiometer}'::text[] AS has_stadiometer,
    reports.doc #>> '{fields,g_height_information,hf_height_updated}'::text[] AS height_measured_by_hf,
    reports.doc #>> '{fields,g_height_information,hf_height}'::text[] AS height_measured_by_chc,
        CASE
            WHEN (reports.doc #>> '{fields,g_height_information,g_no_stadiometer,reason_no_stadiometer}'::text[]) = 'equip_never_received'::text THEN 'Never Received equipment'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_no_stadiometer,reason_no_stadiometer}'::text[]) = 'equip_lost'::text THEN 'Equipment lost'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_no_stadiometer,reason_no_stadiometer}'::text[]) = 'equip_forgot'::text THEN 'Equipment forgotten today'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_no_stadiometer,reason_no_stadiometer}'::text[]) = 'equip_damaged'::text THEN 'Damaged or non-functional equipment'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_no_stadiometer,reason_no_stadiometer}'::text[]) = 'equip_oth'::text THEN 'Other'::text
            ELSE reports.doc #>> '{fields,g_height_information,g_no_stadiometer,reason_no_stadiometer}'::text[]
        END AS reason_for_no_stadiometer,
    reports.doc #>> '{fields,g_height_information,g_no_stadiometer,reason_no_stadiometer_other}'::text[] AS other_reason_for_no_stadiometer,
    reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore_,g_discharge_reminder,new_weight}'::text[] AS new_weight,
    reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore_,g_discharge_reminder,new_height}'::text[] AS new_height,
    reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore_,g_discharge_reminder,updated_wfh_score}'::text[] AS updated_wfh_zscore,
        CASE
            WHEN (reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore_,g_discharge_reminder,updated_wfh_class}'::text[]) = 'unknown'::text THEN 'Unknown'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore_,g_discharge_reminder,updated_wfh_class}'::text[]) = 'normal'::text THEN 'Normal'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore_,g_discharge_reminder,updated_wfh_class}'::text[]) = 'wasted'::text THEN 'Wasted'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore_,g_discharge_reminder,updated_wfh_class}'::text[]) = 'severely_wasted'::text THEN 'Severely Wasted'::text
            ELSE reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore_,g_discharge_reminder,updated_wfh_class}'::text[]
        END AS updated_wfh_class,
    reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore,g_weight_stag_decrease_img,g_referral_given,malnutrition_referral_given}'::text[] AS malnutrition_referral_given,
        CASE
            WHEN (reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore,g_weight_stag_decrease_img,g_referral_given,reason_not_accepting_referrals}'::text[]) = 'verbal_referral'::text THEN 'Referral given - Verbal referral given, please select Yes for RHU Referral given?'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore,g_weight_stag_decrease_img,g_referral_given,reason_not_accepting_referrals}'::text[]) = 'no_staff_closed'::text THEN 'No RHU staff, RHU closed, or RHU has own schedule for delivering services'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore,g_weight_stag_decrease_img,g_referral_given,reason_not_accepting_referrals}'::text[]) = 'no_supplies'::text THEN 'No RHU supplies available'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore,g_weight_stag_decrease_img,g_referral_given,reason_not_accepting_referrals}'::text[]) = 'no_accompany'::text THEN 'No one to accompany child to RHU / no one to take care of child(ren) while household member attends the RHU'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore,g_weight_stag_decrease_img,g_referral_given,reason_not_accepting_referrals}'::text[]) = 'travel_time'::text THEN 'Travel to the RHU takes too much time, too difficult, or too far'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore,g_weight_stag_decrease_img,g_referral_given,reason_not_accepting_referrals}'::text[]) = 'transportation_rhu'::text THEN 'Transportation to the RHU is too expensive or unavailable'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore,g_weight_stag_decrease_img,g_referral_given,reason_not_accepting_referrals}'::text[]) = 'household_refusal'::text THEN 'Household member refused referral'::text
            WHEN (reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore,g_weight_stag_decrease_img,g_referral_given,reason_not_accepting_referrals}'::text[]) = 'other'::text THEN 'Other'::text
            ELSE reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore,g_weight_stag_decrease_img,g_referral_given,reason_not_accepting_referrals}'::text[]
        END AS reason_not_accepting_maln_referrals,
    reports.doc #>> '{fields,g_height_information,g_zscore_calculation,g_zscore,g_weight_stag_decrease_img,g_referral_given,other_reason_not_accepting_referrals}'::text[] AS other_reason_not_accepting_referrals
   FROM raw_reports reports
  WHERE (reports.doc ->> 'form'::text) = 'health_facility_followup_every_2w'::text
  ORDER BY (to_timestamp((((reports.doc ->> 'reported_date'::text)::bigint) / 1000)::double precision)) DESC;