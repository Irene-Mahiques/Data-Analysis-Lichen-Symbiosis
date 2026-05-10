# 🍄 Lichen-Net: Diversidad taxonómica y redes de interacción mico-fotobionte en la Comunidad Valenciana
### Una aproximación funcional y multiescala

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

## 🚀 Escalabilidad y Aplicaciones Transversales (Use Cases)

Aunque este pipeline fue validado con datos empíricos de simbiosis liquénicas, la arquitectura de modelado topológico y los scripts bioestadísticos son directamente extrapolables a otros campos de la **Biología de Sistemas** y la **Ciencia de Datos**:

*   **Microbioma y Metagenómica:** Identificación de taxones clave (*keystone species*) en microbiotas intestinales o de suelos agronómicos mediante el análisis de roles topológicos ($z$ y $c$).
*   **NAMs (New Approach Methodologies):** Modelado de interacciones bipartitas en redes de toxicología predictiva (ej. interacciones Compuesto-Proteína) para alternativas a la experimentación animal.
*   **Epidemiología y Salud Pública:** Análisis de anidamiento y compartimentación en redes de transmisión huésped-patógeno.
*   **Agroecología:** Cuantificación de la estabilidad y el solapamiento de nicho en redes mutualistas planta-polinizador.
  
---

## 🧬 Pipeline del Proyecto

### 1. Fase Experimental (Laboratorio Molecular)
Protocolos optimizados para la obtención de datos genómicos en organismos liquenizados:
*   **Extracción de ADN:** Métodos de extracción rápida mediante resina Chelex® 100.
*   **Amplificación Multilocus (PCR):** Optimización de reacciones para marcadores nucleares (ITS, LSU), mitocondriales (mtSSU) y plastidiales (rbcL) utilizando la polimerasa MyTaq™.
*   **Purificación:** Protocolos de limpieza enzimática mediante ExoCleanUp FAST® previos a la secuenciación.

### 2. Fase Analítica (Ecología Computacional en R)
El flujo de trabajo se divide en 12 etapas secuenciales (disponibles en `/scripts`):

#### I. Preprocesamiento y Biodiversidad
* `01_data_cleaning.R`: Limpieza, estandarización taxonómica y manejo de *missing values*.
* `02_alpha_diversity.R`: Cálculo de índices de Shannon, Simpson y Equidad de Pielou.
* `03_rarefaction_curves.R`: Validación del esfuerzo de muestreo mediante curvas de acumulación.
* `04_beta_diversity.R`: Análisis de similitud florística (Bray-Curtis & Ward.D2).

#### II. Ecología Funcional y Modelado
* `05_structural_characterization.R`: Visualización multipanel de biotipos, sustratos y reproducción.
* `06_glm_analysis.R`: Validación estadística de diferencias mediante GLM multinomiales.
* `09_variance_partitioning.R`: Partición de varianza para determinar el peso de la geografía, biología y filogenia.

#### III. Análisis de Redes y Nichos
* `07_network_and_niche_analysis.R`: Inferencia de anidamiento (NODF) y solapamiento de nicho (*niche overlap*).
* `08_topological_roles_olesen.R`: Clasificación de especies en *Hubs* y *Conectores* (Análisis z-c).
* `12_bipartite_network_plots.R`: Generación de diagramas visuales de red en formato vectorial (SVG).

#### IV. Consolidación de Resultados
* `10_network_descriptives.R`: Extracción de KPIs (N total de muestras, nodos y enlaces).
* `11_floristic_catalogue.R`: Generación del inventario taxonómico y funcional automatizado.

---

## 📂 Estructura del Repositorio
* `/scripts`: Código fuente en R debidamente documentado.
* `/output`: Resultados visuales (SVG) y tablas de métricas (.xlsx).
* `/data`: (Excluido por confidencialidad).

---

## 🔒 Data Privacy & Confidentiality

> [!WARNING]
> **Aviso de Privacidad y Confidencialidad**
> 
> Los conjuntos de datos crudos utilizados en esta investigación contienen información sensible y están sujetos a acuerdos de confidencialidad con la institución y los responsables del muestreo. 
> 
> Por este motivo, el directorio `data/` ha sido excluido de este repositorio público mediante `.gitignore`. Para asegurar la reproducibilidad del código y permitir la revisión del pipeline, se proporciona un archivo `data/sample_data.csv` con registros anonimizados/dummy que permiten ejecutar los scripts y validar la lógica del análisis.

---

## 📈 Visualización de Resultados

### Estructura de la Comunidad


### Análisis de Especialización


### Red de Interacción (Biotipo)

---

## 📑 Cómo citar (Citation)

### Formato APA
> Mahiques-Andrés, I. (2026). *Lichen-Net: Diversidad taxonómica y redes de interacción mico-fotobionte en la Comunidad Valenciana*. GitHub Repository.

### Formato BibTeX
```bibtex
@software{mahiques_lichen_2026,
  author = {Mahiques Andrés, Irene},
  title = {Lichen-Net: Diversidad taxonómica y redes de interacción mico-fotobionte en la Comunidad Valenciana},
  year = {2026},
  publisher = {GitHub},
  journal = {GitHub repository}
}
