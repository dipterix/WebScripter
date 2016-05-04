# Download the Python helper library from twilio.com/docs/python/install
from twilio.rest import TwilioRestClient

# Your Account Sid and Auth Token from twilio.com/user/account
account_sid = "ACb517df00323bf9cd8a524a8d344f6206"
auth_token  = "222639899b5a99614ed4446930fe341d"
client = TwilioRestClient(account_sid, auth_token)

notification = client.notifications.get('NO43c9cd86bdf764c9e94eda860123e42b')

message = client.messages.create(to="+17134165969", from_="+18327693651",
                                     body="TEST MSG Sending Module to 713-416-5969 and 217-979-9486: \n"+snapshot)