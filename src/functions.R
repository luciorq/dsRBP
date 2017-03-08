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

