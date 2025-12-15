-- 001_schema.sql

-- 1) ETL 실행 이력(운영/증빙용)
create table if not exists etl_job_run (
  job_run_id bigserial primary key,
  dag_id text not null,
  task_id text,
  run_date date not null,
  status text not null check (status in ('success','failed','running')),
  row_count bigint default 0,
  message text,
  started_at timestamptz default now(),
  ended_at timestamptz
);

create index if not exists ix_etl_job_run_01
  on etl_job_run (dag_id, run_date, started_at desc);

-- 2) Raw 파일 레지스트리(멱등성/중복수집 방지)
create table if not exists raw_file_registry (
  raw_id bigserial primary key,
  dag_id text not null,
  run_date date not null,
  file_path text not null,
  file_hash text not null unique,
  collected_at timestamptz default now()
);

create index if not exists ix_raw_file_registry_01
  on raw_file_registry (dag_id, run_date);

-- 3) 최종 적재 테이블(예시 Fact)
-- 포폴에선 "키(item_key) + 날짜(run_date)" PK로 upsert 구조를 보여주면 됨
create table if not exists fact_data (
  run_date date not null,
  item_key text not null,
  metric_value numeric,
  metric_text text,
  created_at timestamptz default now(),
  primary key (run_date, item_key)
);
