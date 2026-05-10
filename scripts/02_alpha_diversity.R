# ==============================================================================
# SCRIPT 02: ÍNDICES DE DIVERSIDAD ALFA
# Proyecto: Lichen-Net
# Autora: Irene Mahiques Andrés
# Descripción: Inferencia de diversidad Alfa (Shannon, Simpson, Riqueza, Pielou)
#              y generación de gráficos vectoriales (SVG).
# ==============================================================================

# 1. CARGA DE LIBRERÍAS Y ENTORNO ----------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, tidyr, vegan, ggplot2, svglite)

# Crear directorio de salida si no existe
if (!dir.exists("output")) dir.create("output")

# 2. CARGA DE DATOS LIMPIOS ----------------------------------------------------
# Importante: Leemos el archivo procesado por el script 01_data_cleaning.R
datos_limpios <- read.csv("data/processed/lichen_net_master.csv", stringsAsFactors = FALSE)

# 3. CONSTRUCCIÓN DE LA MATRIZ DE COMUNIDAD ------------------------------------
matriz_comunidad <- datos_limpios %>%
  group_by(Zona, micobionte_clean) %>%
  summarise(Abundancia = n(), .groups = "drop") %>%
  pivot_wider(names_from = micobionte_clean, values_from = Abundancia, values_fill = 0)

# Formateo para la librería 'vegan' (las zonas deben ser los nombres de las filas)
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
  # Calculamos Pielou dentro del mismo flujo
  mutate(Equidad_Pielou = round(Shannon_H / log(Riqueza_S), 3)) %>%
  arrange(desc(Shannon_H))

# Exportar tabla
write.csv(tabla_diversidad, "output/02_Tabla_Diversidad_Resultados.csv", row.names = FALSE)

# 5. VISUALIZACIÓN: GRÁFICA COMPARATIVA (SHANNON) ------------------------------
# Paleta de colores corporativa del proyecto Lichen-Net
colores_enclaves <- c(
  "Comunidad Valenciana" = "#0B536E", 
  "Espadán"              = "#D4AC0D", 
  "Font Roja"            = "#3B5C11", 
  "Penyagolosa"          = "#5C0C0C", 
  "Vall d'Albaida"       = "#542D0F"
)

grafica_shannon <- ggplot(tabla_diversidad, aes(x = reorder(Zona, Shannon_H), y = Shannon_H, fill = Zona)) +
  geom_bar(stat = "identity", color = "white", linewidth = 0.5, alpha = 0.9) +
  coord_flip() +
  scale_fill_manual(values = colores_enclaves) +
  theme_minimal() +
  labs(title = "Diversidad Alfa (Índice de Shannon) por Enclave", 
       x = "", 
       y = "Índice de Shannon (H')") +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 14, margin = margin(b = 15)),
    axis.text.y = element_text(size = 12, face = "bold", color = "black"),
    axis.text.x = element_text(size = 11, color = "black"),
    axis.title.x = element_text(face = "bold", margin = margin(t = 10)),
    legend.position = "none",
    panel.grid.major.y = element_blank(),
    panel.background = element_rect(fill = "transparent", color = NA),
    plot.background = element_rect(fill = "transparent", color = NA)
  )

# Exportar en formato vectorial (SVG)
ggsave("output/02_Comparativa_Shannon.svg", plot = grafica_shannon, width = 8, height = 4, bg = "transparent")

message("✅ SCRIPT 02 (Diversidad Alfa): Ejecución completada con éxito.")
