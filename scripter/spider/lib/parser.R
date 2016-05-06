# load packages
require(RCurl)
require(XML)
require(stringr)
require(urltools)
require(plyr)

# parse_data
gen_re = function(){
  re = list(
    valid = T,
    asofdate = '',
    data = NULL,
    snapshot = ''
  )
  re
}

# PETROLEUM
parser_balance_sheet = function(f){
  re = gen_re()
  data = read.csv(f, head = F, stringsAsFactors = F, fill = TRUE, col.names = paste0("V",seq_len(13)))
  asofdate = as.Date(data[1,2], '%m/%d/%y')
  now = as.Date(Sys.time())
  delta = as.numeric(now - asofdate, unit = 'days')
  
  d1 = data[c(2,5),c(1,4)]; names(d1) = c('Name', 'Difference')
  d2 = data[c(22, 26,34,35), c(2, 5)]; names(d2) = c('Name', 'Difference')
  d = rbind(d1,d2)
  
  re['asofdate'] = str_c(asofdate)
  re$data = d
  re$snapshot = str_c('AsOfDate: ', asofdate, '\n', 
        str_c(str_replace_all(apply(d, 1, function(x){str_c(x[1],': ', x[2])}), 
                              '(\\ \\ )',''),collapse = '\n'))
  if(delta >= 12){  # not up to date file
    re$valid = F
  }
  re
}

parser_google_news = function(html){
  re = gen_re()
  now = str_c(system_time())
  doc = htmlParse(html, asText = T)
  newslist = ldply(doc["//div[@class='g']"], function(x){
    para = htmlParse(toString.XMLNode(x), asText = T)
    #getNodeSet(x, "//h3[@class='r']")
    title = str_trim(xpathSApply(para, "//h3[@class='r']/a", xmlValue))
    src = xpathSApply(para, "//div[@class='slp']/span", xmlValue)
    bref = str_replace_all(xpathSApply(para, "//div[@class='st']", xmlValue), 'Ã|Â', '')
    link = xpathSApply(para, "//h3[@class='r']/a", xmlAttrs)[['href']]
    link = URLdecode(param_get(link, 'q')[[1]])
    snapshot = str_c('<a href="', link, '"><b>', title, '</b></a><br><i>',src,'</i><br>', bref)
    data.frame(Title = title, News_Source = src, Intro=bref, URL=link, snapshot=snapshot, key = str_sub(title, end = 30), stringsAsFactors = F)
  })
  
  if(nrow(newslist) > 0){
    newslist$Timestamp = now
    re$valid = T
  } else{
    re$valid = F
  }
  
  
  re$asofdate = now
  re$data = newslist
  re$snapshot = ""
  re
}


parse_data = function(conn, name){
  fun_name = str_c('parser_', name)
  data = eval(call(fun_name, conn))
  data
}