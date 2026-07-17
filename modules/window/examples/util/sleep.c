#include <moonbit.h>
#include <stdint.h>
#include <time.h>

MOONBIT_FFI_EXPORT
void mbw_examples_sleep_millis(int32_t ms) {
  if (ms <= 0) {
    return;
  }
  struct timespec req;
  req.tv_sec = ms / 1000;
  req.tv_nsec = (long)(ms % 1000) * 1000000L;
  while (nanosleep(&req, &req) != 0) {
    // retry with remaining duration
  }
}
