import os
from datetime import datetime
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

# 1. Configuración de Entorno y Carga de Datos
# Reemplaza 'LINuevo12.xlsx' con la ruta de tu archivo
try:
    # Cargar columnas C y D (Entradas) y F (Salida) asumiendo que la fila 1 son encabezados
    df_input = pd.read_excel('LINuevo12.xlsx', usecols="C:D", skiprows=0).values[:896]
    df_output = pd.read_excel('LINuevo12.xlsx', usecols="F", skiprows=0).values[:896].flatten()
except FileNotFoundError:
    print("Archivo 'LINuevo12.xlsx' no encontrado. Generando datos sintéticos de prueba...")
    np.random.seed(42)
    df_input = np.random.rand(896, 2) * 50
    df_output = 2.5 * df_input[:, 0] - 1.2 * df_input[:, 1] + np.random.normal(0, 5, 896)

# 2. Funciones de Normalización Z-score (normT y desnormT)
x1m, x1s = np.mean(df_input[:, 0]), np.std(df_input[:, 0])
x2m, x2s = np.mean(df_input[:, 1]), np.std(df_input[:, 1])
x3m, x3s = np.mean(df_output), np.std(df_output)

xdata = np.zeros_like(df_input)
xdata[:, 0] = (df_input[:, 0] - x1m) / x1s
xdata[:, 1] = (df_input[:, 1] - x2m) / x2s
ydata = (df_output - x3m) / x3s

yreal = df_output
tm = len(yreal)

# 3. División de Conjuntos (Entrenamiento, Test y Validación)
ndE, ndT, ndV = 717, 89, 89
indices_totales = np.arange(tm)

# Muestreo pseudoaleatorio replicando el comportamiento de RandStream
rng = np.random.default_rng(seed=42) 

inE = rng.choice(indices_totales, size=ndE, replace=False)
restantes = np.setdiff1d(indices_totales, inE)
inT = rng.choice(restantes, size=ndT, replace=False)
inV = np.setdiff1d(restantes, inT)

# Ordenar índices tal como sort() en MATLAB
inE1, inT1, inV1 = np.sort(inE), np.sort(inT), np.sort(inV)

# Creación de arreglos finales filtrados
xdatE, ydatE, yrdatE = xdata[inE1], ydata[inE1], yreal[inE1]
xdatT, ydatT, yrdatT = xdata[inT1], ydata[inT1], yreal[inT1]
xdatV, ydatV, yrdatV = xdata[inV1], ydata[inV1], yreal[inV1]

# 4. Definición de la Red Neuronal (Estructura de pesos y activación ReLU)
def relu(x):
    return np.maximum(0, x)

def nn_model(x_input, w1, w2, b1, w_out, bout):
    """
    Representa la ecuación exacta de tu script de MATLAB:
    (((relu((x1*input1) + (x2*input2) + x3)) * x4) + x5)
    """
    layer1 = relu((w1 * x_input[:, 0]) + (w2 * x_input[:, 1]) + b1)
    return (layer1 * w_out) + bout

def postreg_r(y_pred, y_true):
    """Calcula el coeficiente de correlación de Pearson (r de postreg)"""
    return np.corrcoef(y_pred, y_true)[0, 1]

# 5. Creación de Carpetas y Bucle de Optimización Continua
fecha_str = datetime.now().strftime("%Y-%m-%d")
nomap = f"2IN_N1_relu_RN_RESULTADOS_LSQ_{fecha_str}"
os.makedirs(nomap, exist_ok=True)

valr, valrt, valrv = [], [], []
NmaxIt = 100
num = 1
c = 0

print(f"Iniciando entrenamiento del modelo. Resultados guardados en: ./{nomap}")

while c == 0:
    # Valores aleatorios iniciales entre -1 y 1 para los 5 parámetros (x0 de MATLAB)
    x0 = 2 * np.random.rand(5) - 1
    
    try:
        # curve_fit con 'lm' (Levenberg-Marquardt) emula perfectamente lsqcurvefit
        popt, pcov = curve_fit(nn_model, xdatE, ydatE, p0=x0, method='lm', maxfev=10000)
    except RuntimeError:
        # En caso de que una iteración específica no converja, continúa con la siguiente
        num += 1
        if num > NmaxIt: c = 1
        continue

    # Evaluación y desnormalización en Entrenamiento
    r0_norm = nn_model(xdatE, *popt)
    R = (r0_norm * x3s) + x3m  # desnormT
    
    # Calcular correlación de entrenamiento
    r = postreg_r(R, yrdatE)
    valr.append(r)
    
    # Evaluar criterios de aceptación (r >= 0.70)
    if 0.70 <= r < 0.999999:
        # ---- Fase de Test ----
        rt_norm = nn_model(xdatT, *popt)
        R1 = (rt_norm * x3s) + x3m
        rt = postreg_r(R1, yrdatT)
        valrt.append(rt)
        
        # ---- Fase de Validación ----
        rv_norm = nn_model(xdatV, *popt)
        R2 = (rv_norm * x3s) + x3m
        rv = postreg_r(R2, yrdatV)
        valrv.append(rv)
        
        # Guardar gráficas si cumplen criterios individuales
        fig, ax = plt.subplots(figsize=(5,4))
        ax.scatter(yrdatE, R, alpha=0.5, color='blue')
        ax.set_title(f'Entrenamiento R={r:.4f}')
        plt.savefig(f"{nomap}/grafE_{r:.4f}.jpg")
        plt.close()

        if 0.70 <= rt < 0.999999:
            fig, ax = plt.subplots(figsize=(5,4))
            ax.scatter(yrdatT, R1, alpha=0.5, color='green')
            ax.set_title(f'Test R={rt:.4f}')
            plt.savefig(f"{nomap}/grafT_{rt:.4f}.jpg")
            plt.close()

        if 0.70 <= rv < 0.999999:
            fig, ax = plt.subplots(figsize=(5,4))
            ax.scatter(yrdatV, R2, alpha=0.5, color='red')
            ax.set_title(f'Validación R={rv:.4f}')
            plt.savefig(f"{nomap}/grafV_{rv:.4f}.jpg")
            plt.close()

        # Almacenamiento de Pesos si cumple con todas las condiciones conjuntas
        if (0.70 <= rt < 0.999999) and (0.70 <= rv < 0.999999):
            if r >= 0.72:
                # Mapeo exacto de variables: popt contiene [w1, w2, b1, w_out, bout]
                np.savetxt(f"{nomap}/IW_{r:.4f}.txt", np.array([[popt[0], popt[1]]]), fmt='%f')
                np.savetxt(f"{nomap}/LW_{r:.4f}.txt", np.array([popt[3]]), fmt='%f')
                np.savetxt(f"{nomap}/B1_{r:.4f}.txt", np.array([popt[2]]), fmt='%f')
                np.savetxt(f"{nomap}/B2_{r:.4f}.txt", np.array([popt[4]]), fmt='%f')
                np.savetxt(f"{nomap}/Y2_{r:.4f}.txt", R, fmt='%f')

    # Condición de parada por número máximo de ejecuciones
    if num >= NmaxIt:
        c = 1
        max_re = max(valr) if valr else 0
        np.savetxt(f"{nomap}/RmaxE_{max_re:.4f}.txt", np.array([max_re]), fmt='%f')
        print(f"\nProceso finalizado. Máximo R de entrenamiento alcanzado: {max_re:.4f}")

    num += 1
