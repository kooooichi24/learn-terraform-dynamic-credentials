# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "azurerm" {
  features {}
}

provider "azuread" {}

data "azurerm_subscription" "current" {}
data "azuread_application_published_app_ids" "well_known" {}

resource "azuread_service_principal" "msgraph" {
  application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing   = true
}

resource "azuread_application" "tfc_application" {
  display_name = "tfc-application"

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    resource_access {
      id   = azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.All"]
      type = "Role"
    }
  }
}

resource "azuread_service_principal" "tfc_service_principal" {
  application_id = azuread_application.tfc_application.application_id
}

resource "azuread_application_federated_identity_credential" "tfc_federated_credential_plan" {
  application_object_id = azuread_application.tfc_application.object_id
  display_name          = "my-tfc-federated-credential-plan"
  audiences             = [var.tfc_azure_audience]
  issuer                = "https://${var.tfc_hostname}"
  subject               = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:plan"
}

resource "azuread_application_federated_identity_credential" "tfc_federated_credential_apply" {
  application_object_id = azuread_application.tfc_application.object_id
  display_name          = "my-tfc-federated-credential-apply"
  audiences             = [var.tfc_azure_audience]
  issuer                = "https://${var.tfc_hostname}"
  subject               = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:apply"
}

resource "azurerm_role_assignment" "tfc_role_assignment" {
  scope                = data.azurerm_subscription.current.id
  principal_id         = azuread_service_principal.tfc_service_principal.object_id
  role_definition_name = "Contributor"
}

resource "azuread_app_role_assignment" "tfc_app_role_assignment" {
  app_role_id         = azuread_service_principal.msgraph.app_role_ids["Application.ReadWrite.All"]
  principal_object_id = azuread_service_principal.tfc_service_principal.object_id
  resource_object_id  = azuread_service_principal.msgraph.object_id
}
