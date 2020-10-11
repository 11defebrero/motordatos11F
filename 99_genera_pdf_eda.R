library(formularios11F)
library(rmarkdown)


# Configuración

config <- leer_config("config/config.json")

DIR_EDA_LOCAL <- file.path(rprojroot::find_rstudio_root_file(), "data", "eda")
DIR_EDA_DRIVE <- config$ids_googledrive$carpeta_eda

ID_SHEET_SOLICITUDES_LIMPIO <- config$ids_googledrive$solicitudes$limpio


## Solicitudes charlas

rmarkdown::render(
  input = "templates/eda/resumen_solicitadas.Rmd",
  params = list(id_sheet = ID_SHEET_SOLICITUDES_LIMPIO),
  output_file = "resumen_solicitadas.pdf",
  output_dir = DIR_EDA_LOCAL,
  quiet = TRUE
)

upload_file_to_drive(file.path(DIR_EDA_LOCAL, "resumen_solicitadas.pdf"), DIR_EDA_DRIVE)

