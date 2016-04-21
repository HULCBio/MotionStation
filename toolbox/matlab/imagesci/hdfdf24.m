function varargout = hdfdf24(varargin)
%HDFDF24 MATLAB gateway to HDF 24-bit raster image interface.
%   HDFDFR8 is a gateway to the HDF 24-bit raster image interface
%   (DF24). To use this function, you must be familiar with the
%   information about the DF24 interface contained in the User's
%   Guide and Reference Manual for HDF version 4.1r3. This
%   documentation may be obtained from the National Center for
%   Supercomputing Applications (NCSA) at
%   <http://hdf.ncsa.uiuc.edu>.
%
%   The general syntax for HDFDF24 is
%   HDFDF24(funcstr,param1,param2,...). There is a one-to-one
%   correspondence between DF24 functions in the HDF library and
%   valid values for funcstr.  For example,
%   HDFDF24('lastref') corresponds to the C library call
%   DF24lastref().
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the
%   operation failed.
%
%   HDF uses C-style ordering of elements, in which elements
%   along the last dimension vary fastest.  MATLAB uses
%   FORTRAN-style ordering, in which elements along the first
%   dimension vary fastest.  HDFDF24 does not automatically
%   convert from C-style ordering to MATLAB-style ordering,
%   which means that MATLAB image arrays need to be permuted
%   when using HDFDF24 to read or write from HDF files.  The
%   exact permutation depends on the interlace format
%   specified by, for example, HDFDF24('setil',...).  The
%   following calls to PERMUTE will convert HDF arrays to
%   MATLAB arrays, according to the specified interlace
%   format:
%
%       RGB = permute(RGB,[3 2 1]);  % 'pixel' interlace
%       RGB = permute(RGB,[3 1 2]);  % 'line' interlace
%       RGB = permute(RGB,[2 1 3]);  % 'component' interlace
%
%   Write functions
%   ----------------
%   Write functions create raster image sets and store them in
%   new files or append them to existing files.
%
%     status = hdfdf24('addimage',filename,RGB)
%       Appends a 24-bit raster image to a file
%
%     status = hdfdf24('putimage',filename,RGB)
%       Writes a 24-bit raster image to file by overwriting all
%       existing data
%
%     status = hdfdf24('setcompress',compress_type,...)
%       Sets the compress method for the next raster image
%       written to the file
%       compress_type can be 'none', 'rle', 'jpeg', or 'imcomp'.
%       If compress_type is 'jpeg', then two additional
%       parameters must be passed in: quality (a scalar between 0
%       and 100) and force_baseline (either 0 or 1).  Other
%       compression types do not have additional parameters.
%
%     status = hdfdf24('setdims',width,height)
%       Sets the dimensions for the next raster image written to
%       the file
%
%     status = hdfdf24('setil',interlace)
%       Sets the interlace format of the next raster image
%       written to the file; interlace can be 'pixel', 'line', or
%       'component'.
%
%     ref = hdfdf24('lastref')
%       Reports the last reference number assigned to a 24-bit
%       raster image
%
%   Read functions
%   ----------------
%   Read functions determine the dimensions and interlace format
%   of an image set, read the actual image data, and provide
%   sequential or random read access to any raster image set.
%
%     [width,height,interlace,status] = hdfdf24('getdims',filename)
%       Retrieves the dimensions before reading the next raster
%       image; interlace can be 'pixel', 'line', or 'component'
%
%     [RGB,status] = hdfdf24('getimage',filename)
%       Reads the next 24-bit raster image
%
%     status = hdfdf24('reqil',interlace)
%       Retrieves the interlace format before reading the next
%       raster image; interlace can be 'pixel', 'line', or
%       'component'
%
%     status = hdfdf24('readref',filename,ref)
%       Reads 24-bit raster image with the specified raster
%       number
%
%     status = hdfdf24('restart')
%       Returns to the first 24-bit raster image in the file
%
%     num_images = hdfdf24('nimages',filename)
%       Reports the number of 24-bit raster images in a file
%
%   See also HDF, HDFAN, HDFDFR8, HDFH, HDFHD, HDFHE,
%            HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:10 $

% Call HDF.MEX to do the actual work.
[varargout{1:max(1,nargout)}] = hdf('DF24',varargin{:});
