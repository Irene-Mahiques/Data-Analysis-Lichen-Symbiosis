# ==============================================================================
# SCRIPT 05: CARACTERIZACIÓN ESTRUCTURAL Y RASGOS FUNCIONALES
# Proyecto: Lichen-Net (TFG)
# Autora: Irene Mahiques Andrés
# Descripción: Análisis de abundancias relativas de biotipos, sustratos, 
#              modos de reproducción y fotobiontes. Gráfico multipanel (SVG).
# ==============================================================================

# 1. CARGA DE LIBRERÍAS Y ENTORNO ----------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, ggplot2, patchwork, scales, svglite, readxl)

# Asegurar que existe el directorio de resultados
if (!dir.exists("output")) dir.create("output")

# 2. DEFINICIÓN DE PALETAS Y COLORES -------------------------------------------
paleta_natural <- c("#542D0F", "#5C0C0C", "#3B5C11", "#0B536E", "#001F3F", "#D4AC0D")
paleta_viva    <- c("#4B0082", "#0B2415", "#E67E22", "#E74C3C", "#1ABC9C", "#27AE60", "#7F8C8D")

col_biotipo <- c("Foliáceo"="#542D0F", "Fruticuloso"="#5C0C0C", "Crustáceo"="#3B5C11", 
                 "Escuamuloso"="#0B536E", "Leproso"="#001F3F", "Compuesto"="#D4AC0D")

col_sustrato <- c("Terrícola-Muscícola"="#0B536E", "Saxícola-Terrícola"="#D4AC0D", 
                  "Terrícola"="#3B5C11", "Saxícola"="#5C0C0C", "Epífito"="#542D0F")

col_repro <- c("Sexual"="#3B5C11", "Asexual"="#542D0F")

# 3. CARGA Y PREPARACIÓN DE DATOS (EXCEL) --------------------------------------
# Usamos el archivo procesado. Evitamos conflictos con tildes en nombres de columnas.
df <- read_excel("data/processed/DATOS_R.xlsx") %>%
  rename(Reproduccion = matches("Reproducci"))

# Definimos los enclaves de estudio anonimizados (excluimos 'Zona completa')
zonas_validas <- c("Zona 1", "Zona 2", "Zona 3", "Zona 4")

# Limpieza de huecos vacíos para garantizar proporciones reales (100%)
df_clean <- df %>%
  filter(Zona %in% zonas_validas) %>%
  filter(!is.na(Micobionte), !is.na(Biotipo), !is.na(Sustrato), !is.na(Reproduccion), !is.na(Fotobionte)) %>%
  mutate(
    Biotipo = case_when(
      Biotipo %in% c("Foliaceo", "Foliáceo") ~ "Foliáceo",
      Biotipo %in% c("Crustaceo", "Crustáceo") ~ "Crustáceo",
      TRUE ~ Biotipo
    ),
    Sustrato = case_when(
      Sustrato %in% c("Saxicola", "Saxícola") ~ "Saxícola",
      Sustrato %in% c("Terricola", "Terrícola") ~ "Terrícola",
      Sustrato %in% c("Epifito", "Epífito") ~ "Epífito",
      Sustrato == "Terricola-Muscicola" ~ "Terrícola-Muscícola",
      Sustrato == "Saxicola-Terricola" ~ "Saxícola-Terrícola",
      TRUE ~ Sustrato
    )
  )

# ------------------------------------------------------------------------------
# 🌟 CÁLCULO DINÁMICO DEL TAMAÑO DE MUESTRA (N)
# ------------------------------------------------------------------------------
conteo_n <- df_clean %>% 
  count(Zona) %>% 
  mutate(texto = paste0(Zona, " (", n, ")"))

texto_caption <- paste("N:", paste(conteo_n$texto, collapse = ", "))

# 4. MAPEO DE COLORES DINÁMICO PARA FOTOBIONTES --------------------------------
lista_frecuencia_foto <- df_clean %>%
  count(Fotobionte, sort = TRUE) %>%
  pull(Fotobionte)

colores_foto_mapping <- setNames(
  c(paleta_natural, paleta_viva)[1:length(lista_frecuencia_foto)],
  lista_frecuencia_foto
)

# 5. MOTOR DE RENDERIZADO (FUNCIÓN CUSTOM) -------------------------------------
# Principio DRY (Don't Repeat Yourself) para estandarizar las gráficas
plot_custom <- function(data, columna, titulo, mapa_colores) {
  ggplot(data, aes(x = factor(Zona, levels = zonas_validas), fill = !!sym(columna))) +
    geom_bar(position = "fill", color = "white", linewidth = 0.3) +
    scale_y_continuous(labels = percent) +
    scale_fill_manual(values = mapa_colores) +
    labs(title = titulo, x = NULL, y = "Proporción", fill = NULL) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 35, hjust = 1, size = 10, face = "bold", color = "black"),
      panel.grid.major = element_blank(),
      panel.background = element_rect(fill = "transparent", color = NA),
      plot.background = element_rect(fill = "transparent", color = NA),
      legend.background = element_rect(fill = "transparent", color = NA),
      plot.title = element_text(face = "bold", size = 13, hjust = 0.5)
    )
}

# 6. GENERACIÓN DE PANELES -----------------------------------------------------
p1 <- plot_custom(df_clean, "Biotipo", "(A) Biotipo", col_biotipo)
p2 <- plot_custom(df_clean, "Sustrato", "(B) Sustrato", col_sustrato)
p3 <- plot_custom(df_clean, "Reproduccion", "(C) Reproducción", col_repro)
p4 <- plot_custom(df_clean, "Fotobionte", "(D) Fotobionte", colores_foto_mapping)

# 7. ENSAMBLAJE (PATCHWORK) Y EXPORTACIÓN --------------------------------------
figura_final <- (p1 | p2) / (p3 | p4) + 
  plot_annotation(
    title = "Caracterización Estructural de la Micobiota Liquenizada",
    caption = texto_caption, 
    theme = theme(plot.background = element_rect(fill = "transparent", color = NA))
  )

ggsave("output/05_Caracterizacion_Estructural_Final.svg", plot = figura_final, 
       width = 14, height = 11, bg = "transparent")

message("✅ SCRIPT 05 (Caracterización Estructural): Figura multipanel guardada correctamente.")
message("📊 Tamaño muestral validado: ", texto_caption)
