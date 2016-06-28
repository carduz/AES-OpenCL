#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#include <openssl/engine.h>
#include <openssl/aes.h>
#include <openssl/err.h>

#include <sys/time.h>

#define MB			(1024 * 1024)

unsigned long int total_len;

void run(const char *name, unsigned char *buf, int len) {
  int pass = total_len / len;

  unsigned char key[32] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
                            0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F};


  int outlen = 0;
  struct timeval start, end;
  double total_time, throughput;

  EVP_CIPHER_CTX ctx;
  EVP_CIPHER_CTX_init(&ctx);

  EVP_CIPHER *cipher = (EVP_CIPHER *) EVP_get_cipherbyname("aes-256-ecb");

  EVP_CipherInit_ex(&ctx, cipher, NULL, key, NULL, 1);

  gettimeofday(&start, NULL);
  for (int i = 0; i < pass; i++) {
    fprintf(stderr, "%s: Pass %d/%d\n", name, i + 1, pass);
    // note we cannot run multiple pass on the same buffer, the CPU will cache it! (smart bastards at Intel)
    EVP_CipherUpdate(&ctx, buf + i * len, &outlen, buf, len);
    if (len != outlen) {
      fprintf(stderr, "Fatal error: incorrect output size.\n");
    }
  }

  gettimeofday(&end, NULL);
  total_time = end.tv_sec - start.tv_sec + (end.tv_usec - start.tv_usec) / 1000000.0;
  throughput = total_len * 8 / total_time / 1000000;
  printf("%s: %u-byte blocks, %lubytes in %f s, Throughput: %fMbps\n",
         name, len, total_len, total_time, throughput);

  EVP_CIPHER_CTX_cleanup(&ctx);
}

unsigned long int get_long_from_env(char *name, unsigned long int fallback) {
  char *str;
  char *endptr;
  unsigned long int res;
  
  str = getenv(name);
  
  if(!str || *str == '\0') return fallback;
  
  res = strtoul(str, &endptr, 10);
  
  if(endptr == str) {
    fprintf(stderr, "error parsing env parameter '%s'\n", name);
    return fallback;
  }
  
  return res;
}

int main(int argc, char **argv) {
  OpenSSL_add_all_algorithms();
  ERR_clear_error();
  long int err;
  unsigned char *buf;
  unsigned long int len;
  
  len = get_long_from_env("BENCH_CHUNK_SIZE", 128) * MB;
  
  total_len = get_long_from_env("BENCH_TOTAL_MEMORY", 1024) * MB;

  buf = (unsigned char *) malloc(total_len);
  
  if (!buf) {
    fprintf(stderr, "Error Allocating Memory");
    return 1;
  }

  ENGINE_load_builtin_engines();
  
#ifdef OPENCL_ENGINE
  ENGINE *e = ENGINE_by_id("dynamic");
  if(!e) {
    fprintf(stderr, "Failed to load OpenCL engine (1)!\n");
    return 1;
  }

	if (!ENGINE_ctrl_cmd_string(e, "SO_PATH", OPENCL_ENGINE, 0) ||
		!ENGINE_ctrl_cmd_string(e, "LOAD", NULL, 0)) {
		err = ERR_get_error();
		//http://home.kpn.nl/ojb-hamster/EnWIP/EnWeb/html/erro9r1s.htm - error obtained (reason) = 103
		printf("Error: %ld\n", err);
		printf("Error: %s\n", ERR_error_string(err, NULL));
		printf("Error: %s\n", ERR_reason_error_string(err));
		fprintf(stderr, "Failed to load OpenCL engine (2)!\n");
		return -1;
	}
	ENGINE_set_default(e, ENGINE_METHOD_ALL);

  run(argv[0], buf, len);

#endif
  free(buf);

  return 0;
}
