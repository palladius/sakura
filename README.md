# Sakura

[![Build Status](https://secure.travis-ci.org/palladius/sakura.png)](http://travis-ci.org/palladius/sakura)

Sakura stands for Swiss Army Knife Uncanny Repository and Awesome :)

 <img src='https://github.com/palladius/sakura/raw/master/images/sakura.jpg' height='200' align='right' />
 
It's a very nice way to color your life, I guess. It also provides a lot of tools, aliases, .. that power 
your shell experience. If you're not a shell guy, you shouldn't be using it. If you are, you can have your
shell PS1 to be changed to have the Italian flag, or Irish, or Argentinian, for instance. :)

## Synopsis

This is my famous SVN which is becoming opensource!

## Install

Go to the directory where you want to 'install' this software. Then download the repo:

	git clone git://github.com/palladius/sakura.git
	cat sakura/templates/bashrc.inject >> ~/.bashrc

Note. Any help is appreciated to make this changeable!

## License

Everything in this repo is under the Creative Commons license, except where stated otherwise.

## Usage

 <img src='https://github.com/palladius/sakura/raw/master/images/color-sample.png' height='100' align='right' />
See `doc/sakura-samples.txt` for some usage. 
For instant gratification try the following:

    richelp ubuntu                                   # shows a richelp of my 'ubuntu' cheatsheet
    richelp sakura synopsis                          # shows a richelp of my 'sakura' cheatsheet, grepping for 'synopsis'
    ls | act                                         # randomly scrambles the lines! Taken from cat/cat ;)
    ps | rainbow                                     # colors all lines differently
    twice itunes -                                   # lowers volume of iTunes... twice :)
    10 echo Bart Simpson likes it DRY                # tells you this 10 times. Very sarcastic script!
    ...
    # See `docz/CHEATSHEET` for more!

## Credits

Many people contributed to it. First place goes obviously to my mum (see below).

 <img src='http://www.palladius.it/palladius.jpg' height='100' align='right' />

- Riccardo Carlesso <riccardo.carlesso@gmail.com>

For any comments, please subscribe to this User Group: <sakura-users@googlegroups.com>

- <https://groups.google.com/forum/#!forum/sakura-users>

Borrowed code:

- Dmitry V Golovashkin <Dmitry.Golovashkin@sas.com>: `timeout3`
- William Stearns <wstearns@pobox.com>: `fanout`, GPL
- Synergy FOSS <http://synergy-foss.org/support>
- Google: `upload.py` (Apache license)
- Micha Niskin <micha@thinkminimo.com>: `jsawk`
- A. Iurlano <http://github.com/aiurlano>: `gcutil-fetch`, `gsutil-fetch`
- Ian Bicking <http://blog.ianbicking.org/>: virtualenv

Thanks for who believed in me:

- Enrico "Vector field" Biondini
- Chris <a href='https://github.com/palladius/sakura/raw/master/sounds/awesome.m4a'>"awesome"</a> Glass (Notice `Awesome.m4a` sound, under Creative Commons)
- Lucilla "Mum" Gennari for love and support
- Jeffrey Silverman, my wise colleague for wise suggestions
