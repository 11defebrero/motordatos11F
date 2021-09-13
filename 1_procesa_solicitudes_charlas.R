library(formularios11F)
library(dplyr)


# Configuración

config <- leer_config("config/config.json")

ID_SHEET_SOLICITUDES_ORIGINAL <- config$ids_googledrive$solicitudes$original
ID_SHEET_SOLICITUDES_LIMPIO <- config$ids_googledrive$solicitudes$limpio

# Cargar datos

solicitudes_original <- get_solicitudes_charlas_original(file_id=ID_SHEET_SOLICITUDES_ORIGINAL)
solicitudes_limpio <- get_solicitudes_charlas_limpio(file_id=ID_SHEET_SOLICITUDES_LIMPIO)


# Filtrar nuevas solicitudes

solicitudes_new <- solicitudes_original %>%
  filter(! id %in% solicitudes_limpio$id)


# Añadir solicitudes corregidas que no tienen coordenadas para que se procesen también

solicitudes_corregidas <- solicitudes_limpio %>%
  filter(procesado == "CORREGIDO") %>%
  filter(is.na(lon) | is.na(lat)) %>%
  select(-lon, -lat) %>%
  mutate(
    fallos = "",
    fallos_geolocalizacion = ""
  )

solicitudes_new <- solicitudes_new %>%
  rbind(solicitudes_corregidas) %>%
  arrange(timestamp)

solicitudes_limpio <- solicitudes_limpio %>%
  filter(! id %in% solicitudes_corregidas$id)


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

solicitudes_limpio <- solicitudes_limpio %>%
  rbind(solicitudes_new) %>%
  marca_duplicados_solicitudes_charlas() %>%
  mutate(
    procesado = case_when(
      procesado == "CORREGIDO" ~ "CORREGIDO",
      duplicado_seguro ~ "DUPLICADO",
      duplicado_posible & procesado == "OK" ~ "POSIBLE DUPLICADO (EMAIL)",
      duplicado_posible & grepl("FALLO", procesado) ~ paste("POSIBLE DUPLICADO (EMAIL) +", procesado),
      TRUE ~ procesado
    ),
    duplicado_posible = NULL,
    duplicado_seguro = NULL
  )


# Restaurar estado en las charlas corregidas

solicitudes_limpio <- solicitudes_limpio %>%
  mutate(
    procesado = ifelse(id %in% solicitudes_corregidas$id, "CORREGIDO", procesado)
  )


# Subir a Google Drive

upload_solicitudes_charlas_limpio(solicitudes_limpio, file_id=ID_SHEET_SOLICITUDES_LIMPIO)

