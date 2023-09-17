#!/usr/bin/env bash

shebang="#!/usr/bin/env bash"

root0=${0##*/}
helpmsg(){
    echo "Required: ${root0} <mydatfile>"
    echo "    -d --dat -dat"
    echo "        dat file(s). Arguments without options are assumed to be dat files."
    echo "        Ex 1. ${root0} 1001.dat 2000.dat"
    echo "        Ex 2. ${root0} \"1001.dat -d 2000.dat\""
    echo "        Ex 3. ${root0} -d 1001.dat 2000.dat"
    echo "        Ex 4. ${root0} -d \"1001.dat 2000.dat\""
    echo "        Ex 5. ${root0} -d 1001.dat -d 2000.dat"
    echo "        Ex 6. ${root0} 1001.dat -d 2000.dat"
    echo "    -A --autorun -autorun --AUTORUN -AUTORUN"
    echo "        Flag. Automatically execute *_fileout.sh script. Default is to not execute."
    echo "    -b --batchscript -batchscript"
    echo "        *_fileout.sh scripts are collected in the executable batchscript."
    echo "    -H --HCPDIR -HCPDIR --hcpdir -hcpdir"
    echo "        HCP directory. Optional if set at the top of this script or elsewhere via variable HCPDIR."
    echo "    -F --FREESURFVER -FREESURFVER --freesurferVersion -freesurferVersion"
    echo "        5.3.0-HCP, 7.2.0, 7.3.2, or 7.4.0. Default is 7.3.2 unless set elsewhere via variable FREESURFVER."
    echo "    -m --HOSTNAME"
    echo "        Flag. Use machine name instead of user named file."
    echo "    -D --DATE -DATE --date -date"
    echo "        Flag. Add date (YYMMDD) to name of output script."
    echo "    -DL --DL --DATELONG -DATELONG --datelong -datelong"
    echo "        Flag. Add date (YYMMDDHHMMSS) to name of output script."
    echo "    -r  --hires"
    echo "        Resolution. Should match that for the sturctural pipeline. options : 0.7, 0.8 or 1mm. Default is 1mm."
    echo "    -h --help -help"
    echo "        Echo this help message."
    exit
    }
if((${#@}<1));then
    helpmsg
    exit
fi
echo $0 $@

arg=("$@")
for((i=0;i<${#@};++i));do
    #echo "i=$i ${arg[i]}"
    case "${arg[i]}" in
        -d | --dat | -dat)
            dat+=(${arg[((++i))]})
            for((j=i;j<${#@};++i));do #i is incremented only if dat is appended
                dat0=(${arg[((++j))]})
                [ "${dat0::1}" = "-" ] && break
                dat+=(${dat0[@]})
            done
            ;;
        -A | --autorun | -autorun | --AUTORUN | -AUTORUN)
            lcautorun=1
            echo "lcautorun=$lcautorun"
            ;;
        -b | --batchscript | -batchscript)
            bs=${arg[((++i))]}
            echo "bs=$bs"
            ;;
        -H | --HCPDIR | -HCPDIR | --hcpdir | -hcpdir)
            HCPDIR=${arg[((++i))]}
            echo "HCPDIR=$HCPDIR"
            ;;
        -F | --FREESURFVER | -FREESURFVER | --freesurferVersion | -freesurferVersion)
            FREESURFVER=${arg[((++i))]}
            echo "FREESURFVER=$FREESURFVER"
            ;;
        -m | --HOSTNAME)
            lchostname=1
            echo "lchostname=$lchostname"
            ;;
        -D | --DATE | -DATE | --date | -date)
            lcdate=1
            echo "lcdate=$lcdate"
            ;;
        -DL | --DL | --DATELONG | -DATELONG | --datelong | -datelong)
            lcdate=2
            echo "lcdate=$lcdate"
            ;;
        -r | --hires)
            Hires=${arg[((++i))]}
            echo "Hires=$Hires"
            ;;
        -h | --help | -help)
            helpmsg
            exit
            ;;
        *) unexpected+=(${arg[i]})
            ;;
    esac
done
[ -n "${unexpected}" ] && dat+=(${unexpected[@]})
if [ -z "${dat}" ];then
    echo "Need to provide dat file"
    exit
fi

for((i=0;i<${#dat[@]};++i));do
    COFFEEstructpipeSETUP.sh ${dat[i]} -F 7.4.0 -b 230625.sh
    COFFEEfMRIpipeSETUP.sh ${dat[i]} -f 4 6 -p 60 -F 7.4.0 -b 230625.sh
done

done
