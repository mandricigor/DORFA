#!/bin/bash

# I want to launch DORFA like the following:
# 1) Directory where we have mollusk files. It must have:
#     * noncomplete.cds
#     * 3prime.cds
#     * internal.cds
#     * 5prime.cds
#     * complete.cds
# 2) Working DIRECTORY
# 3) database to use
# 4) Rule: MINIMUM or PRODUCT

# Main arguments:
molluskDir=$1
workingDir=$2
database=$3
rule=$4

# Define some variables here:
PYTHON=python2
DIAMOND_BIN=/home/code/IMPORT/DIAMOND/binary/diamond
SCRIPTS=$PWD/DORFA_SCRIPTS
OVERLAP=3
haveInternal=1
if [ ! -f $molluskDir/internal.cds ]; then
    haveInternal=0
fi

tempDir=$workingDir/tempDir
tempDir1=$workingDir/tempDir1
tempDir2=$workingDir/tempDir2
tempDir3=$workingDir/tempDir3
tempDir4=$workingDir/tempDir4

overlapDir=$workingDir/overlapDir
mappingDir=$workingDir/diamond_mappings
edgesDir=$mappingDir/edges
validationEdgesDir=$edgesDir/validationEdges

noncompleteDiamondMappingFile=$workingDir/noncomplete_orfs_diamond

# Create some directories here:
mkdir -p $tempDir
mkdir -p $tempDir1
mkdir -p $tempDir2
mkdir -p $tempDir3
mkdir -p $tempDir4

mkdir -p $workingDir
mkdir -p $overlapDir
mkdir -p $mappingDir
mkdir -p $edgesDir
mkdir -p $validationEdgesDir


#<<'END'
echo "1: RUNNING DIAMOND ON NONCOMPLETE ORFS"
$DIAMOND_BIN blastx -d $database -q $molluskDir/noncomplete.cds -o $noncompleteDiamondMappingFile -t $tempDir -l1  --max-target-seqs 1
echo "DONE"

echo "2: CUTTING PIECES OF CONTIGS"
$PYTHON $SCRIPTS/NCORFS_pieces.py 3prime.cds $molluskDir $workingDir $haveInternal
$PYTHON $SCRIPTS/NCORFS_pieces.py 5prime.cds $molluskDir $workingDir $haveInternal
if [ "$haveInternal" -eq 1 ]; then
    $PYTHON $SCRIPTS/NCORFS_pieces.py internal.cds $molluskDir $workingDir $haveInternal
fi
echo "DONE"
#END



echo "3: DOING OVERLAPS"
$PYTHON $SCRIPTS/overlap.py $workingDir/3prime.cds.right $workingDir/5prime.cds.left $OVERLAP > $overlapDir/3prime_right_5prime_left
if [ "$haveInternal" -eq 1 ]; then
    $PYTHON $SCRIPTS/overlap.py $workingDir/3prime.cds.right $workingDir/internal.cds.left $OVERLAP > $overlapDir/3prime_right_internal_left &
    $PYTHON $SCRIPTS/overlap.py $workingDir/internal.cds.right $workingDir/internal.cds.left $OVERLAP > $overlapDir/internal_right_internal_left &
    $PYTHON $SCRIPTS/overlap.py $workingDir/internal.cds.right $workingDir/5prime.cds.left $OVERLAP > $overlapDir/internal_right_5prime_left &
    wait
    cat $overlapDir/3prime_right_internal_left $overlapDir/internal_right_internal_left $overlapDir/internal_right_5prime_left > $overlapDir/all_overlaps
else
    cp $overlapDir/3prime_right_5prime_left $overlapDir/all_overlaps
fi
echo "DONE"

echo "4: JOINING NONCOMPLETE ORFS"
$PYTHON $SCRIPTS/JOIN_NON_COMPLETE_ORFS.py $molluskDir/noncomplete.cds $overlapDir/3prime_right_5prime_left $workingDir/3prime_right_5prime_left 
if [ "$haveInternal" -eq 1 ]; then
    $PYTHON $SCRIPTS/JOIN_NON_COMPLETE_ORFS.py $molluskDir/noncomplete.cds $overlapDir/3prime_right_internal_left $workingDir/3prime_right_internal_left &
    $PYTHON $SCRIPTS/JOIN_NON_COMPLETE_ORFS.py $molluskDir/noncomplete.cds $overlapDir/internal_right_internal_left $workingDir/internal_right_internal_left &
    $PYTHON $SCRIPTS/JOIN_NON_COMPLETE_ORFS.py $molluskDir/noncomplete.cds $overlapDir/internal_right_5prime_left $workingDir/internal_right_5prime_left &
    wait
fi
echo "DONE"


echo "5: RUNNING DIAMOND ON EDGES"
$DIAMOND_BIN blastx -d $database -q $workingDir/3prime_right_5prime_left -o $mappingDir/3prime_right_5prime_left -t $tempDir1 -l1 --max-target-seqs 1
if [ "$haveInternal" -eq 1 ]; then
    $DIAMOND_BIN blastx -d $database -q $workingDir/3prime_right_internal_left -o $mappingDir/3prime_right_internal_left -t $tempDir2 -l1 --max-target-seqs 1 &
    $DIAMOND_BIN blastx -d $database -q $workingDir/internal_right_internal_left -o $mappingDir/internal_right_internal_left -t $tempDir3 -l1 --max-target-seqs 1 &
    $DIAMOND_BIN blastx -d $database -q $workingDir/internal_right_5prime_left -o $mappingDir/internal_right_5prime_left -t $tempDir4 -l1 --max-target-seqs 1 &
    wait
fi
echo "DONE"

echo "6: FINDING GOOD EDGES"
$PYTHON $SCRIPTS/evalue_product.py $noncompleteDiamondMappingFile $mappingDir/3prime_right_5prime_left $edgesDir/3prime_right_5prime_left $rule
if [ "$haveInternal" -eq 1 ]; then
    $PYTHON $SCRIPTS/evalue_product.py $noncompleteDiamondMappingFile $mappingDir/3prime_right_internal_left $edgesDir/3prime_right_internal_left $rule &
    $PYTHON $SCRIPTS/evalue_product.py $noncompleteDiamondMappingFile $mappingDir/internal_right_internal_left $edgesDir/internal_internal_internal_left $rule &
    $PYTHON $SCRIPTS/evalue_product.py $noncompleteDiamondMappingFile $mappingDir/internal_right_5prime_left $edgesDir/internal_right_5prime_left $rule &
    wait
fi
echo "DONE"


echo "7: WRITING EDGES TO DISK"
awk '{split($1, a, "___"); print a[1]" "a[2]}' $edgesDir/3prime_right_5prime_left > $edgesDir/3prime_right_5prime_left.edges
if [ "$haveInternal" -eq 1 ]; then
    awk '{split($1, a, "___"); print a[1]" "a[2]}' $edgesDir/3prime_right_internal_left > $edgesDir/3prime_right_internal_left.edges
    awk '{split($1, a, "___"); print a[1]" "a[2]}' $edgesDir/internal_right_internal_left > $edgesDir/internal_right_internal_left.edges
    awk '{split($1, a, "___"); print a[1]" "a[2]}' $edgesDir/internal_right_5prime_left > $edgesDir/internal_right_5prime_left.edges
fi
echo "DONE"


echo "8: DOING SIMPLE PATHS"
if [ "$haveInternal" -eq 1 ]; then
    $PYTHON $SCRIPTS/simple_paths.py $edgesDir/internal_right_5prime_left.edges $edgesDir/internal_right_internal_left.edges $edgesDir/3prime_right_internal_left.edges > $edgesDir/simple_paths
    cat $edgesDir/simple_paths $edgesDir/3prime_right_5prime_left.edges > $edgesDir/all_simple_paths
else
    cp $edgesDir/3prime_right_5prime_left.edges $edgesDir/all_simple_paths
fi
echo "DONE"


 
echo "9: JOINING EDGES INTO PATHS"
$PYTHON $SCRIPTS/create_paths.py $molluskDir/noncomplete.cds $overlapDir/all_overlaps $edgesDir/all_simple_paths $validationEdgesDir/newORFS
echo "DONE"


echo "10: RUNNING DIAMOND ON PATHS"
$DIAMOND_BIN blastx -d $database -q $validationEdgesDir/newORFS -o $validationEdgesDir/diamond_newORFS -t $tempDir -l1 --max-target-seqs 1
echo "DONE"


echo "11: COMPUTING LENGTHS OF NONCOMPLETE ORFS"
$PYTHON $SCRIPTS/NCORFS_len.py $validationEdgesDir/newORFS $validationEdgesDir/diamond_newORFS $validationEdgesDir/newORFs_lens
echo "DONE"

echo "12: CHECK QUALITY OF RECONSTRUCTED ORFS"
$PYTHON $SCRIPTS/CHECK_QUALITY_evalue.py $noncompleteDiamondMappingFile $validationEdgesDir/diamond_newORFS $validationEdgesDir/ultimate_validation_evalue $rule
echo "DONE"


rm -rf $tempDir
rm -rf $tempDir1
rm -rf $tempDir2
rm -rf $tempDir3
rm -rf $tempDir4

