library(GLM3r)
test_files <- list.files(system.file('extdata', package = 'GLM3r'), full.names = TRUE)
sim_folder <- 'glm_test'
dir.create(sim_folder)
file.copy(test_files, sim_folder)
run_glm(sim_folder)