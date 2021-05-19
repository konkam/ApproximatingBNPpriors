using RCall

R"
library(gridExtra)
library(cowplot)
library(tidyverse)
library(latex2exp)
library(viridis)
"


function plot_draw_prior_distribution(df,N,beta,sigma,y_l,x_lab,n,m)
               Pkn_NGG_FK_ = smooth_pk(df.Pkn_FK[1:N])
               Pkn_NGG_SB_ = smooth_pk(df.Pkn_SB[1:N])
               R"p = ggplot(data.frame(k = 1:$N,
                                Pkn_5_numeric = $(df.Pkn_numeric[1:N]),
                                Pkn_4_order2 = $(df.Pkn_order2[1:N]),
                                Pkn_3_NGG_sM = $(df.Pkn_NGGM[1:N]),
                                Pkn_2_NGG_FK = $Pkn_NGG_FK_,
                                Pkn_1_NGG_SB = $Pkn_NGG_SB_
                            ) %>%
                    gather(Process_type, density, Pkn_5_numeric:Pkn_1_NGG_SB),
               aes(x=k, y = density, colour = Process_type)) +
                geom_line(aes(linetype =Process_type) ) + xlab($x_lab) + scale_linetype_manual(values=c('solid','solid','solid','solid','dashed')) +
                ylab('') + ggtitle(TeX(sprintf('$\\tau =%2.f$, $\\sigma = %.2f$,$\\n = %3.f$',$beta,$sigma,$n)))+
                scale_color_viridis(discrete=TRUE, direction = -1)+ theme_minimal()+ylim(0,$y_l)+xlim(1,$N)+scale_x_continuous(limits = c(1, $N), expand = c(0, 0),breaks= c(1,seq(0,$N,length=5)[2:5]))+
               theme(plot.title = element_text(hjust = 0.5,size = 10), axis.text.x = element_text(size=10), plot.margin = unit(c(1,$m, 0, 0),'pt'))"
    return R"p"
end



DF = load("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_4.jld")
DF_1000_1000 = DF["DF_1000_1000"]
n=1000
β= 1.0
ntr=250
sigma_vec= [0.25,0.75]

N_plot = [100, 600]
y_l = [0.15,0.03]
P_all_approx_1000 =Array{RObject{VecSxp}}(undef,length(sigma_vec))
x_lab=[" ","k"]
for i in (1:length(sigma_vec))
             P_all_approx_1000[i]= plot_draw_prior_distribution(DF_1000_1000[1][i],N_plot[i],β,sigma_vec[i],y_l[i],x_lab[i],n,0)

end


β= 10.0
N_plot = [100, 600]
y_l = [0.15,0.03]
P_all_approx_10_1000 =Array{RObject{VecSxp}}(undef,length(sigma_vec))
x_lab=[" ","k"]
for i in (1:length(sigma_vec))
             P_all_approx_10_1000[i]= plot_draw_prior_distribution(DF_1000_1000[2][i],N_plot[i],β,sigma_vec[i],y_l[i],x_lab[i],n,0)

end



R"
m1=as.list($P_all_approx_1000)
m2 = as.list($P_all_approx_10_1000)
prow <- plot_grid(
  m1[[1]] + theme(legend.position='none'),
  m2[[1]] + theme(legend.position='none'),
  m1[[2]] + theme(legend.position='none'),
  m2[[2]]+ theme(legend.position='none'),
  nrow = 2)
legend_b <- get_legend(m1[[1]]+theme(legend.position ='top'))
p <- plot_grid(prow,ncol = 1,rel_heights = c(10, 1))
#ggsave(file = '~/Documents/GitHub/GibbsTypePriors/test/comparison/Plots_sigma_all_approximation_100_n.pdf', width= 6, height = 4,p)
#save(m1,file ='~/Documents/GitHub/GibbsTypePriors/P_100_df_b1.Rdata')
#save(m2,file ='~/Documents/GitHub/GibbsTypePriors/P_100_df_b10.Rdata')
pdf('/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/figures/figure_4.pdf')
plot(p)
dev.off()
"
