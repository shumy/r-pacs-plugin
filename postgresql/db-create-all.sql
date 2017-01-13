create table image (
  id                            bigserial not null,
  ref_serie                     bigint not null,
  uid                           varchar(255) not null,
  number                        integer not null,
  photometric                   varchar(255) not null,
  columns                       integer not null,
  rows                          integer not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
  constraint uq_image_uid unique (uid),
  constraint pk_image primary key (id)
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
  ref_study                     bigint not null,
  uid                           varchar(255) not null,
  number                        integer not null,
  description                   varchar(255) not null,
  datetime                      timestamptz not null,
  modality                      varchar(255) not null,
  laterality                    varchar(255) not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
  constraint uq_serie_uid unique (uid),
  constraint pk_serie primary key (id)
);

create table study (
  id                            bigserial not null,
  ref_patient                   bigint not null,
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

create index ix_image_uid on image (uid);
create index ix_patient_pid on patient (pid);
create index ix_serie_uid on serie (uid);
create index ix_study_uid on study (uid);
alter table image add constraint fk_image_ref_serie foreign key (ref_serie) references serie (id) on delete restrict on update restrict;
create index ix_image_ref_serie on image (ref_serie);

alter table serie add constraint fk_serie_ref_study foreign key (ref_study) references study (id) on delete restrict on update restrict;
create index ix_serie_ref_study on serie (ref_study);

alter table study add constraint fk_study_ref_patient foreign key (ref_patient) references patient (id) on delete restrict on update restrict;
create index ix_study_ref_patient on study (ref_patient);

