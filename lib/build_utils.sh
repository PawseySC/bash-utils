
# The following function loads a module and save its name in an environment variable that then will
# be used to add those module loads in the modulefile itself.
function module_load {
    BU_LOADED_MODULES="$BU_LOADED_LODULES $@"
    module load $@
}


# This function reads the input arguments of a build script and use them to
# define the INSTALL_DIR and MODULEFILE_DIR environment variables
function create_modulefile {
    if ! [ -n "$MODULEFILE_DIR" ]; then
        echo "MODULEFILE_DIR variable not set."
        exit 1 
    fi
    if ! [ -n "$INSTALL_DIR" ]; then
        echo "INSTALL_DIR variable not set."
        exit 1 
    fi

    if ! [ -n "$PROGRAM_NAME" ]; then
        echo "PROGRAM_NAME variable not set."
        exit 1 
    fi
    if ! [ -n "$PROGRAM_VERSION" ]; then
        PROGRAM_VERSION=devel
    fi 
    MODULE_LOAD_COMMANDS=""
    for module in $BU_LOADED_MODULES;
    do
    MODULE_LOAD_COMMANDS="$MODULE_LOAD_COMMANDS load('$module');"
    done
    echo "-- Modulefile for $PROGRAM_NAME.
local root_dir = '$INSTALL_DIR'
if (mode() ~= 'whatis') then
    $MODULE_LOAD_COMMANDS
    prepend_path('PATH', root_dir .. '/bin')
    prepend_path('LD_LIBRARY_PATH', root_dir .. '/lib')
    prepend_path('LIBRARY_PATH', root_dir .. '/lib')
    prepend_path('CPATH', root_dir .. '/include')
    $ADDITIONAL_MODULEFILE_COMMANDS
end
    " > "$MODULEFILE_DIR/${PROGRAM_VERSION}.lua"
}

#
# process_build_script_input
#
# Description
# -----------
# Implements the build  

function process_build_script_input {
    if ! [ -n "$PROGRAM_NAME" ]; then
        echo "PROGRAM_NAME variable not set."
        exit 1 
    fi   
    if ! [ -n "$PROGRAM_VERSION" ]; then
        echo "PROGRAM_VERSION variable not set."
        exit 1
    fi

    if [ $PAWSEY_CLUSTER = "mwa" ]; then
        if [ $1 = 'group' ]; then
            INSTALL_DIR="/astro/mwavcs/pacer_blink/software/sles12sp5/development/$PROGRAM_NAME/$PROGRAM_VERSION"
            MODULEFILE_DIR="/astro/mwavcs/pacer_blink/software/sles12sp5/modulefiles/$PROGRAM_NAME"
        elif  [ $1 = 'user' ]; then
            INSTALL_DIR="/astro/mwavcs/pacer_blink/$USER/software/$PROGRAM_NAME/$PROGRAM_VERSION"
            MODULEFILE_DIR="/astro/mwavcs/pacer_blink/$USER/software/modulefiles/$PROGRAM_NAME"
        elif [ "$1" != 'test' ]; then
            echo "Error parsing build script input: first parameter not recognised."
            exit 1
        fi
    elif [ $PAWSEY_CLUSTER = "topaz" ]; then
        if [ "$1" = 'group' ]; then
            INSTALL_DIR="/group/director2183/software/centos7.6/development/$PROGRAM_NAME/$PROGRAM_VERSION"
            MODULEFILE_DIR="/group/director2183/software/centos7.6/modulefiles/$PROGRAM_NAME"
        elif [ "$1" = 'user' ]; then
            INSTALL_DIR="/group/director2183/$USER/software/centos7.6/development/$PROGRAM_NAME/$PROGRAM_VERSION"
            MODULEFILE_DIR="/group/director2183/$USER/software/centos7.6/modulefiles/$PROGRAM_NAME"
        elif [ "$1" != 'test' ]; then
            echo "Error parsing build script input: first parameter not recognised."
            exit 1
        fi
    elif [ $PAWSEY_CLUSTER = "setonix" ]; then
        if [ "$1" = 'group' ]; then
            INSTALL_DIR="/software/projects/director2183/setonix/$PROGRAM_NAME/$PROGRAM_VERSION"
            MODULEFILE_DIR="/software/projects/director2183/setonix/modules/$PROGRAM_NAME"
        elif [ "$1" = 'user' ]; then
            INSTALL_DIR="/software/projects/director2183/$USER/setonix/$PROGRAM_NAME/$PROGRAM_VERSION"
            MODULEFILE_DIR="/software/projects/director2183/$USER/setonix/modules/$PROGRAM_NAME"
        elif [ "$1" != 'test' ]; then
            echo "Error parsing build script input: first parameter not recognised."
            exit 1
        fi

        echo "Error: cluster not recognised."
        exit 1
    fi
    # irrespective of the cluster, if i is a test build, then the installation path is relative to the build one.
    if [ "$1" = 'test' ]; then
        INSTALL_DIR="`pwd`/build"
        MODULEFILE_DIR="$INSTALL_DIR/modulefiles/$PROGRAM_NAME"
        
        if [[ -n "$2" && "$2" != "-" ]]; then
            INSTALL_DIR="$2"
            MODULEFILE_DIR="$INSTALL_DIR/modulefiles/$PROGRAM_NAME"
        fi
        if [[ -n "$3" && "$3" != "-" ]]; then
            MODULEFILE_DIR=$3
        fi
    fi
    
    # create directories if they don't exist
    [ -d $INSTALL_DIR ] || mkdir -p $INSTALL_DIR
    [ -d $MODULEFILE_DIR ] || mkdir -p $MODULEFILE_DIR
}

