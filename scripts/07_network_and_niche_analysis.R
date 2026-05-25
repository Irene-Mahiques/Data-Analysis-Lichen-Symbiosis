# ==============================================================================
# SCRIPT 07: TOPOLOGÍA DE REDES Y SOLAPAMIENTO DE NICHO
# Proyecto: Lichen-Net (TFG)
# Autora: Irene Mahiques Andrés
# Descripción: Cálculo de métricas de red (Conectancia, NODF, Modularidad Q)
#              e índices de solapamiento de nicho mediante modelos nulos.
# ==============================================================================

# 1. CARGA DE LIBRERÍAS Y ENTORNO ----------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(readxl, dplyr, ggplot2, tidyr, bipartite, writexl, svglite)

# Asegurar directorio de salida
if (!dir.exists("output")) dir.create("output")

# 2. CARGA Y PREPARACIÓN DE DATOS (EXCEL) --------------------------------------
df <- read_excel("data/processed/DATOS_R.xlsx")
zonas_base <- c("Zona 1", "Zona 2", "Zona 3", "Zona 4")

# Creamos el dataset agregado (Zona Completa) y combinamos
df_clean <- df %>% filter(Zona %in% zonas_base)
df_total <- bind_rows(df_clean, df_clean %>% mutate(Zona = "Zona completa"))
todas_las_zonas <- c("Zona completa", zonas_base)

# 3. FUNCIÓN DE ANÁLISIS DE RED ----------------------------------------
# Esta función ejecuta el pipeline de topología e inferencia mediante modelos nulos
calcular_red_completa <- function(tabla_cruda, nombre_zona, tipo_red) {
  
  # Limpieza de matriz: eliminamos vacíos SIN perder las dimensiones
  matriz <- as.matrix(as.data.frame.matrix(tabla_cruda))
  matriz <- matriz[rowSums(matriz) > 0, colSums(matriz) > 0, drop = FALSE]
  
  # --- ANTI-COLAPSO (Mock Data Protection) ---
  if(nrow(matriz) >= 2 && ncol(matriz) >= 2) {
    
    # Métricas empíricas globales (silenciamos los warnings molestos de tamaño)
    suppressWarnings({
      met_emp <- networklevel(matriz, index = c("connectance", "NODF", "niche overlap"))
      mod_emp <- computeModules(matriz)@likelihood
    })
    
    # Extracción segura de métricas
    v_conn <- met_emp[grepl("connectance", names(met_emp), ignore.case = TRUE)][1]
    v_nodf <- met_emp[grepl("NODF", names(met_emp), ignore.case = TRUE)][1]
    v_HL   <- met_emp[grepl("overlap.*(HL|higher)", names(met_emp), ignore.case = TRUE)][1]
    v_LL   <- met_emp[grepl("overlap.*(LL|lower)", names(met_emp), ignore.case = TRUE)][1]
    
    # INFERENCIA: Modelos Nulos (100 iteraciones para Z-score)
    nulls <- nullmodel(matriz, N=100, method="vaznull")
    null_nodf <- sapply(nulls, function(x) {
      suppressWarnings({
        met_nulo <- networklevel(x, index="NODF")
      })
      as.numeric(met_nulo[grepl("NODF", names(met_nulo), ignore.case = TRUE)][1])
    })
    
    # Cálculo de Significancia (Z-score)
    z_nodf <- (as.numeric(v_nodf) - mean(null_nodf, na.rm = TRUE)) / sd(null_nodf, na.rm = TRUE)
    
  } else {
    # Si la matriz es 1x1 o 1xN (típico en datos simulados), devolvemos NAs
    message(paste("⚠️ Matriz demasiado pequeña para", nombre_zona, "-", tipo_red, "(Saltando cálculos de red pura)"))
    v_conn <- NA; v_nodf <- NA; z_nodf <- NA; mod_emp <- NA; v_LL <- NA; v_HL <- NA
  }
  # --------------------------------------------------
  
  return(data.frame(
    Zona = nombre_zona, Tipo_Red = tipo_red,
    Connectance = round(as.numeric(v_conn), 4),
    NODF_Real = round(as.numeric(v_nodf), 4),
    Z_NODF = round(as.numeric(z_nodf), 3),
    Modularidad_Q = round(as.numeric(mod_emp), 3),
    Niche_Micobiontes = round(as.numeric(v_LL), 4), 
    Niche_Recursos = round(as.numeric(v_HL), 4)
  ))
}

# 4. EJECUCIÓN DEL BUCLE DE ANÁLISIS -------------------------------------------
resultados_lista <- list()

for(z in todas_las_zonas) {
  temp_df <- df_total %>% filter(Zona == z)
  
  # A. Red Espacial (Sustratos)
  temp_sus <- temp_df %>% filter(!is.na(Sustrato))
  if(nrow(temp_sus) > 0) {
    t_sus <- table(temp_sus$Micobionte_clean, temp_sus$Sustrato)
    resultados_lista[[paste(z, "S")]] <- calcular_red_completa(t_sus, z, "Red Espacial (Sustrato)")
  }
  
  # B. Red Biológica (Fotobiontes)
  temp_fot <- temp_df %>% filter(!is.na(Fotobionte_clean))
  if(nrow(temp_fot) > 0) {
    t_fot <- table(temp_fot$Micobionte_clean, temp_fot$Fotobionte_clean)
    resultados_lista[[paste(z, "F")]] <- calcular_red_completa(t_fot, z, "Red Biológica (Fotobionte)")
  }
}

df_final <- bind_rows(resultados_lista)
write_xlsx(df_final, "output/07_Resultados_Redes_Topologia.xlsx")

# 5. VISUALIZACIONES VECTORIALES (SVG) -----------------------------------------
orden_zonas <- rev(todas_las_zonas)

# --- Gráfica A: Niche Overlap (Simetría) ---
df_niche <- df_final %>%
  pivot_longer(cols = c(Niche_Micobiontes, Niche_Recursos), names_to = "Simbionte", values_to = "Valor")

grafica_nicho <- ggplot(df_niche, aes(x = Valor, y = factor(Zona, levels = orden_zonas))) +
  geom_line(aes(group = Zona), color = "grey70", linewidth = 2) +
  geom_point(aes(color = Simbionte), size = 8) +
  facet_wrap(~Tipo_Red) +
  scale_color_manual(values = c("Niche_Micobiontes" = "#3B5C11", "Niche_Recursos" = "#542D0F"),
                     labels = c("Micobiontes (Hongos)", "Recursos (Sustrato/Alga)")) +
  labs(title = "Asimetría en la Compartición de Socios (Niche Overlap)",
       x = "Índice de Solapamiento", y = NULL, color = "Nivel Trófico") +
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = "transparent", color = NA),
    panel.background = element_rect(fill = "transparent", color = NA),
    legend.position = "top",
    plot.title = element_text(face = "bold", size = 22, hjust = 0.5, margin = margin(b = 20)),
    strip.text = element_text(face = "bold", size = 16),
    axis.text.y = element_text(size = 16, face = "bold", color = "black"),
    axis.text.x = element_text(size = 15),
    axis.title.x = element_text(size = 18, face = "bold", margin = margin(t = 15)),
    legend.title = element_text(size = 16, face = "bold"),
    legend.text = element_text(size = 15)
  )

# --- Gráfica B: Topología Comparativa ---
df_topol <- df_final %>%
  select(Zona, Tipo_Red, Connectance, NODF_Real, Modularidad_Q) %>%
  pivot_longer(cols = c(Connectance, NODF_Real, Modularidad_Q), names_to = "Metrica", values_to = "Valor") %>%
  mutate(Metrica = factor(recode(Metrica, "Connectance"="Conectancia", "NODF_Real"="Anidamiento (NODF)", "Modularidad_Q"="Modularidad (Q)"),
                          levels = c("Conectancia", "Anidamiento (NODF)", "Modularidad (Q)")))

grafica_topologia <- ggplot(df_topol, aes(x = Valor, y = factor(Zona, levels = orden_zonas), color = Zona)) +
  geom_point(size = 9) +
  facet_grid(Tipo_Red ~ Metrica, scales = "free_x") + 
  scale_color_manual(values = c("Zona completa"="#001F3F", "Zona 1"="#D4AC0D", 
                                "Zona 2"="#3B5C11", "Zona 3"="#5C0C0C", "Zona 4"="#542D0F")) +
  labs(title = "Arquitectura de las Redes Liquénicas", x = "Valor del Índice", y = NULL) +
  theme_light() +
  theme(
    plot.background = element_rect(fill = "transparent", color = NA),
    panel.background = element_rect(fill = "transparent", color = NA),
    legend.position = "none", 
    strip.background = element_rect(fill = "#2C3E50"),
    plot.title = element_text(face = "bold", size = 24, hjust = 0.5, margin = margin(b = 20)),
    strip.text = element_text(color = "white", face = "bold", size = 16),
    axis.text.y = element_text(size = 16, face = "bold", color = "black"),
    axis.text.x = element_text(size = 14),
    axis.title.x = element_text(size = 18, face = "bold", margin = margin(t = 15))
  )

# Exportación final para Inkscape
ggsave("output/07_Grafica_Nichos.svg", grafica_nicho, width = 14, height = 7, bg = "transparent")
ggsave("output/07_Grafica_Topologia.svg", grafica_topologia, width = 16, height = 9, bg = "transparent")

message("✅ SCRIPT 07 (Redes y Nichos): Análisis topológico completado.")
