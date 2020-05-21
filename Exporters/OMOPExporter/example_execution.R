
library(DatabaseConnector)
library(SqlRender)
library(OhdsiSharing)

library(N3cOhdsi)

con_details <- DatabaseConnector::createConnectionDetails(dbms = "",
                                                          user = "",
                                                          password = "",
                                                          server = ""
)

cdmDatabaseSchema <- "" #
resultsDatabaseSchema <- "" # schema with write privileges
vocabularyDatabaseSchema <- ""
targetCohortTable <- "cohort"
targetCohortId <- 999 # TODO: remove?
outputFolder <-  paste0(getwd(), "/output/")

cdmName <- "OMOP"
cdmVersion <- "5.3"

siteAbbrev <- ""
contactName <- "John Doe"
contactEmail <- "johndoe@hotmail.com"


# -------------------------
# run as one large execution
N3cOhdsi::execute(connectionDetails = con_details,
                    cdmDatabaseSchema = cdmDatabaseSchema,
                    resultsDatabaseSchema = resultsDatabaseSchema,
                    vocabularyDatabaseSchema = cdmDatabaseSchema,
                    targetCohortTable = targetCohortTable,
                    targetCohortId = targetCohortId,
                    outputFolder = outputFolder,
                    cdmName = cdmName,
                    cdmVersion = cdmVersion,
                    siteAbbrev = siteAbbrev,
                    contactName = contactName,
                    contactEmail = contactEmail)




# -----------------------------
# run sections individually



# Generate cohort
N3cOhdsi::createCohort(connectionDetails = con_details,
                        cdmDatabaseSchema = cdmDatabaseSchema,
                        resultsDatabaseSchema = resultsDatabaseSchema,
                        vocabularyDatabaseSchema = cdmDatabaseSchema,
                        targetCohortTable = targetCohortTable,
                        targetCohortId = targetCohortId,
                        cdmName = cdmName,
                        cdmVersion = cdmVersion
                        )

# Extract data to pipe delimited files
N3cOhdsi::runExtraction(connectionDetails = con_details,
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


