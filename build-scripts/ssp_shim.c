/* Tiny shim for __stack_chk_fail and __stack_chk_guard.
 *
 * Qt6EntryPoint.a (built with MSVC + -fstack-protector) references these
 * symbols, but Ubuntu's mingw-w64 doesn't ship libssp. We provide them here.
 *
 * IMPORTANT: must be compiled as C (or with extern "C" guards) so the symbol
 * names are NOT mangled by the C++ compiler.
 */
#include <stdint.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

/* 64-bit canary value (matching GCC's libssp convention). */
uintptr_t __stack_chk_guard = 0xdeadbeefcafebabeULL;

void __stack_chk_fail(void) {
    abort();
}

#ifdef __cplusplus
}
#endif
