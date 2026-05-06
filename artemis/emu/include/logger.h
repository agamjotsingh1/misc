#ifndef DIAGNOSTICS_DEF
#define DIAGNOSTICS_DEF

#include <stdio.h>
#include <stdlib.h>

#define ERROR(fmt, ...) \
    do { \
        printf("\033[0;31m[ARTEMIS ERROR]\033[0m " fmt "\n", ##__VA_ARGS__); \
        exit(1); \
    } while (0)

#define DEBUG(fmt, ...) \
    do { \
        printf("\033[0;34m[ARTEMIS DEBUG]\033[0m " fmt "\n", ##__VA_ARGS__); \
    } while (0)

#define WARNING(fmt, ...) \
    do { \
        printf("\033[0;33m[ARTEMIS WARN]\033[0m " fmt "\n", ##__VA_ARGS__); \
    } while (0)

#define LOG(fmt, ...) \
    do { \
        printf("\033[0;90m[ARTEMIS LOG]\033[0m " fmt "\n", ##__VA_ARGS__); \
    } while (0)

#endif