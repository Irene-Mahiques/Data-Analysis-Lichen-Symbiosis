# 1. LIBRERÍAS
library(readxl)
library(ggplot2)
library(dplyr)
library(svglite)

# 2. FUNCIONES DE GRÁFICOS (FAMILIAS Y ÓRDENES)
crear_barra_taxonomia <- function(df, columna, titulo, nombre_archivo, color_barra) {
  df_plot <- df %>%
    filter(!is.na(!!sym(columna)), !!sym(columna) != "") %>%
    count(!!sym(columna)) %>%
    top_n(15, n) %>% 
    arrange(n) %>%
    mutate(!!sym(columna) := factor(!!sym(columna), levels = !!sym(columna)))

  p <- ggplot(df_plot, aes(x = !!sym(columna), y = n)) +
    geom_bar(stat = "identity", fill = color_barra) +
    coord_flip() +
    theme_minimal() +
    labs(title = titulo, x = "", y = "Nº de registros")

  ggsave(paste0("output/", nombre_archivo), p, device = "svg", width = 9, height = 7)
}

# Ejemplo de ejecución para Familias
# crear_barra_taxonomia(datos_tax, "Familia", "Principales Familias", "Bar_Familia.svg", "#3B5C11")
