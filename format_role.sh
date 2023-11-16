#!/bin/bash

# Obtener el ARN completo del OIDC provider
oidc_arn=$(aws cloudformation describe-stacks --stack-name [STACK_NAME] --query "Stacks[0].Outputs[?OutputKey=='OIDCProviderArn'].OutputValue" --output text)

# Extraer el dominio del ARN
oidc_domain=$(echo $oidc_arn | awk -F'[:/]' '{print $NF}')

# Actualizar la plantilla de rol IAM con el ARN completo
sed -i "s|OIDC_PROVIDER_ARN|$oidc_arn|" tu_plantilla_rol_iam.yaml

# Actualizar la plantilla de rol IAM con el dominio
sed -i "s|OIDC_PROVIDER_DOMAIN|$oidc_domain|" tu_plantilla_rol_iam.yaml
