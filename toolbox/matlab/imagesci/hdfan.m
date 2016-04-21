function varargout = hdfan(varargin)
%HDFAN MATLAB gateway to HDF multifile annotation interface.
%   HDFAN is a gateway to the HDF multifile annotation (AN)
%   interface.  To use this function, you must be familiar with
%   the information about the AN interface contained in the
%   User's Guide and Reference Manual for HDF version 4.1r3.
%   This documentation may be obtained from the National Center
%   for Supercomputing Applications (NCSA) at
%   <http://hdf.ncsa.uiuc.edu>.
%
%   The general syntax for HDFAN is
%   HDFAN(funcstr,param1,param2,...). There is a one-to-one
%   correspondence between AN functions in the HDF library and
%   valid values for funcstr.  For example,
%   HDFAN('endaccess',annot_id) corresponds to the C library call
%   ANendaccess(annot_id).
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the
%   operation failed.
%
%   The input variable annot_type can in general be one of these
%   strings: 'file_label', 'file_desc', 'data_label',
%   'data_desc'.
%
%   AN_id refers to the multifile annotation interface
%   identifier.  annot_id refers to an individual annotation
%   identifier.  You must be sure to terminate access to all
%   opened identifiers using either hdfan('end',AN_id) or
%   hdfan('endaccess',annot_id); otherwise the HDF library may
%   not properly write all data to the file.
%   
%   Access functions
%   ----------------
%   Access functions initialize the interface and provide and
%   terminate access to annotations.  The HDFAN syntaxes for the
%   AN access functions include:
%
%     AN_id = hdfan('start', file_id)
%       Initializes the multifile annotation interface
%
%     annot_id = hdfan('select', AN_id, index, annot_type)
%       Selects and returns the identifier for the annotation
%       identified by the given index value and annotation type
%
%     status = hdfan('end', AN_id)
%       Terminates access to the multifile annotation interface
%
%     annot_id = hdfan('create', AN_id, tag, ref, annot_type)
%       Creates a data annotation for the object identified by
%       the specified tag and reference number; annot_type may be
%       'data_label' or 'data_desc'
%
%     annot_id = hdfan('createf', AN_id, annot_type)
%       Creates a file label or file description annotation;
%       annot_type may be 'file_label' or 'file_desc'
%
%     status = hdfan('endaccess', annot_id)
%       Terminates access to an annotation
%
%   Read/write functions
%   --------------------
%   Read/write functions read and write file or object
%   annotations.  The HDFAN syntaxes for the AN read/write
%   functions include:
%
%     status = hdfan('writeann', annot_id, annot_string)
%       Write annotation corresponding to the given annotation
%       identifier
%
%     [annot_string, status] = hdfan('readann', annot_id)
%     [annot_string, status] = hdfan('readann', annot_id, max_str_length)
%       Read annotation corresponding to the given annotation
%       identifier; max_str_length is optional.  If max_str_length is
%       provided, annot_string will not be longer than max_str_length.  
%
%   General inquiry functions
%   -------------------------
%   General inquiry functions return information about the
%   annotations in a file.  The HDFAN syntaxes for the AN general
%   inquiry functions include:
%
%     num_annot = hdfan('numann', AN_id, annot_type, tag, ref)
%       Get number of annotations of specified type corresponding
%       to given tag/ref pair
%
%     [ann_list, status] = hdfan('annlist', AN_id, annot_type, tag, ref)
%       Get list of annotations of given type in file
%       corresponding to given tag/ref pair
%
%     length = hdfan('annlen', annot_id)
%       Get length of annotation corresponding to given
%       annotation identifier
%
%     [nfl, nfd, ndl, ndd, status] = hdfan('fileinfo', AN_id)
%       Get number of file label, file description, data label,
%       and data description annotations in file corresponding to
%       AN_id
%
%     [tag, ref, status] = hdfan('get_tagref', AN_id, index, annot_type)
%       Get tag/ref pair for specified annotation type and index
%
%     [tag, ref, status] = hdfan('id2tagref', annot_id)
%       Get tag/ref pair corresponding to specified annotation
%       identifier
%
%     annot_id = hdfan('tagref2id', AN_id, tag, ref)
%       Get annotation identifier corresponding to specified
%       tag/ref pair
%
%     tag = hdfan('atype2tag', annot_type)
%       Get tag corresponding to specified annotation type
%
%     annot_type = hdfan('tag2atype', tag)
%       Get annotation type corresponding to specified tag
%
%   See also HDF, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%            HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:09 $

% Call HDF.MEX to do the actual work.
[varargout{1:max(1,nargout)}] = hdf('AN',varargin{:});

