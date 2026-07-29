/* Tiny shim for __stack_chk_fail and __stack_chk_guard.
 *
 * Qt6EntryPoint.a (built with MSVC + -fstack-protector) references these
 * symbols, but Ubuntu's mingw-w64 doesn't ship libssp. We provide them here.
 *
 * __stack_chk_guard is a random canary value; __stack_chk_fail is called
 * when a stack overflow is detected. For a desktop app, aborting is fine.
 */
#include <stdint.h>
#include <stdlib.h>

/* 64-bit canary value (matching GCC's libssp convention). */
uintptr_t __stack_chk_guard = 0xdeadbeefcafebabeULL;

void __stack_chk_fail(void) {
    abort();
}
