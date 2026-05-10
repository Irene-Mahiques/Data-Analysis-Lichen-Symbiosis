# ==============================================================================
# SCRIPT 12: DIAGRAMAS DE RED BIPARTITA
# Proyecto: Lichen-Net (TFG)
# Autora: Irene Mahiques Andrés
# Descripción: Generación de representaciones gráficas de redes bipartitas
#              (Biotipo, Reproducción y Hábitat vs. Fotobionte) en formato SVG.
# ==============================================================================

# 1. CARGA DE LIBRERÍAS Y ENTORNO ----------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(readxl, dplyr, bipartite, svglite)

# Creamos una subcarpeta específica para las imágenes de las redes
if (!dir.exists("output/plots_networks")) dir.create("output/plots_networks", recursive = TRUE)

# 2. CARGA Y LIMPIEZA DE DATOS MAESTROS ----------------------------------------
# Leemos desde la carpeta de datos procesados
df_maestro <- read_excel("data/processed/DATOS_R.xlsx") %>%
  rename(
    Reproduccion = matches("Reproducci"),
    Habitat = matches("Sustrato|H.bitat")
  ) %>%
  filter(!is.na(Fotobionte_clean))

# 3. CONFIGURACIÓN VISUAL ESTÁNDAR ---------------------------------------------
# Parámetros para asegurar la legibilidad
rot_texto <- 45
tam_letra <- 2.5
ancho_rec <- 0.05

# 4. MOTOR DE EXPORTACIÓN GRÁFICA (SVG) ----------------------------------------
exportar_red_svg <- function(matriz, nombre_archivo) {
  # Limpieza de nodos huérfanos o etiquetas vacías
  matriz_limpia <- empty(as.matrix(as.data.frame.matrix(matriz)))
  
  if(nrow(matriz_limpia) > 0 && ncol(matriz_limpia) > 0) {
    ruta_final <- paste0("output/plots_networks/", nombre_archivo, ".svg")
    
    svglite(ruta_final, width = 16, height = 10, bg = "transparent")
    
    # Renderizado de la red bipartita
    plotweb(
      matriz_limpia, 
      text.rot = rot_texto, 
      labsize = tam_letra, 
      y.width.low = ancho_rec, 
      y.width.high = ancho_rec,
      col.interaction = "#eaebed",       # Gris suave para las cintas
      bor.col.interaction = "#c5c5c5",   # Borde de las interacciones
      col.low = "#3B5C11",               # Color para nivel inferior (Hongos/Rasgos)
      col.high = "#542D0F"               # Color para nivel superior (Fotobiontes)
    )
    
    dev.off()
  }
}

# 5. GENERACIÓN AUTOMATIZADA POR ZONA ------------------------------------------
generar_set_redes <- function(datos, etiqueta_zona) {
  message(paste("Generando redes para:", etiqueta_zona))
  
  # A. Biotipo vs Fotobionte
  if("Biotipo" %in% colnames(datos)) {
    exportar_red_svg(table(datos$Biotipo, datos$Fotobionte_clean), 
                     paste0("red_biotipo_", etiqueta_zona))
  }
  
  # B. Reproducción vs Fotobionte
  if("Reproduccion" %in% colnames(datos)) {
    exportar_red_svg(table(datos$Reproduccion, datos$Fotobionte_clean), 
                     paste0("red_repro_", etiqueta_zona))
  }
  
  # C. Hábitat vs Fotobionte
  if("Habitat" %in% colnames(datos)) {
    exportar_red_svg(table(datos$Habitat, datos$Fotobionte_clean), 
                     paste0("red_habitat_", etiqueta_zona))
  }
}

# ==============================================================================
# EJECUCIÓN DEL PIPELINE VISUAL
# ==============================================================================

# Extraemos todas las zonas
zonas <- unique(df_maestro$Zona)

# Bucle único y optimizado
for(zona_id in zonas) {
  # Cambiamos los espacios por guiones bajos para el nombre del archivo (ej: "Zona_1")
  id_seguro <- gsub(" ", "_", zona_id)
  
  # Filtramos los datos de esa zona específica
  df_zona <- df_maestro %>% filter(Zona == zona_id)
  
  # Generamos sus 3 redes correspondientes
  generar_set_redes(df_zona, id_seguro)
}

message("✅ SCRIPT 12: Todas las redes bipartitas han sido exportadas a /output/plots_networks/")
