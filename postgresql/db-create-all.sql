create table annotation (
  id                            bigserial not null,
  draft                         boolean not null,
  image_id                      bigint not null,
  annotator_id                  bigint not null,
  quality                       integer not null,
  local                         integer not null,
  retinopathy                   integer not null,
  maculopathy                   integer not null,
  photocoagulation              integer not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
  constraint ck_annotation_quality check ( quality in (0,1,2,3)),
  constraint ck_annotation_local check ( local in (0,1,2)),
  constraint ck_annotation_retinopathy check ( retinopathy in (0,1,2,3,4)),
  constraint ck_annotation_maculopathy check ( maculopathy in (0,1,2)),
  constraint ck_annotation_photocoagulation check ( photocoagulation in (0,1,2)),
  constraint pk_annotation primary key (id)
);

create table annotator (
  id                            bigserial not null,
  name                          varchar(255) not null,
  alias                         varchar(255) not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
  constraint uq_annotator_name unique (name),
  constraint pk_annotator primary key (id)
);

create table image (
  id                            bigserial not null,
  serie_id                      bigint not null,
  uid                           varchar(255) not null,
  number                        integer not null,
  photometric                   varchar(255) not null,
  columns                       integer not null,
  rows                          integer not null,
  laterality                    varchar(255) not null,
  uri                           varchar(255) not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
  constraint uq_image_uid unique (uid),
  constraint pk_image primary key (id)
);

create table lesion (
  id                            bigserial not null,
  image_id                      bigint not null,
  annotator_id                  bigint not null,
  type                          integer not null,
  geometry                      varchar(255) not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
  constraint ck_lesion_type check ( type in (0,1,2,3,4)),
  constraint pk_lesion primary key (id)
);

create table patient (
  id                            bigserial not null,
  pid                           varchar(255) not null,
  name                          varchar(255) not null,
  sex                           varchar(255) not null,
  birthdate                     date not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
  constraint uq_patient_pid unique (pid),
  constraint pk_patient primary key (id)
);

create table serie (
  id                            bigserial not null,
  study_id                      bigint not null,
  uid                           varchar(255) not null,
  number                        integer not null,
  description                   varchar(255) not null,
  datetime                      timestamptz not null,
  modality                      varchar(255) not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
  constraint uq_serie_uid unique (uid),
  constraint pk_serie primary key (id)
);

create table study (
  id                            bigserial not null,
  patient_id                    bigint not null,
  uid                           varchar(255) not null,
  sid                           varchar(255) not null,
  accession_number              varchar(255) not null,
  description                   varchar(255) not null,
  datetime                      timestamptz not null,
  institution_name              varchar(255) not null,
  institution_address           varchar(255) not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
  constraint uq_study_uid unique (uid),
  constraint pk_study primary key (id)
);

create index ix_annotator_name on annotator (name);
create index ix_image_uid on image (uid);
create index ix_patient_pid on patient (pid);
create index ix_serie_uid on serie (uid);
create index ix_study_uid on study (uid);
alter table annotation add constraint fk_annotation_image_id foreign key (image_id) references image (id) on delete restrict on update restrict;
create index ix_annotation_image_id on annotation (image_id);

alter table annotation add constraint fk_annotation_annotator_id foreign key (annotator_id) references annotator (id) on delete restrict on update restrict;
create index ix_annotation_annotator_id on annotation (annotator_id);

alter table image add constraint fk_image_serie_id foreign key (serie_id) references serie (id) on delete restrict on update restrict;
create index ix_image_serie_id on image (serie_id);

alter table lesion add constraint fk_lesion_image_id foreign key (image_id) references image (id) on delete restrict on update restrict;
create index ix_lesion_image_id on lesion (image_id);

alter table lesion add constraint fk_lesion_annotator_id foreign key (annotator_id) references annotator (id) on delete restrict on update restrict;
create index ix_lesion_annotator_id on lesion (annotator_id);

alter table serie add constraint fk_serie_study_id foreign key (study_id) references study (id) on delete restrict on update restrict;
create index ix_serie_study_id on serie (study_id);

alter table study add constraint fk_study_patient_id foreign key (patient_id) references patient (id) on delete restrict on update restrict;
create index ix_study_patient_id on study (patient_id);

