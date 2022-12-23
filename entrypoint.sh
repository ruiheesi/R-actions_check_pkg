#!/bin/sh -l

cd $3


# Check for build only
if [ "$1" = "build" ]; then
    echo "\e[33m\e[1mRunning only build task"
    R CMD build $3
fi


# Build and check
if [ "$1" = "all" ]; then
    echo "\e[33m\e[1mRunning all tasks"
    echo "\e[33m\e[1mStart package build."
    R CMD build $3
    echo "\e[33m\e[1mPackage build ended."
    # Check if description file exist
    if [ -f DESCRIPTION ]; then
        echo "\e[33m\e[1mDESCRIPTION exist."
        echo "\e[33m\e[1mInstall texlive for PDF manual check."
        apt-get -y install texlive

        # Check for bioconductor dependencies
        if [ "$2" = true ]; then
            echo "\e[33m\e[1mInstall Bioconductor"
            Rscript -e 'if (!requireNamespace("BiocManager", quietly=TRUE))  install.packages("BiocManager");if (FALSE) BiocManager::install(version = "devel", ask = FALSE);cat(append = TRUE, file = "~/.Rprofile.site", "options(repos = BiocManager::repositories());")'
            
            echo "\e[33m\e[1mInstall package dependencies."
            Rscript -e 'if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes", repo = c(BiocManager::repositories()))'
            Rscript -e 'deps <- remotes::dev_package_deps(dependencies = NA, repos = c(BiocManager::repositories()));remotes::install_deps(dependencies = TRUE, repos = c(BiocManager::repositories()));if (!all(deps$package %in% installed.packages())) { message("missing: ", paste(setdiff(deps$package, installed.packages(repo=)), collapse=", ")); q(status = 1, save = "no")}'
        else
            echo "\e[33m\e[1mInstall package dependencies."
            Rscript -e 'if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")'
            Rscript -e 'deps <- remotes::dev_package_deps(dependencies = NA);remotes::install_deps(dependencies = TRUE);if (!all(deps$package %in% installed.packages())) { message("missing: ", paste(setdiff(deps$package, installed.packages(repo=)), collapse=", ")); q(status = 1, save = "no")}'
        fi

        echo "\e[33m\e[1mGet package name and version from description file."
        package=$(grep -Po 'Package:(.*)' DESCRIPTION)
        version=$(grep -Po 'Version:(.*)' DESCRIPTION)
        package=${package##Package: }
        version=${version##Version: }
        

        echo "\e[33m\e[1mStart package check and test for ${package}_${version}"
        if [ -f "${package}_${version}.tar.gz" ]; then
            R CMD check ./"${package}_${version}.tar.gz" --as-cran
        else 
            echo "\e[31m\e[1mPackage did not build properly, no package to test."
            # exit 1 
        fi
       
        
    else 
        echo "\e[31m\e[1mDESCRIPTION file does not exist."
        exit 1
    fi
    
fi

echo "Build and check finished, building NAMESPACE file"
echo "\e[33m\e[1mGenerating NAMESPACE file"
Rscript -e 'library(devtools);document()'
echo $(ls)
