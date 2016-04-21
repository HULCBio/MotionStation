function varargout = hdfhx(varargin)
%HDFHX MATLAB gateway to HDF external data interface
%   HDFHX is a gateway to the HDF interface for manipulating linked and
%   external data elements. To use this function, you must be familiar with
%   the information about the HX interface contained in the User's Guide,
%   Reference Manual and HDF Specification and Developer's Guide for HDF
%   version 4.1r3.This documentation may be obtained from the National
%   Center  for Supercomputing Applications (NCSA) at
%   <http://hdf.ncsa.uiuc.edu>.
%
%   The general syntax for HDFHX is 
%   HDFHX(funcstr,param1,param2,...). There is a one-to-one correspondence
%   between HX functions in the HDF library and valid values for funcstr.
%   For example, 
%   HDFHX('setdir',pathname); corresponds to the C library call 
%   HXsetdir(pathname).
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the
%   operation failed.
%
%   In cases where the HDF C library accepts NULL for certain
%   inputs, an empty matrix ([] or '') can be used.
%
%  Syntaxes
%  --------
%  access_id = hdf('HX', 'create', file_id, tag, ref, extern_name,
% 		   offset, length)
%    Create new external file special data element.
% 
%  status = hdf('HX','setcreatedir',pathname);
%    Set directory location for writing external file.
%
%  status = hdf('HX','setdir',pathname);
%    Set directory for locating external files.  PATHNAME may contain
%    multiple directories separated by vertical bars.
%
%   See also HDF, HDFSD, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%            HDFML, HDFV, HDFVF, HDFVH, HDFVS.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:16 $

% Call HDF.MEX to do the actual work.
[varargout{1:max(1,nargout)}] = hdf('HX',varargin{:});

