CREATE OR REPLACE VIEW public.raw_reports
AS SELECT couchdb.doc
   FROM couchdb
  WHERE (couchdb.doc ->> 'type'::text) = 'data_record'::text;