#######################
##  MOTOR DATOS 11F  ##
#######################

# Opcional

detach("package:formularios11F", unload = TRUE)
devtools::install_github("11defebrero/formularios11F")
library("formularios11F")

googledrive::drive_auth()
#TODO seleccionar "1" por defecto

# Charlas solicitadas

# source("1_procesa_solicitudes_charlas.R", encoding = "UTF-8")


# Peticiones de contacto con centros

source("2a_procesa_contactos_centros.R", encoding = "UTF-8")
source("2b_envia_emails_contacto.R", encoding = "UTF-8")


# Charlas concertadas

source("3a_procesa_charlas_concertadas.R", encoding = "UTF-8")
#FIXME los nombres de los campos del formulario no coinciden con los de las 
# funciones de procesado de los campos. Se resuelve modificándolos en la hoja 
# de Google pero dará guerra el año que viene también.


source("3b_actualiza_solicitudes_charlas_restantes.R", encoding = "UTF-8")


# Actividades

source("4a_procesa_actividades.R", encoding = "UTF-8")

source("4b_publica_actividades_wordpress.R", encoding = "UTF-8")
#FIXME Falla

source("4c_revisa_actividades.R", encoding = "UTF-8")
source("4d_actualiza_url_wordpress.R", encoding = "UTF-8")


# Actualización web

source("99_genera_html_web.R", encoding = "UTF-8")

# Actualización resúmenes EDA

# https://bookdown.org/yihui/rmarkdown-cookbook/install-latex.html
# tinytex::install_tinytex()

source("99_genera_pdf_eda.R", encoding = "UTF-8")
