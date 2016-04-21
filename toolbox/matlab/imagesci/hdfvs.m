function varargout = hdfvs(varargin)
%HDFVS MATLAB gateway to VS functions in the HDF Vdata interface.
%   HDFVS is a gateway to the VS functions in the HDF Vdata
%   interface.  To use this function, you must be familiar with
%   the information about the Vdata interface contained in the
%   User's Guide and Reference Manual for HDF version 4.1r3. This
%   documentation may be obtained from the National Center for
%   Supercomputing Applications (NCSA) at
%   <http://hdf.ncsa.uiuc.edu>.
%
%   The general syntax for HDFVS is
%   HDFVS(funcstr,param1,param2,...).  There is a one-to-one
%   correspondence between V functions in the HDF library and
%   valid values for funcstr.  For example,
%   HDFVS('detach',vdata_id) corresponds to the C library call
%   VSdetach(vdata_id).
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the
%   operation failed.
%
%   Access functions
%   ----------------
%   Access functions attach, or allow access, to vdatas.  Data
%   transfer can only occur after a vdata has been accessed.
%   These routines also detach from, or properly terminate access
%   to, vdatas when data transfer has been completed.
%
%     vdata_id = hdfvs('attach',file_id,vdata_ref,access)
%       Establishes access to a specified vdata; access can be
%       'r' or 'w'
%
%     status = hdfvs('detach',vdata_id)
%       Terminates access to a specified vdata
%
%   Read and write functions
%   ------------------------
%   Read and write functions read and write the contents of a
%   vdata.
%
%     status = hdfvs('fdefine',vdata_id,fieldname,data_type,order)
%       Defines a new vdata field. data_type is a string
%       specifying the HDF number type. It can be of these
%       strings: 'uchar8', 'uchar', 'char8', 'char', 'double',
%       'uint8', 'uint16', 'uint32', 'float', 'int8', 'int16',
%       or 'int32'.
%
%     status = hdfvs('setclass',vdata_id,class)
%       Assigns a class to a vdata
%
%     status = hdfvs('setfields',vdata_id,fields)
%       Specifies the vdata fields to be written to
%
%     status = hdfvs('setinterlace',vdata_id,interlace)
%       Sets the interlace mode for a vdata; interlace can be
%       'full' or 'no'
%
%     status = hdfvs('setname',vdata_id,name)
%       Assigns a name to a vdata
%
%     count = hdfvs('write', vdata_id, data)
%       Writes to a vdata.  data must be an nfields-by-1 cell array.
%       Each cell must contain an order(i)-by-n vector of data where
%       order(i) is the number of scalar values in each field.  The types
%       of the data must match the field types set via hdfvs('setfields')
%       or the fields in an already existing vdata.
%
%     [data,count] = hdfvs('read',vdata_id,n)
%       Reads from a vdata.  Data is returned in a nfields-by-1 cell
%       array. Each cell will contain a order(i)-by-n vector of data where
%       order is the number of scalar values in each field.  The fields
%       are returned in the same order as specified in hdfvs('setfields',...).
%
%     pos = hdfvs('seek',vdata_id,record)
%       Seeks to a specified record in a vdata
%
%     status = hdfvs('setattr',vdata_id,field_index,name,A)
%       Sets the attribute of a vdata field or vdata
%
%     status = hdfvs('setexternalfile',vdata_id,filename,offset)
%       Stores vdata information in an external file
%
%   File inquiry functions
%   ----------------------
%   File inquiry functions provide information about how vdatas
%   are stored in a file.  They are useful for locating vdatas in
%   a file.
%
%     vdata_ref = hdfvs('find',file_id,vdata_name)
%       Searches for a given vdata name in the specified HDF file
%
%     vdata_ref = hdfvs('findclass',file_id,vdata_class)
%       Returns the reference number of the first vdata
%       corresponding to the specified vdata class
%
%     next_ref = hdfvs('getid',file_id,vdata_ref)
%       Returns the identifier of the next vdata in the file
%
%     [refs,count] = hdfvs('lone',file_id,maxsize)
%       Returns the reference numbers of the vdatas that are not
%       linked into vgroups
%
%   Vdata inquiry functions
%   -----------------------
%   Vdata inquiry functions provide specific information about a
%   given vdata, including the vdata's name, class, number of
%   fields, number of records, tag and reference pairs, interlace
%   mode, and size.
%
%     status = hdfvs('fexist',vdata_id,fields)
%       Tests for the existence of fields in the specified vdata
%
%     [n,interlace,fields,nbytes,vdata_name,status] = ...
%                          hdfvs('inquire',vdata_id)
%       Returns information about the specified vdata
%
%     count = hdfvs('elts',vdata_id)
%       Returns the number of records in the specified vdata
%
%     [class_name,status] = hdfvs('getclass',vdata_id)
%       Returns the number of records in the specified vdata
%
%     [field_names,count] = hdfvs('getfields',vdata_id)
%       Returns all field names within the specified vdata
%
%     [interlace,status] = hdfvs('getinterlace',vdata_id)
%       Retrieves the interlace mode of the specified vdata
%
%     [vdata_name,status] = hdfvs('getname',vdata_id)
%       Retrieves the name of the specified vdata
%
%     version = hdfvs('getversion',vdata_id)
%       Returns the version number of a vdata
%
%     nbytes = hdfvs('sizeof',vdata_id,fields)
%       Returns the fields sizes of the specified vdata
%
%     [fields,status] = hdfvs('Queryfields',vdata_id)
%       Returns the field names of the specified vdata
%
%     [name,status] = hdfvs('Queryname',vdata_id)
%       Returns the name of the specified vdata
%
%     ref = hdfvs('Queryref',vdata_id)
%       Retrieves the reference number of the specified vdata
%
%     tag = hdfvs('Querytag',vdata_id)
%       Retrieves the tag of the specified vdata
%
%     [count,status] = hdfvs('Querycount',vdata_id)
%       Returns the number of records in the specified vdata
%
%     [interlace,status] = hdfvs('Queryinterlace',vdata_id)
%       Returns the interlace mode of the specified vdata
%
%     vsize = hdfvs('Queryvsize',vdata_id)
%       Retrieves the local size in bytes of the specified vdata
%       record
%
%     [field_index,status] = hdfvs('findex',vdata_id,fieldname)
%       Queries the index of a vdata field given the field name
%
%     status = hdfvs('setattr',vdata_id,field_index,name,A)
%       Sets the attribute of a vdata field or vdata; field_index
%       can be an index number or 'vdata'
%
%     count = hdfvs('nattrs',vdata_id)
%       Returns the number of attributes of the specified vdata
%       and the vdata fields contained in it
%
%     count = hdfvs('fnattrs',vdata_id,field_index)
%       Queries the total number of vdata attributes
%
%     attr_index = hdfvs('findattr',vdata_id,field_index,attr_name)
%       Retrieves the index of an attribute given the attribute
%       name
%
%     tf = hdfvs('isattr',vdata_id)
%       Determines if the given vdata is an attribute
%
%     [name,data_type,count,nbytes,status] = hdfvs('attrinfo',...
%                                vdata_id,field_index,attr_index)
%       Returns the name, data type, number of values, and the
%       size of the values of the specified attributes of the
%       specified vdata field or vdata
%
%   See also HDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%            HDFML, HDFSD, HDFV, HDFVF, HDFVH.

%   Copyright 1984-2001 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:28 $

% Call HDF.MEX to do the actual work.
[varargout{1:max(1,nargout)}] = hdf('VS',varargin{:});

