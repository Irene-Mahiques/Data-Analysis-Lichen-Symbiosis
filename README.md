# 🍄 Lichen-Symbiont Interaction Networks: Molecular & Ecological Pipeline

[![R-v4.3.2](https://img.shields.io/badge/R-v4.3.2-blue.svg)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Investigadora:** Irene Mahiques Andrés  
**Especialidad:** Biología de Sistemas | Ecología Molecular  
**Institución:** Universitat de València (UV)

---

## 🎯 Resumen del Proyecto
Este repositorio documenta el flujo de trabajo desarrollado para el modelado de redes de interacción bipartitas entre micobiontes y fotobiontes en ecosistemas de la Comunidad Valenciana ($N=576$). 

El proyecto integra protocolos de **laboratorio molecular** (extracción y amplificación de marcadores multilocus) con un robusto **pipeline de análisis estadístico en R** para cuantificar la estabilidad y arquitectura de las simbiosis liquénicas.

---

## 🧬 Pipeline del Proyecto

### 1. Fase Experimental (Laboratorio Molecular)
Protocolos optimizados para la obtención de datos genómicos en organismos liquenizados:
*   **Extracción de ADN:** Métodos de extracción rápida mediante resina Chelex® 100.
*   **Amplificación Multilocus (PCR):** Optimización de reacciones para marcadores nucleares (ITS, LSU), mitocondriales (mtSSU) y plastidiales (rbcL) utilizando la polimerasa MyTaq™.
*   **Purificación:** Protocolos de limpieza enzimática mediante ExoCleanUp FAST® previos a la secuenciación.

### 2. Fase Analítica (Ecología Computacional en R)
Procesamiento estadístico de las matrices taxonómicas resultantes ($N=576$):
*   **Diversidad Alfa y Beta:** Cálculo de riqueza específica (S), índices de Shannon, Simpson y equidad de Pielou. Validación mediante curvas de rarefacción y análisis de agrupamiento jerárquico (Bray-Curtis/Ward) mediante `vegan`.
*   **Modelado Estadístico y Partición de Varianza:** Modelos Lineales Generalizados (GLM) multinomiales (`nnet`) y análisis de partición de la varianza (`varpart`) para cuantificar el peso de los determinantes ecológicos (biotipo, sustrato, geografía).
*   **Análisis de Redes Bipartitas:** Inferencia de topología (paquete `bipartite`), métricas de anidamiento (NODF), modularidad ($Q$) y especialización global ($H'_2$).
*   **Roles Topológicos:** Clasificación de especies en *hubs* y conectores mediante análisis de conectividad intra-módulo ($z$) e inter-módulo ($c$).

---

## 📂 Estructura del Repositorio
*   [`/scripts`](./scripts): 
    *   `01_data_cleaning.R`: Limpieza de datos, manejo de *missing values* y estandarización de matrices.
    *   `02_diversity_metrics.R`: Scripts para el cálculo de biodiversidad y rarefacción.
    *   `03_network_topology.R`: Inferencia de métricas de red y ejecución de modelos nulos.
    *   `04_visualization.R`: Generación de figuras de alta calidad (ggplot2, bipartite plots).
*   [`/output`](./output): Resultados visuales (SVG) y tablas de métricas topológicas.

---

## 📈 Visualización de Resultados

### Estructura de la Comunidad


### Análisis de Especialización


### Red de Interacción (Biotipo)


---

## 📑 Cómo citar (Citation)

Si utilizas estos protocolos o scripts en tu investigación, por favor cítalos de la siguiente manera:

### Formato APA
> Mahiques-Andrés, I. (2026). *Lichen-Symbiont Interaction Networks: A molecular and statistical pipeline for ecological networks*. GitHub Repository. [Añadir-URL-de-repo]

### Formato BibTeX
```bibtex
@software{mahiques_lichen_2026,
  author = {Mahiques Andrés, Irene},
  title = {Lichen-Symbiont Interaction Networks: A molecular and statistical pipeline for ecological networks},
  year = {2026},
  publisher = {GitHub},
  journal = {GitHub repository},
  howpublished = {\url{[https://github.com/usuario/repo](https://github.com/usuario/repo)}}
}
