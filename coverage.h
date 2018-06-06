#ifndef COVERAGE_H_
#define COVERAGE_H_

#include "version.h"

int coverage_dump();

/**
 * Use the macro covnop() to insert a line of locial code which is recognized
 * by gcov. This may help to inspect the coverage report.
 */
#ifdef COVERAGE
  #define covnop() asm("NOP")
#else
  #define covnop()
#endif


#endif /* COVERAGE_H_ */
