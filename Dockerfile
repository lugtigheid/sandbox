FROM rocker/verse:3.6.0 as chs_rbase_build

# add shiny server
RUN export ADD=shiny && bash /etc/cont-init.d/add

# install linux system dependencies
RUN apt-get update && apt-get install -y libudunits2-dev python-pip python-virtualenv

RUN echo "rstudio:notrstudio" | chpasswd \
                && chown rstudio:rstudio /home/rstudio

#configure shiny server
COPY ./shiny-server.conf /etc/shiny-server/shiny-server.conf
#RUN chown -hR rstudio:rstudio /home/rstudio/ShinyApps
 
FROM chs_rbase_build as chs_rfull_build

# install R dependencies
RUN R -e "install.packages(c('tidygraph', 'ggforce', 'ggraph'), Ncpus=parallel::detectCores())"

# install orgsurveyr
RUN R -e "devtools::install_github('ukgovdatascience/orgsurveyr', build_vignettes = TRUE)"

#batch 1 - foundational
RUN R -e "install.packages(c('tidytext', 'Rcpp', 'devtools', 'ggplot2', 'shiny', 'rmarkdown', 'caTools', 'tidytest', 'stm', 'flexdashboard', 'plotly',  'stringr',  'lubridate',  'tidyr', 'packrat', 'testthat', 'png', 'broom', 'foreign', 'haven', 'htmlwidgets', 'DT', 'network3D'), repos='http://cran.r-project.org')"

#batch 2 - generally useful
RUN R -e "install.packages(c('pryr', 'plyr', 'RSQLite', 'reshape2', 'wordcloud', 'RPostgreSQL', 'zoo', 'crayon', 'RCurl', 'plumbr', 'survey', 'bookdown'), repos='http://cran.r-project.org')"

# batch 3 - machine learning
RUN R -e "install.packages(c('forecast', 'caret', 'e1071', 'C50', 'rpart', 'neuralnet', 'kernlab', 'lime', 'gbm', 'glmnet', 'naivebayes', 'lme4', 'nlme', 'randomForest'), repos='http://cran.r-project.org')"
RUN R -e "devtools::install_github('rstudio/keras')"
RUN R -e "library(keras); install_keras();"

# batch 4 - extras
RUN R -e "install.packages(c('data.table', 'doParallel', 'Metrics', 'Rserve', 'gmodels'), repos='http://cran.r-project.org')"

#batch 5 - advanced and pipeline - need to install graph (dependency of drake/CodeDepends) 
RUN R -e "source('https://bioconductor.org/biocLite.R');biocLite('graph', suppressUpdates=TRUE, suppressAutoUpdate=TRUE)" 
RUN R -e "install.packages(c('future', 'batchtools', 'furrr', 'drake', 'goodpractice', 'templates', 'prodigenr'), repos='http://cran.r-project.org')"

# batch 6 - advanced plotting packages
RUN R -e "install.packages(c('viridis', 'viridisLite','leaflet', 'grid', 'gridExtra', 'GGally', 'ggvis', 'RColorBrewer', 'shinyjs', 'shinyBS', 'rbokeh', 'shinydashboard', 'shinythemes', 'ggthemes', 'ggplotify', 'ggrepel', 'gganimate', 'ggExtra', 'shinyWidgets'), repos='http://cran.r-project.org')"
