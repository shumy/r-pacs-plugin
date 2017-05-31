create table property_map (
  id                            bigserial not null,
  key                           varchar(255) not null,
  value                         varchar(255) not null,
  version                       bigint not null,
  deleted                       boolean default false not null,
  created_at                    timestamptz not null,
  updated_at                    timestamptz not null,
  constraint pk_property_map primary key (id)
);

create index ix_property_map_key on property_map (key);

/*
insert into property_map (key, value, version, deleted, created_at, updated_at)
  values ('diagnosis.diseases', 'D1', 1, false, current_timestamp, current_timestamp);

insert into property_map (key, value, version, deleted, created_at, updated_at)
  values ('diagnosis.diseases', 'D2', 1, false, current_timestamp, current_timestamp);
*/