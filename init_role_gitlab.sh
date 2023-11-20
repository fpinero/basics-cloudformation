#!/bin/bash

# Preguntar al usuario si ha configurado correctamente config_script.txt
read -p "Have you correctly specified the values for your project in config_script.txt? (y/n): " answer

# Verificar la respuesta
case $answer in
    [Yy]* )
        echo "Continuing with the script..."
        ;;
    [Nn]* )
        echo "Please configure config_script.txt and rerun the script."
        exit 1
        ;;
    * )
        echo "Please answer yes or no."
        exit 1
        ;;
esac

# Cargar variables del archivo config_script.txt
source config_script.txt

echo "...creating gitlab-oidc-provider"

# Ejecutar la plantilla CloudFormation
stackName=gitlab-oidc-provider-stack-$RANDOM

aws cloudformation create-stack --stack-name $stackName --template-body file://gitlab-oidc-provider.yaml --capabilities CAPABILITY_NAMED_IAM

echo "...waiting for the stack to be created"

# Bucle hasta que la pila esté completamente creada
while true; do
    stack_status=$(aws cloudformation describe-stacks --stack-name $stackName --query "Stacks[0].StackStatus" --output text)

    if [[ $stack_status == "CREATE_COMPLETE" ]]; then
        echo "Stack created successfully."
        break
    elif [[ $stack_status == "CREATE_FAILED" ]]; then
        echo "Stack creation failed."
        exit 1
    else
        echo "Creation in progress..."
        sleep 10
    fi
done

# Obtener el ARN completo del OIDC provider
oidc_arn=$(aws cloudformation describe-stacks --stack-name $stackName --query "Stacks[0].Outputs[?OutputKey=='OIDCProviderArn'].OutputValue" --output text)

# Eliminar el slash final del ARN si está presente
oidc_arn_trimmed=$(echo "$oidc_arn" | sed 's:/$::')

echo OIDC ARN: "$oidc_arn_trimmed"

# Extraer el dominio del ARN
oidc_domain=$(echo "$oidc_arn_trimmed" | awk -F'[:/]' '{print $(NF)}')

echo OIDC DOMAIN: "$oidc_domain"

# Actualizar la plantilla de rol IAM con el ARN completo
sed -i "s|OIDC_PROVIDER_ARN|$oidc_arn_trimmed|" role-scheme.yaml

# Actualizar la plantilla de rol IAM con el dominio
sed -i "s|OIDC_PROVIDER_DOMAIN|$oidc_domain|" role-scheme.yaml

# Sustituir placeholders en la plantilla de rol IAM
sed -i "s|ROLE_NAME_PLACEHOLDER|$ROLE_NAME|" role-scheme.yaml
sed -i "s|PROJECT_PATH_1|$PROJECT_PATH_1|" role-scheme.yaml
sed -i "s|PROJECT_PATH_2|$PROJECT_PATH_2|" role-scheme.yaml
sed -i "s|PROJECT_PATH_3|$PROJECT_PATH_3|" role-scheme.yaml

# Reemplazar el placeholder BUCKET_NAME_PLACEHOLDER con el valor de BUCKET_NAME
sed -i "s|BUCKET_NAME_PLACEHOLDER|$BUCKET_NAME|" bucket-schema.yaml

echo
echo creating role in your AWS account "$ROLE_NAME"

# Ejecutar la plantilla CloudFormation para crear el rol
aws cloudformation create-stack --stack-name my-role-management-stack-$RANDOM --template-body file://role-scheme.yaml --capabilities CAPABILITY_NAMED_IAM
