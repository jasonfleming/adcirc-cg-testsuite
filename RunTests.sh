#!/bin/bash

#...List of ADCIRC's test cases. Cases are named by their directory tree
case_list=( adcirc/adcirc_apes                                       \
            adcirc/adcirc_apes-parallel                              \
            adcirc/adcirc_internal_overflow                          \
            adcirc/adcirc_internal_overflow-parallel                 \
            adcirc/adcirc_quarterannular-2d                          \
            adcirc/adcirc_quarterannular-3d                          \
            adcirc/adcirc_quarterannular-2d-netcdf                   \
            adcirc/adcirc_quarterannular-2d-parallel                 \
            adcirc/adcirc_quarterannular-3d-parallel                 \
            adcirc/adcirc_quarterannular-2d-parallel-netcdf          \
            adcirc/adcirc_quarterannular-2d-parallel-netcdf-writer   \
            adcirc/adcirc_quarterannular-2d-parallel-writer          \
            adcirc/adcirc_shinnecock_inlet                           \
            adcirc/adcirc_shinnecock_inlet-parallel                  \
            adcirc-swan/adcirc_swan_apes_irene                       \
            adcirc-swan/adcirc_swan_apes_irene-parallel              )

#...Maximum Absoloute Error
abserr=0.00001

#...Maximum Relative Error
relerr=0.00001

#...Path to the executables
adcirc_path=$1

#...Object directories for each executable
ODIR_adcirc=$adcirc_path/odir3
ODIR_padcirc=$adcirc_path/odir4
ODIR_adcprep=$adcirc_path/odir1
ODIR_adcswan=$adcirc_path/odir33
ODIR_padcswan=$adcirc_path/odir44

#...Current home location
TESTHOME=$(pwd)

#...Sanity check on script arguments
if [ $# -ne 1 ] ; then
    echo "ERROR: Script requires 1 argument with folder containing adcirc.exe and adccmp.exe"
    exit 1
fi

#...Ensure that a relative path is not supplied
if [ "x${adcirc_path:0:1}" != "x/" ] ; then
    echo "ERROR: You must provide an absoloute path."
    exit 1
fi

#...Check if adcirc exists
if [ ! -s $1/adcirc ] ; then
    echo "ERROR: adcirc executable not found."
    exit 1
fi

#...Check if adcprep exists
if [ ! -s $1/adcprep ] ; then
    echo "ERROR: adcprep executable not found."
    exit 1
fi

#...Check if padcirc exists
if [ ! -s $1/padcirc ] ; then
    echo "ERROR: padcirc executable not found."
    exit 1
fi

#...Check of adccmp exists
if [ ! -s $1/adccmp ] ; then
    echo "ERROR: adccmp executable not found."
    exit 1
fi

#...Check if adcswan exists
if [ ! -s $1/adcswan ] ; then
    echo "ERROR: adcswan executable not found."
    exit 1
fi

#...Check if padcswan exists
if [ ! -s $1/padcswan ] ; then
    echo "ERROR: padcswan executable not found."
    exit 1
fi

#...Check for GCOV files
if [ -s $ODIR_adcirc/adcirc.gcno ] ; then
    coverage=1
else
    coverage=0
fi

#...Loop to run over all the test cases
for CASE in ${case_list[@]}
do

    #...Proceed into the case directory
    cd $CASE

    #...Check for the generic run.sh script
    if [ ! -s run.sh ]; then
        echo "ERROR: Could not find run script for $CASE"
        exit 1
    fi
    
    #...Run the case and check the return status
    ./run.sh $adcirc_path $abserr $relerr 2>/dev/null
    if [ $? -ne 0 ] ; then
        echo "ERROR: The case $CASE did not pass."
        exit 1
    fi

    #...Back to testing home location
    cd $TESTHOME
done

#...Check to see if we need to generate coverage report
if [ "x$coverage" == "x1" ] ; then
    echo "Generating ADCIRC Coverage Report..."
    ./GenerateCoverageReport.sh ADCIRC $ODIR_adcirc
    echo ""
    echo "Generating ADCPREP Coverage Report..."
    ./GenerateCoverageReport.sh ADCPREP $ODIR_adcprep
    echo ""
    echo "Generating PADCIRC Coverage Report..."
    ./GenerateCoverageReport.sh PADCIRC $ODIR_padcirc
    echo ""
    echo "Generating ADCSWAN Coverage Report..."
    ./GenerateCoverageReport.sh ADCSWAN $ODIR_adcswan
    echo ""
    echo "Generating PADCSWAN Coverage Report..."
    ./GenerateCoverageReport.sh PADCSWAN $ODIR_padcswan
fi
    

#...Exit with status zero if all tests have passed
exit 0
