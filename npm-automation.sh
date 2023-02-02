#!/bin/bash
echo ''' 
    _   __                   ___         __      
   / | / /___  ____ ___     /   | __  __/ /_____ 
  /  |/ / __ \/ __ `__ \   / /| |/ / / / __/ __ \
 / /|  / /_/ / / / / / /  / ___ / /_/ / /_/ /_/ /
/_/ |_/ .___/_/ /_/ /_/  /_/  |_\__,_/\__/\____/ 
     /_/                                           v1.0.2
              twitter.com/@0xnirob        
warning: BE AWARE OF FALSE POSITIVE, CONFIRM YOUR FINDING MANUALLY.  Good Luck.
Use with caution. You are responsible for your actions.
Developers assume no liability and are not responsible for any misuse or damage.
'''

if [ -d $1 ];then
    echo '' >/dev/null 2>&1
else 
    mkdir $PWD/$1;
fi
echo -e "Running waybackurls on $1"
waybackurls $1 | sort -u | grep .js | sed 's/?.*//' | grep -v '/wp-content/\|/wp-includes/\|.json\|jpg\|png\|css|\|/member/\|.jsp\|oauth\|login\|en-us\|v=\|=\|?\|/help/\|/id/\|paragon\|/wp-json/' | sort -u | tee -a $PWD/$1/$1-js-urls.txt >/dev/null 2>&1;
echo -e "Running gau on $1"
#gau $1 | sort -u | grep .js | sed 's/?.*//' | grep -v '/wp-content/\|/wp-includes/\|.json\|jpg\|png\|css|\|/member/\|.jsp\|oauth\|login\|en-us\|v=\|=\|?\|/help/\|/id/\|paragon\|/wp-json/' | sort -u | tee -a $PWD/$1/$1-js-urls.txt >/dev/null 2>&1;

cd $PWD/$1;
echo -e "Found $(cat $1-js-urls.txt | sort -u |wc -l) js file url ";
cat $1-js-urls.txt | sort -u |while read ut;do
    wget $ut.map >/dev/null 2>&1;
    done

grep -oriahE "[^\"\\'> ]+" | grep 'node_modules' | grep -v '@' | sed 's:.*/node_modules::' | cut -d '/' -f 2 | sort -u | grep -v '.js\|.ts\|.tsx\|.css' | egrep '\b[a-z]+\b' | grep -v '.png\|.pnp' | tee -a $1-npm-packages.txt >/dev/null 2>&1;

rm $1-js-urls.txt;
if [ -s $1-npm-packages.txt ];then
    echo -e "   Found some packages now going for final test on "$1-npm-packages.txt"";
    cat $1-npm-packages.txt | sort -u | while read ut;do
        if $(curl -o /dev/null -s -w "%{http_code}\n" "https://registry.npmjs.org/$ut" | grep "404" >/dev/null 2>&1); then
            echo -e ""$ut" \e[1;31mFound Private npm packgae, \e[0m" && echo $ut >> $1-npm-vuln.txt;

        else
            echo -e ""$ut"\e[1;33m Available in Public Registry \e[0m";
        fi
        done
else
    echo -e "Didn't found any npm packages, now going for scope test "
fi
#this part is for scope package test please be carefull with that, some times `www.npmjs.com` will show you 429 response code
grep -oriahE "[^\"\\'> ]+" | grep 'node_modules' | sed 's:.*/node_modules::' | cut -d '/' -f 2 | sort -u | grep '@' | grep -v '.js\|.ts\|.tsx\|.css' | egrep '\b[a-z]+\b' | grep -v '.png\|.pnp' | grep '@' | cut -d '@' -f 2 | tee -a $1-npm-scope.txt >/dev/null 2>&1;

if [ -s $1-npm-scope.txt ];then
    echo -e "   Found some Scope names now going for final test on "$1-npm-scope.txt"";
    cat $1-npm-scope.txt | sort -u | while read pkg;do
    OPTION=`curl -o /dev/null -s -w "%{http_code}\n" "https://www.npmjs.com/org/$pkg"`
        if $(echo "$OPTION" | grep "200\|302" >/dev/null 2>&1);then
            echo -e "@"$pkg"\e[1;33m Available in Public Registry \e[0m" && echo $pkg >> $1-npm-scope-vuln.txt;
            grep -oriahE "[^\"\\'> ]+" | grep 'node_modules' |grep '@'$pkg'' | sed 's:.*/@'$pkg'::' | cut -d '/' -f 2 | sort -u | while read ut;do echo "Full pacakge name of @"$pkg" is @"$pkg"/"$ut" ";done
        elif $(echo "$OPTION" | grep "429" >/dev/null 2>&1);then
            echo -e "@"$pkg" \e[1;31m Rate limit detected \e[0m"

        else
            echo -e "@"$pkg"\e[1;31m Found Unclaimed scope Name\e[0m";
            grep -oriahE "[^\"\\'> ]+" | grep 'node_modules' |grep '@'$pkg'' | sed 's:.*/@'$pkg'::' | cut -d '/' -f 2 | sort -u | while read ut;do echo -e "\e[1;31mFull pacakge name of @"$pkg" is @"$pkg"/"$ut", this is unclaimed, Add @"$pkg"/"$ut" in your package.json file like {package: @"$pkg"/"$ut"}, \e[0m";done
        fi
        done
else
    echo -e "Didn't found any Scope name";
fi
rm $1-npm-scope.txt *.map.* *.map $1-npm-packages.txt;
