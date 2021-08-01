CREATE OR REPLACE VIEW public.contactview_clinic
AS SELECT cmd.uuid,
    cmd.name,
    chw.uuid AS chw_uuid,
    cmd.reported AS created
   FROM contactview_metadata cmd
     JOIN contactview_chw chw ON cmd.parent_uuid = chw.area_uuid
  WHERE cmd.type = 'clinic'::text;