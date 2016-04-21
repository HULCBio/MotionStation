function varargout = hdfvh(varargin)
%HDFVH MATLAB gateway to VH functions in the HDF Vdata interface.
%   HDFVF is a gateway to the VH functions in the HDF Vdata
%   interface.  To use this function, you must be familiar with
%   the information about the Vdata interface contained in the
%   User's Guide and Reference Manual for HDF version 4.1r3. This
%   documentation may be obtained from the National Center for
%   Supercomputing Applications (NCSA) at
%   <http://hdf.ncsa.uiuc.edu>.
%
%   The general syntax for HDFVH is
%   HDFVH(funcstr,param1,param2,...).  There is a one-to-one
%   correspondence between V functions in the HDF library and
%   valid values for funcstr.
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the
%   operation failed.
%
%   The input vdata_class is a string defining the HDF number
%   type.  It can be one of these strings: 'uchar8', 'uchar',
%   'char8', 'char', 'double', 'uint8', 'uint16', 'uint32',
%   'float', 'int8', 'int16', or 'int32'.
%
%   High-level Vdata functions
%   --------------------------
%   High-level Vdata functions write data to single-field
%   vdatas.
%
%     vgroup_ref = hdfvh('makegroup',file_id,tags,refs,...
%                       vgroup_name,vgroup_class)
%       Groups a collection of data objects within a vgroup
%
%     count = hdfvh('storedata',file_id,fieldname,data,...
%                       vdata_name,vdata_class)
%       Creates vdatas containing records limited to one field
%       with one component per field
%       NOTE: The class of data must match the HDF number type
%       vdata_class. A MATLAB string will be automatically
%       converted to match any of the HDF char types; other data
%       types must match exactly.
%
%
%     count = hdfvh('storedatam',file_id,filename,data,...
%                     vdata_name,vdata_class)
%       Creates vdatas containing records with one field
%       containing one or more components
%       NOTE: The class of data must match the HDF number type
%       vdata_class. A MATLAB string will be automatically
%       converted to match any of the HDF char types; other data
%       types must match exactly.
%
%   See also HDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%            HDFML, HDFSD, HDFV, HDFVF, HDFVS.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:27 $

% Call HDF.MEX to do the actual work.
[varargout{1:max(1,nargout)}] = hdf('VH',varargin{:});

