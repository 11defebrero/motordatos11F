library(formularios11F)
library(rmarkdown)


# Configuración

config <- leer_config("config/config.json")

ID_SHEET_CONCERTADAS_LIMPIO <- config$ids_googledrive$solicitudes$limpio
ID_SHEET_SOLICITUDES_RESTANTES <- config$ids_googledrive$solicitudes$restantes
ID_SHEET_CONCERTADAS_LIMPIO <- config$ids_googledrive$concertadas$limpio
ID_SHEET_ACTIVIDADES_LIMPIO <- config$ids_googledrive$actividades$limpio
ID_SHEET_ACTIVIDADES_WORDPRESS <- config$ids_googledrive$actividades$wordpress
ID_FORMULARIO_CONTACTO <- config$ids_googledrive$contactos$formulario
EDICION <- config$edicion 
DIR_WEB <- file.path(dirname(rprojroot::find_rstudio_root_file()), "web11F")
DIR_WEB_LIBS <- file.path(DIR_WEB, "libs/")


## Solicitudes charlas

rmarkdown::render(
  encoding = "UTF-8",
  input = "templates/github/solicitudes_todas.Rmd",
  params = list(
    id_sheet = ID_SHEET_SOLICITUDES_RESTANTES,
    id_form_contacto = ID_FORMULARIO_CONTACTO 
  ),
  output_file = "solicitudes_todas.html",
  output_dir = DIR_WEB,
  output_options = list(lib_dir = DIR_WEB_LIBS),
  quiet = TRUE
)

Sys.sleep(5)

rmarkdown::render(
  encoding = "UTF-8",
  input = "templates/github/solicitudes_mapa_tabla.Rmd",
  params = list(
    id_sheet = ID_SHEET_SOLICITUDES_RESTANTES,
    id_form_contacto = ID_FORMULARIO_CONTACTO 
  ),
  output_file = "solicitudes_mapa_tabla.html",
  output_dir = DIR_WEB,
  output_options = list(lib_dir = DIR_WEB_LIBS),
  quiet = TRUE
)

Sys.sleep(5)


## Charlas concertadas

rmarkdown::render(
  encoding = "UTF-8",
  input = "templates/github/concertadas_todas.Rmd",
  params = list(id_sheet = ID_SHEET_CONCERTADAS_LIMPIO),
  output_file = "concertadas_todas.html",
  output_dir = DIR_WEB,
  output_options = list(lib_dir = DIR_WEB_LIBS),
  quiet = TRUE
)

Sys.sleep(5)

rmarkdown::render(
  encoding = "UTF-8",
  input = "templates/github/concertadas_mapa_tabla.Rmd",
  params = list(id_sheet = ID_SHEET_CONCERTADAS_LIMPIO),
  output_file = "concertadas_mapa_tabla.html",
  output_dir = DIR_WEB,
  output_options = list(lib_dir = DIR_WEB_LIBS),
  quiet = TRUE
)

Sys.sleep(5)


## Actividades

rmarkdown::render(
  encoding = "UTF-8",
  input = "templates/github/centros11f_todos.Rmd",
  params = list(id_sheet = ID_SHEET_ACTIVIDADES_LIMPIO),
  output_file = "centros11f_todos.html",
  output_dir = DIR_WEB,
  output_options = list(lib_dir = DIR_WEB_LIBS),
  quiet = TRUE
)

Sys.sleep(5)

rmarkdown::render(
  encoding = "UTF-8",
  input = "templates/github/centros11f_mapa_tabla.Rmd",
  params = list(id_sheet = ID_SHEET_ACTIVIDADES_LIMPIO),
  output_file = "centros11f_mapa_tabla.html",
  output_dir = DIR_WEB,
  output_options = list(lib_dir = DIR_WEB_LIBS),
  quiet = TRUE
)

Sys.sleep(5)

# el siguiente aun no funciona

# rmarkdown::render(
#   encoding = "UTF-8",
#   input = "templates/github/actividades_mapa_tabla.Rmd",
#   params = list(id_sheet = ID_SHEET_ACTIVIDADES_WORDPRESS,
#                  edicion = EDICION),
#   output_file = "actividades_mapa_tabla.html",
#   output_dir = DIR_WEB,
#   output_options = list(lib_dir = DIR_WEB_LIBS),
#   quiet = TRUE
# )

