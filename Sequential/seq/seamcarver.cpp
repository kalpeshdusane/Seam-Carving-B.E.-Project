
#include "seamcarver.h"

using std::cout;
using std::endl;
using std::min;
using std::vector;


Seamcarver::Seamcarver(Image* image) {
  _image = image;
}


Seamcarver::~Seamcarver() {

}


// Simply remove n seams.
void Seamcarver::removeSeams(int n) {
  for (int i = 0; i < n; i++) {
    removeSeam();
  }
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

  // Create a min cost table.
  int width = energies.width();
  int height = energies.height();
  for (int i = 0; i < height; i++) {
    for (int j = 0; j < width; j++) {
      energies.set(i, j, minCost(energies, i, j));
    }


  }

  // Find the minimum value in the bottom row.
  int min_index = 0;
  for (int col = 0; col < width; col++) {
    float min = energies.get(height - 1, min_index);
    float test = energies.get(height - 1, col);
    if (test < min) {
      min_index = col;
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


float Seamcarver::minCost(Energies& energies, int i, int j) {
  // For top row entries we return the element itself.
  if (i <= 0) {
    return energies.get(i, j);
  }

  // Take the 3 adjacent cells in the above row.
  float left = energies.get(i - 1, j - 1);
  float middle = energies.get(i - 1, j);
  float right = energies.get(i - 1, j + 1);

  // Compute the minimum, add cost of current cell.
  float minimum = min(left, min(middle, right));
  return minimum + energies.get(i, j);
}
