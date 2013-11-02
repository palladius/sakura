#!/usr/bin/python


"""Guarantees that a command is executed. To do so,
it writes on a Google Spreadsheet (id is on .guarantee.yml,
otherwise defaults to mine). Command is executed and ret is written
in the spreadheet. Some kind of daemon will say "these commands havent been executed right,
do you want me to execute them with some kind of lock?"

I know, I'm some kind of genius.
"""
