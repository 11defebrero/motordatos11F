library(formularios11F)
library(dplyr)


# Configuración

config <- leer_config("config/config.json")

ID_SHEET_SOLICITUDES_ORIGINAL <- config$id_sheets_googledrive$solicitudes$original
ID_SHEET_SOLICITUDES_LIMPIO <- config$id_sheets_googledrive$solicitudes$limpio


# Filtrar nuevas solicitudes

solicitudes_original <- get_solicitudes_charlas_original(file_id=ID_SHEET_SOLICITUDES_ORIGINAL)
solicitudes_limpio <- get_solicitudes_charlas_limpio(file_id=ID_SHEET_SOLICITUDES_LIMPIO)

solicitudes_new <- solicitudes_original %>%
  elimina_duplicados() %>%
  filter(! id %in% solicitudes_limpio$id)

if (nrow(solicitudes_new) == 0) {
  stop("No hay nuevas solicitudes de actividad.")
}


# Limpiar nuevas solicitudes

solicitudes_new <- limpia_solicitudes_charlas(solicitudes_new) %>%
  mutate(procesado = ifelse(fallos == "", "OK", "FALLO"))


# Geolocalizar centros (coordenadas código postal)

solicitudes_new <- geolocaliza_solicitudes_charlas(solicitudes_new) %>%
  mutate(
    procesado = ifelse(fallos_geolocalizacion == "", procesado,
                       ifelse(procesado == "FALLO", "FALLO + FALLO GEO", "FALLO GEO"))
  )


# Tratar duplicados

# marca posibles duplicados en la columna pdup
solicitudes_new <- solicitudes_new %>%
  marca_duplicados()

# elimina duplicados claros
solicitudes_limpio <- solicitudes_limpio %>%
  rbind(solicitudes_new) %>%
  elimina_duplicados() %>%
  marca_duplicados()


# Subir a Google Drive

upload_solicitudes_charlas_limpio(solicitudes_limpio, file_id=ID_SHEET_SOLICITUDES_LIMPIO)

