using RCall

R"
library(gridExtra)
library(cowplot)
library(tidyverse)
library(latex2exp)
library(viridis)
"


load("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_7_1.jld")



R"
range01 <- function(x){(x-min(x))/(max(x)-min(x))}
df_r= $DF_PY
df_r$beta_scaled= range01(df_r$beta_log)
df_r$color = rgb(df_r$beta_scaled, df_r$sigma,0.5,1)
#df_r$color = rgb(0, df_r$sigma,0.5,1)
#df_r$color_sigma = rgb(0, df_r$sigma,0.5,1)
df_r$color_sigma = rgb(df_r$beta_scaled, df_r$sigma,0.5,1)
df_r$color_beta = rgb(0, 0,0.5,1)
p <- df_r %>% ggplot(aes(x=Exp, y = std, group=sigma))  + geom_line(alpha = 0.8,linetype = 'longdash') + geom_point(aes(colour=color), size=4)
p_py <- p  + geom_line(data =df_r, aes(x=Exp, y = std, group=beta), alpha = 0.8, linetype='dotted') +
  xlim(0, 100)+ ylim(0,16)+ labs(y='Std', x='Expectation')+scale_colour_identity()+theme_classic()+
   theme(plot.title = element_text(hjust = 0.5,size = 15), axis.text.x = element_text(size=15), axis.text.y = element_text(size=15),legend.position='none')
"


R"p_py
pdf('/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/figures/figure_7_1.pdf')
plot(p_py)
dev.off()"




load("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_7_2.jld")


R"
range01 <- function(x){(x-min(x))/(max(x)-min(x))}
df_r= $DF_PYM
df_r$beta_scaled= range01(df_r$beta_log)
df_r$color = rgb(df_r$beta_scaled, df_r$sigma,0.5,1)
print(df_r[1:15,])
df_r$color_sigma = rgb(0, df_r$sigma,0.5,1)
df_r$color_beta = rgb(df_r$beta_scaled, 0,0.5,1)
p <- df_r %>% ggplot(aes(x=Exp, y = std, group=sigma))  + geom_line(alpha = 0.8,linetype = 'longdash') + geom_point(aes(colour=color), size=4)
p_pym <- p  + geom_line(data =df_r, aes(x=Exp, y = std, group=beta), alpha = 0.8, linetype='dotted') +
  xlim(0, 100)+ ylim(0,16)+ labs(y='Std', x='Expectation')+scale_colour_identity()+theme_classic()+
   theme(plot.title = element_text(hjust = 0.5,size = 15), axis.text.x = element_text(size=15), axis.text.y = element_text(size=15),legend.position='none')
"

R"p_pym
pdf('/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/figures/figure_7_2.pdf')
plot(p_pym)
dev.off()"



load("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_7_3.jld")


R"
range01 <- function(x){(x-min(x))/(max(x)-min(x))}
df_r= $DF_PY_apr
df_r$beta_scaled= range01(df_r$beta_log)
df_r$color = rgb(df_r$beta_scaled, df_r$sigma,0.5,1)
print(df_r[1:15,])
df_r$color_sigma = rgb(0, df_r$sigma,0.5,1)
df_r$color_beta = rgb(df_r$beta_scaled, 0,0.5,1)
p <- df_r %>% ggplot(aes(x=Exp, y = std, group=sigma))  + geom_line(alpha = 0.8,linetype = 'longdash') + geom_point(aes(colour=color), size=4)
p_py_apr <- p  + geom_line(data =df_r, aes(x=Exp, y = std, group=beta), alpha = 0.8, linetype='dotted') +
  xlim(0, 100)+ ylim(0,16)+ labs(y='Std', x='Expectation')+scale_colour_identity()+theme_classic()+
   theme(plot.title = element_text(hjust = 0.5,size = 15), axis.text.x = element_text(size=15), axis.text.y = element_text(size=15),legend.position='none')
"

R"p_py_apr
pdf('/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/figures/figure_7_3.pdf')
plot(p_py_apr)
dev.off()"


load("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_7_4.jld")


R"
range01 <- function(x){(x-min(x))/(max(x)-min(x))}
df_r= $DF_PY_sb
df_r$beta_scaled= range01(df_r$beta_log)
df_r$color = rgb(df_r$beta_scaled, df_r$sigma,0.5,1)
print(df_r[1:15,])
df_r$color_sigma = rgb(0, df_r$sigma,0.5,1)
df_r$color_beta = rgb(df_r$beta_scaled, 0,0.5,1)
p <- df_r %>% ggplot(aes(x=Exp, y = std, group=sigma))  + geom_line(alpha = 0.8,linetype = 'longdash') + geom_point(aes(colour=color), size=4)
p_p_sb <- p  + geom_line(data =df_r, aes(x=Exp, y = std, group=beta), alpha = 0.8, linetype='dotted') +
  xlim(0, 100)+ ylim(0,16)+ labs(y='Std', x='Expectation')+scale_colour_identity()+theme_classic()+
   theme(plot.title = element_text(hjust = 0.5,size = 15), axis.text.x = element_text(size=15), axis.text.y = element_text(size=15),legend.position='none')
"

R"p_p_sb
pdf('/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/figures/figure_7_4.pdf')
plot(p_p_sb)
dev.off()"




#### color grid

load("/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/saves_for_figures/figure_7_5.jld")

R"
df_color=data.frame(sigma= $(last.(grid_vec)), beta_log=  log($(first.(grid_vec))))
df_color$beta_scaled= range01(df_color$beta_log)
df_color$color= rgb(df_color$beta_scaled,df_color$sigma,0.5,1)
df_color$color_sigma= rgb(0,df_color$sigma,0.5,1)
df_color$color_beta= rgb(df_color$beta_scaled,0,0.5,1)
p <- df_color %>% ggplot(aes(x=beta_log, y = sigma, group=sigma))  + geom_line(aes(color = color_sigma), alpha = 0.8,linetype = 'longdash') + geom_point(aes(colour=color), size=3)
p_color<- p +  geom_line(data =df_color, aes(x=beta_log, y = sigma, group=beta_log), alpha = 0.8, linetype='dotted') +theme_classic()+theme(legend.position='none')
p_color
"


R"p_color
pdf('/Users/dariabystrova/Documents/GitHub/approximatingBNPpriors/figures/figure_7_5.pdf')
plot(p_color)
dev.off()"




#############


R"
range01 <- function(x){(x-min(x))/(max(x)-min(x))}
#df_r$beta_scaled= range01(df_r$beta_log)
#df_r$color = rgb(df_r$beta_scaled, df_r$sigma,0.5,1)

betas = exp(seq(log(1), log(200), length.out=10))
sigmas = seq(0.05, 0.99, length.out = 10)

library(tidyverse)

to_plot = expand_grid(betas, sigmas) %>%
  mutate(col = rgb(red = range01(log(betas)), green = sigmas, blue = 0.5, alpha = 1))

pt = to_plot %>%
  ggplot(aes(x = betas, y = sigmas)) +
  geom_point(aes(colour = col),size=4) + scale_x_log10() + annotation_logticks(base = 10)+ scale_color_identity()
 pt = pt +  geom_line(data =to_plot, aes(x=betas, y = sigmas, group=betas),linetype = 'longdash', alpha = 0.5,size=0.3)+
   geom_line(data =to_plot, aes(x=betas, y = sigmas, group=sigmas),linetype = 'dotted', alpha = 0.5,size=0.3)+ theme_classic()+
   theme(plot.title = element_text(hjust = 0.5,size = 15), axis.text = element_text(size=15), axis.title=element_text(size=15),legend.position='none')+
   ylab(TeX(sprintf('$\\sigma$')))+ xlab(TeX(sprintf('$\\tau$')))"

  R"
  pdf(file = '/Users/bystrova/Documents/GitHub/GibbsTypePriors/test/expectation_variance/Std_variance_NGGs_color_grid_v4.pdf',width= 4, height = 4)
  plot(pt)
  dev.off()
  "
