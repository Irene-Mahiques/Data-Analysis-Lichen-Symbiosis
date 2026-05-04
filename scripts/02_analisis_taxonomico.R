# ==========================================================
# SCRIPT 2: VISUALIZACIÓN DE DIVERSIDAD TAXONÓMICA
# ==========================================================

# 1. LIBRERÍAS
library(readxl)
library(ggplot2)
library(dplyr)
library(svglite)

datos_tax <- read_excel("data/Familia+Orden+Clase.xlsx")

# 2. FUNCIONES DE GRÁFICOS (FAMILIAS Y ÓRDENES)
crear_barra_taxonomia <- function(df, columna, titulo, archivo, color_hex) {
  df_plot <- df %>%
    filter(!is.na(!!sym(columna))) %>%
    count(!!sym(columna)) %>%
    top_n(15, n) %>% arrange(n) %>%
    mutate(!!sym(columna) := factor(!!sym(columna), levels = !!sym(columna)))

  p <- ggplot(df_plot, aes(x = !!sym(columna), y = n)) +
    geom_bar(stat = "identity", fill = color_hex) +
    geom_text(aes(label = n), hjust = -0.3, fontface = "bold") +
    coord_flip() + theme_minimal() +
    labs(title = titulo, x = "", y = "Nº de registros")

  ggsave(paste0("output/", archivo), p, device = "svg", width = 9, height = 7)
}

# Ejecución ejemplo: Familias en Verde Oliva
crear_barra_taxonomia(datos_tax, "Familia", "Principales Familias", "Bar_Familia_CV.svg", "#3B5C11")
