#include <cstdint>
#include <cstdio>

const int DATA_SIZE = 32;

__global__ void smem_kernel_128(int4* ret) {
  __shared__ int4 mem[DATA_SIZE];

  // LDG.128
  for (int i = 0; i < DATA_SIZE; i++) {
    mem[i] = ret[i];
  }

  // STS.128
  for (int i = 0; i < DATA_SIZE; i++) {
    ret[i] = mem[i];
  }
}

__global__ void smem_kernel(int* ret) {
  __shared__ int mem[DATA_SIZE];

  // LDG.32
  for (int i = 0; i < DATA_SIZE; i++) {
    mem[i] = ret[i];
  }

  // STS.32
  for (int i = 0; i < DATA_SIZE; i++) {
    ret[i] = mem[i];
  }
}

// nvcc -cubin LDG_STS.cu
// nvdisasm -c LDG_STS.cubin > LDG_STS.sass

int main() {
  int4* d_ret_128;
  int* d_ret;
  cudaMalloc(&d_ret_128, DATA_SIZE * sizeof(int4));
  cudaMalloc(&d_ret, DATA_SIZE * sizeof(int));
  smem_kernel_128<<<1, 1>>>(d_ret_128);
  smem_kernel<<<1, 1>>>(d_ret);
  cudaFree(d_ret);
  cudaFree(d_ret_128);
}