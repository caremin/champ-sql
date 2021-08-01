CREATE OR REPLACE VIEW public.contactview_chc
AS SELECT chc.name,
    pplfields.uuid,
    pplfields.phone,
    pplfields.phone2,
    pplfields.date_of_birth,
    pplfields.parent_type,
    community.uuid AS area_uuid,
    community.parent_uuid AS branch_uuid
   FROM contactview_person_fields pplfields
     JOIN contactview_metadata chc ON chc.uuid = pplfields.uuid
     JOIN contactview_metadata community ON chc.parent_uuid = community.uuid
  WHERE pplfields.parent_type = 'contact'::text;