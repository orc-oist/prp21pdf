#!/bin/bash

#run the script inside the local github repository folder*
cd ~/Desktop/prp21pdf

#collect the html pages
wget -N --recursive -l1 --no-parent -I policy-library/ --adjust-extension html  https://www.oist.jp/policy-library

#cding into the html folder
cd www.oist.jp/policy-library/

#regexp collecting all links pointing to the pdfs and storing them as list in pdflist_new.txt
grep -Phor '(?<=href=")[^"]*' *.html | grep pdf | grep -i 'public/ch'| sort > pdfslist_new.txt

# remove old pdfs from the list
rm $(<pdfsnamefilelist.txt)

# collect the pdf files
wget -N -i pdfslist_new.txt

# preprocessing list of pdf files before pdfunite
# replace blank spaces in the filenames by big dash 
for f in *\ *; do mv "$f" "${f// /_}"; done

# sorted list of files to file list
ls -lht | grep -oE '([Cc][Hh].+\.pdf)' | sort  > pdfsnamefilelist.txt

# adding cover and version number
date_time=$(date "+%Y-%m-%d %H:%M:%S")
convert cover.png -pointsize 30 -fill white -annotate +150+400 "version: $date_time" cover.pdf

#prepending the cover in the pdf files list
echo -en "cover.pdf\n$(cat pdfsnamefilelist.txt)"  > pdfsnamefilelist.txt

# merging sorted pdfs
pdfunite $(cat pdfsnamefilelist.txt) fullprp.pdf

# convirtiendo todo el fullprp.pdf en fullprp.txt
pdftotext fullprp.pdf

# take snapshot apart if wednesday
cd ~/Desktop/prp21pdf


DAYOFWEEK=$(date +"%u")

if [ "${DAYOFWEEK}" -eq 3 ];  
	then   cp -r www.oist.jp $(date +%F-%T)_www.oist.jp;
fi


#commint to github. ssh keys were generated before for unnatended commit.
#however, a cron job need these commands before pushing
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/orc-oist-github
#git stuff
git add --all
git commit -m "scheduled (cron) commit at 3am"
git push origin master
