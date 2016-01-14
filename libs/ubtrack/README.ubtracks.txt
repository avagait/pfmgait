Upper-body detection and tracking V 1.0
=======================================

Upper-body detector and tracker by V. Ferrari, M.J. Marin-Jimenez, and A. Zisserman
based on the HoG detection framework by N. Dalal and Bill Triggs [2] ( http://pascal.inrialpes.fr/soft/olt/ )


Introduction
~~~~~~~~~~~~
This package contains software for upper-body detection and tracking.
It was first used as a basis building block for a human pose estimator [1].
If you use this software for your research, please cite [1] as a reference.
We refer to [1] for a brief explanation of how the detector and tracker work,
and to [3] for a detailed explanation of the clustering algorithm at the heart of the tracker.


Compatibility
~~~~~~~~~~~~~
Both detector and tracker are portable and should work on any Unix platform.
The tracker requires Matlab v 7.0 or later to run.


Quick start
~~~~~~~~~~~

Let <dir> be the directory where the package was uncompressed.
Start matlab and enter in the matlab shell:

1) cd <dir>/matlab
2) addpath(pwd);
3) mex all_pairs_bb_iou.cxx
4) cd ..
5) test

The test program will detect upper-bodies in the test_video directory,
associate the detections over time, and display the resulting tracks.


Remarks
~~~~~~~

- the detector is designed to detect people viewed both from the front and the back.
- currently, no option is available to distinguish front and back detections.
- minimum detectable window size is [90, 100] (rows, columns).
- the tracker puts every detection in exactly one track.
  You can remove most false-positive detections by discarding short tracks (e.g. less than 10 frames).



Troubleshooting
~~~~~~~~~~~~~~~
- The HoG detector software, and therefore this entire package, builds on libImlib2.
  If you already have libImlib2 installed on your system everything should run fine.


- If you do not have libImlib2, you will get an error like 

  error while loading shared libraries: libImlib2.so.1: cannot open shared object file: No such file or directory

  In this case, try editing file HoG/detect_upperbodyH90.sh by uncommenting the line (i.e. remove '#')

  #LD_LIBRARY_PATH=$BinDIR

  This will cause a local copy of libImlib2 distributed with this package to be used.
  It is built for debian linux 3.1. If you have a difference linux release, it might fail on your machine.
  In this case, a typical error you will get is 

  Caught boost::filesystem::path: invalid name "ÿØÿà


- If the above suggestion fails, you must install the latest version of libImlib2 and everything should work fine.
  Remember to set LD_LIBRARY_PATH to the location where you installed the library.



Support
~~~~~~~

For any query/suggestion/complaint or simply to say you like/use this software, just drop us an email

mjmarin@decsai.ugr.es
ferrari@vision.ee.ethz.ch


References
~~~~~~~~~~

[1] Progressive Search Space Reduction for Human Pose Estimation
Ferrari V., Marin-Jimenez M. and Zisserman A.
Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (2008) 

[2] Histograms of Oriented Gradients for Human Detection
Dalal N. and Triggs B.
Proceedings of IEEE Conference on Computer Vision and Pattern Recognition (2005)

[3] Real-time Affine Region Tracking and Coplanar Grouping
Ferrari V., Tuytelaars T., and Van Gool L.
Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (2001)
