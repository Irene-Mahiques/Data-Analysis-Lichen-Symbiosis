# ==============================================================================
# SCRIPT 07: TOPOLOGÍA DE REDES, SOLAPAMIENTO DE NICHO Y MÓDULOS
# Proyecto: Lichen-Net (TFG)
# Autora: Irene Mahiques Andrés
# Descripción: Cálculo de métricas de red (Conectancia, NODF, Modularidad Q, 
#              índices de solapamiento de nicho) con modelos nulos (N=500),
#              y extracción de composición de módulos (Excel).
# ==============================================================================

# 1. CARGA DE LIBRERÍAS Y ENTORNO ----------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(readxl, dplyr, ggplot2, tidyr, bipartite, writexl, svglite)

if (!dir.exists("output")) dir.create("output")

# 2. CARGA Y PREPARACIÓN DE DATOS ----------------------------------------------
df <- read_excel("data/processed/DATOS_R.xlsx")
zonas_base <- c("Zona 1", "Zona 2", "Zona 3", "Zona 4")

# Creamos el dataset agregado (Zona completa) y combinamos
df_clean <- df %>% filter(Zona %in% zonas_base)
df_total <- bind_rows(df_clean, df_clean %>% mutate(Zona = "Zona completa"))
todas_las_zonas <- c("Zona completa", zonas_base)

# 3. FUNCIONES DE ANÁLISIS ----------------------------------------------------

# --- Función A: Cálculos topológicos generales ---
calcular_red_completa <- function(tabla_cruda, nombre_zona, tipo_red) {
  matriz <- empty(as.matrix(as.data.frame.matrix(tabla_cruda)))
  
  # Valores Empíricos básicos
  met_emp <- networklevel(matriz, index = c("connectance", "NODF", "niche overlap"))
  
  # Modularidad: si falla, por ser una red pequeña, devuelve NA
  mod_emp <- tryCatch(computeModules(matriz)@likelihood, error = function(e) NA)
  
  v_conn <- as.numeric(met_emp[grepl("connectance", names(met_emp), ignore.case = TRUE)][1])
  v_nodf <- as.numeric(met_emp[grepl("NODF", names(met_emp), ignore.case = TRUE)][1])
  v_HL <- as.numeric(met_emp[grepl("overlap.*(HL|higher)", names(met_emp), ignore.case = TRUE)][1])
  v_LL <- as.numeric(met_emp[grepl("overlap.*(LL|lower)", names(met_emp), ignore.case = TRUE)][1])
  
  # Modelos Nulos (500 iteraciones)
  message(paste("Calculando:", nombre_zona, "-", tipo_red, "[500 iteraciones...]"))
  nulls <- nullmodel(matriz, N=500, method="vaznull")
  
  null_metrics <- lapply(nulls, function(x) {
    nl <- networklevel(x, index = c("NODF", "niche overlap"))
    m_val <- tryCatch(computeModules(x)@likelihood, error = function(e) NA)
    list(
      nodf = as.numeric(nl[grepl("NODF", names(nl), ignore.case = TRUE)][1]),
      niche_HL = as.numeric(nl[grepl("overlap.*(HL|higher)", names(nl), ignore.case = TRUE)][1]),
      niche_LL = as.numeric(nl[grepl("overlap.*(LL|lower)", names(nl), ignore.case = TRUE)][1]),
      mod = m_val
    )
  })
  
  v_null_nodf <- sapply(null_metrics, function(x) x$nodf)
  v_null_HL <- sapply(null_metrics, function(x) x$niche_HL)
  v_null_LL <- sapply(null_metrics, function(x) x$niche_LL)
  v_null_mod <- sapply(null_metrics, function(x) x$mod)
  
  # Z-scores (usando na.rm = TRUE para ignorar los NAs de los modelos fallidos)
  z_nodf <- (v_nodf - mean(v_null_nodf, na.rm = TRUE)) / sd(v_null_nodf, na.rm = TRUE)
  z_HL <- (v_HL - mean(v_null_HL, na.rm = TRUE)) / sd(v_null_HL, na.rm = TRUE)
  z_LL <- (v_LL - mean(v_null_LL, na.rm = TRUE)) / sd(v_null_LL, na.rm = TRUE)
  z_mod <- (mod_emp - mean(v_null_mod, na.rm = TRUE)) / sd(v_null_mod, na.rm = TRUE)
  
  return(data.frame(
    Zona = nombre_zona, Tipo_Red = tipo_red,
    Connectance = round(v_conn, 4),
    NODF_Real = round(v_nodf, 4), Z_NODF = round(z_nodf, 3),
    Modularidad_Q = round(mod_emp, 3), Z_Modularidad = round(z_mod, 3),
    Niche_Micobiontes = round(v_LL, 4), Z_Niche_Micobiontes = round(z_LL, 3),
    Niche_Recursos = round(v_HL, 4), Z_Niche_Recursos = round(z_HL, 3)
  ))
}

# --- FUNCIÓN B: Extracción de Módulos a Excel ---
extraer_modulos_cv <- function(tabla_cruda, nombre_zona, sufijo) {
  if(nombre_zona != "Zona completa") return(NULL)
  
  matriz <- empty(as.matrix(as.data.frame.matrix(tabla_cruda)))
  
  # Como esta red es pequeña, mejor no calcular módulos
  if(nrow(matriz) < 3 | ncol(matriz) < 3) {
    message("⚠️ Red demasiado pequeña para extraer módulos en: ", sufijo)
    return(NULL)
  }
  
  # Si computeModules falla, el script sigue adelante
  mis_modulos <- tryCatch({
    computeModules(matriz)
  }, error = function(e) {
    message("⚠️ No se pudieron calcular módulos para: ", sufijo, ". Saltando...")
    return(NULL)
  })
  
  if(is.null(mis_modulos)) return(NULL)
  
  info_bruta <- listModuleInformation(mis_modulos)
  
  # Función interna
  extraer_cajas <- function(nodo) {
    if (is.list(nodo) && length(nodo) == 2 && is.character(nodo[[1]]) && is.character(nodo[[2]])) {
      return(list(nodo))
    } else if (is.list(nodo)) {
      res <- list(); for (i in seq_along(nodo)) res <- c(res, extraer_cajas(nodo[[i]]))
      return(res)
    }
    return(list())
  }
  
  cajas_planas <- extraer_cajas(info_bruta)
  
  df_modulos <- data.frame(Zona=character(), Tipo_Red=character(), Modulo=character(), 
                           Micobiontes=character(), Socios_Ecologicos=character(), stringsAsFactors=FALSE)
  
  contador_modulo <- 1 
  for(i in seq_along(cajas_planas)) {
    hongos <- cajas_planas[[i]][[1]]; socios <- cajas_planas[[i]][[2]]
    if(length(hongos) < 150) { 
      df_modulos <- rbind(df_modulos, data.frame(
        Zona=nombre_zona, Tipo_Red=sufijo, Modulo=paste("Módulo", contador_modulo),
        Micobiontes=paste(hongos, collapse=", "), Socios_Ecologicos=paste(socios, collapse=", ")
      ))
      contador_modulo <- contador_modulo + 1
    }
  }
  
  nombre_limpio <- gsub(" ", "_", nombre_zona)
  write_xlsx(df_modulos, paste0("output/07_Composicion_Modulos_", nombre_limpio, "_", sufijo, ".xlsx"))
}

# 4. EJECUCIÓN ----------------------------------------------------------------
resultados_lista <- list()
for(z in todas_las_zonas) {
  temp_df <- df_total %>% filter(Zona == z)
  
  t_sus <- table(temp_df$Micobionte[!is.na(temp_df$Sustrato)], temp_df$Sustrato[!is.na(temp_df$Sustrato)])
  if(sum(t_sus) > 0) {
    resultados_lista[[paste(z, "S")]] <- calcular_red_completa(t_sus, z, "Red Espacial (Sustrato)")
    extraer_modulos_cv(t_sus, z, "Sustrato") 
  }
  
  t_fot <- table(temp_df$Micobionte[!is.na(temp_df$Fotobionte)], temp_df$Fotobionte[!is.na(temp_df$Fotobionte)])
  if(sum(t_fot) > 0) {
    resultados_lista[[paste(z, "F")]] <- calcular_red_completa(t_fot, z, "Red Biológica (Fotobionte)")
    extraer_modulos_cv(t_fot, z, "Fotobionte") 
  }
}
df_final <- bind_rows(resultados_lista)
write_xlsx(df_final, "output/07_Resultados_Redes_Topologia.xlsx")

# 5. VISUALIZACIONES VECTORIALES (SVG) -----------------------------------------
orden_zonas <- rev(todas_las_zonas)

# --- Gráfica A: Niche Overlap ---
df_niche <- df_final %>%
  pivot_longer(cols = c(Niche_Micobiontes, Niche_Recursos), names_to = "Simbionte", values_to = "Valor")

grafica_nicho <- ggplot(df_niche, aes(x = Valor, y = factor(Zona, levels = orden_zonas))) +
  geom_line(aes(group = Zona), color = "grey70", linewidth = 2) +
  geom_point(aes(color = Simbionte), size = 8) +
  facet_wrap(~Tipo_Red) +
  scale_color_manual(values = c("Niche_Micobiontes" = "#3B5C11", "Niche_Recursos" = "#542D0F"),
                     labels = c("Micobiontes", "Recursos (Sustrato/Alga)")) +
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

# Exportación
ggsave("output/07_Grafica_Nichos.svg", grafica_nicho, width = 14, height = 7, bg = "transparent")
ggsave("output/07_Grafica_Topologia.svg", grafica_topologia, width = 16, height = 9, bg = "transparent")

message("✅ SCRIPT 07 (Redes y Nichos): Análisis topológico y extracción de módulos completado.")
