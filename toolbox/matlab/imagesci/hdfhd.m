function varargout = hdfhd(varargin)
%HDFHD MATLAB gateway to the HDF HD interface.
%   HDFHD is a gateway to the HDF HD interface. To use this
%   function, you must be familiar with the information about the
%   Vdata interface contained in the User's Guide and Reference
%   Manual for HDF version 4.1r3. This documentation may be
%   obtained from the National Center for Supercomputing
%   Applications (NCSA) at <http://hdf.ncsa.uiuc.edu>.
%
%   The general syntax for HDFHD is
%   HDFHD(funcstr,param1,param2,...).  There is a one-to-one
%   correspondence between V functions in the HDF library and
%   valid values for funcstr.
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the
%   operation failed.
%
%     tag_name = hdfhd('gettagsname',tag)
%       Get the name of the specified tag
%
%   See also HDF.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:14 $

% Call HDF.MEX to do the actual work.
[varargout{1:max(1,nargout)}] = hdf('HD',varargin{:});

