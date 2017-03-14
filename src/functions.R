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
  if((!file.exists(paste0("data/",db_name,"/",db_name,".fsa.nhr"))) & (!file.exists(paste0("data/",db_name,"/",db_name,".fsa.phr")))){
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
Blast <- function(blast_program, query_file, db_name, outformat = 10){
  db_name <- paste0("data/",db_name,"/",db_name,".fsa")
  output_file <- paste0(query_file,"_alignment.csv")
  if(outformat == 6){
    output_file <- paste0(query_file,"_alignment.tab")
  }
  ## output format parameter: 6=tab-file, 7=tab-file w/ comment, 10=csv-file
  ## query seq id, subject seq id, query length, alignment length, Evalue, bitscore, Subject title
  if(!file.exists(output_file)){
    system2(blast_program, args = c("-db",db_name,
                                    "-query",query_file,
                                    "-out", output_file,
                                    "-outfmt", paste0('"',outformat,' qseqid sseqid qlen length evalue bitscore stitle"'))
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
## extract Open reading frames from nucleotide sequences in fasta file using EMBOSS software
##  # -find 1 (Translation of regions between START and STOP codons); -minsize 200 (Minimum nucleotide size of ORF to report [Any integer value])
GetORF <- function(sequences_file){
  a = system(paste0("getorf -sequence data/",sequences_file,"_nucl_blast_result.fasta -outseq data/",
                    sequences_file,"_orf.fasta -find 1 -minsize 200"),
             intern = TRUE, ignore.stdout = TRUE, ignore.stderr = TRUE)
  print(paste0("data/",sequences_file,"_orf.fasta"))
}
## Retrieve fasta file for ORFS with hit for Interpro domain term
ORFwithDomain <- function(sequences_file, InterPro){
  orf_id = c()
  orf_seq = c()
  for(orf_file in list.files(paste0("data/iprscan_results/",sequences_file,"_orf/"))){
    XMLfile <- paste(readLines(paste0("data/iprscan_results/",sequences_file,"_orf/",orf_file)))
    if(length(grep(InterPro, XMLfile)) > 0){
      new_id= unlist(strsplit(XMLfile[5]," <xref id=\""))[2]
      new_id = unlist(strsplit(new_id, '\"/>'))[1]
      new_id = paste0(">",new_id)
      orf_id = c(orf_id, new_id)
      new_seq = unlist(strsplit(XMLfile[4],"\\\">"))[2]
      new_seq = unlist(strsplit(new_seq,"<"))[1]
      orf_seq = c(orf_seq, new_seq)
    }
  }
 output = paste0("data/",sequences_file,"_domain_filtered_ORF.fasta")
  for(i in 1:length(orf_id)){
    cat(orf_id[i],file = output, append = TRUE, sep = "\n")
    cat(orf_seq[i],file = output, append = TRUE, sep = "\n")
  }
}

## multiple sequence alignment using MAFFT auto by default from protein sequences in fasta format
Alignment <- function(program = "mafft", parameter = "", input){
  a = system2(program, args = c(parameter, paste0("data/",input,"_result_nr.fasta"),">",
                                paste0("data/",input,"_result.aligned.fasta")),stdout=TRUE, stderr = TRUE)
}
## 
BuildTrees <- function(input_file, outgroup){
  system(paste0("Rscript --no-save src/RootedTree.R data/",
                input_file,"_result.aligned.fasta ", outgroup) )#, intern = TRUE, ignore.stdout = TRUE, ignore.stderr = TRUE)
}
##
FilterFastaRedundancy <- function(input_file, output_file){
  system2("perl", args = c("src/FilterFastaRedundancy.pl",input_file, ">", output_file))
}


