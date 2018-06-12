
#ifndef __BITMAP_H__
#define __BITMAP_H__


//
// Constants for the biCompression field
//
#define BF_TYPE 0x4D42             /* MB */
#define BI_RGB       0             /* No compression - straight BGR data */
#define BI_RLE8      1             /* 8-bit run-length compression */
#define BI_RLE4      2             /* 4-bit run-length compression */
#define BI_BITFIELDS 3             /* RGB bitmap with RGB masks */


//
// BMP file header structure
// Must be 2-byte aligned for reading the binary.
//
#pragma pack(2)
typedef struct {
  unsigned short bfType;           /* Magic number for file */
  unsigned int   bfSize;           /* Size of file */
  unsigned short bfReserved1;      /* Reserved */
  unsigned short bfReserved2;      /* ... */
  unsigned int   bfOffBits;        /* Offset to bitmap data */
} BitmapFileHeader;
#pragma pack()


//
// BMP file info structure
//
typedef struct {
  unsigned int   biSize;           /* Size of info header */
  int            biWidth;          /* Width of image */
  int            biHeight;         /* Height of image */
  unsigned short biPlanes;         /* Number of color planes */
  unsigned short biBitCount;       /* Number of bits per pixel */
  unsigned int   biCompression;    /* Type of compression to use */
  unsigned int   biSizeImage;      /* Size of image data */
  int            biXPelsPerMeter;  /* X pixels per meter */
  int            biYPelsPerMeter;  /* Y pixels per meter */
  unsigned int   biClrUsed;        /* Number of colors used */
  unsigned int   biClrImportant;   /* Number of important colors */
} BitmapInfoHeader;


//
// Colormap entry structure
//
typedef struct {
  unsigned char blue;              /* Blue value */
  unsigned char green;             /* Green value */
  unsigned char red;               /* Red value */
  unsigned char reserved;          /* Reserved */
} RGBQuad;

#endif
