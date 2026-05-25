# ==============================================================================
# SCRIPT 08: ROLES TOPOLÓGICOS (MÉTODO DE OLESEN)
# Proyecto: Lichen-Net (TFG)
# Autora: Irene Mahiques Andrés
# Descripción: Clasificación de especies en base a su conectividad intra-módulo (z) 
#              e inter-módulo (c). Generación de cartografía de red (SVG).
# ==============================================================================

# 1. CARGA DE LIBRERÍAS Y ENTORNO ----------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(readxl, dplyr, ggplot2, bipartite, writexl, ggrepel, svglite)

if(!dir.exists("output")) dir.create("output")

# 2. CARGA Y LIMPIEZA DE DATOS (META-RED) --------------------------------------
message("Cargando datos y generando Meta-Red...")
# Leemos los datos procesados por el Script 01
df <- read_excel("data/processed/DATOS_R.xlsx") %>% 
  filter(!is.na(Micobionte_clean), !is.na(Fotobionte_clean), !is.na(Sustrato))

# 3. MOTOR DE CÁLCULO DE OLESEN ------------------------------------------------
calcular_olesen_cv <- function(matriz_cruda, tipo) {
  # Convertir tabla a matriz matemática
  matriz <- empty(as.matrix(as.data.frame.matrix(matriz_cruda)))
  
  # Filtro de robustez topológica: Exigimos N >= 3 interacciones para evitar sesgos
  matriz <- empty(matriz[rowSums(matriz) >= 3, , drop=FALSE])
  if(nrow(matriz) < 2 | ncol(matriz) < 2) return(NULL)
  
  # Inferencia de Módulos y Roles (Bipartite)
  mod <- computeModules(matriz)
  cz <- czvalues(mod)
  d_vals <- specieslevel(matriz, index = "d")
  
  # Sanitización de strings para cruce seguro de diccionarios
  limpiar_nombres <- function(x) gsub("[[:punct:] ]", "", tolower(x))
  
  v_c <- cz$c; names(v_c) <- limpiar_nombres(names(cz$c))
  v_z <- cz$z; names(v_z) <- limpiar_nombres(names(cz$z))
  
  # Ensamblaje de DataFrames por nivel trófico
  df_h <- data.frame(
    Especie = rownames(matriz), 
    Nivel = "Micobionte (Hongo)",
    c_valor = as.numeric(v_c[limpiar_nombres(rownames(matriz))]),
    z_valor = as.numeric(v_z[limpiar_nombres(rownames(matriz))]),
    Selectividad = as.numeric(d_vals$`lower level`$d)
  )
  
  df_r <- data.frame(
    Especie = colnames(matriz), 
    Nivel = "Recurso (Alga/Sustrato)",
    c_valor = as.numeric(v_c[limpiar_nombres(colnames(matriz))]),
    z_valor = as.numeric(v_z[limpiar_nombres(colnames(matriz))]),
    Selectividad = as.numeric(d_vals$`higher level`$d)
  )
  
  # Clasificación de Roles según umbrales de Olesen (2007)
  bind_rows(df_h, df_r) %>%
    mutate(
      Tipo_Red = tipo,
      Rol_Olesen = case_when(
        c_valor >= 0.62 & z_valor >= 2.5 ~ "Hub de Red",
        c_valor >= 0.62 & z_valor < 2.5  ~ "Conector (Especie Clave)",
        c_valor < 0.62  & z_valor >= 2.5 ~ "Hub Modular",
        TRUE                             ~ "Periférica (Especialista)"
      )
    )
}

# 4. EJECUCIÓN Y EXPORTACIÓN NUMÉRICA ------------------------------------------
message("Calculando roles topológicos...")
res_b <- calcular_olesen_cv(table(df$Micobionte_clean, df$Fotobionte_clean), "Red Biológica (Fotobionte)")
res_s <- calcular_olesen_cv(table(df$Micobionte_clean, df$Sustrato), "Red Espacial (Sustrato)")
df_final <- bind_rows(res_b, res_s)

write_xlsx(df_final, "output/08_Tabla_Topologia_Olesen_MetaRed.xlsx")

# 5. VISUALIZACIÓN: CARTOGRAFÍA DE OLESEN (SVG) --------------------------------
message("Generando cartografía vectorial...")

# Manejo de NAs para retener especies periféricas extremas en la visualización
df_plot <- df_final %>%
  mutate(z_valor = ifelse(is.na(z_valor), 0, z_valor),
         c_valor = ifelse(is.na(c_valor), 0, c_valor))

grafica <- ggplot(df_plot, aes(x = c_valor, y = z_valor)) +
  # Líneas de umbral topológico
  geom_hline(yintercept = 2.5, linetype = "dashed", color = "red", linewidth = 1.2, alpha = 0.5) +
  geom_vline(xintercept = 0.62, linetype = "dashed", color = "red", linewidth = 1.2, alpha = 0.5) +
  
  # Dispersión con 'jitter' para separar solapamientos en nodos periféricos
  geom_point(aes(color = Nivel), size = 8, alpha = 0.6, 
             position = position_jitter(width = 0.015, height = 0.03)) +
  
  # Anotación inteligente (solo conectores para evitar sobrecarga visual)
  geom_text_repel(data = filter(df_plot, Rol_Olesen == "Conector (Especie Clave)"),
                  aes(label = Especie), fontface = "bold.italic", size = 7,
                  box.padding = 1, point.padding = 0.5, segment.color = 'grey50', segment.size = 1) +
  
  coord_cartesian(xlim = c(-0.05, 0.8), ylim = c(-1.5, 3)) +
  facet_wrap(~Tipo_Red) +
  scale_color_manual(values = c("Micobionte (Hongo)" = "#4E7E1A", "Recurso (Alga/Sustrato)" = "#7B4B2A")) +
  
  labs(title = "Roles Topológicos de la Micobiota (Meta-Red)",
       subtitle = "Umbrales: c = 0.62 (Conectores) | z = 2.5 (Hubs). Límite de detección: N ≥ 3",
       x = "Conectividad inter-módulos (c)", y = "Conectividad intra-módulo (z)") +
  
  theme_minimal() +
  theme(
    panel.background = element_blank(),
    plot.background = element_blank(),
    legend.background = element_blank(),
    strip.background = element_rect(fill = "#2C3E50"),
    legend.position = "bottom",
    legend.title = element_blank(),
    
    plot.title = element_text(face = "bold", size = 24, hjust = 0.5, margin = margin(b = 10)),
    plot.subtitle = element_text(size = 18, hjust = 0.5, margin = margin(b = 20), color = "grey30"),
    strip.text = element_text(color = "white", face = "bold", size = 18),
    axis.title.x = element_text(size = 18, face = "bold", margin = margin(t = 15)),
    axis.title.y = element_text(size = 18, face = "bold", margin = margin(r = 15)),
    axis.text = element_text(size = 16, color = "black"),
    legend.text = element_text(size = 18),
    legend.key.size = unit(1.5, "cm")
  )

ggsave("output/08_Grafica_Roles_Olesen_Final.svg", grafica, 
       width = 14, height = 9, bg = "transparent")

message("✅ SCRIPT 08 (Roles Olesen): Ejecución completada y guardada.")
