library(formularios11F)
library(dplyr)
library(rmarkdown)


# Configuración

config <- leer_config("config/config.json")

ID_SHEET_ACTIVIDADES_ORIGINAL <- config$ids_googledrive$actividades$original
ID_SHEET_ACTIVIDADES_LIMPIO <- config$ids_googledrive$actividades$limpio


# Filtrar nuevas peticiones de contacto con centros

actividades_original <- suppressWarnings(
  get_actividades_original(file_id=ID_SHEET_ACTIVIDADES_ORIGINAL)
) # FIXME: simplificar formulario para evitar columnas duplicadas

actividades_limpio <- get_actividades_limpio(file_id=ID_SHEET_ACTIVIDADES_LIMPIO)

actividades_new <- actividades_original %>%
  filter(! id %in% actividades_limpio$id)

if (nrow(actividades_new) == 0) {
  stop("No hay nuevas actividades.")
}


# Limpiar actividades

actividades_new <- actividades_new %>%
  limpia_actividades() %>%
  mutate(procesado = ifelse(fallos_validacion == "", "OK", "FALLO"))


# Geolocalizar actividades (coordenadas código postal)

actividades_geo <- actividades_new %>%
  filter(clase_actividad %in% c("CENTRO11F", "PRESENCIAL")) %>%
  geolocaliza_actividades() %>%
  mutate(
    procesado = ifelse(fallos_geo == "", procesado,
                       ifelse(procesado == "OK", "FALLO GEO", paste(procesado, "+ FALLO GEO")))
  )

actividades_no_geo <- actividades_new %>%
  filter(!id %in% actividades_geo$id) %>%
  mutate(lon = NA, lat = NA)

actividades_new <- actividades_geo %>%
  rbind(actividades_no_geo) %>%
  arrange(timestamp)


# Tratar duplicados

# detecta como duplicados los que tienen el mismo mail y título

actividades_limpio <- actividades_limpio %>%
  rbind(actividades_new) %>%
  marca_duplicados_actividades()


# Subir a Google Drive

upload_actividades_limpio(actividades_limpio, file_id=ID_SHEET_ACTIVIDADES_LIMPIO)


# Generar resumen

rmarkdown::render(
  input = "templates/eda/Resumen_actividades.Rmd",
  output_file = "eda/Resumen_actividades.html",
  output_dir =  "eda",
  output_format = rmarkdown::html_document(self_contained = T,
                                           toc = T,
                                           toc_depth = 3,
                                           toc_float = T,
                                           number_sections = T,
                                           section_divs = T,
                                           theme = "spacelab"),
  quiet = T
)
browseURL("eda/Resumen_actividades.html")
# “default”, “cerulean”, “journal”, “flatly”, “darkly”, “readable”, “spacelab”, “united”, “cosmo”, “lumen”, “paper”, “sandstone”, “simplex”, “yeti”

