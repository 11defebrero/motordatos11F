library(rmarkdown)


# Configuración

config <- leer_config("config/config.json")

DIR_WEB <- file.path(dirname(rprojroot::find_rstudio_root_file()), paste0("web11F-", config$edicion))
DIR_WEB_LIBS <- file.path(DIR_WEB, "libs/")


## Solicitudes charlas

rmarkdown::render(
  encoding = "UTF-8",
  input = "templates/github/solicitudes_todas.Rmd",
  output_file = "solicitudes_todas.html",
  output_dir = DIR_WEB,
  output_options = list(lib_dir = DIR_WEB_LIBS),
  params = config,
  quiet = TRUE
)

Sys.sleep(5)

rmarkdown::render(
  encoding = "UTF-8",
  input = "templates/github/solicitudes_mapa_tabla.Rmd",
  output_file = "solicitudes_mapa_tabla.html",
  output_dir = DIR_WEB,
  output_options = list(lib_dir = DIR_WEB_LIBS),
  params = config,
  quiet = TRUE
)

Sys.sleep(5)

rmarkdown::render(
  encoding = "UTF-8",
  input = "templates/github/solicitudes_videollamada.Rmd",
  output_file = "solicitudes_videollamada.html",
  output_dir = DIR_WEB,
  output_options = list(lib_dir = DIR_WEB_LIBS),
  params = config,
  quiet = TRUE
)

Sys.sleep(5)


## Charlas concertadas

rmarkdown::render(
  encoding = "UTF-8",
  input = "templates/github/concertadas_todas.Rmd",
  output_file = "concertadas_todas.html",
  output_dir = DIR_WEB,
  output_options = list(lib_dir = DIR_WEB_LIBS),
  params = config,
  quiet = TRUE
)

Sys.sleep(5)

rmarkdown::render(
  encoding = "UTF-8",
  input = "templates/github/concertadas_mapa_tabla.Rmd",
  output_file = "concertadas_mapa_tabla.html",
  output_dir = DIR_WEB,
  output_options = list(lib_dir = DIR_WEB_LIBS),
  params = config,
  quiet = TRUE
)

Sys.sleep(5)


## Actividades

rmarkdown::render(
  encoding = "UTF-8",
  input = "templates/github/centros11f_todos.Rmd",
  output_file = "centros11f_todos.html",
  output_dir = DIR_WEB,
  output_options = list(lib_dir = DIR_WEB_LIBS),
  params = config,
  quiet = TRUE
)

Sys.sleep(5)

rmarkdown::render(
  encoding = "UTF-8",
  input = "templates/github/centros11f_mapa_tabla.Rmd",
  output_file = "centros11f_mapa_tabla.html",
  output_dir = DIR_WEB,
  output_options = list(lib_dir = DIR_WEB_LIBS),
  params = config,
  quiet = TRUE
)

Sys.sleep(5)

rmarkdown::render(
  encoding = "UTF-8",
  input = "templates/github/actividades_mapa_tabla.Rmd",
  output_file = "actividades_mapa_tabla.html",
  output_dir = DIR_WEB,
  output_options = list(lib_dir = DIR_WEB_LIBS),
  params = config,
  quiet = TRUE
)

