from argparse import ArgumentParser
import difflib
import re
import os

parser = ArgumentParser()
parser.add_argument('--from', dest='original')
parser.add_argument('--to', dest='destination')

args = parser.parse_args()

def unified_diff(to_file_path, from_file_path, context=1):
  pat_diff = re.compile(r'@@ (.[0-9]+\,[0-9]+) (.[0-9]+,[0-9]+) @@')

  from_lines = []
  if os.path.exists(from_file_path):
    from_fh = open(from_file_path, 'r', encoding='utf-8', errors='ignore')
    from_lines = from_fh.readlines()
    from_fh.close()

  to_lines = []
  if os.path.exists(to_file_path):
    to_fh = open(to_file_path, 'r', encoding='utf-8', errors='ignore')
    to_lines = to_fh.readlines()
    to_fh.close()

  diff_lines = []

  lines = difflib.unified_diff(to_lines, from_lines, n=context)
  for line in lines:
    if line.startswith('--') or line.startswith('++'):
      continue

    m = pat_diff.match(line)
    if m:
      left = m.group(1)
      right = m.group(2)
      lstart = left.split(',')[0][1:]
      rstart = right.split(',')[0][1:]
      diff_lines.append("@@ %s %s @@\n"%(left, right))
      to_lnum = int(lstart)
      from_lnum = int(rstart)
      continue

    code = line[0]

    lnum = from_lnum
    if code == '-':
      lnum = to_lnum
    diff_lines.append("%s%.4d: %s"%(code, lnum, line[1:]))

    if code == '-':
      to_lnum += 1
    elif code == '+':
      from_lnum += 1
    else:
      to_lnum += 1
      from_lnum += 1

  return diff_lines

diff = unified_diff(args.original, args.destination)
if len(diff) != 0:
  print(''.join(diff))
else:
  print('There is no difference between the expected output and the output.')
