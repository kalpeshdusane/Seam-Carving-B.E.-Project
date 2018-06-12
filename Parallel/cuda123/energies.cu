

#include <cuda.h>
#include <cuda_runtime.h>
#include "energies.h"

#define BLOCK_WIDTH 32
#define BLOCK_HEIGHT 32

using std::cout;
using std::endl;
using std::min;


// Kernel functions.

__global__
void compute_energies_kernel(RGBQuad* image, float* energies,
    int width, int height) {
  // Extract thread and block index information
  int ty = threadIdx.y;
  int tx = threadIdx.x;
  int by = blockIdx.y;
  int bx = blockIdx.x;
  
  int row = by * BLOCK_HEIGHT + ty;
  int col = bx * BLOCK_WIDTH + tx;
  
  // Allocate shared memory with padding to avoid bank conflicts
  __shared__ RGBQuad shared_image[BLOCK_HEIGHT * (BLOCK_WIDTH + 1)];

  // Populate shared memory with image pixels
  if (row < height && col < width) {
		shared_image[ty * (blockDim.x + 1) + tx] = image[row * width + col];
  } else {
		RGBQuad& pixel = shared_image[ty * (BLOCK_WIDTH + 1) + tx];
		pixel.red = 0;
		pixel.green = 0;
		pixel.blue = 0;
		return;
  }

  // Wait for all threads to finish loading shared memory
  __syncthreads();

  // Compute differences with boundary checks
  RGBQuad& current = shared_image[ty * (BLOCK_WIDTH + 1) + tx];
  float dx2;
  float dy2;
  float dx_red,dx_green,dx_blue;
  float dy_red,dy_green,dy_blue;
  // Edges of blocks and image are special cases.
  if (col == width - 1) {
     dx_red = (float)current.red;
     dx_green = (float)current.green;
     dx_blue = (float)current.blue;
  }
  else if (tx == BLOCK_WIDTH - 1) {
     RGBQuad& right = image[row * width + col + 1]; // Access Global memory for Boundary Block
     dx_red = (float)right.red - current.red;
     dx_green = (float)right.green - current.green;
     dx_blue = (float)right.blue - current.blue;
  }else {
     RGBQuad& right = shared_image[ty * (BLOCK_WIDTH + 1) + tx + 1];
     dx_red = (float)right.red - current.red;
     dx_green = (float)right.green - current.green;
     dx_blue = (float)right.blue - current.blue;
  }
      // compute gradient in x-direction
  dx2 = dx_red * dx_red + dx_green * dx_green + dx_blue * dx_blue;

  if (row == height - 1) {
     dy_red = (float)current.red;
     dy_green = (float)current.green;
     dy_blue = (float)current.blue;
  }
  else if (ty == BLOCK_HEIGHT - 1) {
     RGBQuad& down = image[(row + 1) * width + col];		//Access Global Memory
     dy_red = (float)down.red - current.red;
     dy_green = (float)down.green - current.green;
     dy_blue = (float)down.blue - current.blue;
  }else {
     RGBQuad& down = shared_image[(ty + 1) * (BLOCK_WIDTH + 1) + tx];
     dy_red = (float)down.red - current.red;
     dy_green = (float)down.green - current.green;
     dy_blue = (float)down.blue - current.blue;
  }
		//compute gradient in y-direction
  dy2 = dy_red * dy_red + dy_green * dy_green + dy_blue * dy_blue;

  // Compute gradient
  float grad = (float) sqrt(dx2 + dy2);

  // Store results
  int index = row * width + col;
  energies[index] = grad;
}

// Class methods.

Energies::Energies(Image* image) {
  _width = image->width();
  _height = image->height();
  _image = image;
  _energies = new float[_width * _height];
}

Energies::~Energies() {
  delete _energies;
}

// Filtering options

void Energies::compute() {
  // Declare pointers for device memory
  RGBQuad* image_d;
  float* energies_d;
  int image_size = _width * _height * sizeof(RGBQuad);
  int energies_size = _width * _height * sizeof(float);

  // Allocate device memory and for inputs and outputs
  cudaMalloc((void**) &image_d, image_size);
  cudaMemcpy(image_d, _image->getPixels(), image_size, cudaMemcpyHostToDevice);
  cudaMalloc((void**) &energies_d, energies_size);

  // Invoke the kernel to compute the energies
  int num_blocks_x = (_width - 1) / BLOCK_WIDTH + 1;
  int num_blocks_y = (_height - 1) / BLOCK_HEIGHT + 1;
  int num_threads_x = min(BLOCK_WIDTH, _width);
  int num_threads_y = min(BLOCK_HEIGHT, _height);
  dim3 dim_grid(num_blocks_x, num_blocks_y, 1);
  dim3 dim_block(num_threads_x, num_threads_y, 1);
			//kernel call
  compute_energies_kernel<<<dim_grid, dim_block>>>
      (image_d, energies_d, _width, _height);

  // Transfer result from device to host
  cudaMemcpy(_energies, energies_d, energies_size, cudaMemcpyDeviceToHost);

  cudaFree(image_d);
  cudaFree(energies_d);
}

// Getters and operators

int Energies::width() const {
  return _width;
}

int Energies::height() const {
  return _height;
}

float Energies::get(int row, int col) const {
  if (row < 0 || row >= _height ||
      col < 0 || col >= _width) {
    // Return a high value so this is never the min.
    return MAX_VALUE;
  }

  // Common case.
  int index = row * _width + col;
  return _energies[index];
}

float* Energies::getEnergies() const {
  return _energies;
}

void Energies::set(int row, int col, float value) {
  int index = row * _width + col;
  _energies[index] = value;
}

void Energies::print() const {
  cout << "Energies: " << endl;
  for (int i = 0; i < _height; i++) {
    for (int j = 0; j < _width; j++) {
      cout << get(i, j) << "\t";
    }
    cout << endl;
  }
  cout << endl;
}

const float* Energies::operator [](int i) const {
  return _energies + (i * _width);
};
