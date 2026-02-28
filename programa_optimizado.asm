# Laboratorio: Estructura de Computadores
# Actividad: Optimizaci�n de Pipeline en Procesadores MIPS
# Objetivo: Calcular Y[i] = A * X[i] + B e identificar riesgos de datos.

# Optimizado por: Felipe Jimenez Melguizo
# 2025.02.26

.data
    vector_x: .word 1, 2, 3, 4, 5, 6, 7, 8
    vector_y: .space 32          # Espacio para 8 enteros (8 * 4 bytes)
    const_a:  .word 3
    const_b:  .word 5
    tamano:   .word 8

.text
.globl main

main:
    # --- Inicialización ---
    la $s0, vector_x      # Dirección base de X
    la $s1, vector_y      # Dirección base de Y
    lw $t0, const_a       # Cargar constante A
    lw $t1, const_b       # Cargar constante B
    lw $t2, tamano        # Cargar el tamaño del vector
    li $t3, 0             # �?ndice i = 0

loop:
    # --- Condición de salida ---
    beq $t3, $t2, fin     # Si i == tamano, salir del bucle
    
    # --- Cálculo de dirección de memoria ---
    sll $t4, $t3, 2       # Desplazamiento: t4 = i * 4
    addu $t5, $s0, $t4    # t5 = dirección de X[i]
    
    # --- Carga de dato ---
    lw $t6, 0($t5)        # Leer X[i]
    # NOTA: En un pipeline, la siguiente instrucción 'mul' depende de este 'lw'.
    
    ### Instrucción reubicada para eliminar Riesgo de Datos: Load-Use
    addu $t9, $s1, $t4    # t9 = dirección de Y[i] - Se calcula la dirección de Y[i] entre la lectura de X[i] y el cálculo de X[i] * A
    
    # --- Operación aritmética ---
    mul $t7, $t6, $t0     # t7 = X[i] * A  (ELIMINADO Riesgo de datos: Load-Use)
    
    ### Instrucción reubicada para eliminar Riesgo de Datos: Dependencia mul-addu
    addi $t3, $t3, 1      # i = i + 1 - Se calcula i + 1 entre el cálculo de X[i] * A y el valor total de Y[i]
    
    # --- Cálculo del valor total de Y[i]
    addu $t8, $t7, $t1    # t8 = t7 + B    (REDUCIDO Riesgo de datos: Dependencia mul-addu)
    
    # --- Almacenamiento de resultado ---
    sw $t8, 0($t9)        # Guardar resultado en Y[i]
    
    # --- salto ---
    j loop

fin:
    # --- Finalización del programa ---
    li $v0, 10            # Syscall para terminar ejecución
    syscall
