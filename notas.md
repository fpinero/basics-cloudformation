## cómo obtener los valores para los parámetros Url y ThumbprintList para un archivo CloudFormation.

### Obtener la URL del Proveedor OIDC

* Para el valor de Url:

Si estás usando GitHub Actions como CI/CD, la URL generalmente es `https://token.actions.githubusercontent.com`.
Para GitLab, la URL depende de si se está usando GitLab.com o una instancia autoalojada. 
Por ejemplo, para GitLab.com, sería algo como `https://gitlab.com`.

## IMPORTANTE

**Para la configuración del proveedor OIDC en AWS CloudFormation, lo que necesitamos es la URL base del proveedor OIDC, 
no la URL específica de un repositorio individual**

* Razón Detrás de Esto
  * El proveedor OIDC se utiliza para establecer la confianza a nivel de la instancia de GitLab en su conjunto, no para un repositorio individual.
  * Cuando configuras un proveedor OIDC en AWS, estás permitiendo que AWS confíe en los tokens emitidos por este proveedor para toda la instancia.
  * La URL específica del repositorio no es relevante para la configuración del proveedor OIDC, ya que los tokens de acceso 
    y las políticas relacionadas no están ligadas a un solo repositorio, sino que son aplicables a nivel de instancia o de usuario en GitLab.

Por lo tanto, en la plantilla CloudFormation para AWS, debemos utilizar:

* GitLab
```yaml
Url: https://code.roche.com/
```

* Github
```yaml
Url: https://token.actions.githubusercontent.com
```

## Obtener el Valor de ThumbprintList

* El valor de ThumbprintList es un poco más complejo. Se refiere a una lista de huellas digitales de certificados 
(thumbprints) que se utilizan para validar los JWT (JSON Web Tokens) emitidos por el proveedor OIDC. 
esta es una forma de obtenerlos:

 - Extraer los Certificados SSL del Proveedor OIDC:

   * Podemos usar herramientas como openssl para extraer los certificados. Por ejemplo, para GitHub, 
     el comando sería algo así:
```shell
openssl s_client -showcerts -connect token.actions.githubusercontent.com:443 </dev/null 2>/dev/null | openssl x509 -outform PEM
```

 - Calcular el Thumbprint del Certificado:

    * Una vez que tengas el certificado, puedes calcular el thumbprint (SHA-1). Con openssl, sería:
```shell
openssl x509 -in certificate.pem -noout -fingerprint -sha1
```
Este comando proporcionará el thumbprint del certificado, donde hay que eliminar los dos puntos (:) y 
convertir a minúsculas para usar en la plantilla CloudFormation.

## Pasos a realizar para automatizar la obtención del Thumbprint e inyectarlo en el fichero cloudFront

* Obtener el Thumbprint de Github:
```commandline
thumbprint=$(echo | openssl s_client -servername token.actions.githubusercontent.com -connect token.actions.githubusercontent.com:443 2>/dev/null | openssl x509 -fingerprint -sha1 -noout | cut -d '=' -f2 | sed 's/://g' | tr '[:upper:]' '[:lower:]')
```

* * Obtener el Thumbprint de Gitlab:
```shell
thumbprint=$(echo | openssl s_client -servername code.roche.com -connect code.roche.com:443 2>/dev/null | openssl x509 -fingerprint -sha1 -noout | cut -d '=' -f2 | sed 's/://g' | tr '[:upper:]' '[:lower:]')
```

* Modificar la Plantilla CloudFormation:
```shell
sed -i "s/thumbprint_a_incluir/$thumbprint/" oidc.yaml
```
(Asegurarse que el valor thumbprint_a_incluir en el comando sed coincide exactamente con el placeholder en la plantilla.)

## Nombre del OIDC provider en AWS

Es importante mencionar que no se puede asignar un nombre "amigable" o fácilmente reconocible al proveedor OIDC 
en AWS a través de CloudFormation. <br/>
La plantilla solo define la configuración del proveedor OIDC, y el nombre o identificador asignado será un ARN 
generado automáticamente por AWS.
