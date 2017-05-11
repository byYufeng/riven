# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
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
