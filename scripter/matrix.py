from urllib.request import urlopen

URL_PETROLEUM = 'https://www.eia.gov/petroleum/supply/weekly/'

conn = urlopen('https://www.eia.gov/petroleum/supply/weekly/pdf/highlights.pdf')

s = conn.readall()
