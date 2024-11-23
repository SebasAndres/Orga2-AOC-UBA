### Agregar Syscall
• Para esto tenemos que hacer una entrada de la IDT (mayor a 32 ya que están reservados, y distinto a los que usamos, en genera, entre 0x80 y 0xFF)
• Modificamos para agregar su rutina de interrupción
• Pasamos los parametros del modo que nos parezca, ya que para las syscall no
hay una convención (en general designamos algunos registros)
• Designo para llamar a la syscall los parámetros en
◦ Selector: AX
◦ Dirección virtual a leer de la tarea espiada: EDI
◦ Dirección virtual a escribir de la tarea espía: ESI