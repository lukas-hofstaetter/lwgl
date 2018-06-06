# lwgl
Leight weight variant of the gcc's gcov-library suitable for stm32.

Normally gcov does use a filesystem do dump out the coverage data. If used on a (embedded) platform without a file system the coverage data can be dumped via a serial interface. This code snippets show how to do so:

  1. Compile those sourcefiles which shall produce a coverage report with `-fprofile-arcs -ftest-coverage`. This will tell the compiler to blow up your source code with additional code which is needed to gain a coverage report.
  2. Take sure that the coverage initializers (`static_init()`) are called if not done by startup code.
  3. Run your software
  4. Call `coverage_dump()` which will dump the coverage data as an human readable format to serial console and capture the data on that serial interface. You may use `cat /dev/ttyUSB0 > inputFile.txt` for this.
  5. Then call `lwfs.sh inputFile.txt` (see example in lwfs.sh) which creates all *.gcov files on your hard disk.
  6. Much fun. 
  
This method works pretty good for me. I addded some shell scripts to my makefile to do all these steps automatically. It works pretty fine. Much fun with it!

NOTE: Works for me with arm-none-eabi-gcc (GNU Tools for ARM Embedded Processors) 5.4.1 
  
