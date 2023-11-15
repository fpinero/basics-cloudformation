## Notas sobre la sección AssumeRolePolicyDocument

```yaml
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: 'Allow'
            Principal:
              Federated: 'arn:aws:iam::<id-de-aws>:oidc-provider/<proveedor-oidc>'
            Action: 'sts:AssumeRoleWithWebIdentity'
            Condition:
              StringEquals:
                '<proveedor-oidc>:sub': 'repo:<repositorio-de-github/gitlab>:ref:refs/heads/<la-rama>'
```

`<id-de-aws>`: Este es el ID de cuenta de AWS. <br/>
`<proveedor-oidc>`: Aquí hay que poner la URL del proveedor OIDC de GitLab o GitHub. Por ejemplo, para GitHub Actions, 
sería algo como token.actions.githubusercontent.com. <br/>
`<repositorio-de-github/gitlab>`: El nombre del repositorio en GitHub o GitLab. <br/>
`<la-rama>`: La rama específica en el repositorio para la cual queremos permitir que el rol sea asumido. <br/>
<br/>
* La condición StringEquals en Condition es especialmente importante, ya que asegura que solo los procesos de CI/CD que 
se ejecutan en la rama específica del repositorio puedan asumir este rol. 
Esto añade una capa de seguridad, asegurando que solo los procesos autorizados tengan acceso a los recursos de AWS.

## ¿Cómo ejecutar el fichero cloudFormation?

```commandline
aws cloudformation create-stack --stack-name MiStackDeIAM --template-body file://role-s3.yaml --capabilities CAPABILITY_NAMED_IAM
```
En este comando:

`--stack-name MiStackDeIAM`: Es el nombre que le das a la pila de CloudFormation. Se puede elegir cualquier nombre que sea único 
dentro de la cuenta de AWS. <br/>
`--template-body file://role-s3.yaml`: Especifica la ruta local al archivo de plantilla de CloudFormation. <br/>
`--capabilities CAPABILITY_NAMED_IAM`: Este parámetro es necesario porque la plantilla está creando un recurso IAM (en este caso, un rol). 
AWS requiere que especifiques explícitamente esta capacidad para crear o actualizar recursos IAM a través de CloudFormation. <br/>

Hay que asegurarse de tener configurado el AWS CLI con las credenciales y la región adecuadas antes de ejecutar este comando. 

## Comprobar que el rol se ha creado correctamente

Este comando devolverá información detallada sobre el rol si existe. Si el rol no existe, 
recibirás un mensaje de error indicando que el rol no se puede encontrar.

```shell
aws iam get-role --role-name <nombre-del-rol>>

aws iam get-role --role-name S3BucketManagementRole
```

Si solo quieres verificar la existencia del rol sin necesidad de toda la información detallada, 
podemos usar el comando list-roles y filtrar los resultados. Por ejemplo:

```shell
aws iam list-roles | grep <nombre-del-rol>

aws iam list-roles | grep S3BucketManagementRole
```

