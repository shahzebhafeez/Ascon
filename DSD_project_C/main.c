#include <stdio.h>
#include <string.h>
#include <stdint.h>
/* Ensure these headers are in your include path from the downloaded library */
#include "aead/ascon-aead-common.c" 

/* Helper function to print data in hexadecimal format */
void print_hex(const char* label, const unsigned char* data, size_t len) {
    printf("%s: ", label);
    for(size_t i = 0; i < len; i++) {
        printf("%02x", data[i]);
    }
    printf("\n");
}

int main() {
    // 1. Initialize Ascon-80pq specific parameters
    // 160-bit key (20 bytes) [cite: 4, 313]
    unsigned char key[20] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 
                             0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 
                             0x10, 0x11, 0x12, 0x13}; 
    // 128-bit nonce (16 bytes) [cite: 5, 510]
    unsigned char nonce[16] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 
                               0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F};
                               
    // Test data [cite: 6, 7]
    unsigned char pt[16] = {0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF, 0x11, 0x22, 
                            0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x99, 0x00}; // Plaintext
    unsigned char ad[16] = {0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 
                            0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10}; // Associated Data
                            
    unsigned char ct[32]; // Buffer for Ciphertext + 16-byte Authentication Tag [cite: 8, 9]
    size_t clen;          // Changed from 'unsigned long long' to 'size_t' to match found file 

    printf("--- Ascon-80pq Golden Vector Generation ---\n");
    print_hex("Key (160-bit)", key, 20);
    print_hex("Nonce (128-bit)", nonce, 16);
    print_hex("Plaintext", pt, 16);
    print_hex("Associated Data", ad, 16);

    // 2. Execute the encryption function from ascon-aead-80pq.c 
    ascon80pq_aead_encrypt(ct, &clen, pt, 16, ad, 16, nonce, key);

    // 3. Output the mathematically correct hardware target (KAT) [cite: 12, 13, 93]
    printf("\n--- Golden Outputs for Verilog Verification ---\n");
    print_hex("Ciphertext + Tag", ct, clen);

    return 0;
}