

#include <cuda.h>
#include <cuda_runtime.h>
#include "seamcarver.h"
#include <conio.h>

#define MAX_THREADS 1024
using namespace std;

// Kernel functions.

__global__
static void find_min_kernel(float* row, float* mins, int* min_indices,
    int width, int power) {
  // Compute current index.
  int tx = threadIdx.x;
  int bx = blockIdx.x;
  int index = tx + bx * power;

  // Set up shared memory for tracking mins.
  extern __shared__ float shared_memory[];
  float* shared_mins = (float*) shared_memory;
  int* shared_min_indices = (int*) (&(shared_memory[power]));

  // Copy global intermediate values into shared memory.
  shared_mins[tx] = (index < width) ? row[index] : MAX_VALUE;
  shared_min_indices[tx] = (index < width) ? index : MAX_VALUE;
  
  __syncthreads();

  // Do the reduction for value pairs.
  for (int i = power / 2; i > 0; i >>= 1){
		if (tx < i)
				if (shared_mins[tx] > shared_mins[tx + i])
				{
					shared_mins[tx] = shared_mins[tx + i];
					shared_min_indices[tx] = shared_min_indices[tx + i];
				}
		__syncthreads();
  }

  // Thread 0 has the solution.
	if (tx == 0){
			mins[bx] = shared_mins[0];
			min_indices[bx] = shared_min_indices[0];
	}
}


__global__
void compute_min_cost_kernel(float* energies, float* min_costs , float* temp_d ,
    int width, int height, int row) {
  // Extract thread and block index information
	int tx = threadIdx.x;
	int bx = blockIdx.x;
	int col = bx * MAX_THREADS + tx;

	if(col >= width )  // for excess threads
		  return;

	float left , right , middle;
	if(bx == 0)
		  left = (tx > 0) ? temp_d[tx - 1] : MAX_VALUE;
	else
		  left = temp_d[col - 1];
	middle = temp_d[col];
	right = ( col < width - 1) ? temp_d[col + 1] : MAX_VALUE;

	float minimum = min(left, min(middle, right));
    float cost= minimum + energies[row * width + col];
	
    __syncthreads();
    temp_d[col] = cost;

   	__syncthreads();
	min_costs[row * width + col] = cost;
}

// Class methods.


Seamcarver::Seamcarver(Image* image) {
  _image = image;
}

Seamcarver::~Seamcarver() {

}

// Simply remove n seams.
void Seamcarver::removeSeams(int n) {
  for (int i = 0; i < n; i++) 
		removeSeam();
}

// Removes 1 seam.
void Seamcarver::removeSeam() {
	findSeam();
	_image->removeSeam(_seam);
}


// Finds the seam of the lowest cost.
void Seamcarver::findSeam() {
  Energies energies(_image);
  energies.compute();
  float* energies_h = energies.getEnergies();

  int width = energies.width();
  int height = energies.height();

  // Declare pointers for device and host memory
  float* energies_d;
  float* min_cost_d;
  float* temp_d;
  float* temp_h = &(energies_h[0]);
    
  int row_size= width * sizeof(float);
  int size = width * height * sizeof(float);
  
  // Allocate device memory and for inputs and outputs
  cudaMalloc((void**) &energies_d, size);
  cudaMemcpy(energies_d, energies_h, size, cudaMemcpyHostToDevice);
  cudaMalloc((void**) &min_cost_d, size);
  cudaMalloc((void**) &temp_d,row_size);
  cudaMemcpy(temp_d, temp_h, row_size, cudaMemcpyHostToDevice);
 
  // Invoke the kernel to compute the min cost table
  int num_blocks = (width - 1) / MAX_THREADS + 1;
  int num_threads = min(MAX_THREADS, width);
  dim3 dim_grid(num_blocks, 1, 1);
  dim3 dim_block(num_threads, 1, 1);
  
  for(int row = 1; row < height ; row++)        // calculate minimum cost table row by row
		 compute_min_cost_kernel<<<dim_grid, dim_block>>>
			(energies_d, min_cost_d,temp_d, width, height, row);          //kernel call happens height times ie no. of rows

  // Transfer result from device to host
  cudaMemcpy(energies_h, min_cost_d, size, cudaMemcpyDeviceToHost);
  cudaFree(energies_d);
  cudaFree(min_cost_d);

   // Calculate threads and blocks for a minimum reduction
  num_threads = min(nextPower2(width), MAX_THREADS); // nextPower2 For nearest Power of 2 ie for 1029 ans. 2048
  num_blocks = (width - 1) / num_threads + 1;
  int mins_size = num_blocks * sizeof(float);
  int min_indices_size = num_blocks * sizeof(int);
  int shared_size = num_threads * (sizeof(float) + sizeof(int));

  // Declare pointers for device and host memory
  float* row = &(energies_h[(height - 1) * width]);
  float* mins = (float*) malloc(mins_size);
  int* min_indices = (int*) malloc(min_indices_size);
  float* row_d;
  float* mins_d;
  int* min_indices_d;

  cudaMalloc((void**) &row_d, row_size);
  cudaMemcpy(row_d, row, row_size, cudaMemcpyHostToDevice);
  cudaMalloc((void**) &mins_d, mins_size);
  cudaMalloc((void**) &min_indices_d, mins_size);
  
  // Use the kernel function to find intermediate minimums
  find_min_kernel<<<num_blocks, num_threads, shared_size>>>
      (row_d, mins_d, min_indices_d, width, num_threads);

  // Compute final minimum
  cudaMemcpy(mins, mins_d, mins_size, cudaMemcpyDeviceToHost);
  cudaMemcpy(min_indices, min_indices_d, min_indices_size,
	cudaMemcpyDeviceToHost);
  float minimum = mins[0];
  int min_index = min_indices[0];
   // finding minimum from bottom row
   for (int i = 1; i < num_blocks; i++) {
    if (mins[i] < minimum) {
		minimum = mins[i];
		min_index = min_indices[i];
    }
 }
   
  // Create the seam in reverse order.
  _seam.clear();
  _seam.push_back(min_index);

  for (int i = height - 2; i >= 0; i--) {
    float left = energies.get(i, min_index - 1);
    float middle = energies.get(i, min_index);
    float right = energies.get(i, min_index + 1);

    // Have the seam follow the least cost.
    if (left < middle && left < right) {
      min_index--; // go left
    } else if (right < middle && right < left) {
      min_index++; // go right
    }
	// Append to the seam.
    _seam.push_back(min_index);
  }

  // Clean up.
  std::reverse(_seam.begin(), _seam.end());
}

int Seamcarver::nextPower2(int n) {
  n--;
  n = n >>  1 | n;
  n = n >>  2 | n;
  n = n >>  4 | n;
  n = n >>  8 | n;
  n = n >> 16 | n;
  return ++n;
}
