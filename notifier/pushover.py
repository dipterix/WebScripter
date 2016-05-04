import http.client, urllib

def send_pushover(msg):
  conn = http.client.HTTPSConnection("api.pushover.net:443")
  conn.request("POST", "/1/messages.json",
    urllib.parse.urlencode({
      "token": "ar3GAiMJPfgPLt5geA92cPQwoBdGTf",
      "user": "uY4UVrP4eusnjdcgvxzksZ1goborkx",
      "message": msg,
    }), { "Content-type": "application/x-www-form-urlencoded" })
  conn.getresponse()
  conn.close()