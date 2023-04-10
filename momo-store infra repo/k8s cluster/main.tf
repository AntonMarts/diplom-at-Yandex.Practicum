terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

# Set configuration for Object Storage for Terraform state tf files
# Описание настроек для сохранение состояний Terraform в объектном хранилище 

  backend "s3" {
    endpoint   = "storage.yandexcloud.net"  
    bucket     = "tf-state-bucket-amarts"                   # <имя бакета>
    region     = "ru-central1"
    key        = "k8-kluster.tfstate"                       # <путь к файлу состояния в бакете>/<имя файла состояния>.tfstate
    access_key = ""                                         # <идентификатор статического ключа>
    secret_key = ""                                         # <секретный ключ>

    skip_region_validation      = true
    skip_credentials_validation = true
  }


  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}