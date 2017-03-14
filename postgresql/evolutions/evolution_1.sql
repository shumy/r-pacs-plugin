--adds the dataset schema--

create table dataset (
  id                            bigserial not null,
  is_default                    boolean default false not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
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

alter table dataset_image add constraint fk_dataset_image_dataset foreign key (dataset_id) references dataset (id) on delete restrict on update restrict;
create index ix_dataset_image_dataset on dataset_image (dataset_id);

alter table dataset_image add constraint fk_dataset_image_image foreign key (image_id) references image (id) on delete restrict on update restrict;
create index ix_dataset_image_image on dataset_image (image_id);

alter table dataset_annotator add constraint fk_dataset_annotator_dataset foreign key (dataset_id) references dataset (id) on delete restrict on update restrict;
create index ix_dataset_annotator_dataset on dataset_annotator (dataset_id);

alter table dataset_annotator add constraint fk_dataset_annotator_annotator foreign key (annotator_id) references annotator (id) on delete restrict on update restrict;
create index ix_dataset_annotator_annotator on dataset_annotator (annotator_id);

alter table annotator add column current_dataset_id bigint;
alter table annotator add constraint uq_annotator_current_dataset_id unique (current_dataset_id);
alter table annotator add constraint fk_annotator_current_dataset_id foreign key (current_dataset_id) references dataset (id) on delete restrict on update restrict;

--procedure to create random datasets of specified size
--use as: select create_random_dataset(<size>);
--setup as a default: update dataset set is_default = true where id = <id>
create or replace function create_random_dataset(size integer)
  returns void as $$
declare
   dt_id integer;
begin
  insert into dataset (version, deleted, created_at, updated_at) values (1, false, current_timestamp, current_timestamp) returning id into dt_id;

  insert into dataset_image
    select dt_id, id from image order by random() limit size;
end;
$$ language plpgsql;