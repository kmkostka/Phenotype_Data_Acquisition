




execute <- function(connectionDetails,
                    cdmDatabaseSchema,
                    resultsDatabaseSchema,
                    vocabularyDatabaseSchema,
                    targetCohortTable,
                    targetCohortId,
                    outputFolder,
                    cdmName,
                    cdmVersion,
                    siteAbbrev,
                    contactName,
                    contactEmail){

  # Generate cohort
  N3cOhdsi::createCohort(connectionDetails = connectionDetails,
                         cdmDatabaseSchema = cdmDatabaseSchema,
                         resultsDatabaseSchema = resultsDatabaseSchema,
                         vocabularyDatabaseSchema = cdmDatabaseSchema,
                         targetCohortTable = targetCohortTable,
                         targetCohortId = targetCohortId
  )


  # Extract data to pipe delimited files
  N3cOhdsi::runExtraction(connectionDetails = connectionDetails,
                          cdmDatabaseSchema = cdmDatabaseSchema,
                          resultsDatabaseSchema = resultsDatabaseSchema,
                          outputFolder = outputFolder,
                          cdmName = cdmName,
                          cdmVersion = cdmVersion,
                          siteAbbrev = siteAbbrev,
                          contactName = contactName,
                          contactEmail = contactEmail
  )


  # Compress into single file
  OhdsiSharing::compressFolder(outputFolder, paste0(siteAbbrev, "_", cdmName, "_", cdmVersion, "_", Sys.Date(),".zip") )


}
