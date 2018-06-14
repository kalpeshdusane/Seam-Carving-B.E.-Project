# Seam Carving

[![Build Status][travis-image]][travis-url]

## *Project Title* - Implementation of [*Seam Carving*](https://en.wikipedia.org/wiki/Seam_carving) for image retargetting using [CUDA](https://en.wikipedia.org/wiki/CUDA) enabled [GPU](https://en.wikipedia.org/wiki/Graphics_processing_unit)

[**SeamCarving**](https://github.com/kalpeshdusane/Seam-Carving-B.E.-Project/blob/master/Project%20exe/SeamCarving.exe) executable is provided.

## Introduction

### What is Seam Carving?

From Wikipedia :

>**Seam carving is an algorithm for image resizing**, developed by Shai Avidan, of Mitsubishi
Electric Research Laboratories (MERL), and Ariel Shamir, of the Interdisciplinary Center and MERL. It
functions by establishing a number of seams (paths of least importance) in an image and **automatically
removes seams to reduce image size or inserts seams to extend it.** Seam carving also allows manually
defining areas in which pixels may not be modified, and **features the ability to remove whole objects from
photographs.** 
>
>*The purpose of the algorithm is to display images without distortion on various media (cell
phones, PDAs) using document standards, like HTML, that already support dynamic changes in page
layout and text, but not images.*

### What is a seam?

From Wikipedia :

>Seams can be either vertical or horizontal. **A vertical seam is a path of connected pixels from top
to bottom in an image with one pixel in each row.** A horizontal seam is similar with the exception of the
connection being from left to right. The importance/energy function values a pixel by measuring its
contrast with its neighbor pixels.

![image](readmeImage/seam1.png)

![image](readmeImage/seam2.png)

## Installation

## Hardware Requirements:

| | Component | Requirement |
|--|--|--|
|1.| Processor |  Minimum Requirement: Intel Pentium 4 or above/AMD Anthon processor range or above.|
| | | Recommended Requirement: Intel i3 2nd Generation or above/AMD Phoenix or above. |
|2.|Memory | Minimum Requirements : 100MB or above. |
| | | Recommended Requirement:250MB or above. |
|3.|Hard disk space | Minimum Requirement : 120MB or above. |
| | | Recommended Requirement: 200MB or above. |
|4.|Others| CUDA enabled GPU's manufactured by NVIDIA present in PC's OR Laptops |

## For execution

1) You have a CUDA enabled GPU in your system.
2) You have CUDA runtime environment (greater than v2.3).
3) You have visual c++ runtime environment.
4) Double click on the exe.
5) Run the project.

## Publication 

- [ACCELERATED SEAM CARVING USING CUDA](https://ijret.org/volumes/2014v03/i10/IJRET20140310048.pdf)

## Contributers

-	Prathmesh
-	Kalpesh
-	Fardeen
- Swapnil

## References

- [Seam Carving for Content-Aware Image Resizing](https://dl.acm.org/citation.cfm?id=1276390) by Shai Avidan and Ariel Shamir
- [CUDASA: Compute Unified Device and Systems Architecture](https://dl.acm.org/citation.cfm?id=2386183) by M. Strengert, C. Müller, C. Dachsbacher, and T. Ertl 
- [Optimization of a single seam removal using a GPU](http://worldcomp-proceedings.com/proc/p2011/PDP3497.pdf) by Rok Cešnovar, Patricio Buliˇc, and Tomaž Dobravec
- [Fast JND-Based Video Carving with GPU Acceleration for Real-Time Video Retargeting](https://ieeexplore.ieee.org/document/5229299/) by Chen-Kuo Chiang, Shu-Fan Wang, Yi-Ling Chen, and Shang-Hong Lai
- [Run-time Image and Video Resizing Using CUDA-enabled GPUs](https://www.semanticscholar.org/paper/Run-time-Image-and-Video-Resizing-Using-GPUs-Duarte-Sendag/c3330696213035ed2d9818c44375cd68604e0a44) by Ronald Duarte and Resit Sendag

<!-- Markdown link & img dfn's -->
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics

