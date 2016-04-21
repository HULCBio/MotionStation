% Image Processing Toolbox --- demos and sample images
%
%   iptdemos        - Index of Image Processing Toolbox demos.
%
%   dctdemo         - 2-D DCT image compression demo.
%   edgedemo        - Edge detection demo.
%   firdemo         - 2-D FIR filtering and filter design demo.
%   imadjdemo       - Intensity adjustment and histogram equalization demo.
%   ipexangle       - Measuring Angle of Intersection.
%   ipexcontrast    - Contrast Enhancement Techniques.
%   ipexfabric      - Color-based Segmentation Using the L*a*b* Color Space.
%   ipexhistology   - Color-based Segmentation Using K-Means Clustering.
%   ipexlanstretch  - Enhancing Multispectral Color Composite Images.
%   ipexpendulum    - Finding the Length of a Pendulum in Motion.
%   ipexradius      - Measuring Radius.
%   ipexreconstruct - Reconstructing an Image from Projection Data.
%   ipexregularized - Deblurring Images Using a Regularized Filter.
%   ipexrice        - Correcting Nonuniform Illumination.
%   ipexrotate      - Finding the Rotation and Scale of a Distorted Image.
%   ipexroundness   - Identifying Round Objects.
%   ipexsnow        - Granulometry of Snowflakes. 
%   ipexwatershed   - Marker-controlled watershed segmentation.
%   landsatdemo     - Landsat color composite demo.
%   nrfiltdemo      - Noise reduction filtering demo.
%   qtdemo          - Quadtree decomposition demo.
%   roidemo         - Region-of-interest processing demo.
%
% Extended-example helper M-files.
%   ipex001      - Used by image padding and shearing example.      
%   ipex002      - Used by image padding and shearing example.      
%   ipex003      - Used by MRI slicing example.
%   ipex004      - Used by conformal mapping example. 
%   ipex005      - Used by conformal mapping example. 
%   ipex006      - Used by conformal mapping example. 
%
% Sample MAT-files.
%   imdemos.mat           - Images used in demos.
%   pendulum.mat          - Used by ipexpendulum.
%   regioncoordinates.mat - Used by ipexfabric.
%   trees.mat             - Scanned painting.
%   westconcordpoints.mat - Used by aerial photo registration example.
%
% Sample FITS images.
%   solarspectra.fts
%
% Sample JPEG images.
%   football.jpg
%   greens.jpg
%
% Sample PNG images.
%   blobs.png
%   circles.png
%   coins.png
%   concordorthophoto.png
%   concordaerial.png
%   fabric.png
%   gantrycrane.png
%   glass.png
%   hestain.png
%   liftingbody.png
%   onion.png
%   pears.png
%   peppers.png
%   pillsetc.png
%   rice.png
%   saturn.png
%   snowflakes.png
%   tape.png
%   testpat1.png
%   text.png
%   tissue.png
%   westconcordorthophoto.png
%   westconcordaerial.png
%
% Sample TIFF images.
%   autumn.tif  
%   board.tif
%   cameraman.tif
%   canoe.tif   
%   cell.tif
%   circbw.tif
%   circuit.tif
%   eight.tif   
%   forest.tif
%   kids.tif
%   logo.tif
%   m83.tif
%   moon.tif
%   mri.tif
%   paper1.tif
%   pout.tif
%   shadow.tif
%   spine.tif
%   tire.tif
%   trees.tif
%
% Sample Landsat images.
%   littlecoriver.lan
%   mississippi.lan
%   montana.lan
%   paris.lan
%   rio.lan
%   tokyo.lan
%
%
% Photo credits
%   board:
%
%     Computer circuit board, courtesy of Alexander V. Panasyuk,
%     Ph.D., Harvard-Smithsonian Center for Astrophysics.
%
%   cameraman:
%
%     Copyright Massachusetts Institute of Technology.  Used with
%     permission.
%
%   cell:
%
%     Cancer cell from a rat's prostate, courtesy of Alan W. Partin, M.D,
%     Ph.D., Johns Hopkins University School of Medicine.
%
%   circuit:
%
%     Micrograph of 16-bit A/D converter circuit, courtesy of Steve
%     Decker and Shujaat Nadeem, MIT, 1993. 
%
%   concordaerial and westconcordaerial:
%
%     Visible color aerial photographs courtesy of mPower3/Emerge.
%
%   concordorthophoto and westconcordorthophoto:
%
%     Orthoregistered photographs courtesy of Massachusetts Executive Office
%     of Environmental Affairs, MassGIS.
%
%   forest:
%
%     Photograph of Carmanah Ancient Forest, British Columbia, Canada,
%     courtesy of Susan Cohen. 
%
%   gantrycrane:
%
%     Gantry crane used to build a bridge, courtesy of Jeff Mather.
%   
%   hestain:
%
%     Image of tissue stained with hemotoxylin and eosin (H&E) at 40X
%     magnification, courtesy of Alan W. Partin, M.D., Ph.D., Johns Hopkins
%     University School of Medicine.
%
%   liftingbody:
%
%     Public domain image of M2-F1 lifting body in tow, courtesy of NASA,
%     1964-01-01, Dryden Flight Research Center #E-10962, GRIN database
%     #GPN-2000-000097.
%
%   m83:
%
%     M83 spiral galaxy astronomical image courtesy of Anglo-Australian
%     Observatory, photography by David Malin. 
%
%   moon:
%
%     Copyright Michael Myers.  Used with permission.
%
%   pears:
%
%     Copyright Corel.  Used with permission.
%
%   tissue:
%
%     Cytokeratin CAM 5.2 stain of human prostate tissue, courtesy of 
%     Alan W. Partin, M.D, Ph.D., Johns Hopkins University School
%     of Medicine.
%
%   trees:
%
%     Trees with a View, watercolor and ink on paper, copyright Susan
%     Cohen.  Used with permission. 
%
%   LAN files:
%
%     Permission to use Landsat TM data sets provided by Space Imaging,
%     LLC, Denver, Colorado.
%
%   saturn:
%
%     Public domain image courtesy of NASA, Voyager 2 image, 1981-08-24, 
%     NASA catalog #PIA01364
%
%   solarspectra:
%
%     Solar spectra image courtesy of Ann Walker, Boston University.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.27.4.7 $  $Date: 2003/05/03 17:52:49 $
