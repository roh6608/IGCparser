#' Parse IGC file
#'
#' @param filepath filepath of IGC file contained within " "
#'
#' @return A data frame, with time in seconds, latitude and longitude in decimal degrees, pressure
#' and GNSS altitude in meters, climb rate in m/s
#' @export
#'
#' @examples IGCparse("2021-02-05-XCS-AAA-03.igc")
#'
#'
IGCparse <- function(filepath){
  `%>%` <- dplyr::`%>%`
  #data import
  df <- read.csv(paste0(filepath), header = F)

  #manipulating data
  data <- as.data.frame(df[grep("B", df$V1),])
  colnames(data) <- c("V1")
  data$time <- as.numeric(hms::hms(seconds = as.numeric(substr(data$V1,6,7)),
                        minutes = as.numeric(substr(data$V1,4,5)),
                        hours = as.numeric(substr(data$V1,2,3))))
  data$time <- data$time - data$time[1]
  data$lat_deg <- paste0(substr(data$V1,8,9),substr(data$V1,15,15))
  data$lat_min <- as.numeric(paste0(substr(data$V1,10,11),".",substr(data$V1,12,14)))
  data$lon_deg <- as.numeric(paste0(substr(data$V1,16,18),substr(data$V1,24,24)))
  data$lon_min <- as.numeric(paste0(substr(data$V1,19,20),".",substr(data$V1,21,23)))
  data$press_alt <- substr(data$V1,26,30)
  data$GNSS_alt <- substr(data$V1,31,35)
  data <- data %>% dplyr::mutate_at(dplyr::vars(lat_deg, lon_deg),
                             dplyr::funs(as.numeric(gsub("[NE]$", "", gsub("^(.*)[WS]$", "-\\1", .)))))
  for(item in data$lat_deg){
    if(item < 0){
      data$lat <- item - data$lat_min/60
    }
    else{
      data$lat <- item + data$lat_min/60
    }
  }

  for(item in data$lon_deg){
    if(item < 0){
      data$lon <- item - data$lon_min/60
    }
    else{
      data$lon <- item + data$lon_min/60
    }
  }
  data$press_alt <- as.numeric(data$press_alt)
  data$GNSS_alt <- as.numeric(data$GNSS_alt)
  data$climb_rate_press <- c(diff(data$press_alt)/diff(data$time),0)
  data$climb_rate_GNSS <- c(diff(data$GNSS_alt)/diff(data$time),0)
  data$V1 <- NULL
  data$lat_deg <- NULL
  data$lat_min <- NULL
  data$lon_deg <- NULL
  data$lon_min <- NULL


  return(data)
}