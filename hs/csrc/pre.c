#include <unistd.h>
#include <string.h>

extern void hs_init(int*, char***);
extern void hs_exit();
extern void setup();

int argc = 0;
char* argv[] = { NULL };
char** pargv = argv;

void __attribute__((constructor)) pre() {
    hs_init(&argc, &pargv);
    setup();
}

void __attribute__((destructor)) post() {
    hs_exit();
}
