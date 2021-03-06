
# Aine Fairbrother-Browne
# 2020

genDistributionPlotWithGene = function(gene, summary_brain){
  
  # fn that generates a distribution plot of all gene-mt values (per region) with a red line for gene X to indicate where it 
  # lies on the distribution
  
  if(grepl('ENS', gene)){
    gene_sym = convert_sym_ens(gene, load_genespace=F)
  }
  if(!grepl('ENS', gene)){
    gene_sym = gene
    gene = convert_sym_ens(gene, input_ENS=F, load_genespace=F)
  }
  
  # for when gene sym maps to two ENS codes  
  if(length(gene) > 1){
    for(g in gene){
      if(length(rownames(summary_brain %>% dplyr::filter(nuc_gene == g))) > 0){
        gene = g
      }
    }
  }
  
  print(gene)
  print(gene_sym)
  
  # filtering for gene R value and pivoting data
  summary_brain_clean = summary_brain %>% 
    dplyr::select(matches("corr|nuc_gene")) %>% 
    tidyr::pivot_longer(2:13, names_to='region', values_to='R_value') %>% 
    dplyr::mutate(region = gsub('_corrs', '', gsub('Brain', '', gsub('basalganglia', 'BG', region))))

  gene_mean_across_mt_df = summary_brain_clean %>%
    dplyr::filter(nuc_gene == gene) %>%
    dplyr::group_by(region) %>%
    dplyr::mutate(gene_mean_across_mt = round(mean(R_value), 4)) %>% 
    dplyr::arrange(gene_mean_across_mt)
  
  gene_mean_label_df = data.frame(
    region = unique(gene_mean_across_mt_df$region),
    label = unique(gene_mean_across_mt_df$gene_mean_across_mt)) %>% 
    dplyr::mutate(label_colour = ifelse(label>0, 'blue', 'red')) %>% 
    dplyr::arrange(label)
  
  distPlot = ggplot(data=summary_brain_clean %>% 
                      dplyr::mutate(region=gdata::reorder.factor(region, new.order=unique(gene_mean_across_mt_df$region))), aes(x=R_value)) +
    theme_minimal(base_size=11) +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme(legend.position="top") +
    geom_density(fill='lightgrey', colour='white', alpha=0.5) + #ECDEFF
    facet_wrap(~region, nrow=4, ncol=3) +
    xlim(-1,1) +
    xlab(expression(rho)) +
    ylab('Density') +
    
    # add line to indicate mean rho of gene across 13 mt genes
    geom_vline(
      data = gene_mean_label_df,
      mapping = aes(
        xintercept = label,
        colour='mean correlation value across 13 mtDNA genes'),
      linetype='dashed',
      size=0.5,
      alpha=0.8) +
    
    # add annotation to distplot: mean rho
    geom_label(
      size=4,
      data = gene_mean_label_df,
      mapping = aes(label=paste0("\U03BC", '=', label),
                    x = as.numeric(label),
                    y = 0.3,
                    fill=label_colour),
      colour = 'white',
      fontface = 'bold',
      alpha=0.4
      
    )  +
    
    scale_fill_manual(guide = FALSE, values=c('red'='#FF1E0E', 'blue'='#1F0FFF')) +
    
    # add legend
    scale_color_manual(name = '', values = c('mean correlation value across 13 mtDNA genes'= 'darkgrey'),
                       labels = paste(gene_sym, 'mean correlation value across 13 mtDNA genes'))
  
  return(distPlot)
  
}

# #test
# start.time = Sys.time()
# gene='SOD2'
# genDistributionPlotWithGene(gene=gene, summary_brain=summary_brain)
# end.time = Sys.time()
# time.taken = end.time - start.time
# print(time.taken)

