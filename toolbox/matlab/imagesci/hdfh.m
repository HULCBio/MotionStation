function varargout = hdfh(varargin)
%HDFH MATLAB gateway to the HDF H interface.
%   HDFH is a gateway to the HDF H interface.  To use this
%   function, you must be familiar with the information about the
%   Vdata interface contained in the User's Guide and Reference
%   Manual for HDF version 4.1r3. This documentation may be
%   obtained from the National Center for Supercomputing
%   Applications (NCSA) at <http://hdf.ncsa.uiuc.edu>.
%
%   The general syntax for HDFH is
%   HDFH(funcstr,param1,param2,...).  There is a one-to-one
%   correspondence between H functions in the HDF library and
%   valid values for funcstr.  For example,
%   HDFH('close',file_id) corresponds to the C library call
%   Hclose(file_id).
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the
%   operation failed.
%
%     status = hdfh('appendable',access_id)
%       Specifies that the element can be appended to
%
%     status = hdfh('close',file_id)
%       Closes the access path to the file
%
%     status = hdfh('deldd',file_id,tag,ref)
%       Deletes a tag and reference number from the data
%       descriptor list
%
%     status = hdfh('dupdd',file_id,tag,ref,old_tag,old_ref)
%
%     status = hdfh('endaccess',access_id)
%       Terminates access to a data object by disposing of the
%       access identifier
%
%     [filename,access_mode,attach,status] = hdfh('fidinquire',file_id)
%       Returns information about specified file
%
%     [tag,ref,offset,length,status] = hdfh('find',file_id,...
%                 search_tag,search_ref,search_type,dir)
%       Locates the next object to be searched for in an HDF
%       file; search_type can be 'new' or 'continue'; dir can be
%       'forward' or 'backward'
%
%     [data,status] = hdfh('getelement',file_id,tag,ref)
%       Reads the data element for the specified tag and
%       reference number
%
%     [major,minor,release,info,status] = hdfh('getfileversion',file_id)
%       Returns version information for an HDF file
%
%     [major,minor,release,info,status] = hdfh('getlibversion')
%       Returns version information for the current HDF library
%
%     [file_id,tag,ref,length,offset,position,access,special,...
%        status] = hdfh('inquire',access_id)
%       Returns access information about a data element
%
%     tf = hdfh('ishdf',filename)
%       Determines if a file is an HDF file
%
%     length = hdfh('length',file_id,tag,ref)
%       Returns the length of a data object specified by the tag
%       and reference number
%
%     ref = hdfh('newref',file_id)
%       Returns a reference number that can be used with any tag
%       to product a unique tag/reference number pair
%
%     status = hdfh('nextread',access_id,tag,ref,origin)
%       Searches for the next data descriptor that matches the
%       specified tag and reference number; origin can be 'start'
%       or 'current'
%
%     num = hdfh('number',file_id,tag)
%       Returns the number of instances of a tag in a file
%
%     offset = hdfh('offset',file_id,tag,ref)
%       Returns the offset of a data element in the file
%
%     file_id = hdfh('open',filename,access,n_dds)
%       Provides an access path to an HDF file by reading all the
%       data descriptor blocks into memory
%
%     count = hdfh('putelement',file_id,tag,ref,X)
%       Writes a data element or replaces an existing data
%       element in an HDF file; X must be a uint8 array
%
%     X = hdfh('read',access_id,length)
%       Reads the next segment in a data element
%
%     status = hdfh('seek',access_id,offset,origin)
%       Sets the access pointer to an offset within a data
%       element; origin can be 'start' or 'current'
%
%     access_id = hdfh('startread',file_id,tag,ref)
%
%     access_id = hdfh('startwrite',file_id,tag,ref,length)
%
%     status = hdfh('sync',file_id)
%
%     length = hdfh('trunc',access_id,trunc_len)
%       Truncates the specified data object to the given length
%
%     count = hdfh('write',access_id,X)
%       Writes the next data segment to a specified data element;
%       X must be a uint8 array
%
%   Unsupported functions
%   ---------------------
%   These functions in the NCSA H interface are not currently
%   supported by HDFH: Hcache, Hendbitaccess, Hexist, Hflushdd,
%   Hgetbit, Hputbit, Hsetlength, Hshutdown, Htagnewref.
%
%   See also HDF, HDFAN, HDFDF24, HDFDFR8, HDFHD, HDFHE,
%            HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:13 $

% Call HDF.MEX to do the actual work.
[varargout{1:max(1,nargout)}] = hdf('H',varargin{:});

