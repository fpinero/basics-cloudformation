#!/bin/bash

echo "...creating github-oidc-provider"

# Ejecutar la plantilla CloudFormation para el oidc provider de github
aws cloudformation create-stack --stack-name github-oidc-provider-stack --template-body file://github-oidc-provider.yaml --capabilities CAPABILITY_NAMED_IAM

echo "...waiting for the stack to be created"

# Bucle hasta que la pila esté completamente creada
while true; do
    stack_status=$(aws cloudformation describe-stacks --stack-name github-oidc-provider-stack --query "Stacks[0].StackStatus" --output text)

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
oidc_arn=$(aws cloudformation describe-stacks --stack-name github-oidc-provider-stack --query "Stacks[0].Outputs[?OutputKey=='OIDCProviderArn'].OutputValue" --output text)

# Extraer el dominio del ARN
oidc_domain=$(echo "$oidc_arn" | awk -F'[:/]' '{print $NF}')

# Actualizar la plantilla de rol IAM con el ARN completo
sed -i "s|OIDC_PROVIDER_ARN|$oidc_arn|" role-scheme.yaml

# Actualizar la plantilla de rol IAM con el dominio
sed -i "s|OIDC_PROVIDER_DOMAIN|$oidc_domain|" role-scheme.yaml

