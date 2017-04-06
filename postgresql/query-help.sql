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
  (select name from node_type where id = p.type_id) as type,
  p.next,
  p.last
from dataset ds, pointer p where ds.id = p.dataset_id
and p.annotator_id = 1
and p.dataset_id = 6;

--annotation nodes--
select
  a.id,
  (select name from annotator where id = a.annotator_id) as annotator,
  (select name from node_type where id = n.type_id) as type,
  n.fields
from annotation a, node n where a.id = n.annotation_id and a.id = 1;