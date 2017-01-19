select
  an.id, draft, us."name",
  case
    when "local"=0 then 'MACULA'
    when "local"=1 then 'OPTIC_DICS'
  end as "local",
  case
    when quality=0 then 'UNDEFINED'
    when quality=1 then 'GOOD'
    when quality=2 then 'PARTIAL'
    when quality=3 then 'BAD'
  end as "quality",
  case
    when retinopathy=0 then 'UNDEFINED'
    when retinopathy=1 then 'R0'
    when retinopathy=2 then 'R1'
    when retinopathy=3 then 'R2'
    when retinopathy=4 then 'R3'
  end as "retinopathy",
  case
    when maculopathy=0 then 'UNDEFINED'
    when maculopathy=1 then 'M0'
    when maculopathy=2 then 'M1'
  end as "maculopathy",
  case
    when photocoagulation=0 then 'UNDEFINED'
    when photocoagulation=1 then 'P0'
    when photocoagulation=2 then 'P1'
  end as "maculopathy"
from annotation an, annotator us where an.annotator_id = us.id


--delete from annotation