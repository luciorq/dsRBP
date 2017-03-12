#!/usr/bin/python
#Script to retrive Seq fasta files from seq ID
 
# Usage: RetrieveSeq.py <sequences.faa> <sequences.faa>
# Example: RetriveSeq.py mySeqs.faa reference_list.fasta 
import sys

# Checks if in proper number of arguments are passed gives instructions on proper use.
def argsCheck(numArgs):
	if len(sys.argv) < numArgs or len(sys.argv) > numArgs:
		print "ERROR, wrong number of arguments"
		print "Usage: " + sys.argv[0] + " mySeqs.fasta reference_list"
		exit(1) # Aborts program. (exit(1) indicates that an error occurred)
#===========================================================================================================
argsCheck(3) # Checks if the number of arguments are correct.

fasta_file = sys.argv[1]
id_list = sys.argv[2]

with open(id_list, "r") as fp:
	for ID in fp:
		check = 0
		with open(fasta_file, "r") as fasta:
			for line in fasta:
				if check == 1:
					if line[0] == ">":
						check = 0
					else:
						print line, 
				if ID[0:-1] in line:
					#print ID[0:-1]
					check = 1
					print line,
				