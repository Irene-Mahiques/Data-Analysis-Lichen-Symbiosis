# ==============================================================================
# SCRIPT 06: MODELO LINEAL GENERALIZADO (GLM MULTINOMIAL)
# Proyecto: Lichen-Net (TFG)
# Autora: Irene Mahiques Andrés
# Descripción: Inferencia estadística sobre la distribución de rasgos funcionales
#              y fotobiontes entre los distintos enclaves (multinom).
# ==============================================================================

# 1. CARGA DE LIBRERÍAS Y ENTORNO ----------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, tidyr, nnet, readxl, writexl)

# Asegurar que existe el directorio de resultados
if (!dir.exists("output")) dir.create("output")

# 2. CARGA DE DATOS Y LIMPIEZA ESTRICTA ----------------------------------------
# Evitamos fallos de codificación renombrando variables con caracteres especiales
df <- read_excel("data/processed/DATOS_R.xlsx") %>%
  rename(Reproduccion = matches("Reproducci"))

# Definimos las zonas anonimizadas válidas para el contraste de hipótesis
zonas_validas <- c("Zona 1", "Zona 2", "Zona 3", "Zona 4")

df_clean <- df %>%
  filter(Zona %in% zonas_validas) %>%
  # Eliminamos filas con NAs en variables críticas del modelo
  drop_na(Zona, Biotipo, Sustrato, Reproduccion, Fotobionte) %>%
  # Convertimos a factores y purgamos niveles vacíos
  mutate(across(c(Zona, Biotipo, Sustrato, Reproduccion, Fotobionte), 
                ~ factor(droplevels(as.factor(.x)))))

# 3. MOTOR ESTADÍSTICO (FUNCIÓN GLM) -------------------------------------------
# Compara un modelo completo (con la Zona como predictor) vs. un modelo nulo
obtener_p_valor <- function(columna, datos) {
  # Modelo con predictor
  formula_full <- as.formula(paste(columna, "~ Zona"))
  mod_full <- multinom(formula_full, data = datos, trace = FALSE)
  
  # Modelo nulo (solo el intercepto)
  formula_null <- as.formula(paste(columna, "~ 1"))
  mod_null <- multinom(formula_null, data = datos, trace = FALSE)
  
  # Contraste de bondad de ajuste (Likelihood Ratio Test)
  comparacion <- anova(mod_null, mod_full)
  return(comparacion$`Pr(Chi)`[2])
}

# 4. EJECUCIÓN ITERATIVA DE LOS MODELOS ----------------------------------------
p_biotipo  <- obtener_p_valor("Biotipo", df_clean)
p_sustrato <- obtener_p_valor("Sustrato", df_clean)
p_repro    <- obtener_p_valor("Reproduccion", df_clean)
p_foto     <- obtener_p_valor("Fotobionte", df_clean)

# 5. CONSOLIDACIÓN DE RESULTADOS Y EXPORTACIÓN ---------------------------------
tabla_final <- data.frame(
  Variable = c("Biotipo", "Sustrato", "Estrategia Reproductiva", "Fotobionte"),
  p_valor  = c(p_biotipo, p_sustrato, p_repro, p_foto)
) %>%
  mutate(
    # Asignación automática de asteriscos de significación estándar
    Significacion = case_when(
      p_valor < 0.001 ~ "***",
      p_valor < 0.01  ~ "**",
      p_valor < 0.05  ~ "*",
      TRUE            ~ "n.s."
    ),
    # Redondeo para presentación formal
    p_valor = round(p_valor, 4) 
  )

# Guardar la tabla en formato Excel
write_xlsx(tabla_final, "output/06_Tabla_Significacion_GLM.xlsx")

# Mostrar por consola para revisión rápida
message("✅ SCRIPT 06 (Modelos GLM): Ejecución completada. Resultados:")
print(tabla_final)
