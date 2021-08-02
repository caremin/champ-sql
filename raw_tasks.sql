CREATE OR REPLACE VIEW public.raw_tasks
AS SELECT couchdb.doc
   FROM couchdb
  WHERE (couchdb.doc ->> 'type'::text) = 'task'::text;