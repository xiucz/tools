library(tidyverse)
rawdf = read.table("/public/frasergen/CLIN/work/zhangbo/tmp2/20240419_EGFRKRAS/all.gene.txt", sep = "\t", header = T) %>% unique

gene_l <- c("ALK", "BCL2L11", "BRAF", "EGFR", "EML4", "ERBB2", "ESR1", "ETV6", "FGFR2", "FGFR3", "IDH1", "KIT", "KRAS", "MAP2K1", "MET", "NCOA4", "NF1", "NPM1", "NRAS", "NTRK1", "NTRK2", "NTRK3", "PALB2", "PDGFRA", "PIK3CA", "PPP2R2A", "RET", "ROS1", "SDHA", "SDHB", "SDHC", "SDHD", "TP53")

#gene_l <- ("EGFR")

#组别	yes	no
#A	1	2
#B	3	4
#matrix(c(A_yes, B_yes, A_no, B_no), nrow=2, ncol=2)

#当 n(样本量)≥40 且所有的T(期望频数)≥5时，用χ2检验的基本公式或四格表资料之χ2检验的专用公式；当P ≈ α时，改用四格表资料的 Fisher 确切概率法；
#当 n≥40 但有 1≤T<5 时，用四格表资料χ2检验的校正公式，或改用四格表资料的 Fisher 确切概率法。
#当 n<40，或 T<1时，用四格表资料的 Fisher 确切概率法。

wdf <- data.frame()

for (i in gene_l){
    df <- rawdf %>% filter(Gene == i)
    #print(df)
    allsample = 40
    ii_1_1 = df %>% filter(group ==1) %>% nrow
    ii_1_0 = 24 - ii_1_1
    ii_0_1 = df %>% filter(group ==0) %>% nrow
    ii_0_0 = 16 - ii_0_1
    tableR <- matrix(c(ii_1_1, ii_0_1, ii_1_0, ii_0_0), nrow=2, ncol=2)
    p_value = round(chisq.test(tableR, correct=F)$p.value, 6)
    expectedT <- chisq.test(tableR, correct=F)$expected
    if (all(expectedT >= 5) && allsample>=40){
        print("χ2 test...")
        p_value = round(chisq.test(tableR, correct=F)$p.value, 6)
        method = "chi.square.test"
    } else {
        print("fisher test...")
        p_value = round(fisher.test(tableR )$p.value, 6)
        method = "fisher.test"
    } 
    q_value =  round(p.adjust(p_value, "BH"), 3)
    wdf <- rbind(wdf,c(i, ii_1_1, ii_0_1, ii_1_0, ii_0_0, p_value, method))
    }
colnames(wdf) <- c('Gene', 'EGFRKRAS组_yes', "非EGFRKRAS组_yes", 'EGFRKRAS组_no', "非EGFRKRAS组_no", "pvalue", "method") # set colnames
write.table(wdf, "all.gene.stats.v2.xls", sep = "\t", quote = F, row.names = F)
