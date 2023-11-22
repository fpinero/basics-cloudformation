## Crear un Archivo .env

En el repo, creamos un archivo .env en el directorio raíz o en un lugar específico donde queramos mantener 
las configuraciones. En este archivo, definimos las variables de entorno. Por ejemplo:

```
BUCKET_NAME=my-s3-bucket-name
```

## Configurar GitHub Secrets

Es importante no colocar directamente los archivos .env en el control de versiones si contienen información 
sensible. En lugar de eso, podemos almacenar el contenido del archivo .env como un secreto en GitHub.
<br/>
Por ejemplo, podemos crear un secreto llamado DOTENV y colocar el contenido del archivo .env allí.

## Utilizar dotenv-action en tu Flujo de Trabajo

En el archivo de flujo de trabajo de GitHub Actions, podemos usar dotenv-action para cargar las variables de entorno. 
Primero, debemos agregar un paso para cargar las variables antes de ejecutar los pasos que dependen de ellas.

Ejemplo de cómo incluir dotenv-action:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2

    # Cargar variables de entorno desde el secreto
    - name: Load .env from secret
      uses: SpicyPizza/create-envfile@v1
      with:
        envkey_DOTENV: ${{ secrets.DOTENV }}
        file_name: .env

    # Ejemplo de paso que usa la variable de entorno
    - name: Deploy to AWS CloudFormation
      uses: aws-actions/aws-cloudformation-github-deploy@v1
      with:
        name: MyS3BucketStack
        template: bucket-schema_org.yaml
        parameter-overrides: |
          BucketName=${{ env.BUCKET_NAME }}
```

* Rápida explicación:

Explicación:
**Paso de `dotenv-action`**: Este paso utiliza la acción SpicyPizza/create-envfile, que toma el contenido del secreto 
DOTENV y lo escribe en un archivo .env. Luego, este archivo se utiliza para configurar las variables de entorno 
para los pasos subsiguientes.<br/>
**Usar la Variable en Pasos Posteriores**: Después de cargar las variables, podemos usar `BUCKET_NAME` y cualquier 
otra variable definida en el archivo `.env` 
<br/><br/>
Este enfoque permite manejar configuraciones específicas de cada proyecto de manera segura y eficiente, 
manteniendo la flexibilidad y la separación entre la definición de la infraestructura y los valores que pueden 
variar entre diferentes entornos o proyectos.

# En caso de no querer usar Secrets de Github

* Si el nombre del bucket S3 no es una información sensible y no necesita ser tratado como un secreto de GitHub, 
podemos optar por incluir el archivo `.env` directamente en el repositorio. <br/>
Esto simplifica el proceso, ya que no es necesario manejar secretos de GitHub.


# Pasos para Utilizar .env en GitHub Actions:

* Incluir `.env` en el Repositorio:

  * Agregar el archivo `.env` al repositorio en la ubicación que se prefiera. Por ejemplo, en la raíz del proyecto.
  * Asegurarse de que el archivo `.env` solo contenga información que sea segura para compartir públicamente.
  * Podemos utilizar un archivo `.env.example` como plantilla para las variables de entorno, y luego copiarlo a 
un archivo .env en nuestro entorno local o de CI/CD para configurar los valores reales.

* Usar el Archivo `.env` en GitHub Actions:

  * Podemos utilizar una acción como `dotenv-action` para cargar automáticamente las variables de entorno desde 
el archivo .env.
  * Alternativamente, podemos cargar manualmente las variables de entorno en el flujo de trabajo de GitHub Actions.

# Ejemplo de GitHub Actions Utilizando .env:

Ejemplo de cómo configurar el flujo de trabajo para utilizar el archivo .env (sin hacer uso de la action `dotenv-action`:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2

    # Cargar variables de entorno desde .env
    - name: Load Environment Variables
      run: |
        set -a
        . ./vars.env
        set +a

    # Ejemplo de paso que usa la variable de entorno
    - name: Deploy to AWS CloudFormation
      uses: aws-actions/aws-cloudformation-github-deploy@v1
      with:
        name: MyS3BucketStack
        template: bucket-schema_org.yaml
        parameter-overrides: |
          BucketName=${{ env.BUCKET_NAME }}
```

* Ejemplo de cómo configurar el flujo de trabajo para utilizar el archivo .env (haciendo uso de la action `dotenv-action`:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2

    # Cargar variables de entorno desde .env usando dotenv-action
    - name: Load Environment Variables
      uses: falti/dotenv-action@v2
      with:
        path: .env

    # Ejemplo de paso que usa la variable de entorno
    - name: Deploy to AWS CloudFormation
      uses: aws-actions/aws-cloudformation-github-deploy@v1
      with:
        name: MyS3BucketStack
        template: bucket-schema_org.yaml
        parameter-overrides: |
          BucketName=${{ env.BUCKET_NAME }}
```

* Nota: 
`path`: Aquí se especifica la ruta del archivo `.env`. Si está en la raíz del repositorio, simplemente se usa `.env`.

