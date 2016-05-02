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
  re$snapshot = str_c('Date: ', asofdate, '\n', 
        str_c(str_replace_all(apply(d, 1, function(x){str_c(x[1],': ', x[2])}), 
                              '(\\ \\ )',''),collapse = '\n'))
  if(delta >= 12){  # not up to date file
    re$valid = F
  }
  re
}


parse_data = function(conn, name){
  fun_name = str_c('parser_', name)
  data = eval(call(fun_name, conn))
  data
}