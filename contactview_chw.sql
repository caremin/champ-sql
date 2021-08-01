CREATE OR REPLACE VIEW public.contactview_chw
AS SELECT chw.name,
    pplfields.uuid,
    pplfields.phone,
    pplfields.phone2,
    pplfields.date_of_birth,
    pplfields.parent_type,
    chcarea.uuid AS area_uuid,
    chcarea.parent_uuid AS branch_uuid
   FROM contactview_person_fields pplfields
     JOIN contactview_metadata chw ON chw.uuid = pplfields.uuid
     JOIN contactview_metadata chcarea ON chw.parent_uuid = chcarea.uuid
  WHERE pplfields.parent_type = 'health_center'::text;