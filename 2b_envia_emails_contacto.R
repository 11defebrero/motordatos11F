library(formularios11F)
library(dplyr)


# Configuración

config <- leer_config("config/config.json")

ID_SHEET_CONTACTOS_LIMPIO <- config$ids_googledrive$contactos$limpio
ID_SHEET_CONTACTOS_ENVIADO <- config$ids_googledrive$contactos$enviado

CUENTA_ENVIO_EMAILS <- config$email_envios

MAX_ENVIOS_DIARIOS <- 400


# Autenticación cuenta Gmail

gmail_acceso("config/gmail_credentials.json")


# Filtrar peticiones de contacto con centros pendientes de gestionar

contactos_limpio <- get_contactos_centros_limpio(file_id=ID_SHEET_CONTACTOS_LIMPIO)

contactos_limpio_filtrado <- contactos_limpio %>%
  filter(procesado %in% c("OK", "CORREGIDO", "ERROR"))

contactos_revisados <- get_contactos_centros_limpio(file_id=ID_SHEET_CONTACTOS_LIMPIO) %>%
  filter(procesado %in% "REVISADO")

contactos_enviado <- get_contactos_centros_limpio(file_id=ID_SHEET_CONTACTOS_ENVIADO)

contactos_pendientes <- contactos_limpio_filtrado %>%
  filter(! id %in% contactos_enviado$id) %>%
  rbind(contactos_revisados)

if (nrow(contactos_pendientes) == 0) {
  stop("No hay contactos con centros pendientes de gestionar.")
}


# Recuento nº mails enviados hoy

total_enviados <- sum(startsWith(contactos_enviado$procesado, format(Sys.Date(), format="%d/%m/%Y")))


# Enviar emails de peticiones de contacto no válidas

for (i in which(contactos_pendientes$procesado == "ERROR")) {

  if (total_enviados >= MAX_ENVIOS_DIARIOS) {
    break # Se sigue ejecutando el script para subir los datos actualizados
  }

  gmail_envia_email(
    to = contactos_pendientes$email[i],
    from = CUENTA_ENVIO_EMAILS,
    reply_to = contactos_pendientes$email[i],
    subject = "Datos incorrectos en formulario de contacto",
    body = paste0(
      "Hola,\n\n",
      "Gracias por interesarte en la iniciativa 11 de Febrero e intentar contactar con un centro educativo. ",
      "Lamentablemente, el número de solicitud o el nombre de centro que has introducido no es válido. ",
      "Puedes verlos más abajo.\n\n",
      "Por favor, vuelve a consultar la tabla y a rellenar de nuevo el formulario con los datos correctos. Gracias.\n",
      "\nCordialmente,\n",
      "El equipo de coordinación de 11 de Febrero",
      "\n\n-------------------------\n\n",
      texto_email_fallo(contactos_pendientes[i,])
    )
  )

  contactos_pendientes$validacion[i] <- contactos_pendientes$procesado[i]
  contactos_pendientes$procesado[i] <- format(Sys.time(), format="%d/%m/%Y %T")

  total_enviados <- total_enviados + 1

  Sys.sleep(1)

}


# Enviar emails de peticiones de contacto válidas

for (i in which(contactos_pendientes$procesado != "ERROR")) { # es decir: OK, CORREGIDO o REVISADO

  if (total_enviados >= MAX_ENVIOS_DIARIOS) {
    break # Se sigue ejecutando el script para subir los datos actualizados
  }

  gmail_envia_email(
    to = contactos_pendientes$email_centro[i],
    from = CUENTA_ENVIO_EMAILS,
    reply_to = contactos_pendientes$email[i],
    subject = "Te ha llegado un mensaje por tu solicitud de charla/taller para el 11F",
    body = paste0(
      "Hola,\n\n",
      "Te ha llegado un mensaje relativo a tu solicitud de una charla o taller en la Iniciativa 11 de Febrero.\n\n",
      "Por favor, escribe a la mayor brevedad a la persona que te ha contactado para impartir la charla. ",
      "Es con ella con quien debes tener la comunicación a partir de ahora. ",
      "Tienes sus datos de contacto junto al mensaje que te ha escrito más abajo.\n\n",
      "En caso de que concertéis la charla, por favor, pedid a la ponente que nos haga llegar la información ",
      "a través del siguiente enlace: https://11defebrero.org/quieres-anunciar-una-charla-o-actividad\n\n",
      "Al responder a este mensaje estarás escribiendo a quien te contactó, y no a la iniciativa 11F.\n\n",
      "En caso de que tengas que contactar con 11deFebrero pincha aquí: https://11defebrero.org/contacto\n",
      "\nCordialmente,\n",
      "El equipo de coordinación de 11 de Febrero",
      "\n\n-------------------------\n\n",
      texto_email_contacto(contactos_pendientes[i,])

    )
  )

  contactos_pendientes$procesado[i] <- format(Sys.time(), format="%d/%m/%Y %T")

  total_enviados <- total_enviados + 1

  Sys.sleep(1)

}

# Subir a Google Drive

contactados <- contactos_pendientes %>%
  rbind(contactos_enviado) %>%
  arrange(procesado)

upload_contactos_centros_limpio(contactados, file_id=ID_SHEET_CONTACTOS_ENVIADO)

contactos_limpio[contactos_limpio$procesado == "REVISADO", "procesado"] <- "REENVIADO"
upload_contactos_centros_limpio(contactos_limpio, file_id=ID_SHEET_CONTACTOS_LIMPIO)


# Aviso alcanzado el máximo de mails enviados

if (total_enviados >= MAX_ENVIOS_DIARIOS) {
  stop(paste(
    "Se ha alcanzado el límite diario de envíos.",
    "La hoja de enviados se ha actualizado con los que han entrado dentro del cupo.",
    "Ejecuta de nuevo mañana para enviar los mails restantes.",
    "Cuidado con los REENVIADOS, es posible que se hayan quedado sin enviar,",
    "compruébalo en la hoja de enviados."
  ))
}

