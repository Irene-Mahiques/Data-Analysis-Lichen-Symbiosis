# ==================================================================================
# SCRIPT 09: PARTICIÓN DE LA VARIANZA (VARPART)
# Proyecto: Lichen-Net (TFG)
# Autora: Irene Mahiques Andrés
# Descripción: Modelado de los determinantes de la simbiosis liquénica mediante 
#              partición de varianza (3 y 4 vías). Diagramas de Euler.
# ==================================================================================

# 1. CARGA DE LIBRERÍAS Y ENTORNO ----------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(readxl, dplyr, tidyr, vegan, writexl, svglite, grid, eulerr)

if (!dir.exists("output")) dir.create("output")

# 2. CARGA CENTRAL DE DATOS ----------------------------------------------------
# Lectura y estandarización del nombre de la variable conflictiva
df_base <- read_excel("data/processed/DATOS_R.xlsx") %>%
  rename(Reproduccion = matches("Reproducci"))


# ==================================================================================================
# MODELO 1: PARTICIÓN DE 4 VÍAS (Filogenia, Geografía, Reproducción y Hábitat (Biotipo + Sustrato))
# ==================================================================================================
message("Ejecutando Modelo 1 (4 Vías Complejo)...")

df_4v <- df_base %>%
  select(Fotobionte_clean, Zona, Reproduccion, Biotipo, Sustrato, Familia) %>% 
  drop_na()

Y_4v  <- as.data.frame(model.matrix(~ Fotobionte_clean - 1, data = df_4v))
X1_4v <- as.data.frame(model.matrix(~ Familia - 1, data = df_4v))      # Filogenia
X2_4v <- as.data.frame(model.matrix(~ Zona - 1, data = df_4v))         # Geografía
X3_4v <- as.data.frame(model.matrix(~ Reproduccion - 1, data = df_4v)) # Reproducción
X4_4v <- as.data.frame(model.matrix(~ Biotipo + Sustrato - 1, data = df_4v)) # Hábitat

mod_4v <- varpart(Y_4v, X1_4v, X2_4v, X3_4v, X4_4v)

df_res_4v <- as.data.frame(mod_4v$part$indfract) %>%
  mutate(Fraccion = rownames(.)) %>%
  select(Fraccion, everything())
write_xlsx(df_res_4v, "output/09_Tabla_Varianza_4Vias.xlsx")

# Exportar Figura Euler (SVG)
vp_4v <- pmax(0, df_res_4v$Adj.R.square[1:15]) * 100
diag_4v <- euler(c(
  "Familia" = vp_4v[1], "Geografía" = vp_4v[2], "Reproducción" = vp_4v[3], "Hábitat" = vp_4v[4],
  "Familia&Geografía" = vp_4v[5], "Familia&Reproducción" = vp_4v[6], "Familia&Hábitat" = vp_4v[7],
  "Geografía&Reproducción" = vp_4v[8], "Geografía&Hábitat" = vp_4v[9], "Reproducción&Hábitat" = vp_4v[10],
  "Familia&Geografía&Reproducción" = vp_4v[11], "Familia&Geografía&Hábitat" = vp_4v[12],
  "Familia&Reproducción&Hábitat" = vp_4v[13], "Geografía&Reproducción&Hábitat" = vp_4v[14],
  "Familia&Geografía&Reproducción&Hábitat" = vp_4v[15]
))
etiquetas_4v <- paste0(sprintf("%.1f", diag_4v$original.values), "%")

svglite("output/09_Figura_Euler_4Vias.svg", width = 14, height = 14, bg = "transparent")
print(plot(diag_4v, 
           fills = list(fill = c("#4E7E1A", "#7B4B2A", "#D4AC0D", "#5D6D7E"), alpha = 0.6), 
           labels = list(cex = 2.5, font = 2), 
           quantities = list(labels = etiquetas_4v, cex = 2.0, font = 2),
           main = list(label = "Determinantes Complejos de la Simbiosis", cex = 2.8, font = 2)))
dev.off()


# ==============================================================================
# MODELO 2: PARTICIÓN DE 3 VÍAS (Familia vs Biotipo vs Sustrato)
# ==============================================================================
message("Ejecutando Modelo 2 (3 Vías - Genética vs Ambiente)...")

df_3v <- df_base %>%
  select(Fotobionte_clean, Familia, Biotipo, Sustrato) %>% 
  drop_na()

Y_3v  <- as.data.frame(model.matrix(~ Fotobionte_clean - 1, data = df_3v))
X1_3v <- as.data.frame(model.matrix(~ Familia - 1, data = df_3v))  # FILOGENIA
X2_3v <- as.data.frame(model.matrix(~ Biotipo - 1, data = df_3v))  # MORFOLOGÍA
X3_3v <- as.data.frame(model.matrix(~ Sustrato - 1, data = df_3v)) # ECOLOGÍA

mod_3v <- varpart(Y_3v, X1_3v, X2_3v, X3_3v)

df_res_3v <- as.data.frame(mod_3v$part$indfract) %>%
  mutate(Fraccion = rownames(.)) %>%
  select(Fraccion, everything())
write_xlsx(df_res_3v, "output/09_Tabla_Varianza_3Vias.xlsx")

# Exportar Figura Euler (SVG)
vp_3v <- pmax(0, df_res_3v$Adj.R.square[1:7]) * 100
diag_3v <- euler(c(
  "Familia" = vp_3v[1], "Biotipo" = vp_3v[2], "Sustrato" = vp_3v[3],
  "Familia&Biotipo" = vp_3v[4], "Familia&Sustrato" = vp_3v[5], "Biotipo&Sustrato" = vp_3v[6],
  "Familia&Biotipo&Sustrato" = vp_3v[7]
))
etiquetas_3v <- paste0(sprintf("%.1f", diag_3v$original.values), "%")

svglite("output/09_Figura_Euler_3Vias.svg", width = 14, height = 14, bg = "transparent")
print(plot(diag_3v, 
           fills = list(fill = c("#4E7E1A", "#D4AC0D", "#0B536E"), alpha = 0.6), 
           labels = list(cex = 2.5, font = 2), 
           quantities = list(labels = etiquetas_3v, cex = 2.0, font = 2),
           main = list(label = "Determinantes de la Simbiosis (Genética vs Ambiente)", cex = 2.8, font = 2)))
dev.off()

message("✅ SCRIPT 09 (Varpart): Modelos ejecutados y guardados correctamente con diagramas de Euler.")
