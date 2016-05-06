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
spider_NAME = 'PETROLEUM'
REF_DIR = str_c(TEMP_DIR, './', spider_NAME)
SNAPSHOT_DIR = str_c(TEMP_DIR, './', spider_NAME, '.snapshot')
DEBUG = F
# subset urls
spider_TASKS = urls[urls$spider == spider_NAME, ]

# import refresh list

REF_LIST <- suppressWarnings(tryCatch(read.csv(REF_DIR, header=T, stringsAsFactors = F), error = function(e){data.frame(name = c('can_release',spider_TASKS$name), last_refreshed = '2000-01-01 00:00:01 EDT', stringsAsFactors = F)}))
snapshot = ''
can_release = F   # Since it's weekly report, only release when all settled

for(i in 1:nrow(spider_TASKS)){
  row = spider_TASKS[i,]
  if(row$is_in_use){
    last_refreshed = REF_LIST[REF_LIST$name == row$name, 'last_refreshed']
    can_refresh = check_time(row)
    is_refreshed = check_time(row, AsOfNow = last_refreshed)
    if(DEBUG | (can_refresh[1] == T & is_refreshed[1] != T)){
      # not refreshed yet, refresh data
      data = import_file(row)
      p = parse_data(data, row$name)
      if(p$valid){
        REF_LIST[REF_LIST$name == row$name, 'last_refreshed'] = str_c(as.POSIXct(str_c(format(Sys.time(), tz=DEFAULT_TZ,usetz=TRUE)), tz = DEFAULT_TZ, usetz=TRUE))
        can_release = T
        snapshot = str_c(snapshot, '\n\n', p$snapshot)
      }
    }
  }
}
cat(snapshot)
REF_LIST[1,2] = str_c(can_release)
write.csv(REF_LIST, REF_DIR, row.names = F)
write.table(snapshot, SNAPSHOT_DIR, col.names=F, row.names = F)

