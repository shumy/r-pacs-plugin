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