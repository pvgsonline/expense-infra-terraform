variable "common_tags"{
    default = {
        Project = "Expense"
        Environemnt = "Dev"
        Terraform = true

    }
}

variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}