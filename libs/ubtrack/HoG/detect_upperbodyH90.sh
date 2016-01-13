#!/bin/sh
if [ $# -lt 4 ]
then
    echo "<usage>: detect_upperbodyH90.sh <image name/image directory/list file> "
    echo "          <out text file> <out image file/out image dir> <detector directory>"
else
    InFile=$1
    OutFile=$2
    ImageFile=$3
    BinDIR=$4

WIDTH=100; export WIDTH
HEIGHT=90; export HEIGHT
THR=0.0001; export THR

lightclassify_POHist=$BinDIR/lightclassify_FastHOG

allOptions="-W $WIDTH,$HEIGHT -C 8,8 -N 2,2 -B 9 -G 8,8 -S 0 --wtscale 2 --maxvalue 0.2 --epsilon 1 --fullcirc 0 -v 3 --proc rgb_sqrt_grad --norm norml2hys -p 1,0 --no_nonmax 0 -z 8,16,1.3 --cachesize 152 --scaleratio 1.05 --stride 8 --margin 4,4 --avsize 0,70 -t $THR -m 0 "


echo Running hog on image list
ResultDir=$OutFile
CMD="$lightclassify_POHist $allOptions $BinDIR/HOGub/model_4BiSVMLight.H90.alt $InFile $OutFile -c histogrammio.txt -i $ImageFile"

#LD_LIBRARY_PATH=$BinDIR      # TURN THIS LINE ON IF YOU WANT TO USE LOCAL COPY OF libImlib2

echo running command: $CMD      
$CMD 
fi
