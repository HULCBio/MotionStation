% Image Processing Toolbox --- images/images/private
%
%   axes2pix   - Convert axes coordinates to pixel coordinates.
%   bwcheck    - Convert valid inputs to uint8 logical.
%   bwfillc    - Helper MEX-file for BWFILL.
%   bwlabel1   - Helper MEX-file for BWLABEL.
%   bwlabel2   - Helper MEX-file for BWLABEL.
%   bwlabelnmex - Helper MEX-file for BWLABELN.
%   cftoolchecknames - Helper function for Java SaveToWorkspace dialog.
%   changeclass - Change numeric storage class of image.
%   checkconn  - Check validity of connectivity argument.
%   conn2array - Convert short-cut connectivity forms to array forms.
%   convhullx  - Compatibility wrapper for CONVHULL.
%   cppredict  - Predict match for new control point.
%   cpsave     - Save control points.
%   cpselecthelp - Display help for Control Point Selection Tool.
%   cq         - Helper MEX-file for VMQUANT.
%   dct        - Discrete cosine transform.
%   ddist      - Compute discrete distance transform.
%   dicom_close_msg - Helper function for DICOMREAD, DICOMINFO.
%   dicom_create_attr - Helper function for DICOMREAD, DICOMINFO.
%   dicom_create_file_struct - Helper function for DICOMREAD, DICOMINFO.
%   dicom_create_meta_struct - Helper function for DICOMREAD, DICOMINFO.
%   dicom_decode_pixel_cells - Helper function for DICOMREAD, DICOMINFO.
%   dicom_decode_rle - Helper function for DICOMREAD, DICOMINFO.
%   dicom_dict_lookup - Helper function for DICOMREAD, DICOMINFO.
%   dicom_get_msg - Helper function for DICOMREAD, DICOMINFO.
%   dicom_get_next_tag - Helper function for DICOMREAD, DICOMINFO.
%   dicom_get_tags - Helper function for DICOMREAD, DICOMINFO.
%   dicom_has_fmeta - Helper function for DICOMREAD, DICOMINFO.
%   dicom_open_msg - Helper function for DICOMREAD, DICOMINFO.
%   dicom_read_attr - Helper function for DICOMREAD, DICOMINFO.
%   dicom_read_attr_by_pos - Helper function for DICOMREAD, DICOMINFO.
%   dicom_read_attr_metadata - Helper function for DICOMREAD, DICOMINFO.
%   dicom_read_attr_tag - Helper function for DICOMREAD, DICOMINFO.
%   dicom_read_attr_vr - Helper function for DICOMREAD, DICOMINFO.
%   dicom_read_encapsulated - Helper function for DICOMREAD, DICOMINFO.
%   dicom_read_fmeta - Helper function for DICOMREAD, DICOMINFO.
%   dicom_read_image - Helper function for DICOMREAD, DICOMINFO.
%   dicom_read_mmeta - Helper function for DICOMREAD, DICOMINFO.
%   dicom_read_native - Helper function for DICOMREAD, DICOMINFO.
%   dicom_set_image_encoding - Helper function for DICOMREAD, DICOMINFO.
%   dicom_set_imfinfo_values - Helper function for DICOMREAD, DICOMINFO.
%   dicom_set_mmeta_encoding - Helper function for DICOMREAD, DICOMINFO.
%   dicom_supported_txfr_syntax - Helper function for DICOMREAD, DICOMINFO.
%   dicom_uid_decode - Helper function for DICOMREAD, DICOMINFO.
%   dicom_warn - Helper function for DICOMREAD, DICOMINFO.
%   dicom_xform_image - Helper function for DICOMREAD, DICOMINFO.
%   ditherc    - Floyd-Steinberg image dithering MEX-file computation.
%   eucdist2   - Compute 2-D Euclidean distance transform.
%   eucdistn   - Compute N-D Euclidean distance transform.
%   getcurpt   - Get current point.
%   grayto8    - Scale and convert grayscale image to uint8.
%   grayto16   - Scale and convert grayscale image to uint16.
%   grayxform  - Apply grayscale transformation to an image.
%   idct       - Inverse discrete cosine transform.
%   imdivmex   - Divide images.
%   imfilter_mex - Helper MEX-file for IMFILTER.
%   imhistc    - Image histogram MEX-file computation.
%   immultmex  - Multiply images.
%   intline    - Integer-coordinate line drawing algorithm.
%   iptprefs   - Defaults for Image Processing Toolbox preferences.
%   iptregistry - Store toolbox information in persistent memory.
%   iscpstruct - True for control point structure.
%   isresampler - True for resampler structure.
%   istform    - True for tform structure.
%   kdtree     - Optimized k-d tree of set of points.
%   lutbridge  - Bridge lookup table used by BWMORPH.
%   lutclean   - Clean lookup table used by BWMORPH.
%   lutdiag    - Diag lookup table used by BWMORPH.
%   lutdilate  - Dilate lookup table used by BWMORPH.
%   luterode   - Erode lookup table used by BWMORPH.
%   lutfatten  - Fatten lookup table used by BWMORPH.
%   lutfill    - Fill lookup table used by BWMORPH.
%   luthbreak  - Hbreak lookup table used by BWMORPH.
%   lutiso     - Iso lookup table used by BWMORPH.
%   lutmajority - Majority lookup table used by BWMORPH.
%   lutper4    - Perimeter lookup table used by BWMORPH.
%   lutper8    - Perimeter lookup table used by BWMORPH.
%   lutremove  - Remove lookup table used by BWMORPH.
%   lutshrink  - Shrink lookup table used by BWMORPH.
%   lutsingle  - Single lookup table used by BWMORPH.
%   lutskel1   - Skeleton lookup table used by BWMORPH.
%   lutskel2   - Skeleton lookup table used by BWMORPH.
%   lutskel3   - Skeleton lookup table used by BWMORPH.
%   lutskel4   - Skeleton lookup table used by BWMORPH.
%   lutskel5   - Skeleton lookup table used by BWMORPH.
%   lutskel6   - Skeleton lookup table used by BWMORPH.
%   lutskel7   - Skeleton lookup table used by BWMORPH.
%   lutskel8   - Skeleton lookup table used by BWMORPH.
%   lutspur    - Spur lookup table used by BWMORPH.
%   lutthin1   - Thin lookup table used by BWMORPH.
%   lutthin2   - Thin lookup table used by BWMORPH.
%   lutthin3   - Thin lookup table used by BWMORPH.
%   lutthin4   - Thin lookup table used by BWMORPH.
%   mkconstarray - Make constant array of specified numeric class.
%   morphmex   - Helper MEX-file for MORPHOP.
%   morphop    - Morphological operations.
%   nnsearch   - Nearest-neighbor search.
%   ordfa      - Helper function for ORDFILT2.
%   ordfb      - Helper function for ORDFILT2.
%   padlength  - Helper function for deconvolution functions.
%   radonc     - Radon transform MEX-file computation.
%   resampsep  - Generalized multidimensional resampler.
%   strelcheck - Check validity of structuring element.
%   tokenize   - String parser helper function for DICOMREAD, DICOMINFO.
%   vmquant    - Color quantization.
%   vmquantc   - Color quantization MEX-file computation.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.18.4.1 $  $Date: 2003/01/26 05:57:35 $
