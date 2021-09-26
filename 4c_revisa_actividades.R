library(formularios11F)
library(dplyr)


# Configuración

config <- leer_config("config/config.json")

ID_SHEET_ACTIVIDADES_LIMPIO <- config$ids_googledrive$actividades$limpio
ID_SHEET_ACTIVIDADES_WORDPRESS <- config$ids_googledrive$actividades$wordpress


## Cargar datos limpios

actividades_limpio <- get_actividades_limpio(file_id = ID_SHEET_ACTIVIDADES_LIMPIO)
actividades_rev <-  actividades_limpio %>%
  filter(clase_actividad %in% c("PRESENCIAL", "NO PRESENCIAL")) %>%
  filter(procesado %in% "REVISADO")

if (nrow(actividades_rev) == 0) {
  stop("No hay actividades para revisar.")
}

# Subir a Google Drive - limpio ###############################################################
actividades_rev$procesado <- "CORREGIDO"

actividades_resto <- actividades_limpio %>%
  filter(! id %in% actividades_rev$id )

actividades_limpio <- actividades_rev %>%
  rbind(actividades_resto) %>%
  arrange(timestamp)

upload_actividades_limpio(actividades_limpio, file_id = ID_SHEET_ACTIVIDADES_LIMPIO)
###############################################################################################

actividades_wordpress <- get_actividades_limpio(file_id = ID_SHEET_ACTIVIDADES_WORDPRESS)

actividades_rev <- left_join(actividades_rev, actividades_wordpress[ , 1:2], by = "id") %>%
  rename(procesado = procesado.y)
actividades_rev$procesado.x <- NULL

# col_order <- c("id",   "procesado", "fallos_validacion", "fallos_geo", "clase_actividad",   "timestamp",
#                 "email",  "nombre", "titulo",   "es_centro",   "codpostal",
#                 "localidad", "provincia", "com_autonoma", "lon", "lat",
#                 "centro", "tipo", "web", "des", "es_presencial",
#                 "audiencia", "email2",      "telf",       "fecha" , "hora_inicio",
#                 "hora_fin", "organiza",     "patrocina", "imagen",  "reserva"     ,
#                 "espacio", "direccion")

col_order <- c( 1, 33, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
                22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32)

actividades_rev <- actividades_rev[, col_order]

actividades_resto <- actividades_wordpress %>%
  filter(! id %in% actividades_rev$id )


# Subir a Google Drive

actividades_publicadas <- actividades_rev %>%
  rbind(actividades_resto) %>%
  arrange(timestamp)

upload_actividades_limpio(actividades_publicadas, file_id = ID_SHEET_ACTIVIDADES_WORDPRESS)
