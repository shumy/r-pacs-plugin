alter table annotation drop constraint if exists fk_annotation_image_id;
drop index if exists ix_annotation_image_id;

alter table annotation drop constraint if exists fk_annotation_annotator_id;
drop index if exists ix_annotation_annotator_id;

alter table annotator drop constraint if exists fk_annotator_current_dataset_id;
drop index if exists ix_annotator_current_dataset_id;

alter table dataset_image drop constraint if exists fk_dataset_image_dataset;
drop index if exists ix_dataset_image_dataset;

alter table dataset_image drop constraint if exists fk_dataset_image_image;
drop index if exists ix_dataset_image_image;

alter table dataset_annotator drop constraint if exists fk_dataset_annotator_dataset;
drop index if exists ix_dataset_annotator_dataset;

alter table dataset_annotator drop constraint if exists fk_dataset_annotator_annotator;
drop index if exists ix_dataset_annotator_annotator;

alter table image drop constraint if exists fk_image_serie_id;
drop index if exists ix_image_serie_id;

alter table node drop constraint if exists fk_node_type_id;
drop index if exists ix_node_type_id;

alter table node drop constraint if exists fk_node_annotation_id;
drop index if exists ix_node_annotation_id;

alter table pointer drop constraint if exists fk_pointer_dataset_id;
drop index if exists ix_pointer_dataset_id;

alter table pointer drop constraint if exists fk_pointer_annotator_id;
drop index if exists ix_pointer_annotator_id;

alter table pointer drop constraint if exists fk_pointer_type_id;
drop index if exists ix_pointer_type_id;

alter table serie drop constraint if exists fk_serie_study_id;
drop index if exists ix_serie_study_id;

alter table study drop constraint if exists fk_study_patient_id;
drop index if exists ix_study_patient_id;

drop table if exists annotation;

drop table if exists annotator;

drop table if exists dataset;

drop table if exists dataset_image;

drop table if exists dataset_annotator;

drop table if exists image;

drop table if exists node;

drop table if exists node_type;

drop table if exists patient;

drop table if exists pointer;

drop table if exists serie;

drop table if exists study;

drop index if exists ix_annotator_name;
drop index if exists ix_image_uid;
drop index if exists ix_patient_pid;
drop index if exists ix_serie_uid;
drop index if exists ix_study_uid;
