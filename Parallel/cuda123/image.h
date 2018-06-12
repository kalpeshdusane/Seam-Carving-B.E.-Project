
#ifndef __IMAGE_H__
#define __IMAGE_H__

#include <iostream>
#include <stdio.h>
#include <vector>
#include "bitmap.h"

class Image {
 public:
  Image(const char* path);
  ~Image();
  void removeSeam(std::vector<int>& seam);
  void save(const char* path) const;

  // getters
  int width() const;
  int height() const;
  const RGBQuad& get(int row, int col) const;
  const RGBQuad* getPixels() const;
  const RGBQuad* operator [](int i) const;

 private:
  void readBitmap(FILE* file);

  // data
  int _width;
  int _height;
  RGBQuad* _pixels;

  // TODO: Should use some sort of polymorphism here.
  BitmapFileHeader _file_header;
  BitmapInfoHeader _info_header;
};

#endif