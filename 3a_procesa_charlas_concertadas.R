library(formularios11F)
library(dplyr)
library(rmarkdown)

# Nota: está hecho para los headers del archivo de 2020. Si da algún problema coger los headers del archivo original de googlesheets de 2020.
# ANUNCIAR CHARLAS CONCERTADAS (Original)
# https://docs.google.com/spreadsheets/d/1JVaEcf_CDPOhMobx1PzOzAkRvyvdI_NYKyXmH7TIu6A/edit#gid=816873668

# Configuración

config <- leer_config("config/config.json")

ID_SHEET_CONCERTADAS_ORIGINAL <- config$ids_googledrive$concertadas$original
ID_SHEET_CONCERTADAS_LIMPIO <- config$ids_googledrive$concertadas$limpio
ID_SHEET_SOLICITUDES_LIMPIO <- config$ids_googledrive$solicitudes$limpio


# Filtrar nuevos anuncios de charlas concertadas

charlas_original <- get_charlas_concertadas_original(file_id=ID_SHEET_CONCERTADAS_ORIGINAL)
charlas_limpio <- get_charlas_concertadas_limpio(file_id=ID_SHEET_CONCERTADAS_LIMPIO)

charlas_new <- charlas_original %>%
  filter(! id %in% charlas_limpio$id)

if (nrow(charlas_new) == 0) {
  stop("No hay nuevas charlas concertadas.")
}


# Limpiar charlas concertadas

charlas_new <- charlas_new %>%
  limpia_charlas_concertadas() %>%
  mutate(procesado = ifelse(fallos == "", "OK", "FALLO"))


# Completar info charlas concertadas

solicitudes <- get_solicitudes_charlas_limpio(file_id=ID_SHEET_SOLICITUDES_LIMPIO)

charlas_new <- charlas_new %>%
  completa_info_charlas_concertadas(solicitudes) %>%
  mutate(
    procesado = ifelse(fallos_validacion == "", procesado,
                       ifelse(procesado == "OK", "NO VÁLIDA", paste(procesado, "+ NO VÁLIDA")))
  )


# Geolocalizar centros (coordenadas código postal)

charlas_new <- charlas_new %>%
  geolocaliza_charlas_concertadas() %>%
  mutate(
    procesado = ifelse(fallos_geolocalizacion == "", procesado,
                       ifelse(procesado == "OK", "FALLO GEO", paste(procesado, "+ FALLO GEO")))
  )


# Tratar duplicados

charlas_limpio <- charlas_limpio %>%
  rbind(charlas_new) %>%
  marca_duplicados_charlas_concertadas()


# Subir a Google Drive

upload_charlas_concertadas_limpio(charlas_limpio, file_id=ID_SHEET_CONCERTADAS_LIMPIO)
