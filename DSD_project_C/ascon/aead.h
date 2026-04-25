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
  
 #ifndef ASCON_AEAD_H
 #define ASCON_AEAD_H
  
 #include <ascon/permutation.h>
  
 #ifdef __cplusplus
 extern "C" {
 #endif
  
 #define ASCON128_KEY_SIZE 16
  
 #define ASCON128_NONCE_SIZE 16
  
 #define ASCON128_TAG_SIZE 16
  
 #define ASCON80PQ_KEY_SIZE 20
  
 #define ASCON80PQ_NONCE_SIZE 16
  
 #define ASCON80PQ_TAG_SIZE 16
  
 #define ASCON128_RATE 8
  
 #define ASCON128A_RATE 16
  
 #define ASCON80PQ_RATE 8
  
 void ascon128_aead_encrypt
     (unsigned char *c, size_t *clen,
      const unsigned char *m, size_t mlen,
      const unsigned char *ad, size_t adlen,
      const unsigned char *npub,
      const unsigned char *k);
  
 int ascon128_aead_decrypt
     (unsigned char *m, size_t *mlen,
      const unsigned char *c, size_t clen,
      const unsigned char *ad, size_t adlen,
      const unsigned char *npub,
      const unsigned char *k);
  
 void ascon128a_aead_encrypt
     (unsigned char *c, size_t *clen,
      const unsigned char *m, size_t mlen,
      const unsigned char *ad, size_t adlen,
      const unsigned char *npub,
      const unsigned char *k);
  
 int ascon128a_aead_decrypt
     (unsigned char *m, size_t *mlen,
      const unsigned char *c, size_t clen,
      const unsigned char *ad, size_t adlen,
      const unsigned char *npub,
      const unsigned char *k);
  
 void ascon80pq_aead_encrypt
     (unsigned char *c, size_t *clen,
      const unsigned char *m, size_t mlen,
      const unsigned char *ad, size_t adlen,
      const unsigned char *npub,
      const unsigned char *k);
  
 int ascon80pq_aead_decrypt
     (unsigned char *m, size_t *mlen,
      const unsigned char *c, size_t clen,
      const unsigned char *ad, size_t adlen,
      const unsigned char *npub,
      const unsigned char *k);
  
 /* ---------------------------------------------------------------- */
 /*            Incremental API's for the AEAD modes below            */
 /* ---------------------------------------------------------------- */
  
 typedef struct
 {
     ascon_state_t state;
  
     unsigned char key[ASCON128_KEY_SIZE];
  
     unsigned char posn;
  
 } ascon128_state_t;
  
 typedef struct
 {
     ascon_state_t state;
  
     unsigned char key[ASCON128_KEY_SIZE];
  
     unsigned char posn;
  
 } ascon128a_state_t;
  
 typedef struct
 {
     ascon_state_t state;
  
     unsigned char key[ASCON80PQ_KEY_SIZE];
  
     unsigned char posn;
  
 } ascon80pq_state_t;
  
 void ascon128_aead_start
     (ascon128_state_t *state, const unsigned char *ad, size_t adlen,
      const unsigned char *npub, const unsigned char *k);
  
 void ascon128_aead_abort(ascon128_state_t *state);
  
 void ascon128_aead_encrypt_block
     (ascon128_state_t *state, const unsigned char *in,
      unsigned char *out, size_t len);
  
 void ascon128_aead_encrypt_finalize
     (ascon128_state_t *state, unsigned char *tag);
  
 void ascon128_aead_decrypt_block
     (ascon128_state_t *state, const unsigned char *in,
      unsigned char *out, size_t len);
  
 int ascon128_aead_decrypt_finalize
     (ascon128_state_t *state, const unsigned char *tag);
  
 void ascon128a_aead_start
     (ascon128a_state_t *state, const unsigned char *ad, size_t adlen,
      const unsigned char *npub, const unsigned char *k);
  
 void ascon128a_aead_abort(ascon128a_state_t *state);
  
 void ascon128a_aead_encrypt_block
     (ascon128a_state_t *state, const unsigned char *in,
      unsigned char *out, size_t len);
  
 void ascon128a_aead_encrypt_finalize
     (ascon128a_state_t *state, unsigned char *tag);
  
 void ascon128a_aead_decrypt_block
     (ascon128a_state_t *state, const unsigned char *in,
      unsigned char *out, size_t len);
  
 int ascon128a_aead_decrypt_finalize
     (ascon128a_state_t *state, const unsigned char *tag);
  
 void ascon80pq_aead_start
     (ascon80pq_state_t *state, const unsigned char *ad, size_t adlen,
      const unsigned char *npub, const unsigned char *k);
  
 void ascon80pq_aead_abort(ascon80pq_state_t *state);
  
 void ascon80pq_aead_encrypt_block
     (ascon80pq_state_t *state, const unsigned char *in,
      unsigned char *out, size_t len);
  
 void ascon80pq_aead_encrypt_finalize
     (ascon80pq_state_t *state, unsigned char *tag);
  
 void ascon80pq_aead_decrypt_block
     (ascon80pq_state_t *state, const unsigned char *in,
      unsigned char *out, size_t len);
  
 int ascon80pq_aead_decrypt_finalize
     (ascon80pq_state_t *state, const unsigned char *tag);
  
 #ifdef __cplusplus
 }
 #endif
  
 #endif