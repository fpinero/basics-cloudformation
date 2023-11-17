#!/bin/bash

echo "...creating gitlab-oidc-provider"

# Ejecutar la plantilla CloudFormation
aws cloudformation create-stack --stack-name gitlab-oidc-provider-stack --template-body file://gitlab-oidc-provider.yaml --capabilities CAPABILITY_NAMED_IAM

echo "...waiting for the stack to be created"

# Bucle hasta que la pila esté completamente creada
while true; do
    stack_status=$(aws cloudformation describe-stacks --stack-name gitlab-oidc-provider-stack --query "Stacks[0].StackStatus" --output text)

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
oidc_arn=$(aws cloudformation describe-stacks --stack-name gitlab-oidc-provider-stack --query "Stacks[0].Outputs[?OutputKey=='OIDCProviderArn'].OutputValue" --output text)

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

# lancemos la plantilla que crea el rol con la trust entity

