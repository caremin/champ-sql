CREATE OR REPLACE VIEW public.contactview_hospital
AS SELECT cmd.uuid,
    cmd.name
   FROM contactview_metadata cmd
  WHERE cmd.type = 'district_hospital'::text;