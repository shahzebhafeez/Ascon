/*
  * Copyright (C) 2022 Southern Storm Software, Pty Ltd.
  *
  * Permission is hereby granted, free of charge, to any person obtaining a
  * copy of this software and associated documentation files (the "Software"),
  * to deal in the Software without restriction, including without limitation
  * the rights to use, copy, modify, merge, publish, distribute, sublicense,
  * and/or sell copies of the Software, and to permit persons to whom the
  * Software is furnished to do so, subject to the following conditions:
  *
  * The above copyright notice and this permission notice shall be included
  * in all copies or substantial portions of the Software.
  *
  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
  * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  * DEALINGS IN THE SOFTWARE.
  */
  
 #ifndef ASCON_PERMUTATION_H
 #define ASCON_PERMUTATION_H
  
 #include <stdint.h>
 #include <stddef.h>
  
 #ifdef __cplusplus
 extern "C" {
 #endif
  
 typedef union
 {
     uint64_t S[5];                  
     uint32_t W[10];                 
     uint8_t B[40];                  
     void *P[40 / sizeof(void *)];   
 } ascon_state_t;
  
 void ascon_init(ascon_state_t *state);
  
 void ascon_free(ascon_state_t *state);
  
 void ascon_add_bytes
     (ascon_state_t *state, const uint8_t *data, unsigned offset, unsigned size);
  
 void ascon_overwrite_bytes
     (ascon_state_t *state, const uint8_t *data, unsigned offset, unsigned size);
  
 void ascon_overwrite_with_zeroes
     (ascon_state_t *state, unsigned offset, unsigned size);
  
 void ascon_extract_bytes
     (const ascon_state_t *state, uint8_t *data, unsigned offset, unsigned size);
  
 void ascon_extract_and_add_bytes
     (const ascon_state_t *state, const uint8_t *input, uint8_t *output,
      unsigned offset, unsigned size);
  
 void ascon_extract_and_overwrite_bytes
     (ascon_state_t *state, const uint8_t *input, uint8_t *output,
      unsigned offset, unsigned size);
  
 void ascon_permute(ascon_state_t *state, uint8_t first_round);
  
 #define ascon_permute12(state) ascon_permute((state), 0)
  
 #define ascon_permute8(state) ascon_permute((state), 4)
  
 #define ascon_permute6(state) ascon_permute((state), 6)
  
 void ascon_release(ascon_state_t *state);
  
 void ascon_acquire(ascon_state_t *state);
  
 void ascon_copy(ascon_state_t *dest, const ascon_state_t *src);
  
 #ifdef __cplusplus
 }
 #endif
  
 #endif
