create table annotation (
  id                            bigint auto_increment not null,
  status                        integer not null,
  image_id                      bigint not null,
  annotator_id                  bigint not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamp not null,
  updated_at                    timestamp not null,
  constraint ck_annotation_status check ( status in (0,1)),
  constraint uq_annotation_image_id_annotator_id unique (image_id,annotator_id),
  constraint pk_annotation primary key (id)
);

create table annotator (
  id                            bigint auto_increment not null,
  name                          varchar(255) not null,
  alias                         varchar(255) not null,
  current_dataset_id            bigint,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamp not null,
  updated_at                    timestamp not null,
  constraint uq_annotator_name unique (name),
  constraint pk_annotator primary key (id)
);

create table dataset (
  id                            bigint auto_increment not null,
  is_default                    boolean default false not null,
  name                          varchar(255) not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamp not null,
  updated_at                    timestamp not null,
  constraint uq_dataset_name unique (name),
  constraint pk_dataset primary key (id)
);

create table dataset_image (
  dataset_id                    bigint not null,
  image_id                      bigint not null,
  constraint pk_dataset_image primary key (dataset_id,image_id)
);

create table dataset_annotator (
  dataset_id                    bigint not null,
  annotator_id                  bigint not null,
  constraint pk_dataset_annotator primary key (dataset_id,annotator_id)
);

create table image (
  id                            bigint auto_increment not null,
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
  created_at                    timestamp not null,
  updated_at                    timestamp not null,
  constraint uq_image_uid unique (uid),
  constraint pk_image primary key (id)
);

create table node (
  id                            bigint auto_increment not null,
  type_id                       bigint not null,
  annotation_id                 bigint not null,
  fields                        clob,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamp not null,
  updated_at                    timestamp not null,
  constraint uq_node_type_id_annotation_id unique (type_id,annotation_id),
  constraint pk_node primary key (id)
);

create table node_type (
  id                            bigint auto_increment not null,
  name                          varchar(255) not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamp not null,
  updated_at                    timestamp not null,
  constraint uq_node_type_name unique (name),
  constraint pk_node_type primary key (id)
);

create table patient (
  id                            bigint auto_increment not null,
  pid                           varchar(255) not null,
  name                          varchar(255) not null,
  sex                           varchar(255) not null,
  birthdate                     date not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamp not null,
  updated_at                    timestamp not null,
  constraint uq_patient_pid unique (pid),
  constraint pk_patient primary key (id)
);

create table pointer (
  id                            bigint auto_increment not null,
  dataset_id                    bigint not null,
  annotator_id                  bigint not null,
  type_id                       bigint not null,
  last                          bigint not null,
  next                          bigint not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamp not null,
  updated_at                    timestamp not null,
  constraint uq_pointer_dataset_id_annotator_id_type_id unique (dataset_id,annotator_id,type_id),
  constraint pk_pointer primary key (id)
);

create table serie (
  id                            bigint auto_increment not null,
  study_id                      bigint not null,
  uid                           varchar(255) not null,
  number                        integer not null,
  description                   varchar(255) not null,
  datetime                      timestamp not null,
  modality                      varchar(255) not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamp not null,
  updated_at                    timestamp not null,
  constraint uq_serie_uid unique (uid),
  constraint pk_serie primary key (id)
);

create table study (
  id                            bigint auto_increment not null,
  patient_id                    bigint not null,
  uid                           varchar(255) not null,
  sid                           varchar(255) not null,
  accession_number              varchar(255) not null,
  description                   varchar(255) not null,
  datetime                      timestamp not null,
  institution_name              varchar(255) not null,
  institution_address           varchar(255) not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamp not null,
  updated_at                    timestamp not null,
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

alter table annotator add constraint fk_annotator_current_dataset_id foreign key (current_dataset_id) references dataset (id) on delete restrict on update restrict;
create index ix_annotator_current_dataset_id on annotator (current_dataset_id);

alter table dataset_image add constraint fk_dataset_image_dataset foreign key (dataset_id) references dataset (id) on delete restrict on update restrict;
create index ix_dataset_image_dataset on dataset_image (dataset_id);

alter table dataset_image add constraint fk_dataset_image_image foreign key (image_id) references image (id) on delete restrict on update restrict;
create index ix_dataset_image_image on dataset_image (image_id);

alter table dataset_annotator add constraint fk_dataset_annotator_dataset foreign key (dataset_id) references dataset (id) on delete restrict on update restrict;
create index ix_dataset_annotator_dataset on dataset_annotator (dataset_id);

alter table dataset_annotator add constraint fk_dataset_annotator_annotator foreign key (annotator_id) references annotator (id) on delete restrict on update restrict;
create index ix_dataset_annotator_annotator on dataset_annotator (annotator_id);

alter table image add constraint fk_image_serie_id foreign key (serie_id) references serie (id) on delete restrict on update restrict;
create index ix_image_serie_id on image (serie_id);

alter table node add constraint fk_node_type_id foreign key (type_id) references node_type (id) on delete restrict on update restrict;
create index ix_node_type_id on node (type_id);

alter table node add constraint fk_node_annotation_id foreign key (annotation_id) references annotation (id) on delete restrict on update restrict;
create index ix_node_annotation_id on node (annotation_id);

alter table pointer add constraint fk_pointer_dataset_id foreign key (dataset_id) references dataset (id) on delete restrict on update restrict;
create index ix_pointer_dataset_id on pointer (dataset_id);

alter table pointer add constraint fk_pointer_annotator_id foreign key (annotator_id) references annotator (id) on delete restrict on update restrict;
create index ix_pointer_annotator_id on pointer (annotator_id);

alter table pointer add constraint fk_pointer_type_id foreign key (type_id) references node_type (id) on delete restrict on update restrict;
create index ix_pointer_type_id on pointer (type_id);

alter table serie add constraint fk_serie_study_id foreign key (study_id) references study (id) on delete restrict on update restrict;
create index ix_serie_study_id on serie (study_id);

alter table study add constraint fk_study_patient_id foreign key (patient_id) references patient (id) on delete restrict on update restrict;
create index ix_study_patient_id on study (patient_id);

