library(formularios11F)
library(dplyr)


# Configuración

config <- leer_config("config/config.json")

ID_SHEET_CONTACTOS_ORIGINAL <- config$ids_googledrive$contactos$original
ID_SHEET_CONTACTOS_LIMPIO <- config$ids_googledrive$contactos$limpio
ID_SHEET_SOLICITUDES_LIMPIO <- config$ids_googledrive$solicitudes$limpio


# Filtrar nuevas peticiones de contacto con centros

contactos_original <- get_contactos_centros_original(file_id=ID_SHEET_CONTACTOS_ORIGINAL)
contactos_limpio <- get_contactos_centros_limpio(file_id=ID_SHEET_CONTACTOS_LIMPIO)

contactos_new <- contactos_original %>%
  filter(! id %in% contactos_limpio$id)

if (nrow(contactos_new) == 0) {
  stop("No hay nuevos contactos con centros.")
}


# Limpiar peticiones de contacto

contactos_new <- contactos_new %>%
  limpia_contactos_centros() %>%
  mutate(procesado = ifelse(fallos == "", "OK", "FALLO"))


# Validar peticiones de contacto (checkeo nombre de centro)

solicitudes <- get_solicitudes_charlas_limpio(file_id=ID_SHEET_SOLICITUDES_LIMPIO)

contactos_new <- contactos_new %>%
  completa_info_contactos_centros(solicitudes) %>%
  mutate(
    procesado = ifelse(validacion == TRUE, procesado, "NO VÁLIDA")
  )


# Tratar duplicados

contactos_limpio <- contactos_limpio %>%
  rbind(contactos_new) %>%
  marca_duplicados_contactos_centros()


# Subir a Google Drive

upload_contactos_centros_limpio(contactos_limpio, file_id=ID_SHEET_CONTACTOS_LIMPIO)

