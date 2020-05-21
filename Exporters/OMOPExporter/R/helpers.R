

getSqlFile <- function(cdmName,
                         cdmVersion,
                         scriptType){

  sql_i <-  read.csv(system.file("csv/sql_file_index.csv", package = "N3cOhdsi"), stringsAsFactors = FALSE)

  sql_i <- sql_i[which(sql_i$cdm == cdmName),]
  sql_i <- sql_i[which(sql_i$version == cdmVersion),]
  sql_i <- sql_i[which(sql_i$script_type == scriptType),]

  # TODO: throw error if rownum <> 1

  return(sql_i$file_path[1])



}
