# Ficheros de configuración

La carpeta `config/` se usa para los ficheros de configuración del motor, que no deben subirse a Github.

Son dos ficheros:

- `config.json`: configuración general del motor (IDs de las hojas de GoogleDrive, credenciales de Wordpress, ...). El formato que debe tener este fichero es el siguiente:

```

{
    "edicion": "2021",
    "email_envios": "xxxx@xxxx.com",
    "ids_googledrive": {
        "solicitudes": {
            "original": "xxxx",
            "limpio": "xxxx",
            "restantes": "xxxx"
        },
        "contactos": {
            "original": "xxxx",
            "limpio": "xxxx",
            "enviado": "xxxx"
        },
        "concertadas": {
            "original": "xxxx",
            "limpio": "xxxx"
        },
        "actividades": {
            "original": "xxxx",
            "limpio": "xxxx",
            "wordpress": "xxxx"
        },
        "codpostales": "xxxx",
        "carpeta_eda": "xxxx"
    },
    "wordpress": {
        "url": "xxxx",
        "user": "xxxx",
        "password": "xxxx"
    }
}

```


- `gmail_credentials.json`: credenciales de Gmail necesarios para enviar emails. Este fichero se genera automáticamente desde [aquí](https://developers.google.com/gmail/api/quickstart/python#step_1_turn_on_the).
