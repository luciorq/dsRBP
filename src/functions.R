## Download and extract files from a test file with paths
DownloadLibraries <- function(db_name){
  if(!(length(list.files(path = paste0("raw/",db_name,"/"), pattern = ".(fa|fasta)$")) > 0)){
    a = system2("wget", args = c("-i",paste0("raw/",db_name,"_list.txt"),
                                 "-P", paste0("raw/", db_name)), stdout=TRUE, stderr = TRUE)
    system2("gunzip", args = c(paste0("raw/",db_name,"/*.gz")), stdout = TRUE)
  }
}
## Creates Database for local blast
makeBlastDB <- function(db_name, db_type){
  if(!file.exists(paste0("data/",db_name,"/",db_name,".fsa"))){
    if(!dir.exists(paste0("data/",db_name))){dir.create(paste0("data/",db_name))}
    system(paste0("cat $(ls -t raw/",db_name,"/*.fa*) > data/",db_name,"/",db_name,".fsa"))
  }
  if(!file.exists(paste0("data/",db_name,"/",db_name,".fsa.nhr"))){
    a = system2("makeblastdb", args = c("-in", paste0("data/",db_name,"/",db_name,".fsa"), 
                                  "-parse_seqids", "-dbtype",db_type, 
                                  "-title", db_name),
                                  stdout=TRUE, stderr = TRUE)
  print("Database Created")
  }
}
## Convert MultiLine fasta to SingleLine fasta file
### awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < file.fa
MLtoSLfasta <- function( ML_fasta ){
  a = system2("python", c("src/FastaMultiLineToSingle.py", ML_fasta ),stdout=TRUE)
} 
## Local Blast using Blast+ software package
Blast <- function(blast_program, query_file, db_name){
  db_name <- paste0("data/",db_name,"/",db_name,".fsa")
  output_file <- paste0(query_file,"_alignment.csv")
  ## output format parameter: 6=tab-file, 7=tab-file w/ comment, 10=csv-file
  ## query seq id, subject seq id, query length, alignment length, Evalue, bitscore, Subject title
  if(!file.exists(output_file)){
    a = system2(blast_program, args = c("-db",db_name,
                                    "-query",query_file,
                                    "-out", output_file,
                                    "-outfmt", '"10 qseqid sseqid qlen length evalue bitscore stitle"')
                ,stdout=TRUE)
  }
}
##
RetrieveFasta <- function (fasta_file, id_list) {
  if(!file.exists(paste0("data/",id_list,"_blast_result.fasta"))){
    system(paste0("python src/RetrieveFasta.py data/",fasta_file,"/",fasta_file,
                  ".fsa data/",id_list,"_ids.txt > data/",id_list,"_blast_result.fasta"))
  }
}
## Run remote InterProScan search for a sequeces in a fasta file
RunIprScan <- function (fasta_file , result_folder) {
  email = "luciorqueiroz@gmail.com"
  if(dir.exists(result_folder) == FALSE) {
    dir.create(result_folder)  
  }
  output <- "a"
  while ((length(output))> 0) {
    output <- system2('java', args = c('-jar', 'lib/RunIprScan-1.1.0/RunIprScan.jar', '-v', 
                           "-i", fasta_file, 
                           "-m", email, 
                           "-o", result_folder),stdout=TRUE)
    print(paste("Running:",Sys.time(), "UTC"))
    }
    return(length(output))
}



