workspace {

    model {
        Gebruiker = person "Gebruiker" {
            tags "OutOfScope"
        }

        Medewerker = person "Esri medewerker" {
            tags "OutOfScope"
        }

        GraphApi = softwareSystem "Graph API" {
            this -> gebruiker "Stuurt email"
            tags "OutOfScope"
        }

        ArcGIS = softwareSystem "ArcGIS API" {
            description "GIS data systeem ook gebruikt voor het opslaan van infographic templates"
            Medewerker -> this "Maakt infographic templates"
            tags "OutOfScope"
        }

        ArcGIS_Demo = softwareSystem "ArcGIS Demo" {
            Gebruiker -> this
            Medewerker -> this "Selecteerd infographic template"
            ArcGIS -> this
            this -> GraphApi "Maakt email"

            Survey123 = container "Survey123" {
                description "Creeren en publiceren van formulieren"
                gebruiker -> this "Vult in"
                tags "OutOfScope"
            }

            AzureApplicatie = container "Azure applicatie" {
                description "Applicatie die gebruiker data omzet en doorstuurt"
                Survey123 -> this "Stuurt data door naar"
                this -> GraphApi "Stuurt email data naar"
                ArcGIS -> this "maken infographic"
                AzureHttpTrigger = component "Http trigger"{
                    Survey123 -> this "Stuurt aan"
                }

                AzureQueue = component "Queue" {
                    AzureHttpTrigger -> this "Stuurt infographic request"
                }

                AzureQueueTrigger = component "Queue trigger" {
                    AzureQueue -> this "Stuurt aan"
                    ArcGIS -> this "Maken infographic"
                }

            }

        }

        TemplateSystem = softwareSystem "TemplateSysteem" {
            description "Systeem voor het gebruik van infographic templates"
            medewerker -> this "Selecteerd actieve template"
            this -> AzureQueueTrigger "ophalen actieve infographic"

            database = container "Infographic templates database" {
                description "slaat de infographic templates op"
                tags "database" "OutOfScope"
                this -> AzureApplicatie "ophalen actieve infographic"
                medewerker -> this "Selecteren actieve infographic"
            }

            DatabaseSyncher = container "Template database syncher" {
                description "Systeem voor het synchroniseren van de template selector en ArcGIS database"
                ArcGIS -> this "ophalen templates"
                this -> database "slaat templates op"
                
                templateHttpTrigger = component "Http trigger" {

                }

                templateTimerTrigger = component "Timer trigger" {

                }

                TemplateQueue = component "Queue" {
                    templateHttpTrigger -> this "Stuurt record"
                    templateTimerTrigger -> this "Stuurt record"
                    tags "database"
                }

                templateQueueTrigger = component "Queue trigger" {
                    this -> database "Opslaan templates"
                    ArcGIS -> this "Ophalen templates"
                    TemplateQueue -> this "stuurt aan"
                }



            }

            ExperienceBuilder = container "Infographic selector" {
                medewerker -> this "Selecteren actieve infographic"
                this -> database "opslaan actieve infographic"
                tags "OutOfScope"
            }
        }



    }

    views {
        styles {
            element "OutOfScope" {
                background #949494
            } 
            element "database"{
                shape cylinder
            }
        }

        systemContext ArcGIS_Demo {
            include element.type==softwareSystem
            include element.type==person
            default
        }

        container TemplateSystem {
            include ArcGIS
            include Medewerker
            include TemplateSystem
            include database
            include DatabaseSyncher
            include ExperienceBuilder
        }

        component AzureApplicatie {
            include Survey123
            include ArcGIS
            include TemplateSystem
            include AzureHttpTrigger
            include AzureQueueTrigger
            include AzureQueue
        }

        component DatabaseSyncher {
            include database
            include ArcGIS
            include templateHttpTrigger
            include templateQueueTrigger
            include templateTimerTrigger
            include TemplateQueue
        }

        container ArcGIS_Demo {
            include element.type==softwareSystem
            include element.type==person
            include element.type==container
        }

        
        theme default
    }

}