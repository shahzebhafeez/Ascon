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
  
 #ifndef ASCON_AEAD_COMMON_H
 #define ASCON_AEAD_COMMON_H
  
 /* Common utilities for supporting the implementation of AEAD modes */
  
 #include <ascon/aead.h>
 #include <ascon/permutation.h>
 #include <ascon/utility.h>
  
 int ascon_aead_check_tag
     (unsigned char *plaintext, size_t plaintext_len,
      const unsigned char *tag1, const unsigned char *tag2, size_t size);
  
 void ascon_aead_absorb_8
     (ascon_state_t *state, const unsigned char *data,
      size_t len, uint8_t first_round, int last_permute);
  
 void ascon_aead_absorb_16
     (ascon_state_t *state, const unsigned char *data,
      size_t len, uint8_t first_round, int last_permute);
  
 unsigned char ascon_aead_encrypt_8
     (ascon_state_t *state, unsigned char *dest,
      const unsigned char *src, size_t len, uint8_t first_round,
      unsigned char partial);
  
 unsigned char ascon_aead_encrypt_16
     (ascon_state_t *state, unsigned char *dest,
      const unsigned char *src, size_t len, uint8_t first_round,
      unsigned char partial);
  
 unsigned char ascon_aead_decrypt_8
     (ascon_state_t *state, unsigned char *dest,
      const unsigned char *src, size_t len, uint8_t first_round,
      unsigned char partial);
  
 unsigned char ascon_aead_decrypt_16
     (ascon_state_t *state, unsigned char *dest,
      const unsigned char *src, size_t len, uint8_t first_round,
      unsigned char partial);
  
 #endif