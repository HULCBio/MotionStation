function varargout = hdfsd(varargin)
%HDFSD MATLAB gateway to HDF multifile scientific dataset interface.
%   HDFSD is a gateway to the HDF multifile scientific dataset
%   interface (SD). To use this function, you must be familiar
%   with the information about the SD interface contained in the
%   User's Guide and Reference Manual for HDF version 4.1r3.
%   This documentation may be obtained from the National Center 
%   for Supercomputing Applications (NCSA) at
%   <http://hdf.ncsa.uiuc.edu>.
%
%   The general syntax for HDFSD is
%   HDFSD(funcstr,param1,param2,...). There is a one-to-one
%   correspondence between SD functions in the HDF library and
%   valid values for funcstr.  For example,
%   HDFSD('endaccess',sds_id) corresponds to the C library call
%   SDendaccess(sds_id).
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the
%   operation failed.
%
%   SD_id refers to the multifile scientific dataset interface
%   identifier.  sds_id refers to an individual dataset
%   identifier. You must be sure to terminate access to all
%   opened identifiers using either hdfsd('end',SD_id) or 
%   hdfsd('endaccess',sds_id); otherwise the HDF library may not
%   properly write all data to the file. 
%   
%   HDF files use C-style ordering for multidimensional arrays,
%   while MATLAB uses FORTRAN-style ordering.  This means that
%   the size of the MATLAB array must be flipped relative to the
%   defined dimension sizes of the HDF data set.  For example, if
%   the HDF data set has dimensions 3-by-4-by-5, then the
%   equivalent MATLAB array has size 5-by-4-by-3.  The PERMUTE
%   command is useful for making any necessary conversions when
%   reading from or writing to HDF data sets.
%
%   In cases where the HDF C library accepts NULL for certain
%   inputs, an empty matrix ([]) can be used.
%
%   Access functions
%   ----------------
%   Access functions initialize and terminate access to HDF files
%   and data sets.
%
%     status = hdfsd('end',SD_id)
%       Terminates access to the corresponding file
%
%     status = hdfsd('endaccess',sds_id)
%       Terminates access to the corresponding data set
%
%     sds_id = hdfsd('select',SD_id, sds_index)
%       Returns the identifier of the data set with the specified
%       index
%
%     SD_id = hdfsd('start',filename,access_mode)
%       Initializes the SD interface for a particular file;
%       access_mode can be 'read', 'write', 'create', 'rdwr', or
%       'rdonly'
%
%   Read/write functions
%   --------------------
%   Read/write functions read and write data sets by manipulating
%   their dimensions, rank, and data type.
%
%     sds_id = hdfsd('create',SD_id,name,data_type,rank,dimsizes)
%       Creates a new data set
%
%     [data,status] = hdfsd('readdata',sds_id,start,stride,edge)
%       Reads data from a chunked or nonchunked data set
%       NOTE: the coordinates in the vector start should be
%       zero-based, not one-based.
%
%     status = hdfsd('setexternalfile', sds_id, filename, offset)
%       Defines the data type to be stored in an external file
%
%     status = hdfsd('writedata',sds_id, start, stride, edge, data)
%       Writes data to a chunked or nonchunked data set
%       NOTE: The class of data must match the HDF number type
%       defined for the HDF data set.  A MATLAB string will be
%       automatically converted to match any of the HDF char
%       types; other data types must match exactly.
%       NOTE: the coordinates in the vector start should be
%       zero-based, not one-based.
%
%   General inquiry functions
%   -------------------------
%   General inquiry functions return information about the
%   location, contents, and description of the scientific data
%   sets in an HDF file.
%
%     [ndatasets,nglobal_attr,status] = hdfsd('fileinfo',SD_id)
%       Returns information about the contents of a file
%
%     [name,rank,dimsizes,data_type,nattrs,status] = hdfsd('getinfo',sds_id)
%       Returns information about a data set
%
%     ref = hdfsd('idtoref',sds_id)
%       Returns the reference number corresponding to the
%       specified data set
%
%     tf = hdfsd('iscoordvar',sds_id)
%       Distinguishes data sets from dimension scales
%
%     idx = hdfsd('nametoindex',SD_id,name)
%       Returns index value of the named data set
%
%     sds_index = hdfsd('reftoindex',SD_id,ref)
%       Returns the index of the data set corresponding to a
%       given reference number
%
%   Dimension scale functions
%   -------------------------
%   Dimension scale functions define and access dimension scales
%   within a data set.
%
%     [name,count,data_type,nattrs,status] = hdfsd('diminfo',dim_id)
%       Gets information about a dimension
%
%     dim_id = hdfsd('getdimid',sds_id,dim_number)
%       Retrieves the identifier of a dimension
%
%     status = hdfsd('setdimname',dim_id,name)
%       Associates a name with a dimension
%
%     [scale,status] = hdfsd('getdimscale',dim_id)
%       Returns scale values for a dimension
%
%     status = hdfsd('setdimscale',dim_id,scale)
%       Defines the values of this dimension
%
%   User-defined attribute functions
%   --------------------------------
%   User-defined attribute functions describe and access
%   characteristics of an HDF file, data set, or dimension
%   defined by the HDF user.
%
%     [name,data_type,count,status] = hdfsd('attrinfo',id,attr_idx)
%       Gets information about an attribute; id can be an SD_id,
%       an sds_id, or a dim_id
%     
%     attr_index = hdfsd('findattr',id,name)
%       Returns the index of the specified index; id can be an
%       SD_id, an sds_id, or a dim_id
%
%     [data,status] = hdfsd('readattr',id,attr_index)
%       Reads the values of the specified attribute; id can be an
%       SD_id, an sds_id, or a dim_id
%
%     status = hdfsd('setattr',id,name,A)
%       Creates and defines a new attribute; id can be an SD_id,
%       an sds_id, or a dim_id
%
%   Predefined attribute functions
%   ------------------------------
%   Predefined attribute functions access previously-defined
%   characteristics of an HDF file, data set, or dimension.
%
%     [cal,cal_err,offset,offset_err,data_type,status] = hdfsd('getcal',sds_id)
%       Returns calibration information
%
%     [label,unit,format,coordsys,status] = hdfsd('getdatastrs',sds_id,maxlen)
%       Returns the label, limit, format, and coordinate system
%       of a data set
%
%     [label,unit,format,status] = hdfsd('getdimstrs',dim_id)
%       Returns the attribute strings for the specified dimension
%
%     [fill,status] = hdfsd('getfillvalue',sds_id)
%       Reads the fill value if it exists
%
%     [rmax,rmin,status] = hdfsd('getrange',sds_id)
%       Returns the range of values of the specified data set
%
%     status = hdfsd('setcal',sds_id,cal,cal_err,offset,offset_err,data_type)
%       Defines the calibration information
%
%     status = hdfsd('setdatastrs',sds_id,label,unit,format,coordsys)
%       Defines the attribute strings of the specified data set
%
%     status = hdfsd('setdimstrs',dim_id,label,unit,format)
%       Defines the attribute strings of the specified dimension
%
%     status = hdfsd('setfillvalue',sds_id,value)
%       Defines the fill value of the specified data set
%
%     status = hdfsd('setfillmode',SD_id,mode)
%       Defines the fill mode to be applied to all scientific
%       data sets in the specified file
%
%     status = hdfsd('setrange',sds_id,max,min)
%       Defines the maximum and minimum values of the valid range
%
%   Compression functions
%   ---------------------
%   Compression functions determine the compression method for
%   scientific data sets.
%
%     status = hdfsd('setcompress',SD_id,comp_type,...)
%       Defines the compression method to be applied to data set
%       data; comp_type can be 'none','jpeg','rle','deflate',or
%       'skphuff'
%
%       Additional param/value pairs must be passed for some
%       methods.  This routine understands the following
%       param/value pairs: 
%         'jpeg_quality'        , integer
%         'jpeg_force_baseline' , integer
%         'skphuff_skp_size'    , integer
%         'deflate_level'       , integer
%
%   Chunking/tiling functions
%   -------------------------
%   Chunking/tiling functions determine the chunking
%   configuration for SDS data.
%
%     [chunk_lengths,chunked,compressed,status] = hdfsd('getchunkinfo',sds_id)
%       Obtains information about a chunked scientific data set;
%       chunked or compressed is true (1) if the SDS is chunked or compressed.
%
%     status = hdfsd('setchunkcache',sds_id,maxcache,flags)
%       Sets the size of the chunk cache
%
%     status = hdfsd('setchunk',sds_id,chunk_lengths,comp_type,...)
%       Makes a nonchunked scientific data set a chunked
%       scientific data set
%
%       comp_type can be 'none','jpeg','rle','deflate',or
%       'skphuff'.  'none' implies HDF_CHUNK, the others imply
%       HDF_CHUNK | HDF_COMP. Additional param/value pairs must
%       be passed for some methods.  This routine understands the
%       following param/value pairs: 
%         'jpeg_quality'        , integer
%         'jpeg_force_baseline' , integer
%         'skphuff_skp_size'    , integer
%         'deflate_level'       , integer
%
%     status = hdfsd('writechunk',sds_id,origin,data)
%       Writes data to a chunked scientific data set
%
%     [data,status] = hdfsd('readchunk',sds_id,origin)
%       Reads data from a chunked scientific data set
%
%   N-bit data set functions
%   ------------------------
%   N-bit data set functions determine the nonstandard data bit
%   length configuration for scientific data set data.
%
%     status = hdfsd('setnbitdataset',sds_id,start_bit,bit_len,sign_ext,fill_one)
%       Defines the nonstandard bit length of the data set data
%
%   See also HDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%            HDFML, HDFV, HDFVF, HDFVH, HDFVS.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:21 $

% Call HDF.MEX to do the actual work.
[varargout{1:max(1,nargout)}] = hdf('SD',varargin{:});
