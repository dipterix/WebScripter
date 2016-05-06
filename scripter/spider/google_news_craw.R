require(stringr)
# PETROLEUM report scripting
print(getwd())
if(str_sub(getwd(), end=1) == '/'){
  setwd('/home/nitrous/code/WebScripter/scripter/spider')
  source('./lib/import_pkg.R', chdir = T)
  source('./lib/parser.R', chdir = T)
} else{
  setwd('C:/Users/Zhengjia/Desktop/code/code/WebScripter/scripter/spider')
  source('./lib/import_pkg.R', chdir = T)
  source('./lib/parser.R', chdir = T)
}


# global vars
spider_NAME = 'GOOGLE_NEWS'
REF_DIR = str_c(TEMP_DIR, './', spider_NAME)
SNAPSHOT_DIR = str_c(TEMP_DIR, './', spider_NAME, '.snapshot')
DEBUG = T
# subset urls
spider_TASKS = urls[urls$spider == spider_NAME, ]

# get old records
REF_LIST <- suppressWarnings(tryCatch(read.csv(REF_DIR, header=T, stringsAsFactors = F), error = function(e){data.frame(
  Title = character(0),
  News_Source = character(0),
  Intro = character(0),
  URL = character(0),
  snapshot = character(0),
  key = character(0),
  Timestamp = character(0),
  Topic = character(0),
  stringsAsFactors = F
)}))
snapshot = ''
timestamp = REF_LIST$Timestamp
if(length(timestamp) > 0){
  timestamp = strptime(timestamp, format = "%Y-%m-%d %H:%M:%S", tz = DEFAULT_TZ)
  last_hour = strptime(system_time(), format = "%Y-%m-%d %H:%M:%S", tz = DEFAULT_TZ) - 60 * 60
  REF_LIST = REF_LIST[timestamp > last_hour, ]
}

news = NULL
# parse
for(i in 1:nrow(spider_TASKS)){
  row = spider_TASKS[i,]
  html = getURL(row$url)
  re = parse_data(html, 'google_news')
  if(re$valid){
    dat = re$data
    dat$Topic = row$name
    dat = dat[!(dat$key %in% REF_LIST$key), ]
    REF_LIST = rbind(REF_LIST, dat)
    news = rbind(news, dat)
  }
}


# generate snapshot
if(!is.null(news) && nrow(news) > 0){
  # TODO filter news
  
  # gen snapshots
  news = ddply(news, "Topic", summarise, snapshot = str_c(snapshot, collapse = '\n'))
  snapshot = str_c('<font color="blue">',news$Topic, '</font>',
                   str_replace_all(news$snapshot, '<br>', "\n"),collapse = '\n\n')
}

# save REF_LIST and generate snapshot
write.csv(REF_LIST, REF_DIR, row.names = F)
write(snapshot, SNAPSHOT_DIR)
