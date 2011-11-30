# Sakura

Sakura stands for Swiss Army Knife Uncanny Repository and Awesome :)

 <img src='https://github.com/palladius/sakura/raw/master/images/sakura.jpg' height='200' align='right' />

## Synopsis

This is my famous SVN which is becoming opensource!

## Install

Download the repo:

	mkdir -p ~/git
	cd ~/git
	git clone git@github.com/palladius/sakura.git

Then add this line to your `~/.bashrc` to get it sourced:

	# Add me to ~/.bashrc
	export SAKURADIR=~/git/sakura/
	if [ -f "$SAKURADIR/.bashrc" ]; then
	  . "$SAKURADIR/.bashrc"
	fi 

Note. Any help is appreciated to make this changeable!


## Usage

 <img src='https://github.com/palladius/sakura/raw/master/images/color-sample.png' height='100' align='right' />
See `doc/sakura-samples.txt` for some usage. 
For instant gratification try the following:

	ls | act # randomly
	ps | rainbow 

### BUGS

- None (yet!)
    
### TODO 

- make it to work in whichever dir it is (atm it requires it to be in ~/git/sakura/

## Credits

Many people contributed to it. Today for the first time Im contributing back!

 <img src='http://www.palladius.it/palladius.jpg' height='100' />

- Riccardo Carlesso <riccardo.carlesso@gmail.com>
