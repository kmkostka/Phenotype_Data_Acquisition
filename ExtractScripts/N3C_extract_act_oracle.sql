--ACT/i2b2 extraction code for N3C
--ACT Ontology Version 2.0.1 and optionally ACT_COVID V3
--Written by Michele Morris, UPitt
--Code written for MS SQL Server
--This extract includes only i2b2 fact relevant tables and the concept dimension table for mapping concept codes
--Assumptions: 
--	1. You have already built the N3C_COHORT table (with that name) prior to running this extract
--	2. You are extracting data with a lookback period of 2 years (Not Yet)
--  3. This currently only works for the traditional i2b2 single fact table

--select concept_dimension table to allow the harmonization team to harmonize local coding

--CONCEPT_DIMENSION TABLE
--OUTPUT_FILE: CONCEPT_DIMENSION.CSV
SELECT concept_path,
    concept_cd,
    name_char,
    update_date,
    download_date,
    import_date,
    sourcesystem_cd,
    upload_id
FROM @cdmDatabaseSchema.concept_dimension ;

--select all facts - concept_cd determines domain/value    
--OBSERVATION_FACT TABLE
--OUTPUT_FILE: OBSERVATION_FACT.CSV
SELECT encounter_num,
    observation_fact.patient_num,
    concept_cd,
    provider_id,
    start_date,
    end_date,
    modifier_cd,
    instance_num,
    valtype_cd,
    location_cd,
    tval_char,
    nval_num,
    valueflag_cd,
    units_cd,
    update_date,
    download_date,
    import_date,
    sourcesystem_cd,
    upload_id
FROM @cdmDatabaseSchema.observation_fact join @resultsDatabaseSchema.n3c_cohort on observation_fact.patient_num = n3c_cohort.patient_num 
  WHERE start_date >= '1/1/2018' ;
    
    
--select patient dimension the demographic facts including ethnicity are included in observation_fact table as well
--PATIENT_DIMENSION TABLE
--OUTPUT_FILE: PATIENT_DIMENSION.csv
SELECT patient_dimension.patient_num,
    SUBSTR(CAST(BIRTH_DATE as varchar(20)),0,7) as birth_date,
    death_date,
    race_cd,
    sex_cd,
    vital_status_cd,
    age_in_years_num,
    language_cd,
    marital_status_cd,
    religion_cd,
    zip_cd,
    statecityzip_path,
    income_cd,
    update_date,
    download_date,
    import_date,
    sourcesystem_cd,
    upload_id
FROM @cdmDatabaseSchema.patient_dimension join @resultsDatabaseSchema.n3c_cohort on patient_dimension.patient_num = n3c_cohort.patient_num  ;

    
    
--select visit_dimensions (encounter/visit) vary by site  
--VISIT_DIMENSION TABLE
--OUTPUT_FILE: VISIT_DIMENSION.csv
SELECT visit_dimension.patient_num,
    encounter_num,
    active_status_cd,
    start_date,
    end_date,
    inout_cd,
    location_cd,
    location_path,
    length_of_stay,
    update_date,
    download_date,
    import_date,
    sourcesystem_cd,
    upload_id,
FROM @cdmDatabaseSchema.visit_dimension join @resultsDatabaseSchema.n3c_cohort on visit_dimension.patient_num = n3c_cohort.patient_num
  WHERE start_date >= '1/1/2018' ;
    
--DATA_COUNTS TABLE
--OUTPUT_FILE: DATA_COUNTS.csv
SELECT * FROM (SELECT 'OBSERVATION_FACT' as TABLE_NAME, 
   (SELECT count(*) FROM @cdmDatabaseSchema.OBSERVATION_FACT join @resultsDatabaseSchema.n3c_cohort on observation_fact.patient_num = n3c_cohort.patient_num 
  WHERE start_date >= '1/1/2018' ) as ROW_COUNT

 FROM DUAL  UNION SELECT 'VISIT_DIMENSION'  TABLE_NAME,
   (SELECT count(*) FROM @cdmDatabaseSchema.VISIT_DIMENSION join @resultsDatabaseSchema.n3c_cohort on visit_dimension.patient_num = n3c_cohort.patient_num
  WHERE start_date >= '1/1/2018' ) as ROW_COUNT

  FROM DUAL  UNION SELECT 'PATIENT_DIMENSION'  TABLE_NAME,
   (SELECT count(*) FROM @cdmDatabaseSchema.PATIENT_DIMENSION join @resultsDatabaseSchema.n3c_cohort on patient_dimension.patient_num = n3c_cohort.patient_num ) as ROW_COUNT

  FROM DUAL   UNION select 
   'CONCEPT_DIMENSION'  TABLE_NAME,
   (SELECT count(*) FROM @cdmDatabaseSchema.CONCEPT_DIMENSION ) as ROW_COUNT  FROM DUAL ) ;

--MANIFEST TABLE: CHANGE PER YOUR SITE'S SPECS
--OUTPUT_FILE: MANIFEST.csv
SELECT 'UNC' as SITE_ABBREV,
   'University of North Carolina at Chapel Hill' as SITE_NAME,
   'Jane Doe' as CONTACT_NAME,
   'jane_doe@unc.edu' as CONTACT_EMAIL,
   'ACT' as CDM_NAME,
   '2.0.1' as CDM_VERSION,
   null as VOCABULARY_VERSION, --leave null as this only applies to OMOP
   'Y' as N3C_PHENOTYPE_YN,
   '1.3' as N3C_PHENOTYPE_VERSION,
   CAST(SYSDATE as date) as RUN_DATE,
   CAST( (SYSDATE + NUMTODSINTERVAL(-2, 'day')) as date) as UPDATE_DATE,	--change integer based on your site's data latency
   CAST( (SYSDATE + NUMTODSINTERVAL(3, 'day')) as date) as NEXT_SUBMISSION_DATE FROM DUAL;
