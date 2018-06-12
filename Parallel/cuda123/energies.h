

#ifndef __ENERGIES_H__
#define __ENERGIES_H__

#include <cfloat>
#include <cmath>
#include <iostream>

#include "bitmap.h"
#include "image.h"

// macros for consistency
#define MAX_VALUE FLT_MAX

class Energies {
 public:
  Energies(Image* image);
  ~Energies();

  // filter options
  void compute();

  // getters
  int width() const;
  int height() const;
  float get(int row, int col) const;
  float* getEnergies() const;
  void set(int row, int col, float value);
  void print() const;
  const float* operator [](int i) const;

 private:
  // data
  Image* _image;
  int _width;
  int _height;
  float* _energies;
};

#endif