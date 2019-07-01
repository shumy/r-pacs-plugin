/*
delete from node;
delete from annotation;
delete from pointer;

update pointer set next = 1, last = 0;
*/

select count(*) from study; --studies 7350
select count(*) from serie; --series 16083
select count(*) from image; --images 30985

select count(*), count(distinct image_id) from annotation; -- a total of 3302 annotations from 1185 distincts images
select count(distinct annotation_id) from node where type_id = 4;

/*deleting invalid annotations*/
select * from node
--delete from node
where annotation_id in (select id from annotation where annotator_id in (3, 5)); 

select * from annotation
--delete from annotation
where annotator_id in (3, 5);

select * from pointer
--delete from pointer
where annotator_id in (3, 5);

--assigned dataset--
select
  an.id, an.alias, an.name, ds.id, ds.name
from dataset ds, annotator an
where ds.id  = an.current_dataset_id
and an.name in ('susanaapenas', 'amvgcarneiro', 'carolinamaia', 'luismendonc', 'ricardopereira');

--my datasets--
select
  an.id, an.alias, an.name, ds.id, ds.name
from dataset ds, dataset_annotator dsa, annotator an
where ds.id  = dsa.dataset_id and dsa.annotator_id = an.id
and an.name in ('susanaapenas', 'amvgcarneiro', 'carolinamaia', 'luismendonc', 'ricardopereira')
order by an.id, ds.id;

--remove from my-datasets--
select * from dataset_annotator dsa
--delete from dataset_annotator dsa
where dsa.dataset_id not in (select id from dataset where name in ('Dataset_22Nov','Dataset_Lesions_001','Dataset_Lesions_002','Dataset_Lesions_003','Dataset_Lesions_004'))
and dsa.annotator_id in (select id from annotator where name in ('susanaapenas', 'amvgcarneiro', 'carolinamaia', 'luismendonc', 'ricardopereira'));


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


--Time stats--
select t_time / 3600 as total_time, t_time / t_number as avg_pet_an, t_number as total_number from 
  (select sum(spent) as t_time, count(*) as t_number from
    (select cast(fields->key->>'timeSpent' as double precision) as spent from
      (select id, fields, jsonb_object_keys(fields) as key from node where type_id = 4) sub1
    ) sub2 where spent > 0 and spent < 400) sub3 
;

2688 -> 17.9h
3207 -> 21.4h / 45.6h
    
