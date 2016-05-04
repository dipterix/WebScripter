import subprocess
import re

SPIDER_DIR = '/home/nitrous/code/WebScripter/scripter/spider/'
#from notifier import pushover
def spider_eia_report():
  global SPIDER_DIR
  cmd = 'R CMD BATCH '+ SPIDER_DIR +'eia_petroleum_report.R '+SPIDER_DIR+'tmp/eia_petroleum_report.Rout'
  result = subprocess.check_output(cmd, shell=True)

  send_report = False

  s = []
  with open(SPIDER_DIR + 'tmp/PETROLEUM', 'r') as f:
    s = [x for x in f]
    t = re.findall('TRUE', s[1])
    if(len(t) > 0):
      send_report = True
    s[1] = '"can_release","FALSE"'

  f = open(SPIDER_DIR + 'tmp/PETROLEUM', 'w')
  for ws in s:
    f.write(ws+'\n')
  f.close()

  snapshot = None
  if send_report:
    with open(SPIDER_DIR + 'tmp/PETROLEUM.snapshot', 'r') as f:
      snapshot = ''.join([x for x in f])
      snapshot = snapshot.strip()[1:-1].strip()
  return(snapshot)
