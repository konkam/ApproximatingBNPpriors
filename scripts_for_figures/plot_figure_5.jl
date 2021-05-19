using RCall, JLD


R"
library(gridExtra)
library(cowplot)
library(tidyverse)
library(latex2exp)
library(viridis)
"



function plot_draw_prior_distribution(df,N,beta,sigma,y_l,x_lab,n,m)
               ps_sb_py = smooth_pk(df.Pkn_SB[1:N])
               R"p = ggplot(data.frame(k = 1:$N,
                                Pkn_4_numeric = $(df.Pkn_numeric[1:N]),
                                Pkn_3_order2 = $(df.Pkn_order2[1:N]),
                                Pkn_2_PY_Mult = $(df.Pkn_PYM[1:N]),
                                Pkn_1_PY_SB = $(ps_sb_py)
                            ) %>%
                    gather(Process_type, density, Pkn_4_numeric:Pkn_1_PY_SB),
               aes(x=k, y = density, colour = Process_type)) +
                geom_line(aes(linetype =Process_type) ) + xlab($x_lab) + scale_linetype_manual(values=c('solid','solid','solid','dashed')) +
                ylab('') + ggtitle(TeX(sprintf('$\\tau =%2.f$, $\\sigma = %.2f$,$\\n = %3.f$',$beta,$sigma,$n)))+
               scale_color_viridis(discrete=TRUE, direction=-1) + theme_minimal()+ylim(0,$y_l)+scale_x_continuous(limits = c(1, $N), expand = c(0, 0),breaks= c(1,seq(0,$N,length=5)[2:5]))+
               theme(plot.title = element_text(hjust = 0.5,size = 10), axis.text.x = element_text(size=10), plot.margin = unit(c(1,$m, 0, 0),'pt'))"
    return R"p"
end


load("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_5.jld")



N_plot = [100, 100]
y_l = [0.15,0.1]
P_all_approx_100_PY =Array{RObject{VecSxp}}(undef,length(sigma_vec))
x_lab=[" ","k"]
for i in (1:length(sigma_vec))
             P_all_approx_100_PY[i]= plot_draw_prior_distribution(DF_100_250_py[1][i],N_plot[i],β,sigma_vec[i],y_l[i],x_lab[i],n,0)

end



N_plot = [100, 100]
y_l = [0.15,0.1]
P_all_approx_100_10_py =Array{RObject{VecSxp}}(undef,length(sigma_vec))
x_lab=[" ","k"]
for i in (1:length(sigma_vec))
             P_all_approx_100_10_py[i]= plot_draw_prior_distribution(DF_100_250_py[2][i],N_plot[i],β,sigma_vec[i],y_l[i],x_lab[i],n,10)

end



R"library(gridExtra)
library(cowplot)
m1=as.list($P_all_approx_100_PY)
m2 = as.list($P_all_approx_100_10_py)
prow <- plot_grid(
  m1[[1]] + theme(legend.position='none'),
  m2[[1]] + theme(legend.position='none'),
  m1[[2]] + theme(legend.position='none'),
  m2[[2]]+ theme(legend.position='none'),
  nrow = 2
)
legend_b <- get_legend(m1[[1]]+theme(legend.position ='top'))
p <- plot_grid(prow,ncol = 1,rel_heights = c(10, 1))
pdf('/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/figures/figure_5.pdf')
plot(p)
dev.off()
"
