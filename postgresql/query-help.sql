/*
delete from node;
delete from annotation;
delete from pointer;

update pointer set next = 1, last = 0;
*/

--dataset pointers--
select
  ds.id,
  ds.name,
  (select name from annotator where p.annotator_id = id) as annotator,
  (select name from node_type where id = p.type_id) as type,
  p.next,
  p.last
from dataset ds, pointer p where ds.id = p.dataset_id;

--annotator stats--
select
  (select name from annotator where id = annotator_id) as annotator,
  count(*) as total from annotation
group by annotator
order by total desc;

--annotation nodes--
select
  a.id,
  a.image_id as image,
  (select name from annotator where id = a.annotator_id) as annotator,
  (select name from node_type where id = n.type_id) as type,
  n.fields
from annotation a, node n where a.id = n.annotation_id
order by a.id, type desc;

--jsonb queries
select id, fields->'local' as local from node where fields->>'quality' != 'BAD' order by annotation_id;
select * from node where fields ? 'quality';


select
  a.id,
  a.image_id as image,
  (select name from annotator where id = a.annotator_id) as annotator,
  (select name from node_type where id = n.type_id) as type,
  n.fields, n.created_at
from annotation a, node n where a.id = n.annotation_id
order by a.id, type desc;

--annotation timestamps
select
  an.id, 
  at.name,
  to_char(an.created_at, 'YYYY-MM-DD HH24:MI:SS.MS') as created_at
from annotation an, annotator at where an.annotator_id = at.id
and at.name = 'susanaapenas'
order by an.created_at;

--annotation timeSpent statistics
select
 annotation_id, created_at,
 (select name from node_type where id = n.type_id),
 fields->>'timeSpent'
from node n order by annotation_id, created_at;

