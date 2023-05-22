## Practica 5

Objeyivo de la practica:
Instalar el software para compilar código para el microcontrolador STM32F103.
Analizar la estructura de un programa arm escrito para un microcontrolador.
Grabar en la tarjeta de desarrollo blue pill un programa de pruebas empleando el grabador ST-LINK v2.
Modificar el programa de prueba para controlar el encendido de 5 a 10 LED mediante un par de push button.

Desarrollo:
Grabar por medio de los siguientes comandos en la blue pill :
Con el siguiente comando se crea el objeto.
arm-as blink1.s -o blink1.o
Con el siguiente comando se saca el binario.
 arm-objcopy -O binary blink1.o blink1.bin
 Con el siguiente comando se graba el programa escrito en ARM
 st-flash write 'blink1.bin' 0x8000000


![Captura desde 2023-05-22 14-53-50](https://github.com/545Mariana/Practica5/assets/109254012/a140e953-86ee-4028-8dcf-7c4d1bad99f8)
