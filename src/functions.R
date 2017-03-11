makeVectorBaseDB <- function(){
  if(!(length(list.files(path = "raw/VectorBaseDB/", pattern = ".fa$")) > 0)){
    a = system2("wget", args = c("-i","raw/VectorBase_list.txt",
                             "-P", "raw/VectorBaseDB"), stdout=TRUE, stderr = TRUE)
    system2("gunzip", args = c("raw/VectorBaseDB/*.gz"), stdout = TRUE)
    system("cat $(ls -t raw/VectorBaseDB/*.fa) > data/VectorBase_transcript.fsa")
  }
  b = system2("makeblastdb", args = c("-in", "data/VectorBase_transcript.fsa", 
                                  "-parse_seqids", "-dbtype nucl", 
                                  "-title", "VectorBaseTranscriptsdb"),
                                  stdout=TRUE, stderr = TRUE)
  print("DataBase Created")
}

# awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < file.fa
MLtoSLfasta <- function( ML_fasta ){
  a = system2("python", c("src/FastaMultiLineToSingle.py", ML_fasta ),stdout=TRUE)
} 

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
    print(paste("Still Running:",Sys.time(), "UTC"))
    }
    return(length(output))
}

tBlastn <- function(){
  system2("tblastn", args = c())
}

