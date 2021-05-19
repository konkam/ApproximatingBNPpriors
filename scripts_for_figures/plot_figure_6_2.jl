using RCall, JLD


R"
library(gridExtra)
library(cowplot)
library(tidyverse)
library(latex2exp)
library(viridis)
"


DF = load("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_6_2.jld")
EV_NGG__approx = DF["NGG_approx"]



DF_NGGM_approx = DataFrame(Exp = first.(EV_NGG__approx),Var =last.(EV_NGG__approx), beta = first.(grid_vec), sigma = last.(grid_vec))
DF_NGGM_approx.std = sqrt.(DF_NGGM_approx.Var)
DF_NGGM_approx.beta_log= log.(DF_NGGM_approx.beta)


R"
df_r= $DF_NGGM_approx
df_r$beta_scaled= range01(df_r$beta_log)
df_r$color = rgb(df_r$beta_scaled, df_r$sigma,0.5,1)
df_r$color_sigma = rgb(0, df_r$sigma,0.5,1)
df_r$color_beta = rgb(df_r$beta_scaled, 0,0.5,1)
"
R"
p <- df_r %>% ggplot(aes(x=Exp, y = std, group=sigma))  + geom_line(alpha = 0.8,linetype = 'longdash') + geom_point(aes(colour=color), size=4)
p_nggm_approx <- p  + geom_line(data =df_r, aes(x=Exp, y = std, group=beta), alpha = 0.9,linetype = 'dotted') +
         xlim(0, 100)+ ylim(0,15)+labs(y='Std', x='Expectation')+scale_colour_identity()+theme_classic()+ theme(plot.title = element_text(hjust = 0.5,size = 15), axis.text = element_text(size=15),legend.position='none')
"

R"p_nggm_approx
pdf('/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/figures/figure_6_2.pdf', width= 4, height = 4)
plot(p_nggm_approx)
dev.off()"
