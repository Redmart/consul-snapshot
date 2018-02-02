#!/bin/bash

## usage 
##  trigger_prod_release.sh < major | minor | patch >

RED="\033[31m"
GREEN="\033[32m"
PURPLE="\033[35m"
CYAN="\033[36m"
CLOSE="\033[m"

rel_type=$1
deploy_env=$2
if [ "$deploy_env" != "ms" ] ;then    
    deploy_env="sg"
fi    

curr_branch=`git rev-parse --abbrev-ref HEAD`

function usage(){
	echo -e "$GREEN [USAGE]: trigger_prod_release.sh <major | minor | patch>  <sg> $CLOSE"
	echo ""
	echo -e "$CYAN [EXAMPLE To Trigger Major Release in 'sg' prod environment ]: ./trigger_prod_release.sh major sg $CLOSE"
	echo -e "$CYAN [EXAMPLE To Trigger Minor Release in 'sg' prod environment ]: ./trigger_prod_release.sh minor sg $CLOSE"
	echo -e "$CYAN [EXAMPLE To Trigger Patch Release in 'sg' prod environment ]: ./trigger_prod_release.sh patch sg $CLOSE"
	echo ""
	exit 1;
}

function read_release_msg(){
        echo -e "$PURPLE[Add a short release summary, and then press <enter> key]: $CLOSE"
        echo ""
        read release_notes
        echo ""
        if [ "$release_notes" == "" ] ;then
                echo ""
                echo -e "$RED [ERROR] Oops... Sorry you have not added the release summary !!! $CLOSE"
                echo -e "$CYAN [Hint] Adding a release summary helps your team and others to know about this release. $CLOSE"
                echo -e "$CYAN [Hint] Please re-run script and add release summary!!. $CLOSE"
                echo ""
                exit 1;
	else
		release_notes=`echo "$release_notes" | sed "s/['\"]//g"`
        fi
}

#### Execution starts from here ########

## Check when required parameter is missing
if [ $# -lt 1 ] ;then
	echo ""
        echo -e "$RED Oops... Sorry you have not passed the release triggers !!! $CLOSE"
        echo ""
	usage
fi

## Check if current branch is master or not
if [ "$curr_branch" != "master" ] ;then
	echo ""
    echo -e "$RED [ERROR] Oops... Sorry your current branch is [ $curr_branch ] not master !!! $CLOSE"
    echo ""
    echo -e "$CYAN [INFO] Please switch branch to master, do git pull and trigger this script again for prod release. $CLOSE"
    echo ""
    exit 1;
fi

## Check when required parameter is passed
if [ $# -le 2 ] ;then
        if [ "$rel_type" == "major" ] || [ "$rel_type" == "minor" ] || [ "$rel_type" == "patch" ] ;then
                echo "Triggering ${rel_type} Release ..."
                echo ""
                read_release_msg
                if [ "$release_notes" != "" ] ;then
                        commit_msg=$"Releasing #${rel_type} version. Deploy environment is: #${deploy_env} production


[Release Summary]: $release_notes"
                else
                        commit_msg=$"Releasing #${rel_type} version. Deploy environment is: #${deploy_env} production"
                fi
                main_commit_msg=`echo "$commit_msg" | head -n 1`
                release_summary=`echo "$commit_msg" | grep -A100 '\[Release Summary\]'`
                echo ""
                echo -e "main_commit_msg = $main_commit_msg"
                echo -e "release_summary = $release_summary"
		echo ""
                #echo -e "git commit --allow-empty -m '$commit_msg'"
                git commit --allow-empty -m "$commit_msg"
                git push origin master
                echo ""
                echo "Release build is triggered. Please get the status from the travis-CI console."
                echo ""

        else
                echo -e "$RED Sorry trigger parameters not matched. Please check usage !!! $CLOSE"
                usage
        fi
else
        echo -e "$RED Sorry trigger parameters count not correct. Please check usage !!! $CLOSE"
        usage
fi
