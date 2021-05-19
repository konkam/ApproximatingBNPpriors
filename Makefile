############ Comments

# Using a makefile is a way to record how to make all figures in a single script, this is one way of making Supplemental Information for a paper.
# The advantage of a makefile is that with the make utility, whenever a change is made to the SI, only the part of the computations relevant to the change are run. In other words, the dependence structure of the files is recorded in the makefile, so it is possible to identify what scripts or file can be affected by a change to another file. This also allows performing independent computations in parallel.

# To use, run in a terminal:

# make Figures

# Parallel computations using 8 cores can be made by:

# make -j8 Figures


#-------------------

# Scripts to make the figures are in the folder scripts_for_figure/
# If a figure takes a long time to draw, it is more convenient to save the results than to recompute everything each time the figure needs change.
# Saved results are in the folder saves_for_figure/

# A script to make figure "figname" is named figname_fig.jl
# A script to compute the results beforehand is named figname_precomp.jl
# A saved result for a figure is a file named figname.jld, created using the Julia package JLD

#-------------------

# To get reproducible julia figures, we use the following command:
# julia --project=. myscript.jl
# The above command makes sure that julia runs using all the packages that are specified in the Manifest.toml file, ensuring reproducibility.
# For more info, see https://julialang.github.io/Pkg.jl/v1/environments/#Using-someone-else's-project-1

############# Figures

## accuracy_PknCnkVnk_1000_5000bits
saves_for_figures/figure_1.jld: scripts_for_figures/cmp_figure_1.jl
	julia --project=. scripts_for_figures/cmp_figure_1.jl

saves_for_figures/figure_2.jld: scripts_for_figures/cmp_figure_2.jl
		julia --project=. scripts_for_figures/cmp_figure_2.jl

saves_for_figures/figure_5.jld: scripts_for_figures/cmp_figure_5.jl
		julia --project=. scripts_for_figures/cmp_figure_5.jl

saves_for_figures/figure_7.jld: scripts_for_figures/cmp_figure_7.jl
		julia --project=. scripts_for_figures/cmp_figure_7.jl


figures/figure_1.pdf: saves_for_figures/figure_1.jld scripts_for_figures/plot_figure_1.jl
	julia --project=. scripts_for_figures/plot_figure_1.jl

figures/figure_2.pdf: saves_for_figures/figure_2.jld scripts_for_figures/plot_figure_2.jl
	julia --project=. scripts_for_figures/plot_figure_2.jl

figures/figure_3.pdf: saves_for_figures/figure_3.jld scripts_for_figures/plot_figure_3.jl
	julia --project=. scripts_for_figures/plot_figure_3.jl

figures/figure_4.pdf: saves_for_figures/figure_4.jld scripts_for_figures/plot_figure_4.jl
	julia --project=. scripts_for_figures/plot_figure_4.jl

figures/figure_5.pdf: saves_for_figures/figure_5.jld scripts_for_figures/plot_figure_5.jl
	julia --project=. scripts_for_figures/plot_figure_5.jl

figures/figure_7_1.pdf: saves_for_figures/figure_7_1.jld scripts_for_figures/plot_figure_7_1.jl
	julia --project=. scripts_for_figures/plot_figure_7_1.jl

figures/figure_7_2.pdf: saves_for_figures/figure_7_2.jld scripts_for_figures/plot_figure_7_2.jl
	julia --project=. scripts_for_figures/plot_figure_7_2.jl

figures/figure_7_3.pdf: saves_for_figures/figure_7_3.jld scripts_for_figures/plot_figure_7_3.jl
	julia --project=. scripts_for_figures/plot_figure_7_3.jl

figures/figure_7_4.pdf: saves_for_figures/figure_7_4.jld scripts_for_figures/plot_figure_7_4.jl
	julia --project=. scripts_for_figures/plot_figure_7_4.jl

figures/figure_7_5.pdf: saves_for_figures/figure_7_5.jld scripts_for_figures/plot_figure_7_5.jl
	julia --project=. scripts_for_figures/plot_figure_7_5.jl


Figures: figures/figure_1.pdf
	       figures/figure_2.pdf
				 figures/figure_3.pdf
				 figures/figure_5.pdf
				 figures/figure_7_1.pdf
				 figures/figure_7_2.pdf
				 figures/figure_7_3.pdf
				 figures/figure_7_4.pdf
				 figures/figure_7_5.pdf


############# Cleaning
clean:
	$(RM) saves_for_figures/*
	$(RM) figures/*
