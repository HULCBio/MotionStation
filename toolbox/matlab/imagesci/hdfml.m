function varargout = hdfml(varargin)
%HDFML MATLAB-HDF gateway utilities.
%   HDFML provides several utilities functions for working with
%   the MATLAB-HDF gateway functions.  To use the MATLAB-HDF
%   gateway functions, you must be familiar with the information
%   contained in the User's Guide and Reference Manual for HDF
%   version 4.1r3. This documentation may be obtained from the
%   National Center for Supercomputing Applications (NCSA) at
%   <http://hdf.ncsa.uiuc.edu>.
%
%   The general syntax for HDFML is
%   HDFML(funcstr,param1,param2,...).
%
%   The MATLAB-HDF gateway functions maintain lists of certain
%   HDF file and data object identifiers so that, for example,
%   HDF objects and files can be properly closed when a user
%   issues the command:
%
%     clear mex
%
%   These lists are updated whenever these identifiers are
%   created or closed.  Two of the functions provided by HDFML
%   are for manipulating these identifier lists.
%
%     hdfml('closeall')
%       Closes all open registered HDF file and data object
%       identifiers
%
%     hdfml('listinfo')
%       Prints information about all open registered HDF file and
%       data object identifiers
%
%     tag = hdfml('tagnum',tagname)
%       Returns tag number corresponding given tag name
%
%     nbytes = hdfml('sizeof',data_type)
%       Returns size in bytes of specified data type
%
%     hdfml('defaultchartype',char_type)
%	Defines the HDF data type for MATLAB strings.
%       Valid values for char_type are 'char8' or 'uchar8'. 
%       The change persists until the MATLAB-HDF gateway function is
%	cleared from memory.  MATLAB strings are mapped to char8 by 
%	default.
%
%   See also HDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%            HDFSD, HDFV, HDFVF, HDFVH, HDFVS.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:18 $

% Call HDF.MEX to do the actual work.
ans = [];
if nargout>0
  [varargout{1:nargout}] = hdf('ML',varargin{:});
else
  hdf('ML',varargin{:})
end
if ~isempty(ans)
  varargout{1} = ans;
end




