#define FILES_MAX 100
static const char *stm32Files[FILES_MAX];
static int fileCounter = 0;

int _open(const char *name, int flags, int mode) {
  if (fileCounter < FILES_MAX) {
    stm32Files[fileCounter] = name;
    return fileCounter++;
  }
  return -1;
}

int _write(int file, char *ptr, int len) {
  static char last = '\n';
  if (file < fileCounter) {
    const char *fileName = stm32Files[file];
    if (last != '\n')                                       // print to new line
      serial_putc('\n');
    serial_putc(LWFSS_INDICATOR);                           // Start of file
    while (*fileName != '\0' && fileName < (fileName + 5))  // File name
      serial_putc(*fileName++);
    serial_putc(LWFSS_SEPARATOR);                           // Separator

    for (int i = 0; i < len; i++)                           // File content
      serial_printf(" %02X", *ptr++);

    serial_putc('\n');                                      // end with new line
    last = '\n';
  } else {
    for (int i = 0; i < len; i++) {                         // Write STD
      serial_putc(*ptr++);
    }
    last = *(ptr-1);
  }

  return len;  // amount of data, without the filename
}

void static_init(void) {
  /* linker defined symbols, array of function pointers */
  extern uint32_t __init_array_start, __init_array_end;
  uint32_t beg = (uint32_t) & __init_array_start;
  uint32_t end = (uint32_t) & __init_array_end;

  while (beg < end) {
    void (**p)(void);
    p = (void (**)(void)) beg; /* get function pointer */
    (*p)(); /* call constructor */
    beg += sizeof(p); /* next pointer */
  }
}
