library(formularios11F)
library(dplyr)
library(httr)
library(knitr)
library(devtools)
library(XMLRPC)
library(RWordPress)

# devtools::install_github(c("duncantl/XMLRPC", "duncantl/RWordPress"))


# Configuración

config <- leer_config("config/config.json")

ID_SHEET_ACTIVIDADES_LIMPIO <- config$ids_googledrive$actividades$limpio
ID_SHEET_ACTIVIDADES_WORDPRESS <- config$ids_googledrive$actividades$wordpress


options(
  WordpressLogin = setNames(config$wordpress$password, config$wordpress$user),
  WordpressURL = config$wordpress$url
)



## Cargar datos limpios

actividades_limpio <- get_actividades_limpio(file_id=ID_SHEET_ACTIVIDADES_LIMPIO) %>%
  filter(clase_actividad %in% c("PRESENCIAL", "NO PRESENCIAL")) %>%
  filter(procesado %in% c("OK", "CORREGIDO"))

#FIXME la primera vez tengo que ejecutar lo siguiente en vez de lo de después
# actividades_wordpress <- NULL

actividades_wordpress <- get_actividades_limpio(file_id=ID_SHEET_ACTIVIDADES_WORDPRESS)

actividades_publicar <- actividades_limpio %>%
  filter(! id %in% actividades_wordpress$id)

if (nrow(actividades_publicar) == 0) {
  stop("No hay actividades por publicar.")
}


# Publicar posts en borrador

for (i in 1:nrow(actividades_publicar)) {

  tags <- tags_actividad(actividades_publicar[i,], config$edicion)
  #FIXME 8F2022??
  
  ## render post

  post_id <- knitr::knit2wp(
    "templates/wordpress/actividades_wordpress_template.Rmd",
    envir = parent.frame(),
    action = "newPost",
    publish = FALSE,
    title = actividades_publicar$titulo[i],
    categories = paste0("Actividades", config$edicion),
    mt_keywords = tags
  )
  #FIXME 

  actividades_publicar$procesado[i] <- post_id
  print(paste("Vamos por el post", i, " de ", nrow(actividades_publicar)))

}

#FIXME aquí falla
# Error in function (type, msg, asError = TRUE)  : 
#   error:1407742E:SSL routines:SSL23_GET_SERVER_HELLO:tlsv1 alert protocol version

# Dejar fuera las marcadas con "NO PUBLICAR" en actividades limpio

actividades_no_publicar <- actividades_limpio %>%
  filter( procesado == "NO PUBLICAR")
actividades_wordpress <- actividades_wordpress %>%
  filter(! id %in% actividades_no_publicar$id)

# Subir a Google Drive

actividades_publicadas <- actividades_publicar %>%
  filter(!procesado %in% c("OK", "CORREGIDO")) %>%
  rbind(actividades_wordpress) %>%
  arrange(timestamp)

upload_actividades_limpio(actividades_publicadas, file_id=ID_SHEET_ACTIVIDADES_WORDPRESS)

