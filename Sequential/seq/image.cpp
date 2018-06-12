

#include "image.h"


// namespace shortcuts
using std::cout;
using std::endl;
using std::vector;


Image::Image(const char* path) {


  // Black pixel.
  _zero.red = 0;
  _zero.green = 0;
  _zero.blue = 0;

  // Try to open and then read in file.
  FILE* file = fopen(path, "rb");
  if (file) {
    readBitmap(file);
    fclose(file);
  } else {
    cout << ">> unable to open: " << path << endl;
	std::cin.get();
	exit(1);
  }
}


Image::~Image() {
  delete _pixels;
}


int Image::width() const {
  return _width;
}


int Image::height() const {
  return _height;
}


const RGBQuad& Image::get(int row, int col) const {
  if (row < 0 || row >= _height ||
      col < 0 || col >= _width) {
    return _zero;
  }
  int index = row * _width + col;
  return _pixels[index];
}


const RGBQuad* Image::operator [](int i) const {
  return _pixels + (i * _width);
};


void Image::removeSeam(vector<int>& seam) {
  int length = (_width - 1) * _height;
  int num_removed = 0;
  for (int i = 0; i < length; i++) {
    if (num_removed < _height) {
      int row = num_removed;
      int col = seam[row];
      int index = (row * _width + col) - num_removed;
      if (i == index) {
        num_removed++;
      }
    }
    // Shift everything backwards.
    _pixels[i] = _pixels[i + num_removed];
  }

  // Update the dimensions.
  _width--;
  _info_header.biWidth = _width;
}



void Image::save(const char* path) const {
  FILE* file = fopen(path, "wb");
  fwrite(&_file_header, sizeof(BitmapFileHeader), 1, file);
  fwrite(&_info_header, sizeof(BitmapInfoHeader), 1, file);
  fwrite(_pixels, sizeof(RGBQuad), _width * _height, file);
  fclose(file);
}


//
// Private methods
//

void Image::readBitmap(FILE* file) {
  fread(&_file_header, sizeof(BitmapFileHeader), 1, file);
  fread(&_info_header, sizeof(BitmapInfoHeader), 1, file);
  _width = _info_header.biWidth;
  if(_info_header.biHeight<0)
  _height = -_info_header.biHeight; 
  else
  _height = _info_header.biHeight;

  // Read in the pixel data.
  int size = _width * _height;
  _pixels = new RGBQuad[size];
  fread(_pixels, sizeof(RGBQuad), size, file);

  // Print out some info.
  cout << ">> parsing bitmap ..." << endl;
  cout << "   width: " << _width << endl;
  cout << "   height: " << _height << endl;
}
