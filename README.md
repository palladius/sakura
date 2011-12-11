# Sakura

Sakura stands for Swiss Army Knife Uncanny Repository and Awesome :)

 <img src='https://github.com/palladius/sakura/raw/master/images/sakura.jpg' height='200' align='right' />
 
It's a very nice way to color your life, I guess. It also provides a lot of tools, aliases, .. that power 
your shell experience. If you're not a shell guy, you shouldn't be using it. If you are, you can have your
shell PS1 to be changed to have the Italian flag, or Irish, or Argentinian, for instance. :)

## Synopsis

This is my famous SVN which is becoming opensource!

## Install

Download the repo:

	mkdir -p ~/git
	cd ~/git
	git clone git@github.com/palladius/sakura.git

Then add this lines to your `~/bashrc` to get it sourced:

	take it from ~bashrc.inject~

Note. Any help is appreciated to make this changeable!


## Usage

 <img src='https://github.com/palladius/sakura/raw/master/images/color-sample.png' height='100' align='right' />
See `doc/sakura-samples.txt` for some usage. 
For instant gratification try the following:

	ls | act                          # randomly scrambles the lines! Taken from cat/cat ;)
	ps | rainbow                      # colors all lines differently
	twice itunes -                    # lowers volume of iTunes... twice :)
	10 echo Bart Simpson likes it DRY # tells you this 10 times. Very sarcastic script!
	seq 100 | 1suN 7                  # prints every 7th element of the list

### BUGS

- None (yet!)
    
### TODO 

- make it to work in whichever dir it is (atm it requires it to be in ~/git/sakura/

## Credits

Many people contributed to it. Today for the first time Im contributing back!

 <img src='http://www.palladius.it/palladius.jpg' height='100' align='right' />

- Riccardo Carlesso <riccardo.carlesso@gmail.com>
