#!/bin/bash
################################################################################
##                             CBRdownload                                    ##
## Description:                                                               ##
##     this script is used to down load record from China Bird Report Center  ##
##     (中国观鸟记录中心).                                                      ##
## Author:  Wolfson                                                           ##
## Date:    20140823                                                          ##
## Modify:  20160811                                                          ##
## Version: 0.1                                                               ##
## Comment:                                                                   ##
##     This program works just fine.                                          ##
##     But there were still some errors in the result files.                  ##
##     The check of result was needed.                                        ##
################################################################################

echo -e "Hi, there!\n\nI am designed to download records from China Bird Report Center (http://birdtalker.net/report/index.asp).\n\n Just enter the maximal and minimal numbers of records you want to download, I will help you download all the data.\n\n Good luck!\n\n"

read -p "Please enter the minimal record ID you want:" MINID

read -p "Please enter the maximal record ID you want:" MAXID

# make directory if not exist
[ -d "./html/" ] && mkdir ./html/

ID=$MINID
# echo $MAXID $MINID $ID


while [ $ID -le $MAXID ]; do
    HTMLFILE=$(echo "./html/"$ID".html")
    HTML=$(echo "./html/GBK"$ID".html")
    wget -c --random-wait \
         --post-data="agreeview=true&Submit1=进入" \
         birdtalker.net/report/reportview.asp?id=$ID -O $HTML
    # convert code -c means omit illigle code like "鸊鷉" cannot be shown by GBK
    iconv -c -f GBK -t UTF-8 $HTML -o $HTMLFILE
    # test file end
    TEND=$(grep "</HTML>" $HTMLFILE | wc -l)
    Tendx=$(grep "</html>" $HTMLFILE | wc -l)
    if [[ $TEND -ne 1 && $Tendx -ne 1 ]]; then
        echo $ID ",no end." >> error.txt &&\
            rm $HTMLFILE $HTML && ID=$(($ID+1)) && \
            continue
    fi
    ####---- get the record metadata
    ## get record id
    RECORDID=$(grep "号观测记录" $HTMLFILE |\
                   sed 's/^.*记录中心·第//' |\
                   sed 's/号观测记录.*$//')
    if [[ $RECORDID -ne $ID ]];then
        echo -e "\aID NOT EQUAL"":"" ID="$ID" RECORDID="$RECORDID &&\
            rm $HTMLFILE $HTML &&\
            ID=$(($ID+1)) &&\
            continue
    fi
    ## get locate id
    LOCATEID=$(grep "locateinfo.asp?id=" $HTMLFILE |\
                   sed 's/[[:punct:]]>.*$//' |\
                   sed 's/^.*id=//')
    ## get locate
    LOCATE=$(grep "locateinfo.asp?id=" $HTMLFILE |\
                 sed 's/<[[:punct:]][[:alpha:]]>.*$//' |\
                 sed 's/^.*[[:digit:]][[:punct:]]>//' )
    ## get the first date
    FDATE=$(grep "共[[:digit:]]*天" $HTMLFILE |\
                sed 's/[[:blank:]]至.*$//' |\
                sed 's/^.*<[[:alpha:]][[:alpha:]]>//')
    ## get the last date
    LDATE=$(grep "共[[:digit:]]*天" $HTMLFILE |\
                sed 's/[[:blank:]]共.*$//' |\
                sed 's/^.*至[[:blank:]]//')
    ## get user id
    USERID=$(grep "userinfo.asp?id=" $HTMLFILE |\
                 head -n 1 |\
                 sed 's/[[:punct:]]>.*$//' |\
                 sed 's/^.*id=//')
    ## get user name
    USER=$(grep "userinfo.asp?id=" $HTMLFILE |\
               head -n 1 |\
               sed 's/<[[:punct:]][[:alpha:]]>.*$//' |\
               sed 's/^.*[[:digit:]].>//')
    ## get species amount
    SPECIES=$(grep "共[[:digit:]]*种 (包含[[:digit:]]*" $HTMLFILE |\
                  sed 's/种.*$//' |\
                  sed 's/^.*共//')
    ## write the information into file
    echo -e $RECORDID","$LOCATEID","$LOCATE","$FDATE","$LDATE","$USERID","$USER","$SPECIES >> recordhead.txt

    ####---- get the bird list
    ## get the bird number in the record
    SNUMBER=$(grep '×[[:digit:]]*[[:blank:]]' $HTMLFILE | wc -l)
    N=1
    while  [ $N -le $SNUMBER ]; do
        ## get the bird code
        BCODE[$N]=$(grep 'birdinfo.asp?id=' $HTMLFILE |\
                        head -n $N |\
                        tail -n 1 |\
                        sed 's/^.*birdinfo.asp?id=//' |\
                        sed 's/[[:punct:]]>.*$//')
        ## get the species amounts
        BNUM[$N]=$(grep '×[[:digit:]]*[[:blank:]]' $HTMLFILE |\
                       head -n $N |\
                       tail -n 1 |\
                       sed 's/^.*×//' |\
                       sed 's/[[:blank:][:alpha:]].*$//')
        ## write the bird records into file
        echo -e $RECORDID","${BCODE[$N]}","${BNUM[$N]} >> birdlist.txt
        N=$(($N+1))
    done
    ID=$(($ID+1))
done

echo -e "\n\nInformation collecting is finished. \n\nPlease check the results.\n\nBirdrecords are in birdlist.txt.\n\nRecords metadata is in recordhead.txt\n"

exit 0

################################################################################
##                                 EOF                                        ##
################################################################################

