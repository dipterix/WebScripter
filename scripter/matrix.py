import threading
import time
from scripter import worker
from notifier import pushover
from django.conf import settings

DEBUG = False
# tmp params for quick setup
settings.SPIDER_REFRESH_INTV = 300  # 300s = 5 min
settings.SPIDER_WORKING = True

if DEBUG:
  settings.SPIDER_REFRESH_INTV = 10

# a local wrap for push system
def notify(msg, *args, **kwargs):
  pushover.send_pushover(msg)

  # define worker for EIA report, refresh every INTV
def EIA_report_Worker():
  err_count_left = 10
  while settings.SPIDER_WORKING:
    try:
      snapshot = worker.spider_eia_report()
      if snapshot:
        if DEBUG:
          print(snapshot)
        else:
          # send notification
          notify(snapshot)
      else:
        print('EIA Report Not Updated')
    except Exception as e:
      print("EIA REPORT ERROR")
      print(e)
      err_count_left -= 1
      if err_count_left == 0:
        break
    time.sleep(settings.SPIDER_REFRESH_INTV)


def start_working():
  t = threading.Timer(0, EIA_report_Worker)
  t.start()