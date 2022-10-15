#!/bin/bash
# First, you need to source the bash library.
source lib/build_utils.sh
# In your own script, you will have to load the bash-utils module and then
# source the library in the following way.

# module load bash-utils
# source "${BASH_UTILS_DIR}/build_utils.sh"

# Set the program name and versions, used to create the installation paths.
PROGRAM_NAME=bash-utils
PROGRAM_VERSION=devel
# the following function sets up the installation path according to the
# cluster the script is running on and the first argument given. The argument
# can be:
# - "group": install the software in the group wide directory
# - "user": install the software only for the current user
# - "test": install the software in the current working directory 
process_build_script_input group

# load all the modules required for the program to compile and run.
# the following command also adds those module names in the modulefile
# that this script will generate.

# module_load module1/ver module2/ver ..

# build your software here
cp -r . $INSTALL_DIR/

# add any additional LMOD command you want to be run here.. 
ADDITIONAL_MODULEFILE_COMMANDS="setenv('BASH_UTILS_DIR', root_dir .. '/lib');" 

create_modulefile



