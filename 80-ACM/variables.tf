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


variable "zone_name"{
    default = "pvgs.online"
}

variable "zone_id"{
    default = "Z0374240SJG94LFMUIHX"
}




