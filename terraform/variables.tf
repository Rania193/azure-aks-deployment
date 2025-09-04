variable "prefix" {
    type = string 
    default = "msvc" 
}

variable "location" { 
    type = string 
    default = "westeurope" 
}

variable "resource_group_name" { 
    type = string 
    default = "rg-microservices" 
}

variable "acr_name" { 
    # must be globally unique, 5-50 lowercase alnum
    type = string
    default = "acrmsvc012345"
}


variable "aks_name" { 
    type = string 
    default = "aks-microservices" 
}

variable "node_count" { 
    type = number 
    default = 1
}

variable "node_vm_size" { 
    type = string 
    default = "Standard_B2ms" 
}

variable "kubernetes_version" { 
    type = string 
    default = null 
}