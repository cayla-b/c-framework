#ifndef __TEST2_H
#define __TEST2_H

#include "config.h"

#ifdef __TEST2_MAIN__
#define test2_main main
#else
#define test2_main test2_main
#endif

extern void public_test2_function(void);

#endif /* __TEST2_H */
