function varargout = hdfvf(varargin)
%HDFVF MATLAB gateway to VF functions in the HDF Vdata interface.
%   HDFVF is a gateway to the VS functions in the HDF Vdata
%   interface.  To use this function, you must be familiar with
%   the information about the Vdata interface contained in the
%   User's Guide and Reference Manual for HDF version 4.1r3. This
%   documentation may be obtained from the National Center for
%   Supercomputing Applications (NCSA) at
%   <http://hdf.ncsa.uiuc.edu>.
%
%   The general syntax for HDFVF is
%   HDFVF(funcstr,param1,param2,...).  There is a one-to-one
%   correspondence between V functions in the HDF library and
%   valid values for funcstr.  For example,
%   HDFVF('nfields',vdata_id) corresponds to the C library call
%   VFnfields(vdata_id).
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the
%   operation failed.
%
%   Field inquiry functions
%   -----------------------
%   Field inquiry functions provide specific information about
%   the fields in a given vdata, including the field's size,
%   name, order, type, and number of fields in the vdata.
%
%     fsize = hdfvf('fieldesize',vdata_id,field_index)
%       Retrieves the field size (as stored in a file) of a
%       specified field
%
%     fsize = hdfvf('fieldisize',vdata_id,field_index)
%       Retrieves the field size (as stored in memory) of a
%       specified field
%
%     name = hdfvf('fieldname',vdata_id,field_index)
%       Retrieves the name of the specified field in the given
%       vdata
%
%     order = hdfvf('fieldorder',vdata_id,field_index)
%       Retrieves the order of the specified field in the given
%       vdata
%
%     data_type = hdfvf('fieldtype',vdata_id,field_index)
%       Retrieves the data type for the specified field in the
%       given vdata
%
%     count = hdfvf('nfields',vdata_id)
%       Retrieves the total number of fields in the specified
%       vdata
%
%   See also HDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%            HDFML, HDFSD, HDFV, HDFVH, HDFVS.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:26 $

% Call HDF.MEX to do the actual work.
[varargout{1:max(1,nargout)}] = hdf('VF',varargin{:});

