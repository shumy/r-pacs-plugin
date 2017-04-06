drop table lesion;
drop table dataset_image;
drop table dataset_annotator;
drop table annotation;
drop table annotator;
drop table dataset;

create table annotation (
  id                            bigserial not null,
  status                        integer not null,
  image_id                      bigint not null,
  annotator_id                  bigint not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
  constraint ck_annotation_status check ( status in (0,1)),
  constraint uq_annotation_image_id_annotator_id unique (image_id,annotator_id),
  constraint pk_annotation primary key (id)
);

create table annotator (
  id                            bigserial not null,
  name                          varchar(255) not null,
  alias                         varchar(255) not null,
  current_dataset_id            bigint,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
  constraint uq_annotator_name unique (name),
  constraint pk_annotator primary key (id)
);

create table dataset (
  id                            bigserial not null,
  is_default                    boolean default false not null,
  name                          varchar(255) not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
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

create table node (
  id                            bigserial not null,
  type_id                       bigint not null,
  annotation_id                 bigint not null,
  fields                        jsonb,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
  constraint uq_node_type_id_annotation_id unique (type_id,annotation_id),
  constraint pk_node primary key (id)
);

create table node_type (
  id                            bigserial not null,
  name                          varchar(255) not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
  constraint uq_node_type_name unique (name),
  constraint pk_node_type primary key (id)
);

create table pointer (
  id                            bigserial not null,
  dataset_id                    bigint not null,
  annotator_id                  bigint not null,
  type_id                       bigint not null,
  last                          bigint not null,
  next                          bigint not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
  constraint uq_pointer_dataset_id_annotator_id_type_id unique (dataset_id,annotator_id,type_id),
  constraint pk_pointer primary key (id)
);

create index ix_annotator_name on annotator (name);

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

---------------------------------------
insert into node_type (name, version, deleted, created_at, updated_at)
  values ('quality', 1, false, current_timestamp, current_timestamp);

insert into node_type (name, version, deleted, created_at, updated_at)
  values ('diagnosis', 1, false, current_timestamp, current_timestamp);
---------------------------------------

drop function if exists create_random_dataset(size integer, name varchar);

create or replace function create_random_dataset(size integer, name varchar)
  returns integer as $$
declare
   dt_id integer;
begin
  insert into dataset (name, version, deleted, created_at, updated_at) values (name, 1, false, current_timestamp, current_timestamp) returning id into dt_id;

  insert into dataset_image
    select dt_id, id from image order by random() limit size;

  return dt_id;
end;
$$ language plpgsql;

do $$
declare
  total integer;
  ds_id integer;
begin
  select count(*) into total from image;
  select create_random_dataset(total, 'all') into ds_id;
  update dataset set is_default = true where id = ds_id;
end $$;
