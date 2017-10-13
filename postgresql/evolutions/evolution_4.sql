--update property_map selection
delete from property_map;

insert into property_map (key, value, version, deleted, created_at, updated_at)
  values ('diagnosis.diseases', 'Glaucoma', 1, false, current_timestamp, current_timestamp);

insert into property_map (key, value, version, deleted, created_at, updated_at)
  values ('diagnosis.diseases', 'Age-related macular degeneration', 1, false, current_timestamp, current_timestamp);

insert into property_map (key, value, version, deleted, created_at, updated_at)
  values ('diagnosis.diseases', 'Retinal vein occlusion', 1, false, current_timestamp, current_timestamp);

-- order ??
insert into property_map (key, value, version, deleted, created_at, updated_at)
  values ('diagnosis.diseases', 'Choroidal nevus', 1, false, current_timestamp, current_timestamp);

insert into property_map (key, value, version, deleted, created_at, updated_at)
  values ('diagnosis.diseases', 'Other vascular disorders', 1, false, current_timestamp, current_timestamp);

insert into property_map (key, value, version, deleted, created_at, updated_at)
  values ('diagnosis.diseases', 'Other maculopathies', 1, false, current_timestamp, current_timestamp);

insert into property_map (key, value, version, deleted, created_at, updated_at)
  values ('diagnosis.diseases', 'Other neoformations', 1, false, current_timestamp, current_timestamp);

insert into property_map (key, value, version, deleted, created_at, updated_at)
  values ('diagnosis.diseases', 'Other', 1, false, current_timestamp, current_timestamp);

--replace "Vascular disorders" --> "Other vascular disorders"
update node set fields = (select replace(fields::TEXT, '"Vascular disorders"', '"Other vascular disorders"')::JSONB) where fields @> '{"diseases": ["Vascular disorders"]}';

--update serie table
alter table serie add column station_name character varying(255);
alter table serie add column manufacturer character varying(255);
alter table serie add column manufacturer_model_name character varying(255);


