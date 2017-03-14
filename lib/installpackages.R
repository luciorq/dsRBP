
library(BiocInstaller) # shouldn't be necessary


pkgs <- c(
#"AnnotationDbi",
#"AnnotationHub",
#"Biobase",
#"BiocParallel",
#"biocViews",
#"biomaRt",
"Biostrings",
#"BSgenome",
# Temporarily disabled because it does not build in devel-3.5 yet
#"epivizr",
#"GenomicFeatures",
#"GenomicRanges" ,
"ggtree"
)

ap.db <- available.packages(contrib.url(biocinstallRepos()))
ap <- rownames(ap.db)

pkgs_to_install <- pkgs[pkgs %in% ap]

biocLite(pkgs_to_install)

# just in case there were warnings, we want to see them
# without having to scroll up:
warnings()

if (!is.null(warnings()))
{
    w <- capture.output(warnings())
    if (length(grep("is not available|had non-zero exit status", w)))
        quit("no", 1L)
}

suppressWarnings(BiocInstaller::biocValid(fix=TRUE, ask=FALSE))

