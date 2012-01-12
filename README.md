# Sakura

Sakura stands for Swiss Army Knife Uncanny Repository and Awesome :)

 <img src='https://github.com/palladius/sakura/raw/master/images/sakura.jpg' height='200' align='right' />
 
It's a very nice way to color your life, I guess. It also provides a lot of tools, aliases, .. that power 
your shell experience. If you're not a shell guy, you shouldn't be using it. If you are, you can have your
shell PS1 to be changed to have the Italian flag, or Irish, or Argentinian, for instance. :)

## Synopsis

This is my famous SVN which is becoming opensource!

## Install

Go to the directory where you want to 'install' this software. Then download the repo:

	git clone git@github.com/palladius/sakura.git
	cat sakura/templates/bashrc.inject >> ~.bashrc

Note. Any help is appreciated to make this changeable!

## License

Everything in this repo is under the Creative Commons license, except where otherwise stated.

## Usage

 <img src='https://github.com/palladius/sakura/raw/master/images/color-sample.png' height='100' align='right' />
See `doc/sakura-samples.txt` for some usage. 
For instant gratification try the following:

    ls | act                                         # randomly scrambles the lines! Taken from cat/cat ;)
    ps | rainbow                                     # colors all lines differently
    twice itunes -                                   # lowers volume of iTunes... twice :)
    10 echo Bart Simpson likes it DRY                # tells you this 10 times. Very sarcastic script!
    seq 100 | 1suN 7                                 # prints every 7th element of the list
    zombies                                          # prints processes that show zombies (plus funny options to kill them)
    find . -size +300M | xargs mvto /tmp/bigfiles/   # moves big files to that directory
    alias gp='never_as_root git pull'                # only if u r not root it runs!
    dimmiora                                         # Tells you the time with Riccardo voice in Italian. Brilliant!

### BUGS

- None (yet!)

## Credits

Many people contributed to it. Today for the first time Im contributing back!

 <img src='http://www.palladius.it/palladius.jpg' height='100' align='right' />

- Riccardo Carlesso <riccardo.carlesso@gmail.com>

Thanks for who believed in me:

- Enrico "Vector field" Biondini
- Chris "Awesome" Glass (Notice Awesome.m4a sound, under Creative Commons)
- Lucilla "Mum" Gennari
