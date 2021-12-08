library(formularios11F)
library(dplyr)
# library(httr)
# library(knitr)
# library(devtools)
# library(XMLRPC)
# library(RWordPress)

# devtools::install_github(c("duncantl/XMLRPC", "duncantl/RWordPress"))


# Configuración

config <- leer_config("config/config.json")

ID_SHEET_ACTIVIDADES_LIMPIO <- config$ids_googledrive$actividades$limpio
ID_SHEET_ACTIVIDADES_WORDPRESS <- config$ids_googledrive$actividades$wordpress

CUENTA_ENVIO_EMAILS <- config$email_envios
MAX_ENVIOS_DIARIOS <- 200 # comparte el numero con los envios a contactos, si no podrían ser 400
MAIL_WORDPRESS <- config$wordpress$email
DIR_WEB <- file.path(dirname(rprojroot::find_rstudio_root_file()), "actividades11F")

# options(
#   WordpressLogin = setNames(config$wordpress$password, config$wordpress$user),
#   WordpressURL = config$wordpress$url
# )

# Autenticación cuenta Gmail
gmail_acceso("config/gmail_credentials.json")


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

# Recuento nº mails enviados hoy

try(
  enviados <- startsWith(actividades_publicar$fallos_geo, 
                                    format(Sys.Date(), format="%d/%m/%Y")),
  total_enviados <- sum(enviados) 
  )

total_enviados <- ifelse(is.na(total_enviados), 0, total_enviados)


# Publicar posts en borrador

for (i in 1:nrow(actividades_publicar)) {
  
  if (total_enviados >= MAX_ENVIOS_DIARIOS) {
    break # Se sigue ejecutando el script para subir los datos actualizados
  }
  
  tags <- tags_actividad(actividades_publicar[i,], config$edicion)

  # FILE_NAME <- paste0("actividad_", i,".html")
  
  post_id <- gmail_envia_email_html(
                to = MAIL_WORDPRESS,
                from = CUENTA_ENVIO_EMAILS,
                reply_to = CUENTA_ENVIO_EMAILS,
                subject = actividades_publicar$titulo[i],
                body = cuerpo_mail_actividad(actividades_publicar[i, ])
  )
  
  actividades_publicar$fallos_geo[i] <- format(Sys.time(), format="%d/%m/%Y %T")

  total_enviados <- total_enviados + 1
  
  Sys.sleep(1)
  
  # post_id <- knitr::knit2wp(
  #   "templates/wordpress/actividades_wordpress_template.Rmd",
  #   envir = parent.frame(),
  #   action = "newPost",
  #   publish = FALSE,
  #   title = actividades_publicar$titulo[i],
  #   categories = paste0("Actividades", config$edicion),
  #   mt_keywords = tags
  # )
  
  actividades_publicar$procesado[i] <- as.character(post_id[[1]])
  print(paste("Vamos por el post", i, " de ", nrow(actividades_publicar)))

}

# Daba este error al usar knit2wp
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

