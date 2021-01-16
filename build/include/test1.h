#ifndef __TEST1_H
#define __TEST1_H

#include "config.h"

#ifdef __TEST1_MAIN__
#define test1_main main
#else
#define test1_main test1_main
#endif

extern void public_test1_function(void);

#endif /* __TEST1_H */
