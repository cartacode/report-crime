
db <- dbConnect(SQLite(), dbname="../db/crimenmexico.db")
muns <- dbGetQuery(db, "SELECT state_code, state, mun_code, municipio, 
                   tipo_text as tipo, subtipo_text as subtipo, modalidad_text as modalidad,
                   date, count, population,
                   (count * 12) / population * 100000 as rate
                   FROM municipios_fuero_comun 
                   NATURAL JOIN modalidad_municipios 
                   NATURAL JOIN tipo_municipios  
                   NATURAL JOIN subtipo_municipios 
                   NATURAL JOIN state_names 
                   NATURAL JOIN municipio_names  
                   NATURAL JOIN population_municipios
WHERE modalidad_text  = 'DELITOS PATRIMONIALES' or
modalidad_text  = 'HOMICIDIOS' or
modalidad_text  = 'LESIONES' or
modalidad_text  = 'PRIV. DE LA LIBERTAD (SECUESTRO)' or
(modalidad_text  = 'ROBO COMUN' and subtipo_text = 'DE VEHICULOS')")
dbDisconnect(db)

muns <- left_join(muns, abbrev)
muns$name <- str_c(muns$municipio, ", ", muns$state_abbrv)
muns$date <- as.Date(as.yearmon(muns$date))
muns %<>% mutate(rate = round(((count /  numberOfDays(date) * 30) * 12) / population * 10^5, 1))
# muns$name <- reorder(muns$name, -muns$rate, function(x) {
#   i = length(x)
#   print(i)
#   while(is.na(x[i]) & i > 0) {
#     i = i -1
#     print(i)
#   }
#   return(x[i])
#   })
# ggplot(muns, aes(date, rate, group = name)) +
#   geom_line(color = "#555555") +
#   geom_smooth(se = FALSE) +
#   facet_wrap(~name) +
#   sm_theme()




findAnomalies <- function(category, type, subtype="", munvec){
  anomalies <- data.frame()
  pb <- txtProgressBar(min = 0, max = length(munvec), style = 3)
  l <- 1
  for(munname in munvec){
    if (subtype != "")
      df <- subset(muns, name == munname & modalidad == category & 
                     tipo == type &
                     subtipo == subtype)
    else
      df <- subset(muns, name == munname & modalidad == category & 
                     tipo == type)
    df <- df[order(df$date),]
    df <- df %>%
      group_by(date, name, state_code, mun_code)  %>%
      summarise(count = sum(count, na.rm = TRUE),
                rate = ((count /  numberOfDays(date[1]) * 30) * 12) / population[1] * 10^5)
    i = nrow(df)
    while(is.na(df$rate[i]) & i > 0) {
      i = i -1
      #print(i)
    }
    hom <- df
    for(j in i:1) {
      if(is.na(hom$rate[j])) {
        hom$rate[j] <- median(hom$rate, na.rm = TRUE)
      }
    }
    hom <- na.omit(hom)
    hom$date  <- as.POSIXlt(hom$date, tz = "CST")
    max_date <- max(hom$date)
    if(hom$count[nrow(hom)] >= 5) {
      
        #hom$rate[is.na(hom$rate)] <- mean(hom$rate, na.rm = TRUE)
        #breakout(hom$rate, min.size = 2, method = 'multi', beta=0.001, plot=TRUE)
        suppressMessages(anoms <- AnomalyDetectionTs(hom[ ,c("date", "rate")], 
                                    max_anoms = 0.02, 
                                    direction = 'both',
                                    only_last = 'day')$anoms$timestamp)
        if(!is.null(anoms))
          if(anoms[length(anoms)] == max_date) {
            print(munname)
            anomalies <- rbind(anomalies, df)
          }
      
    }
    # update progress bar
    setTxtProgressBar(pb, l)
    l = l + 1
    
  }
  return(anomalies)
}


sm_anom <- function(df, title, xtitle, ytitle) {
  df$name <- reorder(df$name, -df$rate, min)
  title <- switch(title,
         hom = "HOMICIDIOS INTENCIONALES",
         rvcv = "ROBO DE VEHICULO C/V",
         rvsv = "ROBO DE VEHICULO S/V",
         kidnapping = "SECUESTRO",
         lesions = "LESIONES INTENCIONALES",
         ext = "EXTORSIÓN")
  ggplot(df, aes(date, rate)) +
    geom_line() +
    facet_wrap(~name, ncol = 5) +
    sm_theme() +
    ggtitle(title)+
    xlab(xtitle) +
    ylab(ytitle)
}

sm_anom_en <- function(df, title, xtitle, ytitle) {
  df$name <- reorder(df$name, -df$rate, min)
  title <- switch(title,
                  hom = "INTENTIONAL HOMICIDE",
                  rvcv = "CAR ROBBERY WITH VIOLENCE",
                  rvsv = "CAR ROBBERY WITHOUT VIOLENCE",
                  kidnapping = "KIDNAPPING",
                  lesions = "INTENTIONAL LESIONS",
                  ext = "EXTORTION")
  ggplot(df, aes(date, rate)) +
    geom_line() +
    facet_wrap(~name, ncol = 5) +
    sm_theme() +
    ggtitle(title) +
    xlab(xtitle) +
    ylab(ytitle)
}



dotMap <- function(centroids, mx, df, legend_title) {
  centroids <- right_join(centroids, df)
  centroids %<>%
    group_by(name, state_code, mun_code, lat, long) %>%
    do(tail(. ,1))
  
  ggplot(centroids, aes(long, lat), 
         color = "black") +
    geom_polygon(data = mx, aes(long, lat, group = group),
                 size = .1, color = "black", fill = "#9f794c") +
    coord_map("albers", lat0 = bb[ 2 , 1 ] , lat1 = bb[ 2 , 2 ] ) +
    geom_point(aes(size = count), 
               shape = 21, color = "white", fill = "#e34a33",
               guide = FALSE) +
    scale_size_area(legend_title, max_size = 5,
                    labels=trans_format("identity", function(x) round(x,0))) +
    infographic_theme2() +
    theme_bare() +
    theme(plot.title = element_blank(),
          axis.title = element_blank(),
          legend.position = c(.89, .95), 
          legend.margin = unit(0, "lines"),
          legend.title = element_text(family = "Ubuntu", 
                                      colour = "#0D0D0D", size = 8),
          legend.text = element_text(family = "Ubuntu", colour = "#0D0D0D", size = 6),
          legend.key = element_rect( fill = NA),
          legend.background = element_rect(fill = "#C7B470"),
          legend.key.height = unit(0.4, "cm"), 
          legend.key.width = unit(0.4, "cm"))
}


centroids <- read.csv("data/mun_centroids.csv")
#bigmuns <- subset(muns, population >= 50000)
muns_to_analyze <-  unique(muns$name)

ll <- list()
ll$hom <- findAnomalies("HOMICIDIOS", "DOLOSOS", munvec = muns_to_analyze)
ll$rvcv = findAnomalies("ROBO COMUN", "CON VIOLENCIA", "DE VEHICULOS",muns_to_analyze)
ll$rvsv = findAnomalies("ROBO COMUN", "SIN VIOLENCIA", "DE VEHICULOS", muns_to_analyze)

ll$lesions <- findAnomalies("LESIONES", "DOLOSAS", munvec = muns_to_analyze)
ll$kidnapping = findAnomalies("PRIV. DE LA LIBERTAD (SECUESTRO)", "SECUESTRO", "SECUESTRO", 
                           muns_to_analyze)
ll$ext <- findAnomalies("DELITOS PATRIMONIALES", "EXTORSION", "EXTORSION", muns_to_analyze)

j = 1
ll2 <- list()
for(i in 1:length(ll)){
  if(nrow(ll[[i]]) > 0) {
    ll2[j] <- ll[i]
    names(ll2)[j] <- names(ll)[i]
    j = j + 1
  }
}


max_date = muns$date %>% max(., na.rm = TRUE) %>% as.yearmon  %>% as.character 

svg(str_c("graphs/municipios_", tolower(str_replace(max_date, " ", "_")), ".svg"), 
    width = 12, height = 20)
grid.newpage() 
pushViewport(viewport(layout = grid.layout((length(ll2)*2)+1, 5)))
grid.rect(gp = gpar(fill = "#C7B470", col = "#C7B470"))
# Title
grid.text("CRIME BY MUNICIPIO", y = unit(.997, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, 
          gp = gpar(fontfamily = "Fugaz One", col = "#001D00", cex = 5, alpha = 0.3))
# Black square with the date on it
grid.rect(gp = gpar(fill = "black", col = "black"), 
          x = unit(0.94, "npc"), y = unit(0.988, "npc"), 
          width = unit(.085, "npc"), height = unit(0.04, "npc"))
# Text with the date
grid.text(max_date, vjust = 0, hjust = 0, x = unit(0.907, "npc"), 
          y = unit(0.98, "npc"), gp = gpar(fontfamily = "Open Sans Extrabold", 
                                           col = "white", cex = 1.08))
# Yellow bar for text
grid.rect(gp = gpar(fill = "#E7A922", col = "#E7A922"), 
          x = unit(0.5, "npc"), y = unit(0.951, "npc"), 
          width = unit(1, "npc"), height = unit(0.025, "npc"))
grid.text("All municipios with a crime rate anomaly during the last available date (30 day months).
Author: Diego Valle-Jones                                                    http://crimenmexico.diegovalle.net/en                                                    Source: SNSP and CONAPO", vjust = 0, hjust = 0, x = unit(0.01, "npc"), 
          y = unit(0.94, "npc"), 
          gp = gpar(fontfamily = "Ubuntu", col = "#552683", cex = 1.08))
# all the charts
j=1
for(i in seq(1,length(ll2)*2, by=2)) {
  print(sm_anom_en(ll2[[j]], names(ll2)[j], "date", "annualized rate"), vp = vplayout((i+1):(i+2), 1:3))
  print(dotMap(centroids, mx, ll2[[j]], "count"), vp = vplayout((i+1):(i+2), 4:5))
  j = j + 1
}
dev.off()

system(str_replace_all("convert graphs/municipios_XXX.svg graphs/municipios_XXX.png; 
                       optipng graphs/municipios_XXX.png;", "XXX",
                       tolower(str_replace(max_date, " ", "_"))))


lct <- Sys.getlocale("LC_TIME")
Sys.setlocale("LC_TIME", "es_ES.UTF-8")

max_date = muns$date %>% max(., na.rm = TRUE) %>% as.yearmon  %>% as.character 

svg(str_c("graphs/municipios_es_", tolower(str_replace(max_date, " ", "_")), ".svg"),
    width = 12, height = 20)
grid.newpage() 
pushViewport(viewport(layout = grid.layout((length(ll2)*2)+1, 5)))
grid.rect(gp = gpar(fill = "#C7B470", col = "#C7B470"))
# Title
grid.text("CRIMEN ✕ MUNICIPIO", y = unit(.997, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, 
          gp = gpar(fontfamily = "Fugaz One", col = "#001D00", cex = 5, alpha = 0.3))
# Black square with the date on it
grid.rect(gp = gpar(fill = "black", col = "black"), 
          x = unit(0.94, "npc"), y = unit(0.988, "npc"), 
          width = unit(.085, "npc"), height = unit(0.04, "npc"))
# Text with the date
grid.text(max_date, vjust = 0, hjust = 0, x = unit(0.907, "npc"), 
          y = unit(0.98, "npc"), gp = gpar(fontfamily = "Open Sans Extrabold", 
                                           col = "white", cex = 1.08))
# Yellow bar for text
grid.rect(gp = gpar(fill = "#E7A922", col = "#E7A922"), 
          x = unit(0.5, "npc"), y = unit(0.951, "npc"), 
          width = unit(1, "npc"), height = unit(0.025, "npc"))
grid.text("Todos los municipios con tasas de criminalidad fuera de lo normal durante la última fecha disponible para delitos seleccionados (meses de 30 días).
Autor: Diego Valle                                                               http://crimenmexico.diegovalle.net/es                                                               Fuente: SNSP y CONAPO", vjust = 0, hjust = 0, x = unit(0.01, "npc"), 
          y = unit(0.94, "npc"), 
          gp = gpar(fontfamily = "Ubuntu", col = "#552683", cex = 1.08))
# all the charts
j=1
for(i in seq(1,length(ll2)*2, by=2)) {
  print(sm_anom(ll2[[j]], names(ll2)[j], "fecha", "tasa anualizada"), vp = vplayout((i+1):(i+2), 1:3))
  print(dotMap(centroids, mx, ll2[[j]], "número"), vp = vplayout((i+1):(i+2), 4:5))
  j = j + 1
}
dev.off()


Sys.setlocale("LC_TIME", lct)

system(str_replace_all("convert graphs/municipios_es_XXX.svg graphs/municipios_es_XXX.png; 
                       optipng graphs/municipios_es_XXX.png;", "XXX",
                       tolower(str_replace(max_date, " ", "_"))))


