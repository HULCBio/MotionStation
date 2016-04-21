function varargout = hdfhe(varargin)
%HDFHE MATLAB gateway to the HDF HE interface.
%   HDFHE is a gateway to the HDF HE interface. To use this
%   function, you must be familiar with the information about the
%   Vdata interface contained in the User's Guide and Reference
%   Manual for HDF version 4.1r3. This documentation may be
%   obtained from the National Center for Supercomputing
%   Applications (NCSA) at <http://hdf.ncsa.uiuc.edu>.
%
%   The general syntax for HDFHE is
%   HDFHE(funcstr,param1,param2,...).  There is a one-to-one
%   correspondence between V functions in the HDF library and
%   valid values for funcstr.
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the
%   operation failed.
%
%     hdfhe('clear')
%       Clears all information on reported errors from the error
%       stack
%
%     hdfhe('print',level)
%       Prints information in error stack; if level is 0, the
%       entire error stack is printed
%
%     error_text = hdfhe('string',error_code)
%       Returns the error message associated with the specified
%       error code
%
%     error_code = hdfhe('value',stack_offset)
%       Returns an error code from the specified level of the
%       error stack; stack_offset of 1 gets the most recent error
%       code
%
%   The HDF library functions HEpush and HEreport are not
%   currently supported by this gateway.
%
%   See also HDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, 
%            HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:15 $

% Call HDF.MEX to do the actual work.
ans = [];
if nargout>0
  [varargout{1:nargout}] = hdf('HE',varargin{:});
else
  hdf('HE',varargin{:});
end
if ~isempty(ans)
  varargout{1} = ans;
end
