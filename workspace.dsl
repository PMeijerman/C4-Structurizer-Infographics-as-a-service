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
            Gebruiker -> this "Vult formulier in"
            ArcGIS -> this "Maakt infographic"
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

        TemplateSysteem = softwareSystem "TemplateSysteem" {
            description "Systeem voor het gebruik van infographic templates"
            medewerker -> this "Selecteerd actieve template"
            this -> AzureQueueTrigger "ophalen actieve infographic"

            database = container "Infographic templates database" {
                description "slaat de infographic templates op"
                tags "database" "OutOfScope"
                this -> AzureApplicatie "ophalen actieve infographic"
            }

            ExperienceBuilder = container "template selector" {
                medewerker -> this "Selecteren actieve infographic"
                this -> database "opslaan actieve infographic"
                tags "OutOfScope"
            }

            DatabaseSyncher = container "Template database syncher" {
                description "Systeem voor het synchroniseren van de template selector en ArcGIS database"
                ArcGIS -> this "ophalen templates"
                this -> database "slaat templates op"
                
                templateHttpTrigger = component "Http trigger" {
                    ExperienceBuilder -> this "Synch templates"
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
            title "Niveau 1"
            include element.type==softwareSystem
            include element.type==person
        }

        container TemplateSysteem {
            title "Template systeem niveau 2"
            include ArcGIS
            include Medewerker
            include TemplateSysteem
            include database
            include DatabaseSyncher
            include ExperienceBuilder
        }

        container ArcGIS_Demo {
            title "ArcGIS Demo niveau 2"
            include element.type==softwareSystem
            include element.type==person
            include element.type==container
        }

        component AzureApplicatie {
            title "Azure applicatie niveau 3"
            include Survey123
            include ArcGIS
            include TemplateSysteem
            include AzureHttpTrigger
            include AzureQueueTrigger
            include AzureQueue
        }

        component DatabaseSyncher {
            title "Database syncher niveau 3"
            include database
            include ArcGIS
            include templateHttpTrigger
            include templateQueueTrigger
            include templateTimerTrigger
            include TemplateQueue
        }

        #region Flowcharts

        dynamic ArcGIS_Demo {
            title "ArcGIS Demo flowchart"
            Gebruiker -> Survey123
            Survey123 -> AzureApplicatie "stuurt aan"
            TemplateSysteem -> AzureApplicatie "Stuurt infographic template"
            ArcGIS -> AzureApplicatie "Maakt infographic"
            AzureApplicatie -> GraphApi "Maakt email"
            GraphApi -> Gebruiker "Stuurt email"
        }

        dynamic TemplateSysteem {
            title "Template systeem flowchart"
            Medewerker -> ArcGIS "Maakt template"
            Medewerker -> ExperienceBuilder "Klikt refresh"
            ExperienceBuilder -> DatabaseSyncher "Stuurt aan"
            ArcGIS -> DatabaseSyncher "Haalt templates op"
            DatabaseSyncher -> database "Slaat templates op"
            Medewerker -> ExperienceBuilder "Selecteerd actieve template"
            ExperienceBuilder -> database "Slaat actieve template op" 
        }

        #endregion
        
        theme default
    }

}