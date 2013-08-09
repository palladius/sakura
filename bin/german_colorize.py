#!/usr/bin/python
# -*- coding: utf-8 -*-

import os, sys, re

ver = '0.1'
context = 'html' # 'txt'

PREPOSITIONS = '(wie|wo|welche|welcher|woher|wer|welches|bei)'
#RPREPOSITIONS = r'(wie|Wie|wo|welche|welcher|woher|wer|welches)'
PREPOSITIONEN = re.compile(PREPOSITIONS, re.IGNORECASE)

def html_color(col,str,description):
  #return "<font color='{}' description='{}'>{}</font>".format(col,description,str)
  return "<font color='{}'>{}</font>".format(col,str)
def bash_color(col,str,description):
  return "\033[1;31m{}\033[0m".format(col,str)
def color(col,str,description='none'):
  return html_color(col,str,description)

def preposition_token(str):
  return color('green',str)
def subject_token(str):
  return color('yellow',str)
def verb_token(str):
  return color('purple',str)

def gender(gen,s):
  if gen == 'n': # or neutral
    return color('gray',s)
  elif gen == 'm':
    return color('blue',s)
  elif gen == 'f':
    return color('pink',s)
  else:
    raise NameError("Gender unknown: '{}'".format(gen))

def process(l):
  m = re.match(r"(?P<first_name>\w+) (?P<last_name>\w+)", l)
  if context == 'html':
    l = re.sub(r'\n', r'<br/>\n', l)
  # umlauts
  l = re.sub(r'(ae)', 'ä', l)
  l = re.sub(r'(oe)', 'ö', l)
  l = re.sub(r'(ue)', 'ü', l)
  l = re.sub(r'([Dd]as) (\w+)', gender('n', r'\1 \2'), l)
  l = re.sub(r'([Dd]er) (\w+)', gender('m', r'\1 \2'), l)
  l = re.sub(r'([Dd]ie) (\w+)', gender('f', r'\1 \2'), l)
  l = re.sub(r"''", color('red',"''"), l)                 # Error for a'' instead of a<umlaut>
  l = re.sub(PREPOSITIONEN, preposition_token(r'\1'), l)
  #l = re.sub(RPREPOSITIONS, preposition_token(r'\1'), l)
  #l = re.sub(r'([Ii]st)', verb_token('ist'), l)
  return l

def read_german_file(filename):
    '''recursively descend the directory tree rooted at top,
       calling the callback function for each regular file
    '''
    ret = ''
    if context == 'html':
      ret += "<html><body><h1>Text from file {}</h1>\n".format(filename)

    print "OK - while read(line) do process_line"
    with open(filename) as f:
      for line in f:
        #line = line.rstrip()
        ret += process(line)
    return ret

if __name__ == '__main__':
  print "deb ARGV: ", sys.argv
  if len(sys.argv) > 1:
    print read_german_file(sys.argv[1])
  else:
    print '''Usage: {} <GERMAN_FILE>'''.format(sys.argv[0])
