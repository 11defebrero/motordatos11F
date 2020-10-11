library(formularios11F)
library(dplyr)
library(RWordPress)


# Configuración

config <- leer_config("config/config.json")

ID_SHEET_ACTIVIDADES_WORDPRESS <- config$id_sheets_googledrive$actividades$wordpress

options(
  WordpressLogin = setNames(config$wordpress$password, config$wordpress$user),
  WordpressURL = config$wordpress$url
)


## Cargar datos Wordpress

actividades_wordpress <- get_actividades_limpio(file_id=ID_SHEET_ACTIVIDADES_WORDPRESS)

ind_actividades_revisar <- which(!startsWith(actividades_wordpress$procesado, "http"))

if (length(ind_actividades_revisar) == 0) {
  stop("No hay actividades por revisar.")
}


# Guardar URL del post una vez publicado

for (i in ind_actividades_revisar) {

  post_info <- suppressWarnings(RWordPress::getPost(actividades_wordpress$procesado[i]))

  if (post_info$post_status == "publish") {
    actividades_wordpress$procesado[i] <- post_info$permaLink
  } else if (post_info$post_status != "draft") {
    stop(paste("Algo ha ido mal: el status del post es", post_info$post_status))
  }

}


# Subir a Google Drive

upload_actividades_limpio(actividades_wordpress, file_id=ID_SHEET_ACTIVIDADES_WORDPRESS)

