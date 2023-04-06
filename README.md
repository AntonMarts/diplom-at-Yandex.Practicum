# Дипломный проект 
###  курса Яндекс Практикум: DevOps для эксплуатации и разработки

![Яндекс](https://user-images.githubusercontent.com/106011284/230385089-99d0ed66-9854-41b6-a57c-8dfac54279a0.svg)![Практикум](https://user-images.githubusercontent.com/106011284/230385205-fcfa20fe-532f-4c5c-9477-5a3dd609aad3.svg)



_**Задачи проекта**_: 

- Реализовать цикл сборки и поставки приложения в `GitlabCI`
- Построить кластер `Kubernetes` в `Яндекс Облаке`
- Развернуть инфраструктуру приложения в данном кластере 
- Настроить автоматизированную доставку приложения на основе `ArgoCD`
- Настроить систему мониторинга инфраструктуры и приложения на основе `Prometheus+Grafana`

## Структура проекта

- Проект разделен на 2 репозитория:
1.  Репозиторий с кодом приложения
  MOMO-STORE CODE REPO
  ├───backend 
  └───frontend
2. Репозиторий с Helm charts инфраструктуры приложения
 MOMO-STORE INFRA REPO
├───charts
│   ├───apps
│   ├───argo-cd
│   ├───backend
│   ├───frontend
│   ├───grafana
│   ├───prometheus
│   ├───secret
│   └───yc-alb-ingress-controller-chart
├───k8s cluster
└───values        



## Реализация цикла CI/CD приложения

В репозитории с кодом приложения реализован цикл сборки, тестирования и доставки артефактов приложения в репозиторий. В `GitlabCI` организован pipeline в котором присутствуют данные этапы:
![pipeline](https://user-images.githubusercontent.com/106011284/230436445-e217fefc-1194-47d7-9d77-c552ce73ac29.png)
* **Build** - сборка артефактов приложения и сборка `Docker` образов. Артефакты после сборки тегируются и загружаются в `Nexus repository`
![nexus_back](https://user-images.githubusercontent.com/106011284/230437588-76fe7282-1a80-491b-9409-fc27817ada13.png)
* **Test** - Проверка кода. Реализовано тестирование SAST и тесты `Sonarqube`
![sonarqube](https://user-images.githubusercontent.com/106011284/230437665-6172f684-e915-45c5-99d4-bb995f7e3971.png)
* **Release** - После успешной проверки `Docker` образы тэгируются и загружаются в `Gitlab Container Registry`
![Container registry](https://user-images.githubusercontent.com/106011284/230439989-55980cc8-944d-4d9d-a04f-83b2d8a03ded.png)
* Для запуска приложения в тестовом окружении реализован manual deploy средствами `Docker compose`

### Installation

Для тестирования приложения на localhost:

#### Frontend

```bash
npm install
NODE_ENV=production VUE_APP_API_URL=http://localhost:8081 npm run serve
```

#### Backend

```bash
go run ./cmd/api
go test -v ./... 
```
## Организация инфраструктуры приложения

Для организации инфраструктуры приложения создан кластер Kubernetes в Яндекс Облаке:
![ycloud](https://user-images.githubusercontent.com/106011284/230447047-8d8b05d7-de1a-4521-9bb3-00c2c74baa09.png)

* Кластер создается при помощи конфигураций `Terraform`. Файлы состояния `Terraform` загружаются  в _Object Storage_ (данные файлы находятся в папке k8s cluster репозитория инфраструктуры)
* Приложения кластера описаны в `Helm` чартах в инфраструктурном репозитории (папка charts). Данные чарты версионируются по **SemVer** и загружаются в `Nexus Repository`.
![nexus_helm](https://user-images.githubusercontent.com/106011284/230458400-cf54efdf-b6d4-4047-bce0-984c99ef8d07.png)

## Реализация автоматизированной доставки приложения

Для автоматизации доставки приложения в production среду был выбран инструмент GitOps `ArgoCD`
![argocd_example](https://user-images.githubusercontent.com/106011284/230452142-958b4f3e-3940-4d4f-8b59-7cb659e82858.png)
`ArgoCD` настроен на синхронизацию изменения репозитория инфраструктуры приложения. После внесения изменений в репозиторий с кодом приложения запускается pipeline `GitlabCI` и обновляются `Docker` образы приложения. Пользователь вносит изменения в инфраструктурный репозиторий, после чего `ArgoCD` запускает синхоронизацию манифестов `Kubernetes` и вносит необходимые изменения при помощи обновления `Helm charts` инфраструктуры. 
Мы можем создавать приложения в `ArgoCD`, добавляя новые манифесты _Application_. Чтобы не делать это вручную и придерживаться подхода _IaC_ используется паттерн  [Aps of Aps](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/). Его суть — создать приложение, которое создаёт другие приложения. 

![aps of aps](https://user-images.githubusercontent.com/106011284/230456135-d7cf5c23-f9f4-4f20-b26a-26f16c5c2ce0.png)


>**Теперь для любого нового приложения необходимы следующие действия:**
> Добавить чарт приложения в папку charts
> Добавить Namespace и Application в templates чарта apps
> Добавить values-файл для развёртывания

Пользуясь данным паттерном на кластере установлены компоненты инфраструктуры и само приложение.
![k9s](https://user-images.githubusercontent.com/106011284/230458347-7b5d4445-406b-4b5f-8979-a3e489773b78.png)
## Мониторинг

Кластер мониторится связкой дыух приложений `Grafana` и `Prometheus`. `Prometheus` снимает метрики с компонентов кластера и приложений, `Grafana` визуализирует эти данные в графическом интерфейсе и представляет их в виде удоьно настраиваемых дашбордов. Так же есть возможность подключения системы оповещений на основе `Prometheus Alert Manager`.
![prometheus](https://user-images.githubusercontent.com/106011284/230458451-170aedab-30c6-4ec2-bc19-cdaae4d4d9bd.png)
![garfana](https://user-images.githubusercontent.com/106011284/230458438-fbe108cb-5dae-4395-8344-c3b0d5c9f7a6.png)

## Доступ к ресурсам инфраструктуры и приложению



Создан домен martsinovskiy.ru, выпущен сертификат **SSL** на _Let's Encrypt_. Сертификат внесен в `Certificate Manager` **Яндекс Облака**. Всем необходимым компонентам при помощи `Yandex Application Load Balancer` присвоено доменное имя:

ArgoCD - argocd.infra.martsinovskiy.ru
Grafana - grafana.infra.martsinovskiy.ru
Prometheus - prometheus.infra.martsinovskiy.ru
frontend приложения - momo-store.martsinovskiy.ru
> Кластер был создан на временных ресурсах Яндекс Облака, выделенных на время прохождения курса. На текущий момент все ресурсы удалены и нет возможности пройти по указанным ссылкам

![main page](https://user-images.githubusercontent.com/106011284/230461373-bafb7239-8001-48b5-be0f-566130da1c48.png)




