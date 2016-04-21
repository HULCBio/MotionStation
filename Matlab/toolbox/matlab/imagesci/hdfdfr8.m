function varargout = hdfdfr8(varargin)
%HDFDFR8 MATLAB gateway to HDF 8-bit raster image interface.
%   HDFDFR8 is a gateway to the HDF 8-bit raster image interface
%   (DFR8). To use this function, you must be familiar with the
%   information about the DFR8 interface contained in the User's
%   Guide and Reference Manual for HDF version 4.1r3. This
%   documentation may be obtained from the National Center for
%   Supercomputing Applications (NCSA) at
%   <http://hdf.ncsa.uiuc.edu>.
%
%   The general syntax for HDFDFR8 is
%   HDFDFR8(funcstr,param1,param2,...). There is a one-to-one
%   correspondence between DFR8 functions in the HDF library and
%   valid values for funcstr.  For example,
%   HDFDFR8('setpalette',map) corresponds to the C library call
%   DFR8setpalette(map).
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the
%   operation failed.
%
%   HDF uses C-style ordering of elements, in which elements
%   along the last dimension vary fastest.  MATLAB uses
%   FORTRAN-style ordering, in which elements along the first
%   dimension vary fastest.  HDFDFR8 does not automatically
%   convert from C-style ordering to MATLAB-style ordering, which
%   means that MATLAB image and colormap matrices need to be
%   transposed when using HDFDFR8 to read or write from HDF
%   files.
%
%   Functions in HDFDFR8 that read and write palette information
%   expect to use uint8 data in the range [0,255], while MATLAB
%   colormaps contain double-precision values in the range [0,1].
%   Therefore, HDF palettes need to be converted to double and
%   scaled to be used as MATLAB colormaps.
%
%   Write functions
%   ----------------
%   Write functions create raster image sets and store them in
%   new files or append them to existing files.
%
%     status = hdfdfr8('writeref',filename,ref)
%       Stores the raster image using the specified reference
%       number
%
%     status = hdfdfr8('setpalette',colormap)
%       Sets palette for multiple 8-bit raster images
%
%     status = hdfdfr8('addimage',filename,X,compress)
%       Appends an 8-bit raster image to a file; compress can be
%       'none', 'rle', 'jpeg', or 'imcomp'
%
%     status = hdfdfr8('putimage',filename,X,compress)
%       Writes an 8-bit raster image to an existing file or
%       creates the file; compress can be 'none', 'rle', 'jpeg',
%       or 'imcomp'
%
%     status = hdfdfr8('setcompress',compress_type,...)
%       Sets the compression type
%       compress_type can be 'none', 'rle', 'jpeg', or 'imcomp'.
%       If compress_type is 'jpeg', then two additional
%       parameters must be passed in: quality (a scalar between 0
%       and 100) and force_baseline (either 0 or 1).  Other
%       compression types do not have additional parameters.
%
%   Read functions
%   ----------------
%   Read functions determine the dimension and palette assignment
%   for an image set, read the actual image data, and provide
%   sequential or random read access to any raster image set.
%
%     [width,height,hasmap,status] = hdfdfr8('getdims',filename)
%       Retrieves dimensions for an 8-bit raster image
%
%     [X,map,status] = hdfdfr8('getimage',filename)
%       Retrieves an 8-bit raster image and its palette
%
%     status = hdfdfr8('readref',filename,ref)
%       Gets the next raster image with the specified reference
%       number
%
%     status = hdfdfr8('restart')
%       Ignores information about last file accessed and restarts
%       from beginning
%
%     num_images = hdfdfr8('nimages',filename)
%       Returns number of raster images in a file
%
%     ref = hdfdfr8('lastref')
%       Returns reference number of last element accessed
%
%   See also HDF, HDFAN, HDFDF24, HDFH, HDFHD, HDFHE,
%            HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:11 $

% Call HDF.MEX to do the actual work.
[varargout{1:max(1,nargout)}] = hdf('DFR8',varargin{:});
