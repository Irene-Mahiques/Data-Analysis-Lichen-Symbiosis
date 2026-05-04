# 1. LIBRERÍAS
library(readxl)
library(dplyr)
library(stringr)
library(openxlsx)

# 2. CONFIGURACIÓN DE CARPETAS
if (!dir.exists("output")) dir.create("output")

# 3. PROCESO DE CURACIÓN TAXONÓMICA
# Nota: Este script requiere un archivo 'Catálogo.xlsx' en la raíz.
tryCatch({
  datos <- read_excel("Catálogo.xlsx")
  
  datos_corregidos <- datos %>%
    mutate(
      Biotipo = str_replace_all(Biotipo, c("Crustaceo"="Crustáceo", "Foliaceo"="Foliáceo")),
      Sustrato = str_replace_all(Sustrato, c("Terricola"="Terrícola", "Muscicola"="Muscícola", 
                                             "Saxicola"="Saxícola", "Epifito"="Epífito")),
      Fotobionte = str_replace_all(Fotobionte, "_", " ")
    )
  
  # Exportación de catálogo limpio
  write.xlsx(datos_corregidos, "output/Catalogos_Corregidos.xlsx")
  message("Curación completada con éxito.")
}, error = function(e) {
  message("Aviso: Archivo de datos no encontrado para ejecución local.")
})
