# ==========================================================
# SCRIPT 1: LIMPIEZA Y GENERACIÓN DE CATÁLOGOS
# ==========================================================

# 1. CARGAMOS LIBRERÍAS
library(readxl)
library(dplyr)
library(stringr)
library(openxlsx)

if (!dir.exists("output")) dir.create("output")

# 2. LEER BASE DE DATOS
# Cambia "Catálogo.xlsx" por el nombre de tu archivo original
datos <- read_excel("data/Catálogo.xlsx")

# 3. LIMPIEZA ORTOGRÁFICA UNIFICADA
datos_corregidos <- datos %>%
  mutate(
    Biotipo = str_replace_all(Biotipo, c("Crustaceo"="Crustáceo", "Foliaceo"="Foliáceo")),
    Sustrato = str_replace_all(Sustrato, c("Terricola"="Terrícola", "Muscicola"="Muscícola", 
                                           "Saxicola"="Saxícola", "Epifito"="Epífito")),
    Fotobionte = str_replace_all(Fotobionte, "_", " ")
  )

# 4. FUNCIÓN PARA COLAPSAR REGISTROS POR MICOBIONTE
crear_catalogo_global <- function(df) {
  df %>%
    group_by(Micobionte) %>%
    summarise(
      Fotobionte = paste(sort(unique(na.omit(Fotobionte))), collapse = ", "),
      Biotipo = paste(sort(unique(na.omit(Biotipo))), collapse = ", "),
      Sustrato = paste(sort(unique(na.omit(Sustrato))), collapse = ", "),
      Reproducción = paste(sort(unique(na.omit(Reproducción))), collapse = ", "),
      Zonas = paste(sort(unique(na.omit(Zona))), collapse = ", ")
    ) %>%
    arrange(Micobionte)
}

# 5. GUARDAR CATÁLOGO
catalogo_final <- crear_catalogo_global(datos_corregidos)
write.xlsx(catalogo_final, "output/Catalogo_Floristico_TFG.xlsx")
