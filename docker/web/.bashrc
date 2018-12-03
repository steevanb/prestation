function echo_git_branch {
    if [[ $1 != "" ]] ; then
        if [ "$1" == "develop" ]; then
            color="44";
        elif [ "$1" == "master" ]; then
            color="41";
        else
            color="33";
        fi
        echo -en "[\033[${color}m$1\033[00m]";
     fi
}
function parse_git_branch {
    branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/' -e 's/(//g' -e 's/)//g')
    if [[ $branch != "" ]] ; then
        branchColored=$(echo_git_branch "$branch")
        echo -en "\033[33m$(git config core.description)\033[00m $branchColored";
    fi
}
PS1='\n\e[45m\u@prestation-web\e[m [\033[32m\w\033[00m] $(parse_git_branch) \n\$ '

alias prestation-php-errors="tail -f /var/log/nginx/prestation_error.log"

cd /var/www/prestation
