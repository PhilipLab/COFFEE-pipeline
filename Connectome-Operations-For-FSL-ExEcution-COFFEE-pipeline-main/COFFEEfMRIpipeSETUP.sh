#!/usr/bin/env bash

shebang="#!/usr/bin/env bash"

#Hard coded location of workbench
[ -z ${WBDIR+x} ] && WBDIR=/Users/Shared/pipeline/HCP/workbench-mac/bin_macosx64

#Hard coded location of HCP scripts
[ -z ${HCPDIR+x} ] && HCPDIR=/Users/Shared/pipeline/HCP

#START230319
[ -z ${FSLDIR+x} ] && export FSLDIR=/usr/local/fsl

#Hard coded location of freesurfer installations
[ -z ${FREESURFDIR+x} ] && FREESURFDIR=/Applications/freesurfer

##Hard coded freesurfer version options: 5.3.0-HCP 7.2.0 7.3.2
#[ -z ${FREESURFVER+x} ] && FREESURFVER=7.3.2
#START230712
#Hard coded freesurfer version options: 5.3.0-HCP 7.2.0 7.3.2 7.4.0
[ -z ${FREESURFVER+x} ] && FREESURFVER=7.4.0

#Hard coded GenericfMRIVolumeProcessingPipelineBatch.sh
#P0=221103GenericfMRIVolumeProcessingPipelineBatch_dircontrol.sh
#START230610
P0=COFFEEGenericfMRIVolumeProcessingPipelineBatch.sh

#Hard coded T1w_restore.sh 
#P1=230117T1w_restore.sh
#START230610
P1=COFFEET1w_restore.sh

#Hard coded SmoothingProcess.sh
#P2=220723SmoothingProcess.sh
#START230610
P2=COFFEESmoothingProcess.sh

#Hard coded makeregdir.sh
#P3=makeregdir230314.sh
#START230610
P3=COFFEEmakeregdir.sh

#Hard coded pipeline settings
#setup0=230319SetUpHCPPipeline.sh
#START230610
setup0=COFFEESetUpHCPPipeline.sh

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

    #echo "        Flag. Automatically execute script. Default is not execute *_autorun.sh"
    #START230620
    echo "        Flag. Automatically execute *_fileout.sh script. Default is to not execute."

    echo "    -b --batchscript -batchscript"

    #echo "        *_autorun.sh scripts are collected in the executable batchscript."
    #START230620
    echo "        *_fileout.sh scripts are collected in the executable batchscript."

    echo "    -H --HCPDIR -HCPDIR --hcpdir -hcpdir"
    echo "        HCP directory. Optional if set at the top of this script or elsewhere via variable HCPDIR."
    echo "    -F --FREESURFVER -FREESURFVER --freesurferVersion -freesurferVersion"

    #echo "        5.3.0-HCP, 7.2.0 or 7.3.2. Default is 7.3.2 unless set elsewhere via variable FREESURFVER."
    #START230620
    echo "        5.3.0-HCP, 7.2.0, 7.3.2, or 7.4.0. Default is 7.3.2 unless set elsewhere via variable FREESURFVER."

    echo "    -m --HOSTNAME"
    echo "        Flag. Use machine name instead of user named file."
    echo "    -D --DATE -DATE --date -date"
    echo "        Flag. Add date (YYMMDD) to name of output script."
    echo "    -DL --DL --DATELONG -DATELONG --datelong -datelong"
    echo "        Flag. Add date (YYMMDDHHMMSS) to name of output script."
    echo "    -f --fwhm"
    echo "        Smoothing in mm for SUSAN. Multiple values ok."
    echo "    -p --paradigm_hp_sec"
    echo "        High pass filter cutoff in sec"
    echo "    -T --T1COPYMASKONLY"
    echo "        Flag. Only copy the T1w_restore.2 and mask to create T1w_restore_brain.2"
    echo "    -s --SMOOTHONLY"
    echo "        Flag. Only do the smoothing: SUSAN and high pass filtering."

    #START230623
    #echo "    -c --CLEANONLY"
    #echo "        Flag. Only do the cleaning: remove all directories except MNINonLinear."
    #echo "    -i --CLEAN"
    #echo "        Flag. Include cleaning (ie remove all directories except MNINonLinear)."
    #echo "        Cleaning is normally not included because little things can go wrong and who wants to have to rerun the structural pipeline."

    echo "    -o -fsf1 --fsf1"
    echo "        Text file. List of fsf files for first-level FEAT analysis. A makeregdir call is created for each fsf."

    echo "    -t -fsf2 --fsf2"
    echo "        Text file. List of fsf files for second-level FEAT analysis. A makeregdir call is created for each fsf."
    #START230605
    #echo "        This option will not be executed unless -o is also included."


    echo "    -M --MAKEREGDIRONLY -MAKEREGDIRONLY"
    echo "        Flag. Only write the makeregdir scripts."
    echo "    -h --help -help"
    echo "        Echo this help message."
    exit
    }
if((${#@}<1));then
    helpmsg
    exit
fi
echo $0 $@

#lcautorun=0;bs=;lchostname=0;lcdate=0;fwhm=;paradigm_hp_sec=;lct1copymaskonly=0;lcsmoothonly=0;lccleanonly=0;lcclean=0;fsf1=;fsf2=;lcmakeregdironly=0 #do not set dat or unexpected
#START230623
#lcautorun=0;bs=;lchostname=0;lcdate=0;fwhm=;paradigm_hp_sec=;lct1copymaskonly=0;lcsmoothonly=0;fsf1=;fsf2=;lcmakeregdironly=0 #do not set dat or unexpected
#START230712
lcautorun=0;lchostname=0;lcdate=0;lct1copymaskonly=0;lcsmoothonly=0;lcmakeregdironly=0 #do not set dat or unexpected
unset bs fwhm paradigm_hp_sec fsf1 fsf2

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
        -b | --batchScript | -batchscript)
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

        -f | --fwhm)

            #START230712
            #fwhm=

            for((j=0;++i<${#@};));do
                if [ "${arg[i]:0:1}" = "-" ];then
                    ((--i));
                    break
                else
                    fwhm[((j++))]=${arg[i]}
                fi
            done
            #echo "fwhm=${fwhm[@]} nelements=${#fwhm[@]}"
            echo "fwhm=${fwhm[@]}"
            ;;
        -p | --paradigm_hp_sec)
            paradigm_hp_sec=${arg[((++i))]}
            echo "paradigm_hp_sec=$paradigm_hp_sec"
            ;;
        -T | --T1COPYMASKONLY)
            lct1copymaskonly=1
            echo "lct1copymaskonly=$lct1copymaskonly"
            ;;

        -s | --SMOOTHONLY)
            lcsmoothonly=1
            echo "lcsmoothonly=$lcsmoothonly"
            ;;

        #START230623
        #-c | --CLEANONLY)
        #    lccleanonly=1
        #    echo "lccleanonly=$lccleanonly"
        #    ;;
        #-i | --CLEAN)
        #    lcclean=1
        #    echo "lcclean=$lcclean"
        #    ;;


        -o | -fsf1 | --fsf1)
            fsf1=${arg[((++i))]}
            echo "fsf1=$fsf1"
            ;;
        -t | -fsf2 | --fsf2)
            fsf2=${arg[((++i))]}
            echo "fsf2=$fsf2"
            ;;
        -M | --MAKEREGDIRONLY | -MAKEREGDIRONLY)
            lcmakeregdironly=1
            echo "lcmakeregdironly=$lcmakeregdironly"
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
#echo "dat[@]=${dat[@]}"
#echo "#dat[@]=${#dat[@]}"


if [ -z "${fwhm}" ];then

    #echo "-f | --fwhm has not been specified. SUSAN noise reduction will not be performed."
    #START230605
    ((lcmakeregdironly==0)) && echo "-f | --fwhm has not been specified. SUSAN noise reduction will not be performed."

    fwhm=0
fi
if [ -z "${paradigm_hp_sec}" ]; then

    #echo "-p | --paradigm_hp_sec has not been specified. High pass filtering will not be performed."
    #START230605
    ((lcmakeregdironly==0)) && echo "-p | --paradigm_hp_sec has not been specified. High pass filtering will not be performed."

    paradigm_hp_sec=0
fi


if [ -n "${fsf1}" ];then
    IFS=$'\r\n,\t ' read -d '' -ra FSF1 < $fsf1

    #outputdir1=
    #START230712
    unset outputdir1

    for((i=0;i<${#FSF1[@]};++i));do
        IFS=$'"' read -ra line0 < <(grep "set fmri(outputdir)" ${FSF1[i]})
        outputdir1[i]=${line0[1]}
    done

    #START230605
    #if [ -n "${fsf2}" ];then
    #    IFS=$'\r\n,\t ' read -d '' -ra FSF2 < $fsf2
    #    outputdir2=
    #    for((i=0;i<${#FSF2[@]};++i));do
    #        IFS=$'"' read -ra line0 < <(grep "set fmri(outputdir)" ${FSF2[i]})
    #        outputdir2[i]=${line0[1]}
    #    done
    #fi

fi

#START230605
if [ -n "${fsf2}" ];then
    IFS=$'\r\n,\t ' read -d '' -ra FSF2 < $fsf2

    #outputdir2=
    #START230712
    unset outputdir2

    for((i=0;i<${#FSF2[@]};++i));do
        IFS=$'"' read -ra line0 < <(grep "set fmri(outputdir)" ${FSF2[i]})
        outputdir2[i]=${line0[1]}
    done
fi


SCRIPT0=${HCPDIR}/scripts/${P0}
SCRIPT1=${HCPDIR}/scripts/${P1}
SCRIPT2=${HCPDIR}/scripts/${P2}
SCRIPT3=${HCPDIR}/scripts/${P3}
ES=${HCPDIR}/scripts/${setup0}

for((i=0;i<${#dat[@]};++i));do
    IFS=$'\r\n' read -d '' -ra csv0 < ${dat[i]}
    csv+=("${csv0[@]}")
done
#printf '%s\n' "${csv[@]}"

if [ -z "${bs}" ];then
    num_sub=0
    for((i=0;i<${#csv[@]};++i));do
        IFS=$'\r\n\t, ' read -ra line <<< ${csv[i]}
        if [[ "${line[0]:0:1}" = "#" ]];then
            #echo "Skiping line $((i+1))"
            continue
        fi
        ((num_sub++))
    done
    num_cores=$(sysctl -n hw.ncpu)
    ((num_sub>num_cores)) && echo "${num_sub} will be run, however $(hostname) only has ${num_cores}. Please consider -b | --batchscript."
fi

#START230618
#if [[ "${FREESURFVER}" != "5.3.0-HCP" && "${FREESURFVER}" != "7.2.0" && "${FREESURFVER}" != "7.3.2" ]];then
#    echo "Unknown version of freesurfer. FREESURFVER=${FREESURFVER}"
#    exit
#fi

if [ -n "${bs}" ];then

    #bs0=${bs%/*}
    #mkdir -p ${bs0}
    #START230622
    [[ $bs == *"/"* ]] && mkdir -p ${bs%/*}


    echo -e "$shebang\n" > $bs
fi

#START230712
#wd0=$(pwd)


for((i=0;i<${#csv[@]};++i));do

    #IFS=$',\r\n ' read -ra line <<< ${csv[i]}
    IFS=$'\r\n\t, ' read -ra line <<< ${csv[i]}


    if [[ "${line[0]:0:1}" = "#" ]];then
        #echo "Skiping line $((i+1))"
        continue
    fi
    echo ${line[0]}

    dir0=${line[1]}${FREESURFVER}
    if [ ! -d "${dir0}" ];then
        echo "${dir0} does not exist"
        continue
    fi

    if((lcdate==1));then
        date0=$(date +%y%m%d)
    elif((lcdate==2));then
        date0=$(date +%y%m%d%H%M%S)
    fi
    #echo "date0=${date0}"

    F0=


    #if((lcmakeregdironly==0));then
    #    if((lcsmoothonly==0)) && ((lccleanonly==0));then
    #        l0=hcp3.27fMRIvol 
    #    else
    #        ((lccleanonly==0)) && l0=smooth || l0=clean
    #    fi 
    #else
    #    l0=makeregdir
    #fi
    #START230623
    if((lcmakeregdironly==0));then
        ((lcsmoothonly==0)) && l0=hcp3.27fMRIvol || l0=smooth
    else
        l0=makeregdir
    fi






    ((lcdate==0)) && F0stem=${dir0}/${line[0]////_}_${l0} || F0stem=${dir0}/${line[0]////_}_${l0}_${date0}
    F0[0]=${F0stem}.sh

    #F1=${F0stem}_autorun.sh
    #START230620
    F1=${F0stem}_fileout.sh

    if((lcmakeregdironly==0)) && [ -n "${outputdir1}" ];then
        ((lcdate==0)) && F0[1]=${dir0}/${line[0]////_}_makeregdir.sh || F0[1]=${dir0}/${line[0]////_}_makeregdir_${date0}.sh
    fi


    #START230625
    if [ -n "${bs}" ];then
        ((lcdate==0)) && bs0stem=${dir0}/${line[0]////_}_hcp3.27batch || bs0stem=${dir0}/${line[0]////_}_hcp3.27batch_$(date +%y%m%d)
        bs0=${bs0stem}.sh
        [[ ! -f ${bs0} ]] && echo -e "$shebang\nset -e\n" > ${bs0}
        bs1=${bs0stem}_fileout.sh
        echo -e "$shebang\nset -e\n" > ${bs1} #ok to crush, because nothing new is written
    fi



    if((lcmakeregdironly==0));then

        #bold=
        #for((j=7;j<=23;j+=2));do
        #    if [ "${line[j]}" != "NONE" ] && [ "${line[j]}" != "NOTUSEABLE" ];then
        #        [ ! -f ${line[j]} ] &&  echo "    ${line[j]} does not exist" || bold[j]=1
        #    fi
        #done
        #START230618
        for((j=7;j<=23;j+=2));do
            bold[j]=0
            if [ "${line[j]}" != "NONE" ] && [ "${line[j]}" != "NOTUSEABLE" ];then
                [ ! -f ${line[j]} ] &&  echo "    ${line[j]} does not exist" || bold[j]=1
            fi
        done




        lcbold=$(IFS=+;echo "$((${bold[*]}))")
        ((lcbold==0)) && continue

        #printf '%s ' "${bold[@]}";echo '';echo "${#bold[@]}"


        #make sure bolds and SBRef have same phase encoding direction and dimensions
        lcSBRef=0;ped=;dim1=;dim2=;dim3=
        for((j=6;j<=22;j+=2));do
            if((${bold[j+1]}==1));then
                if [ "${line[j]}" != "NONE" ] && [ "${line[j]}" != "NOTUSEABLE" ];then
                    if [ ! -f ${line[j]} ];then
                        echo "    ${line[j]} does not exist"
                        continue
                    fi 
                    for((k=j;k<=((j+1));++k));do
                        json=${line[k]%%.*}.json
                        if [ ! -f $json ];then
                            echo "    $json not found. Abort!"
                            exit
                        fi
                        IFS=$' ,' read -ra line0 < <( grep PhaseEncodingDirection $json )
                        IFS=$'"' read -ra line1 <<< ${line0[1]}
                        ped[k]=${line1[1]}
                    done
                    if [[ "${ped[j]}" != "${ped[j+1]}" ]];then
                        echo "    ERROR: ${line[j]} ${ped[j]}, ${line[j+1]} ${ped[j+1]}. Phases should be the same. Will not use this SBRef."
                        continue
                    fi

                    for((k=j;k<=((j+1));++k));do
                        IFS=$'\r\n,\t ' read -d '' -ra line1 <<< $(fslinfo ${line[k]} | grep -w dim[1-3])
                        dim1[k]=${line1[@]:1:1}
                        dim2[k]=${line1[@]:3:1}
                        dim3[k]=${line1[@]:5:1}
                    done
                    #form and test tuple
                    if [[ "${dim1[j]}${dim2[j]}${dim3[j]}" != "${dim1[j+1]}${dim2[j+1]}${dim3[j+1]}" ]];then
                        echo "    ERROR: ${line[j]} ${dim1[j]} ${dim2[j]} ${dim3[j]}"
                        echo "           ${line[j+1]} ${dim1[j+1]} ${dim2[j+1]} ${dim3[j+1]}"
                        echo "           Dimensions should be the same. Will not use this SBRef."
                        continue
                    fi


                    bold[j]=1
                    ((lcSBRef++))
                fi
            fi
        done

        #for((j=4;j<=22;++j));do
        #    #echo "line[$j]=${line[j]} ped[$j]=${ped[j]}"
        #    echo "${line[j]} ${ped[j]} bold[$j]=${bold[j]} dim1[$j]=${dim1[j]} dim2[$j]=${dim2[j]} dim3[$j]=${dim3[j]}"
        #done

        lcbadFM=1

        #if((lcsmoothonly==0)) && ((lccleanonly==0)) && ((lct1copymaskonly==0));then
        #START230623
        if((lcsmoothonly==0)) && ((lct1copymaskonly==0));then

            if [[ "${line[4]}" != "NONE" && "${line[4]}" != "NOTUSEABLE" && "${line[5]}" != "NONE" && "${line[5]}" != "NOTUSEABLE" ]];then
                lcbadFM=0
                for((j=4;j<=5;j++));do
                    json=${line[j]%%.*}.json
                    if [ ! -f $json ];then
                        echo "    $json not found"
                        lcbadFM=1
                        break
                    fi
                    IFS=$' ,' read -ra line0 < <( grep PhaseEncodingDirection $json )
                    IFS=$'"' read -ra line1 <<< ${line0[1]}
                    ped[j]=${line1[1]}
                done
                if((lcbadFM==0));then
                    for((j=4;j<5;j+=2));do
                        if [[ "${ped[j]:0:1}" != "${ped[j+1]:0:1}" ]];then
                            echo "    ERROR: ${line[j]} ${ped[j]}, ${line[j+1]} ${ped[j+1]}. Fieldmap encoding direction must be the same!"
                            lcbadFM=1
                            break
                        fi
                        if [[ "${ped[j]}" = "${ped[j+1]}" ]];then
                            echo "    ERROR: ${line[j]} ${ped[j]}, ${line[j+1]} ${ped[j+1]}. Fieldmap phases must be opposite!"
                            lcbadFM=1
                            break
                        fi
                        for((k=j;k<=((j+1));++k));do
                            IFS=$'\r\n,\t ' read -d '' -ra line1 <<< $(fslinfo ${line[k]} | grep -w dim[1-3])
                            dim1[k]=${line1[@]:1:1}
                            dim2[k]=${line1[@]:3:1}
                            dim3[k]=${line1[@]:5:1}
                        done
                        #form and test tuple
                        if [[ "${dim1[j]}${dim2[j]}${dim3[j]}" != "${dim1[j+1]}${dim2[j+1]}${dim3[j+1]}" ]];then
                            echo "    ERROR: ${line[j]} ${dim1[j]} ${dim2[j]} ${dim3[j]}"
                            echo "           ${line[j+1]} ${dim1[j+1]} ${dim2[j+1]} ${dim3[j+1]}"
                            echo "           Dimensions must be the same. Will not use this SBRef."
                            break
                            lcbadFM=1
                        fi
                        nline=24;fm_idx=
                        for((k=7;k<=23;k+=2));do
                            if((${bold[k]}==1));then
                                if [[ "${ped[j]:0:1}" != "${ped[k]:0:1}" ]];then
                                    echo "    ERROR: ${line[j]} ${ped[j]}, ${line[k]} ${ped[k]}. Fieldmap encoding direction must be the same!"
                                    echo "           Fieldmap won't be applied."
                                    continue
                                fi
                                #form and test tuple
                                if [[ "${dim1[j]}${dim2[j]}${dim3[j]}" == "${dim1[k]}${dim2[k]}${dim3[k]}" ]];then
                                    fm_idx[k]=4
                                    continue
                                fi
                                for((l=24;l<nline;l+=2));do
                                    if [[ "${dim1[l]}${dim2[l]}${dim3[l]}" == "${dim1[k]}${dim2[k]}${dim3[k]}" ]];then
                                        fm_idx[k]=l
                                        break
                                    fi
                                done
                                if [[ -z "${fm_idx[k]}" ]];then
                                    echo "    ERROR: ${line[j]} ${dim1[j]} ${dim2[j]} ${dim3[j]}"
                                    echo "           ${line[k]} ${dim1[k]} ${dim2[k]} ${dim3[k]}"
                                    echo "           Dimensions must be the same."
                                    echo "           Fieldmap won't be applied unless it is resampled."
                                    read -p '    Would like to resample the field maps? y, n, q: ' ynq
                                    #echo "ynq=$ynq"
                                    if [[ "$ynq" = "q" || "$ynq" = "Q" || "$ynq" = "quit" || "$ynq" = "exit" ]];then
                                        exit
                                    elif [[ "$ynq" = "y" || "$ynq" = "Y" || "$ynq" = "yes" || "$ynq" = "YES" || "$ynq" = "Yes" ]];then
                                        fm_idx[k]=${nline} 
                                        for((l=j;l<=((j+1));++l));do
                                            line[nline]=${line[l]%.nii*}_resampled${dim1[k]}x${dim2[k]}x${dim3[k]}.nii.gz
                                            ${WBDIR}/wb_command -volume-resample ${line[l]} ${line[k]} CUBIC ${line[nline]}
                                            dim1[nline]=${dim1[k]}
                                            dim2[nline]=${dim2[k]}
                                            dim3[nline]=${dim3[k]}
                                            ((nline++))
                                        done
                                    fi
                                fi 
                            fi
                        done 
                    done
                fi
            fi
        fi
    fi

    for((j=0;j<${#F0[@]};++j));do

        #echo -e "$shebang\n" > ${F0[j]} 
        #START230610
        echo -e "$shebang\nset -e\n" > ${F0[j]} 

        echo -e "#$0 $@\n" >> ${F0[j]}
    done 

    #echo -e "$shebang\n" > ${F1}
    #START230610
    echo -e "$shebang\nset -e\n" > ${F1}

    if((lcmakeregdironly==0));then
        echo "FREESURFDIR=${FREESURFDIR}" >> ${F0[0]}
        echo "FREESURFVER=${FREESURFVER}" >> ${F0[0]}

        #if((lccleanonly==0));then
        #    echo -e export FREESURFER_HOME='${FREESURFDIR}/${FREESURFVER}'"\n" >> ${F0[0]}
        #fi
        #START230623
        echo -e export FREESURFER_HOME='${FREESURFDIR}/${FREESURFVER}'"\n" >> ${F0[0]}

    fi

    #if [ -n "${outputdir1}" ];then
    #START230605
    if [[ -n "${outputdir1}" || -n "${outputdir2}" ]];then

        for((j=0;j<${#F0[@]};++j));do
            echo "FSLDIR=${FSLDIR}" >> ${F0[j]}

            #echo -e export FSLDIR='${FSLDIR}'"\n" >> ${F0[j]}
            #START230605
            echo export FSLDIR='${FSLDIR}' >> ${F0[j]}
        done
    fi
    if((lcmakeregdironly==0));then


        #if((lcsmoothonly==0)) && ((lccleanonly==0)) && ((lct1copymaskonly==0));then
        #    echo 'P0='${SCRIPT0} >> ${F0[0]}
        #fi
        #if((lcsmoothonly==0)) && ((lccleanonly==0));then
        #    echo 'P1='${SCRIPT1} >> ${F0[0]}
        #fi
        #if((lct1copymaskonly==0)) && ((lccleanonly==0));then
        #    echo 'P2='${SCRIPT2} >> ${F0[0]}
        #fi
        #START230623
        if((lcsmoothonly==0)) && ((lct1copymaskonly==0));then
            echo 'P0='${SCRIPT0} >> ${F0[0]}
        fi
        if((lcsmoothonly==0));then
            echo 'P1='${SCRIPT1} >> ${F0[0]}
        fi
        if((lct1copymaskonly==0));then
            echo 'P2='${SCRIPT2} >> ${F0[0]}
        fi



    fi
    if [ -n "${outputdir1}" ];then
        for((j=0;j<${#F0[@]};++j));do
            #echo 'P3='${SCRIPT3} >> ${F0[j]}
            #START230605
            echo -e "\n"'P3='${SCRIPT3} >> ${F0[j]}
        done
    fi
    if((lcmakeregdironly==0));then

        #((lccleanonly==0)) && echo 'ES='${ES} >> ${F0[0]}
        #START230623
        echo 'ES='${ES} >> ${F0[0]}

        echo "" >> ${F0[0]}
        echo "sf0=${line[1]}"'${FREESURFVER}' >> ${F0[0]}

        #if((lct1copymaskonly==0)) && ((lccleanonly==0));then
        #START230623
        if((lct1copymaskonly==0));then

            if((lchostname==1));then
                echo 's0=$(hostname)' >> ${F0[0]}
            else
                IFS=$'/' read -ra line2 <<< ${line[1]}
                sub0=${line2[-2]}
                echo "s0=${sub0}" >> ${F0[0]}
            fi
        fi
        echo "" >> ${F0[0]}

        #if((lcsmoothonly==0)) && ((lccleanonly==0)) && ((lct1copymaskonly==0));then
        #START230623
        if((lcsmoothonly==0)) && ((lct1copymaskonly==0));then

            echo '${P0} \' >> ${F0[0]}
            echo '    --StudyFolder=${sf0} \' >> ${F0[0]}
            echo '    --Subject=${s0} \' >> ${F0[0]}
            echo '    --runlocal \' >> ${F0[0]}

            #endquote=
            #START230712
            unset endquote

            echo "here0 endquote=${endquote[@]} nelements=${#endquote[@]}"

            for((j=23;j>=7;j-=2));do
                if [ "${line[j]}" != "NONE" ] && [ "${line[j]}" != "NOTUSEABLE" ];then
                    endquote[j]='"'
                    break
                fi
            done
            echo '    --fMRITimeSeries="\' >> ${F0[0]}
            for((j=7;j<=23;j+=2));do
                ((${bold[j]}==1)) && echo '        '${line[j]}${endquote[j]}' \' >> ${F0[0]}
            done
            if((lcSBRef>0));then
                echo '    --fMRISBRef="\' >> ${F0[0]}
                for((j=6;j<=22;j+=2));do

                    #if((${bold[j+1]}==1));then
                    #    echo '        '${bold[j]}${endquote[j+1]}' \' >> ${F0[0]}
                    #fi
                    #START230521
                    if((${bold[j+1]}==1));then
                        ((${bold[j]}==1)) && echo '        '${line[j]}${endquote[j+1]}' \' >> ${F0[0]} || echo '        '${endquote[j+1]}' \' >> ${F0[0]}
                    fi

                done
            fi
            if((lcbadFM==0));then
                for((j=4;j<=5;j++));do
                    if [[ "${ped[j]:1:1}" == "-" ]];then
                        echo '    --SpinEchoPhaseEncodeNegative="\' >> ${F0[0]}


                        #for((k=7;k<=23;k+=2));do
                        #    if [[ -n "${fm_idx[k]}" ]];then
                        #        echo '        '${line[fm_idx[k]]}${endquote[k]}' \' >> ${F0[0]}
                        #    else
                        #        echo '       '${endquote[k]}' \' >> ${F0[0]}
                        #    fi
                        #done
                        #START230618
                        for((k=7;k<=23;k+=2));do
                            if((${bold[k]}==1));then
                                if [[ -n "${fm_idx[k]}" ]];then
                                    echo '        '${line[fm_idx[k]]}${endquote[k]}' \' >> ${F0[0]}
                                else
                                    echo '       '${endquote[k]}' \' >> ${F0[0]}
                                fi
                            fi
                        done
                

                    else
                        echo '    --SpinEchoPhaseEncodePositive="\' >> ${F0[0]}


                        #for((k=7;k<=23;k+=2));do
                        #    if [[ -n "${fm_idx[k]}" ]];then
                        #        echo '        '${line[fm_idx[k]+1]}${endquote[k]}' \' >> ${F0[0]}
                        #    else
                        #        echo '       '${endquote[k]}' \' >> ${F0[0]}
                        #    fi
                        #done
                        #START230618
                        for((k=7;k<=23;k+=2));do
                            if((${bold[k]}==1));then
                                if [[ -n "${fm_idx[k]}" ]];then
                                    echo '        '${line[fm_idx[k]+1]}${endquote[k]}' \' >> ${F0[0]}
                                else
                                    echo '       '${endquote[k]}' \' >> ${F0[0]}
                                fi
                            fi
                        done


                    fi
                done
                echo '    --freesurferVersion=${FREESURFVER} \' >> ${F0[0]}
                echo -e '    --EnvironmentScript=${ES}\n' >> ${F0[0]}
            fi
        fi

        #if((lcsmoothonly==0)) && ((lccleanonly==0)) && ((lcbadFM==0));then
        #START230623
        if((lcsmoothonly==0)) && ((lcbadFM==0));then

            echo '${P1} \' >> ${F0[0]}
            for((j=7;j<=23;j+=2));do
                if((bold[j]==1));then
                    str0=${line[j]##*/}
                    str0=${str0%.nii*}
                    echo '    --t1=${sf0}/'${str0}/T1w_restore.2.nii.gz' \' >> ${F0[0]}
                    echo '    --mask=${sf0}/'${str0}/brainmask_fs.2.nii.gz' \' >> ${F0[0]}
                    echo '    --outpath=${sf0}/MNINonLinear/Results \' >> ${F0[0]}
                    echo -e '    --EnvironmentScript=${ES}\n' >> ${F0[0]}
                    break
                fi
            done
        fi

        #if((lct1copymaskonly==0)) && ((lccleanonly==0)) && ((lcbadFM==0));then
        #START230623
        if((lct1copymaskonly==0)) && ((lcbadFM==0));then

            endquote0=
            for((j=17;j>=7;j-=2));do
                if [ "${line[j]}" != "NONE" ] && [ "${line[j]}" != "NOTUSEABLE" ];then
                    endquote0[j]='"'
                    break
                fi
            done
            echo '${P2} \' >> ${F0[0]}
            echo '    --fMRITimeSeriesResults="\' >> ${F0[0]}
            #for((j=7;j<=23;j+=2));do
            for((j=7;j<=17;j+=2));do #task runs only
                if((bold[j]==1));then
                    str0=${line[j]##*/}
                    str0=${str0%.nii*}
                    echo '        ${sf0}/MNINonLinear/Results/'${str0}/${str0}.nii.gz${endquote0[j]}' \' >> ${F0[0]}
                fi
            done
            if((${fwhm[0]}>0));then
                echo '    --fwhm="'${fwhm[@]}'" \' >> ${F0[0]}
            fi
            if((paradigm_hp_sec>0));then
                echo '    --paradigm_hp_sec="'${paradigm_hp_sec}'" \' >> ${F0[0]}
                trstr=
                #for((j=7;j<=23;j+=2));do
                for((j=7;j<=17;j+=2));do #task runs only
                    if((bold[j]==1));then
                        json=${line[j]%%.*}.json
                        if [ ! -f $json ];then
                            echo "    $json not found"
                            rm -f ${F0[0]}
                            continue
                        fi
                        IFS=$' ,' read -ra line0 < <( grep RepetitionTime $json )
                        trstr+="${line0[1]} "
                    fi
                done
                echo '    --TR="'${trstr::-1}'" \' >> ${F0[0]}
            fi
            echo '    --EnvironmentScript=${ES}' >> ${F0[0]}
        fi
    fi


    if [ -n "${outputdir1}" ];then
        for((j=0;j<${#F0[@]};++j));do
            echo "" >> ${F0[j]}
            printf '${FSLDIR}/bin/feat %s\n' "${FSF1[@]}" >> ${F0[j]}
            echo "" >> ${F0[j]}
            printf '${P3}'" ${line[0]} %s\n" "${outputdir1[@]##*/}" >> ${F0[j]}


            #START230605
            #if [ -n "${outputdir2}" ];then
            #    echo "" >> ${F0[j]}
            #    printf '${FSLDIR}/bin/feat %s\n' "${FSF2[@]}" >> ${F0[j]}
            #fi

        done
    fi

    #START230605
    if [ -n "${outputdir2}" ];then
        for((j=0;j<${#F0[@]};++j));do
            echo "" >> ${F0[j]}
            printf '${FSLDIR}/bin/feat %s\n' "${FSF2[@]}" >> ${F0[j]}
        done
    fi



    #START230623
    #if((lcmakeregdironly==0));then
    #    if((lcclean==1)) || ((lccleanonly==1));then
    #        echo -e '\nrm -rf ${sf0}/T1w' >> ${F0[0]}
    #        T2f=;T20=${line[3]}
    #        if [[ "${T20}" = "NONE" || "${T20}" = "NOTUSEABLE" ]];then
    #            #echo "    T2 ${T20}"
    #            :
    #        elif [ ! -f "${T20}" ];then
    #            #echo "    T2 ${T20} not found"
    #            :
    #        else
    #            T2f=${T20}
    #            #echo "    T2 ${T2f}"
    #            echo 'rm -rf ${sf0}/T2w' >> ${F0[0]}
    #        fi
    #        for((j=7;j<=23;j+=2));do
    #            if((bold[j]==1));then
    #                str0=${line[j]##*/}
    #                str0=${str0%.nii*}
    #                echo 'rm -rf ${sf0}/'${str0} >> ${F0[0]}
    #            fi
    #        done
    #    fi 
    #fi


    #echo "${F0[0]} > ${F0[0]}.txt 2>&1 &" >> ${F1}
    #for((j=0;j<${#F0[@]};++j));do
    #    chmod +x ${F0[j]}
    #    echo "    Output written to ${F0[j]}"
    #done
    #chmod +x ${F1}
    #echo "    Output written to ${F1}"
    #START230502
    if [ -f "${F0[0]}" ];then

        #echo "${F0[0]} > ${F0[0]}.txt 2>&1 &" >> ${F1}
        #START230623
        echo "out=${F0[0]}.txt" >> ${F1}
        echo 'if [ -f "${out}" ];then' >> ${F1}
        echo '    echo -e "\n\n**********************************************************************" >> ${out}' >> ${F1}
        echo '    echo "    Reinstantiation $(date)" >> ${out}' >> ${F1}
        echo '    echo -e "**********************************************************************\n\n" >> ${out}' >> ${F1}
        echo "fi" >> ${F1}
        echo ${F0[0]}' >> ${out} 2>&1 &' >> ${F1}



        for((j=0;j<${#F0[@]};++j));do
            chmod +x ${F0[j]}
            echo "    Output written to ${F0[j]}"
        done
        chmod +x ${F1}
        echo "    Output written to ${F1}"
    else
        rm -f ${F1}
    fi


    if [ -n "${bs}" ];then
        echo "cd ${dir0}" >> $bs

        #echo -e "${F0[0]} > ${F0[0]}.txt 2>&1 &\n" >> $bs
        #START230625
        echo -e "${bs0} > ${bs0}.txt 2>&1\n" >> $bs
        echo -e "${F0[0]} > ${F0[0]}.txt 2>&1\n" >> $bs0
        echo "${bs0} > ${bs0}.txt 2>&1 &" >> ${bs1}
        #chmod +x ${bs0}
        #chmod +x ${bs1}
        #START230712
        chmod +x ${bs0} ${bs1}
        echo "    Output written to ${bs0}"
        echo "    Output written to ${bs1}"

    fi 
    if((lcautorun==1 && lcmakeregdironly==0));then
        cd ${dir0}

        #${F0[0]} > ${F0[0]}.txt 2>&1 &
        #START230409
        ${F1}
        echo "    ${F1} has been executed"

        #cd ${wd0} #"cd -" echoes the path
        #START230712
        cd $(pwd) #"cd -" echoes the path

        #START230409
        #echo "    ${F0[0]} has been executed"
    fi
done
if [ -n "${bs}" ];then

    #chmod +x $bs
    #echo "Output written to $bs"
    #START230712
    [[ $bs != *"/"* ]] && bs=$(pwd)/${bs}
    bs2=${bs%.*}_fileout.sh
    echo -e "$shebang\n" > $bs2
    echo "${bs} > ${bs}.txt 2>&1 &" >> ${bs2}
    chmod +x $bs $bs2
    echo "Output written to $bs"
    echo "Output written to $bs2"

fi
