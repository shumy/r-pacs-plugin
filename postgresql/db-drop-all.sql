alter table if exists annotation drop constraint if exists fk_annotation_image_id;
drop index if exists ix_annotation_image_id;

alter table if exists annotation drop constraint if exists fk_annotation_annotator_id;
drop index if exists ix_annotation_annotator_id;

alter table if exists image drop constraint if exists fk_image_serie_id;
drop index if exists ix_image_serie_id;

alter table if exists lesion drop constraint if exists fk_lesion_image_id;
drop index if exists ix_lesion_image_id;

alter table if exists lesion drop constraint if exists fk_lesion_annotator_id;
drop index if exists ix_lesion_annotator_id;

alter table if exists serie drop constraint if exists fk_serie_study_id;
drop index if exists ix_serie_study_id;

alter table if exists study drop constraint if exists fk_study_patient_id;
drop index if exists ix_study_patient_id;

drop table if exists annotation cascade;

drop table if exists annotator cascade;

drop table if exists image cascade;

drop table if exists lesion cascade;

drop table if exists patient cascade;

drop table if exists serie cascade;

drop table if exists study cascade;

drop index if exists ix_annotator_name;
drop index if exists ix_image_uid;
drop index if exists ix_patient_pid;
drop index if exists ix_serie_uid;
drop index if exists ix_study_uid;
