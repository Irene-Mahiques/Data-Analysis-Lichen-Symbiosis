# 1. CARGAMOS LIBRERÍAS
library(readxl)
library(dplyr)
library(stringr)
library(openxlsx)

# 2. LEEMOS Y NORMALIZAMOS
# Cambia "Catálogo.xlsx" por el nombre de tu archivo original
datos <- read_excel("Catálogo.xlsx")

datos_corregidos <- datos %>%
  mutate(
    Biotipo = str_replace_all(Biotipo, "Crustaceo", "Crustáceo"),
    Biotipo = str_replace_all(Biotipo, "Foliaceo", "Foliáceo"),
    Sustrato = str_replace_all(Sustrato, "Terricola", "Terrícola"),
    Sustrato = str_replace_all(Sustrato, "Muscicola", "Muscícola"),
    Sustrato = str_replace_all(Sustrato, "Saxicola", "Saxícola"),
    Sustrato = str_replace_all(Sustrato, "Epifito", "Epífito"),
    Fotobionte = str_replace_all(Fotobionte, "_", " ")
  )

# 3. GENERACIÓN DE CATÁLOGOS FLORÍSTICOS
crear_catalogo <- function(df) {
  df %>%
    group_by(Micobionte) %>%
    summarise(
      Fotobionte = paste(sort(unique(na.omit(Fotobionte))), collapse = ", "),
      Biotipo = paste(sort(unique(na.omit(Biotipo))), collapse = ", "),
      Sustrato = paste(sort(unique(na.omit(Sustrato))), collapse = ", "),
      Reproducción = paste(sort(unique(na.omit(Reproducción))), collapse = ", ")
    ) %>%
    arrange(Micobionte)
}

# Guardar en un Excel con varias pestañas (una por zona)
zonas <- unique(datos_corregidos$Zona)
lista_hojas <- list()
for (z in zonas) {
  lista_hojas[[z]] <- crear_catalogo(filter(datos_corregidos, Zona == z))
}
write.xlsx(lista_hojas, "output/Catalogos_Limpios.xlsx")
