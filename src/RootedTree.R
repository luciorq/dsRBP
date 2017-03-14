
list_of_packages <- c("ggplot2","ggtree","ape","seqinr","ggrepel","Biostrings")
lapply(list_of_packages, require, character.only = TRUE)

args = commandArgs(trailingOnly = TRUE)
fasta_alignment = args[1]
#fasta_alignment = "data/teste1_result.aligned.fasta"
out_group = args[2]
#out_group = "Ce.Rde-4"
    
# define a function for making a tree:
makemytree <- function(alignmentmat, outgroup = out_group){
    alignment <- ape::as.alignment(alignmentmat)
    mydist <- dist.alignment(alignment)
    mytree <- njs(mydist)
    myrootedtree <- root(mytree, outgroup, r=TRUE )
    return(myrootedtree)
}

prot_align <- read.alignment(file = fasta_alignment, format = "fasta")
# infer a tree
align_matrix  <- as.matrix.alignment(prot_align)

base_tree <- makemytree(align_matrix, outgroup = out_group)
# bootstrap the tree
prot_bootstrap <- boot.phylo(base_tree, align_matrix, makemytree)
prot_tree = apeBoot(base_tree, prot_bootstrap)

#write.tree(base_tree, "data/dsRBPv3.aligned.tre")
#tree_tree <- read.tree("data/dsRBPv3.aligned.tre")

tree = ggtree(prot_tree, ladderize = TRUE, branch.length="none") + 
    geom_tiplab() + #geom_treescale(x = 0.5, y = 63, offset = 2) +
    geom_label(aes(label=bootstrap, fill=bootstrap)) +
    theme_tree()  + xlim(-1, 20)

msa_tree = msaplot(ggtree(prot_tree), fasta = fasta_alignment, offset = 0) # offset parameter to adjust msa distance from tree, in case of label

circular_tree = ggtree(prot_tree, ladderize = TRUE, branch.length="none", layout="circular") + 
    geom_tiplab2(size = 2.5, aes(angle=angle), color="black") +
    theme_tree() + geom_nodepoint(color="#b5e521", alpha=1/3, size=2.5) +
    xlim(-1, 20)

file_name = unlist(strsplit(fasta_alignment,"/"))[2]
tree_height = (11 / 74 ) * length(prot_align$seq)

pdf(paste("plots/",file_name,".rooted_tree",".pdf",sep = ""), width = 11.5, height = tree_height )
print(tree)
dev.off()

pdf(paste("plots/",file_name,".msa_tree",".pdf",sep = ""), width = 11.5, height = tree_height )
print(msa_tree)
dev.off()

pdf(paste("plots/",file_name,".circular_tree",".pdf",sep = ""), width = 11.5, height = 11)
print(circular_tree)
dev.off()


print("Work done!")
