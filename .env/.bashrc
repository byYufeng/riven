# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
#alias riven_commit='cd ~/riven && bin/commit_git.sh $1 && cd -'
riven_commit(){
    cd ~/riven && ./bin/commit_git.sh $1
    cd -
}

#disable generate .pyc
export PYTHONDONTWRITEBYTECODE=x

#replace rm of mv
alias rm='trash'
trash()
{
    # I quote this path last time and suffers a lot...
    #if [ ! -d ~/.trash ]; then
    #    mkdir ~/.trash
    #fi 
    mkdir -p ~/.trash/`date +%Y%m%dT%H%M%S`
    mv $@ ~/.trash/`date +%Y%m%dT%H%M%S`
}

#download and upload files like scp
#but...The folder name always strange when use dl
dl(){
        cmd="ssh $1 tar cz $2 | tar xzv"
        echo $cmd
        $cmd
}

ul(){
        cmd="tar cz $2 | ssh $1 tar xzv"
        echo $cmd
        $cmd
}

#avoid to enter ssh phrase each time
ssh-agent_login(){
        eval `ssh-agent`
        ssh-add ~/code/documents/key/id_rsa.r81.hdp
}

alias ll='ls -lh --color=auto'
alias free='free -h'

alias im="python ~/mojo_im.py "
alias qq="python ~/mojo_im.py qq"
alias wx="python ~/mojo_im.py wx"
alias ttt="python ~/mojo_im.py qq printt | tail -7 | head -5"
alias tt="python ~/mojo_im.py qq send uid 1873181129 "