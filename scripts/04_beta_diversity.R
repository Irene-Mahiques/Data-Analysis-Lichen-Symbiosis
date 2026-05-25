# ==============================================================================
# SCRIPT 04: DIVERSIDAD BETA (SIMILITUD FLORÍSTICA)
# Proyecto: Lichen-Net (TFG)
# Autora: Irene Mahiques Andrés
# Descripción: Matriz de disimilitud de Bray-Curtis y agrupamiento jerárquico.
#              Generación de dendrograma vectorial (SVG).
# ==============================================================================

# 1. CARGA DE LIBRERÍAS Y ENTORNO ----------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, tidyr, vegan, ggplot2, ggdendro, svglite, readxl)

# Asegurar que existe el directorio de resultados
if (!dir.exists("output")) dir.create("output")

# 2. CARGA DE DATOS LIMPIOS (EXCEL) --------------------------------------------
datos_limpios <- read_excel("data/processed/DATOS_R.xlsx") %>%
  filter(!is.na(Zona), !is.na(Micobionte_clean)) # Elimina filas con huecos clave

# 3. CONSTRUCCIÓN DE LA MATRIZ DE COMUNIDAD ------------------------------------
matriz_comunidad <- datos_limpios %>%
  group_by(Zona, Micobionte_clean) %>%
  summarise(Abundancia = n(), .groups = "drop") %>%
  pivot_wider(names_from = Micobionte_clean, values_from = Abundancia, values_fill = 0)

comu_df <- as.data.frame(matriz_comunidad)
rownames(comu_df) <- comu_df$Zona
comu_df <- comu_df[, -1] 

# 4. ESTANDARIZACIÓN Y MATRIZ DE DISIMILITUD -----------------------------------
# Corrección del sesgo de tamaño muestral (Abundancias relativas)
comu_df_relativa <- decostand(comu_df, method = "total")

# Cálculo de la distancia de Bray-Curtis
dist_bray <- vegdist(comu_df_relativa, method = "bray")

# Exportar matriz de distancias
write.csv(as.matrix(dist_bray), "output/04_Matriz_Distancias_BrayCurtis.csv")

# 5. AGRUPAMIENTO JERÁRQUICO (Clúster Ward.D2) ---------------------------------
cluster_floristico <- hclust(dist_bray, method = "ward.D2")

# 6. VISUALIZACIÓN: DENDROGRAMA ------------------------------------------------
dendro_data <- dendro_data(cluster_floristico)

grafica_cluster <- ggplot() +
  geom_segment(data = segment(dendro_data), aes(x = x, y = y, xend = xend, yend = yend), 
               linewidth = 1, color = "#7B4B2A") +
  geom_text(data = label(dendro_data), aes(x = x, y = -0.02, label = label), 
            angle = 0, hjust = 0.5, vjust = 1, size = 5, fontface = "bold") +
  scale_y_continuous(expand = expansion(mult = c(0.15, 0.1))) +
  scale_x_continuous(expand = expansion(add = c(0.6, 0.6))) + 
  labs(
    title = "Similitud Florística entre Enclaves",
    subtitle = "Basado en abundancias relativas (Distancia de Bray-Curtis)",
    y = "Nivel de Disimilitud",
    x = ""
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 11, color = "gray40", margin = margin(b=15)),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.text.y = element_text(size = 14),                                           # Números del eje Y
    axis.title.y = element_text(face = "bold", size = 16, margin = margin(r = 10)),  # Título del eje Y
    # ------------------------------------
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "transparent", color = NA),
    plot.background = element_rect(fill = "transparent", color = NA)
  )

# Guardar en formato vectorial
ggsave("output/04_Dendrograma_Floristico.svg", plot = grafica_cluster, width = 8, height = 5, bg = "transparent")

message("✅ SCRIPT 04 (Diversidad Beta): Dendrograma y matriz generados correctamente.")
