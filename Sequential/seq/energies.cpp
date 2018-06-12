

#include "energies.h"

using std::cout;
using std::endl;


Energies::Energies(Image* image) {
  _width = image->width();
  _height = image->height();
  _image = image;
  _energies = new float[_width * _height];
}


Energies::~Energies() {
  delete _energies;
}


//
void Energies::compute() {
  for (int row = 0; row < _height; row++) {
    for (int col = 0; col < _width; col++) {
      const RGBQuad& current = _image->get(row, col);
      const RGBQuad& right = _image->get(row, col + 1);
      const RGBQuad& down = _image->get(row + 1, col);

      // Compute gradient.
      // This is a vector operation, so there is room for improvement.
      float dx_red = (float)right.red - current.red;
      float dx_green = (float)right.green - current.green;
      float dx_blue = (float)right.blue - current.blue;
      float dy_red = (float)down.red - current.red;
      float dy_green = (float)down.green - current.green;
      float dy_blue = (float)down.blue - current.blue;

      // Sum the squares of differences.
      float dx2 = dx_red*dx_red + dx_green*dx_green + dx_blue*dx_blue;
      float dy2 = dy_red*dy_red + dy_green*dy_green + dy_blue*dy_blue;
      float grad = (float) sqrt(dx2 + dy2);

      // Store results.
      int index = row * _width + col;
      _energies[index] = grad;
    }
  }

}



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


void Energies::set(int row, int col, float value) {
  int index = row * _width + col;
  _energies[index] = value;
}


void Energies::print() const {
  cout << "Energies: " << endl;
  for (int i = 0; i < _height; i++) {
    for (int j = 0; j < _width; j++) {
      cout << std::fixed << std::setprecision(3) << get(i, j) << "\t";
    }
    cout << endl;
  }
  cout << endl;
}


const float* Energies::operator [](int i) const {
  return _energies + (i * _width);
};
