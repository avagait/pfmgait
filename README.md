Pyramidal Fisher Motion descriptor
==================================

[F.M. Castro](https://scholar.google.es/citations?hl=es&user=xXZz8m4AAAAJ) and [M.J. Marin-Jimenez](http://www.uco.es/~in1majim/)

Quick start
-----------
Start Matlab and setup [VLFeat library](http://www.vlfeat.org/), then, type the following commands:
```matlab
cd <pfmrootfolder>
addpath(genpath(pwd))
downloadPFMData        % Optional
demopfm
```

Alternatively, you can run the whole pipeline from an 'avi' video by typing ```demopipeline``` in Matlab.

See ```README.pfm.txt```[1,4],  ```README.audio.txt```[2], ```README.prl.txt```[3] and ```README.mva.txt```[5] for further details.

If you use this code, please, cite any of the following papers:

[1] Francisco M. Castro, Manuel J. Marín-Jiménez, Rafael Medina Carnicer,
["Pyramidal Fisher Motion for Multiview Gait Recognition"](http://arxiv.org/abs/1403.6950), in Proc. ICPR, 2014, pp. 1692-1697

[2] Francisco M. Castro, Manuel J. Marín-Jiménez, Nicolás Guil, 
["Empirical Study of Audio-Visual Features Fusion for Gait Recognition"](http://link.springer.com/chapter/10.1007%2F978-3-319-23192-1_61), in Proc. CAIP, 2015, pp. 727-739

[3] M. Marin-Jimenez, F.M. Castro, A. Carmona-Poyato, N. Guil,
["On how to improve tracklet-based gait recognition systems"](http://www.sciencedirect.com/science/article/pii/S0167865515002901), Pattern Recognition Letters, vol. 68, 2015, pp. 103-110

[4] M. Marin-Jimenez, F.M. Castro, N. Guil, R. Muñoz Salinas,
["Fisher Motion Descriptor for Multiview Gait Recognition"] (http://arxiv.org/abs/1601.06931)
arXiv:1601.06931, January 2016

[5] F.M. Castro, M. Marin-Jimenez, N. Guil,
["Multimodal features fusion for gait, gender and shoes recognition"] (https://doi.org/10.1007/s00138-016-0767-5)
Machine Vision and Applications, May 2016
