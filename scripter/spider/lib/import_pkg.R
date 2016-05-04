# install packages
{
inst_pkges = installed.packages()[,'Package']
pkges = c('stringr', 'plyr', 'tm', 'reshape2')
reqr_pkges = pkges[!(pkges %in% inst_pkges)]
if(length(reqr_pkges) > 0){
  install.packages(reqr_pkges)
}

for(p in pkges){
  require(package = p, quietly = T, character.only = T)
}
}

# import urls
# > names(urls)
#"spider" "name" "url" "release_time" "time_zone"    "description" 
#"file_type"    "is_in_use"
urls = read.csv('urls.csv', header = T, stringsAsFactors = F)
config = read.csv('config.csv', header = T, stringsAsFactors = F)

TEMP_DIR = paste0(getwd(),'/',config[config$name == 'tmp_dir', 'data'])
REFRESH_INV = as.numeric(config[config$name == 'refresh_inv', 'data'])
DEFAULT_TZ = config[config$name == 'default_tz', 'data']; DEFAULT_TZ

# function registry
import_file = function(url_row){
  #url_row: one row in "urls"
  
  # accept postfixs
  accepted_type = c('csv', 'pdf', 'html')
  dat = NULL
  # if yes, download it
  if(url_row$file_type %in% accepted_type){
    filename = paste0(TEMP_DIR,'./', url_row$name, '.', url_row$file_type)
    download.file(url_row$url, destfile = filename, method = 'curl', quiet=T)
    if(url_row$file_type == 'csv'){
      dat = file(filename)
    }
  }
  
  dat
  
}

check_time = function(url_row, AsOfNow = format(Sys.time(), tz=DEFAULT_TZ,usetz=TRUE)){
  time = url_row$release_time
  tz = url_row$time_zone; if(is.na(tz)){tz = DEFAULT_TZ}
  day = url_row$release_day
  pb.date <- as.POSIXct(str_c(AsOfNow), tz=DEFAULT_TZ)
  now = as.POSIXct(format(pb.date, tz=tz,usetz=TRUE), tz = tz)

  refresh = c(T, 0)   # refresh[1]: we may get data, refresh[2]: how many interval passed
  if(!is.na(time)){
    check_time_sp = strptime(time, '%H:%M', tz = tz)
    print(str_c(check_time_sp, '\t', now))
    if(now > check_time_sp){
      refresh[2] = as.numeric(now - check_time_sp, unit='secs')/REFRESH_INV
    }
    else{
      refresh[1] = F
    }
  }
  if(day != format(now, '%u')){
    refresh[1] = F
  }
  refresh
}

#read.pdf = function(url, name){
#  filename = paste0(TEMP_DIR,'./', name)
#  download.file(url, destfile = filename, method = 'curl')
#  pdf = readPDF(engine = 'Rcampdf', control = list(text = "-layout"))(
#                elem = list(uri = filename),
#                language = "en",id = "id1")
#}














