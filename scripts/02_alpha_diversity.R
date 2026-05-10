# ==============================================================================
# SCRIPT 02: ÍNDICES DE DIVERSIDAD ALFA
# Proyecto: Lichen-Net (TFG)
# Autora: Irene Mahiques Andrés
# Descripción: Inferencia de diversidad Alfa y generación de gráficos (SVG).
# ==============================================================================

# 1. CARGA DE LIBRERÍAS Y ENTORNO ----------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, tidyr, vegan, ggplot2, svglite, readxl, writexl)

# Asegurar que existe el directorio de resultados
if (!dir.exists("output")) dir.create("output")

# 2. CARGA DE DATOS LIMPIOS (EXCEL) --------------------------------------------
# Se asume que DATOS_R.xlsx ya contiene los nombres de zona anonimizados
datos_limpios <- read_excel("data/processed/DATOS_R.xlsx")

# 3. CONSTRUCCIÓN DE LA MATRIZ DE COMUNIDAD ------------------------------------
matriz_comunidad <- datos_limpios %>%
  group_by(Zona, Micobionte_clean) %>%
  summarise(Abundancia = n(), .groups = "drop") %>%
  pivot_wider(names_from = Micobionte_clean, values_from = Abundancia, values_fill = 0)

# Formateo para la librería 'vegan'
comu_df <- as.data.frame(matriz_comunidad)
rownames(comu_df) <- comu_df$Zona
comu_df <- comu_df[, -1] 

# 4. CÁLCULO DE ÍNDICES ECOLÓGICOS ---------------------------------------------
tabla_diversidad <- data.frame(
  Zona = rownames(comu_df),
  Riqueza_S = specnumber(comu_df),
  Shannon_H = round(diversity(comu_df, index = "shannon"), 3),
  Simpson_1_D = round(diversity(comu_df, index = "simpson"), 3)
) %>%
  # Cálculo de la Equidad de Pielou (J')
  mutate(Equidad_Pielou = round(Shannon_H / log(Riqueza_S), 3)) %>%
  arrange(desc(Shannon_H))

# Exportación de resultados
write_xlsx(tabla_diversidad, "output/02_Tabla_Diversidad_Resultados.xlsx")

# 5. VISUALIZACIÓN: GRÁFICA COMPARATIVA (SHANNON) ------------------------------
colores_enclaves <- c(
  "Zona completa" = "#0B536E", 
  "Zona 1"        = "#D4AC0D", 
  "Zona 2"        = "#3B5C11", 
  "Zona 3"        = "#5C0C0C", 
  "Zona 4"        = "#542D0F"
)

grafica_shannon <- ggplot(tabla_diversidad, aes(x = reorder(Zona, Shannon_H), y = Shannon_H, fill = Zona)) +
  geom_bar(stat = "identity", color = "white", linewidth = 0.5, alpha = 0.9) +
  coord_flip() +
  scale_fill_manual(values = colores_enclaves) +
  theme_minimal() +
  labs(title = "Diversidad Alfa (Índice de Shannon) por Enclave", 
       subtitle = "Análisis comparativo de la diversidad de micobiontes",
       x = "", 
       y = "Índice de Shannon (H')") +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 14, margin = margin(b = 5)),
    plot.subtitle = element_text(hjust = 0.5, size = 10, color = "gray30", margin = margin(b = 15)),
    axis.text.y = element_text(size = 12, face = "bold", color = "black"),
    axis.text.x = element_text(size = 11, color = "black"),
    legend.position = "none",
    panel.grid.major.y = element_blank(),
    panel.background = element_rect(fill = "transparent", color = NA),
    plot.background = element_rect(fill = "transparent", color = NA)
  )

# Guardar en formato vectorial para edición en Inkscape
ggsave("output/02_Comparativa_Shannon.svg", plot = grafica_shannon, width = 8, height = 4, bg = "transparent")

message("✅ SCRIPT 02 (Diversidad Alfa): Ejecución completada con éxito.")
