#define FILES_MAX 100
static const char *stm32Files[FILES_MAX];
static int fileCounter = 0;

int _open(const char *name, int flags, int mode) {
#ifdef LWFSS_ENABLE
  if (fileCounter < FILES_MAX) {
    stm32Files[fileCounter] = name;
    return fileCounter++;
  }
#endif
  return -1;
}

int _write(int file, char *ptr, int len) {
#ifdef LWFSS_ENABLE
  static char last = '\n';
  if (file < fileCounter) {
    const char *fileName = stm32Files[file];
    if (last != '\n')                                       // print to new line
      stdPutc('\n');
    stdPutc(LWFSS_INDICATOR);                          // Start of file
    while (*fileName != '\0' && fileName < (fileName + 5))  // File name
      stdPutc(*fileName++);
    stdPutc(LWFSS_SEPARATOR);                          // Separator

    for (int i = 0; i < len; i++)                           // File content
      printf(" %02X", *ptr++);

    stdPutc('\n');                                     // end with new line
    last = '\n';
  } else {
    for (int i = 0; i < len; i++) {                          // Write STD
      stdPutc(*ptr++);
    }
    last = *(ptr-1);
  }
#endif

  return len;  // amount of data, without the filename
}
