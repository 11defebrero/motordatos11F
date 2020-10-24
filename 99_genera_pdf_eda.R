library(formularios11F)
library(rmarkdown)


# Configuración

config <- leer_config("config/config.json")

DIR_EDA_LOCAL <- file.path(rprojroot::find_rstudio_root_file(), "data", "eda")
DIR_EDA_DRIVE <- config$ids_googledrive$carpeta_eda

ID_SHEET_SOLICITUDES_LIMPIO <- config$ids_googledrive$solicitudes$limpio
ID_SHEET_CONTACTOS_LIMPIO <- config$ids_googledrive$contactos$limpio
ID_SHEET_CONTACTOS_ENVIADO <- config$ids_googledrive$contactos$enviado


## Solicitudes charlas

rmarkdown::render(
  input = "templates/eda/resumen_solicitadas.Rmd",
  params = list(id_sheet = ID_SHEET_SOLICITUDES_LIMPIO),
  output_file = "resumen_solicitadas.pdf",
  output_dir = DIR_EDA_LOCAL,
  quiet = TRUE
)

upload_file_to_drive(file.path(DIR_EDA_LOCAL, "resumen_solicitadas.pdf"), DIR_EDA_DRIVE)

## Contactos con los centros para concertar una charla

rmarkdown::render(
  input = "templates/eda/resumen_contactos.Rmd",
  params = list(id_sheet_limpios = ID_SHEET_CONTACTOS_LIMPIO, 
                id_sheet_enviado = ID_SHEET_CONTACTOS_ENVIADO),
  output_file = "resumen_contactos.pdf",
  output_dir = DIR_EDA_LOCAL,
  quiet = TRUE
)

upload_file_to_drive(file.path(DIR_EDA_LOCAL, "resumen_contactos.pdf"), DIR_EDA_DRIVE)
