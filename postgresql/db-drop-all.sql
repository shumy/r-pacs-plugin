alter table if exists image drop constraint if exists fk_image_ref_serie;
drop index if exists ix_image_ref_serie;

alter table if exists serie drop constraint if exists fk_serie_ref_study;
drop index if exists ix_serie_ref_study;

alter table if exists study drop constraint if exists fk_study_ref_patient;
drop index if exists ix_study_ref_patient;

drop table if exists image cascade;

drop table if exists patient cascade;

drop table if exists serie cascade;

drop table if exists study cascade;

drop index if exists ix_image_uid;
drop index if exists ix_patient_pid;
drop index if exists ix_serie_uid;
drop index if exists ix_study_uid;
