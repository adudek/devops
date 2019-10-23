#!/usr/bin/env python3
import sys
import json
import functools
import operator
import random

numlist = list()


def subtract(numlist):
  """Substract single element from list by value"""
  print("Insert element to substract from list")
  try:
    num = int(sys.stdin.readline().strip())
    numlist.remove(num)
  except ValueError:
    pass
  return "List: " + ",".join([str(i) for i in numlist])


def multiply(numlist):
  """Multiply list elements and save results to file in json format"""
  x = functools.reduce(operator.mul, numlist, 1)
  numdict = {
    'InputNumber%d' % (i+1): numlist[i]
    for i in range(0, len(numlist))
    }
  numdict.update({'Multiplication': x})
  with open('Result.json', 'w') as resultfile:
    resultfile.write(json.dumps(numdict))
  return "Result.json file generated sucessfully!"


def menuitem(select):
  functions = {
    's': subtract,
    'm': multiply,
    'r': lambda numlist: numlist[random.randint(0, len(numlist)-1)],
    'd': lambda numlist: sorted(numlist, reverse=True),
    'a': lambda numlist: sorted(numlist)
  }
  return functions.get(
    select, lambda numlist: """
    Select function
    =======================================
    Perform (s)ubtraction and show output on screen comma separated
    Perform (m)ultiplication and store result in a Result.json file
    Pick (r)andomly a number and show it on screen
    Print sorted in (d)escending order list numbers
    Print sorted in (a)scending order list numbers
    """
  )


assert len(sys.argv) == 7, Exception('''Error: Bad number of arguments!
  Program exepects 6 positional arguments!''')
try:
  for item in sys.argv[1:]:
    numlist.insert(len(numlist), int(item))
except ValueError:
  sys.exit("Error: Arguments need to be integers!")

funct = menuitem('help')
while True:
  print(funct(numlist[:]))
  funct = menuitem(sys.stdin.readline().rstrip())
  pass
