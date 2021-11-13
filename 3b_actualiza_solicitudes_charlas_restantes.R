library(formularios11F)
library(dplyr)


# Configuración

config <- leer_config("config/config.json")

ID_SHEET_SOLICITUDES_LIMPIO <- config$ids_googledrive$solicitudes$limpio
ID_SHEET_SOLICITUDES_RESTANTES <- config$ids_googledrive$solicitudes$restantes
ID_SHEET_CONCERTADAS_LIMPIO <- config$ids_googledrive$concertadas$limpio


# Descargar listados de solicitudes y de concertadas

solicitudes_restantes <- get_solicitudes_charlas_limpio(file_id=ID_SHEET_SOLICITUDES_LIMPIO)

concertadas <- get_charlas_concertadas_limpio(file_id=ID_SHEET_CONCERTADAS_LIMPIO) %>%
  filter(es_charla_solicitada == "Sí" & procesado %in% c("OK", "CORREGIDO"))


# Eliminar solicitudes ya concertadas

solicitudes_restantes <- solicitudes_restantes %>%
  elimina_solicitudes_charlas_concertadas(concertadas)
#FIXME añadir educación especial a los niveles

# Subir a Google Drive

upload_solicitudes_charlas_limpio(solicitudes_restantes, file_id=ID_SHEET_SOLICITUDES_RESTANTES)

