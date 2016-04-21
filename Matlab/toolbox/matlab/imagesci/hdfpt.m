function varargout = hdfpt(varargin)
%HDFPT MATLAB interface to the HDF-EOS Point object.
%
%   HDFPT is the MATLAB interface to the HDF-EOS Point object.
%   HDF-EOS is an extension of NCSA (National Center for
%   Supercomputing Applications) HDF (Hierarchical Data Format).
%   HDF-EOS is the scientific data format standard selected by
%   NASA as the baseline standard for EOS (Earth Observing
%   System).
%   
%   HDFPT is a gateway to the Point functions in the HDF-EOS C
%   library, which is developed and maintained by EOSDIS (Earth
%   Observing System Data and Information System).  A Point data
%   set comprises a series of data records taken at (possibly)
%   irregular time intervals and at scattered geographic
%   locations.  Each data record consists of a set of one or more
%   data values representing the state of a point in time and/or
%   space.
%   
%   In addition to the information here, users should also have
%   the document:
%   
%       HDF-EOS Library User's Guide for the ECS Project,
%       Volume 1: Overview and Examples; Volume 2: Function
%       Reference Guide 
%   
%   This document is available on the web:
%   
%       http://hdfeos.gsfc.nasa.gov
%   
%   If you are unable to obtain the document from this location,
%   please contact MathWorks Technical Support
%   (support@mathworks.com).
%   
%   Syntax conventions
%   ------------------
%   There is a one-to-one mapping between Point functions in the
%   HDF-EOS C library and HDFPT syntaxes.  For example, the C
%   library contains this function for getting the level name
%   corresponding to given level index:
%   
%       intn PTgetlevelname(int32 pointid, int32 level, 
%                           char *levelname, int32 *strbufsize)
%   
%   The equivalent MATLAB usage is:
%   
%       [LEVELNAME,STATUS] = HDFPT('getlevelname',POINTID,LEVEL)
%   
%   LEVELNAME is a string.  STATUS is either 0 (indicating
%   success) or -1 (indicating failure).
%   
%   Some of the C library functions accept input values that are
%   defined in terms of C macros.  For example, the C PTopen()
%   function requires an access mode input that can be
%   DFACC_READ, DFACC_RDWR, or DFACC_CREATE, where these symbols
%   are defined in the appropriate C header file.  Where macro
%   definitions are used in the C library, the equivalent MATLAB
%   syntaxes use strings derived from the macro names.  You can
%   either use a string containing the entire macro name, or you
%   can use omit the common prefix.  You can use either upper or
%   lower case.  For example, this C function call:
%   
%       status = PTopen("PointFile.hdf",DFACC_CREATE)
%   
%   is equivalent to these MATLAB function calls:
%   
%       status = hdfpt('open','PointFile.hdf','DFACC_CREATE')
%       status = hdfpt('open','PointFile.hdf','dfacc_create')
%       status = hdfpt('open','PointFile.hdf','CREATE')
%       status = hdfpt('open','PointFile.hdf','create')
%   
%   In cases where a C function returns a value with a macro
%   definition, the equivalent MATLAB function returns the value
%   as a string containing the lower-case short form of the
%   macro.
%   
%   HDF number types are specified by strings, including
%   'uchar8', 'uchar', 'char8', 'char', 'double', 'uint8',
%   'uint16', 'uint32', 'float', 'int8', 'int16', and 'int32'.
%   
%   In cases where the HDF-EOS library accepts NULL, an empty
%   matrix ([]) should be used.
%   
%   Most routines return the flag STATUS, which is 0 when the
%   routine succeeds and -1 when the routine fails.  Routines
%   with syntaxes which don't contain STATUS will return failure
%   information in one of its outputs as notated in the function
%   syntaxes below.
%  
%   Programming Model
%   -----------------
%   The programming model for accessing a point data set through
%   HDFPT is as follows:
%   
%   1. Open the file and initialize the PT interface by
%      obtaining a file id from a file name.
%   2. Open or create a point data set by obtaining a point id
%      from a point name.
%   3. Perform desired operations on the data set.
%   4. Close the point data set by disposing of the point id.
%   5. Terminate point access to the file by disposing of the
%      file id. 
%   
%   To access a single point data set that already exists in an
%   HDF-EOS file, use the following MATLAB commands:
%   
%       fileid = hdfpt('open',filename,access);
%       pointid = hdfpt('attach',fileid,pointname);
%   
%       % Optional operations on the data set...
%   
%       status = hdfpt('detach',pointid);
%       status = hdfpt('close',fileid);
%   
%   To access several files at the same time, obtain a separate
%   file identifier for each file to be opened.  To access more
%   than one point data set, obtain a separate point id for each
%   data set.
%   
%   It is important to properly dispose of point id's and file
%   id's so that buffered operations are written completely to
%   disk.  If you quit MATLAB or clear all MEX-files with PT
%   identifiers still open, MATLAB will issue a warning and
%   automatically dispose of them.
%   
%   Note that file identifiers returned by HDFPT are not
%   interchangeable with file identifiers returned by any
%   other HDF-EOS or HDF function.
%   
%   Function categories
%   -------------------
%   Point data set routines are classified into the following
%   categories:
%   
%   - Access routines initialize and terminate access to the PT
%     interface and point data sets (including opening and
%     closing files).
%   
%   - Definition routines allow the user to set key features
%     of a point data set.
%   
%   - Basic I/O routines read and write data and metadata to a
%     point data set.
%   
%   - Index I/O routines read and write information that links
%     two tables in a point data set.
%   
%   - Inquiry routines return information about data contained
%     in a point data set.
%   
%   - Subset routines allow reading of data from a specified
%     geographic region.
%   
%   Access routines
%   ---------------
%   PTopen
%       FILE_ID = HDFPT('open',FILENAME,ACCESS)
%       Given the filename and desired access mode, opens or
%       creates an HDF file in order to create, read, or write
%       a point.  ACCESS can be 'read', 'readwrite', or
%       'create'.  FILE_ID is -1 if the operation fails. 
%   
%   PTcreate
%       POINT_ID = HDFPT('create',FILE_ID,POINTNAME)
%       Creates a point data set with the specified name.
%       POINTNAME is a string contain the name of the point data
%       set. POINT_ID is -1 if the operation fails.
%   
%   PTattach
%       POINT_ID = HDFPT('attach',FILE_ID,POINTNAME)
%       Attaches to an existing point data set within the file.
%       POINT_ID is -1 if the operation fails.
%   
%   PTdetach
%       STATUS = HDFPT('detach',POINT_ID)
%       Detaches from point data set.
%   
%   PTclose
%       STATUS = HDFPT('close', FILE_ID)
%       Closes file.
%   
%   Definition routines
%   -------------------
%   PTdeflevel
%       STATUS = HDFPT('deflevel',POINT_ID,LEVELNAME,...
%                  FIELDLIST,FIELDTYPES,FIELDORDERS)
%       Defines a new level within a point data set.  LEVELNAME
%       is the name of the level to be defined.  FIELDLIST is a
%       string containing a comma-separated list of field names
%       in the new level.  FIELDTYPES is a cell array containing
%       the number type string for each field.  Valid number type
%       strings include 'uchar8', 'uchar', 'char8', 'char',
%       'double', 'uint8', 'uint16', 'uint32', 'float', 'int8',
%       'int16', and 'int32'. FIELDORDERS is a vector containing
%       the order for each field.
%   
%   PTdeflinkage
%       STATUS = HDFPT('deflinkage',POINT_ID,PARENT,...
%                         CHILD,LINKFIELD)
%       Defines a linkfield between two adjacent levels.  PARENT
%       is the name of the parent level.  CHILD is the name of
%       the child level.  LINKFIELD is the name of a field that
%       is defined at both levels.
%   
%   Basic I/O routines
%   ------------------
%   PTwritelevel
%       STATUS = HDFPT('writelevel',POINT_ID,LEVEL,DATA)
%       Appends new records to the specified level in a point
%       data set.  LEVEL is the desired level index (zero-based).
%       DATA must be a P-by-1 cell array where P is the number of
%       fields defined for the specified level. Each cell of DATA
%       must contain an M(k)-by-N matrix of data where M(k) is
%       the order of the k-th field (the number of scalar values
%       in the field) and N is the number of records.  The MATLAB
%       class of the cells must match the HDF data type defined
%       for the corresponding fields.  A MATLAB string will be
%       automatically converted to match any of the HDF char
%       types; other data types must match exactly.
%   
%   PTreadlevel
%       [DATA,STATUS] = HDFPT('readlevel',POINT_ID,LEVEL,FIELDLIST,RECORDS)
%       Reads data from a given level in a point data set.  LEVEL
%       is the index (zero-based) of the desired level.
%       FIELDLIST is a string containing a comma-separated list
%       of the fields to be read.  RECORDS is a vector containing
%       the indices (zero-based) of the records to be read.  DATA
%       is a P-by-1 cell array where P is the number of requested
%       fields.  Each cell of DATA contains an M(k)-by-N matrix
%       of data where M(k) is the order of the k-th field and N
%       is the number of records, or LENGTH(RECORDS).
%   
%   PTupdatelevel
%       STATUS = HDFPT('updatelevel',POINT_ID,LEVEL,...
%                         FIELDLIST,RECORDS,DATA)
%       Updates (corrects) data in a particular level of a point
%       data set.  LEVEL is the index (zero-based) of the desired
%       level.  FIELDLIST is a string containing a
%       comma-separated list of fieldnames to be updated.
%       RECORDS is a vector containing the indices (zero-based)
%       of the records to be updated.  DATA is a P-by-1 cell
%       array where P is the number of specified fields. Each
%       cell of DATA must contain an M(k)-by-N matrix of data
%       where M(k) is the order of the k-th field (the number of
%       scalar values in the field) and N is the number of
%       records, or LENGTH(RECORD).  The MATLAB class of the
%       cells must match the HDF data type defined for the
%       corresponding fields.  A MATLAB string will be
%       automatically converted to match any of the HDF char
%       types; other data types must match exactly.
%   
%   PTwriteattr
%       STATUS = HDFPT('writeattr',POINT_ID,ATTRNAME,DATA)
%       Writes or updates the point data set attribute with the
%       specified name. If the attribute does not already exist,
%       it is created.
%   
%   PTreadattr
%       [DATA,STATUS] = HDFPT('readattr',POINT_ID,ATTRNAME)
%       Reads the attribute data from the specified attribute.
%   
%   Inquiry routines
%   ----------------
%   PTnlevels
%       NLEVELS = HDFPT('nlevels',POINT_ID)
%       Returns the number of levels in a point data set.
%       NLEVELS is -1 if the operation fails.
%   
%   PTnrecs
%       NRECS = HDFPT('nrecs',POINT_ID,LEVEL)
%       Returns the number of records in the specified level.
%       NRECS is -1 if the operation fails.
%   
%   PNnfields
%       [NUMFIELDS,STRBUFSIZE] = HDFPT('nfields',POINT_ID,LEVEL)
%       Returns the number of fields in the specified level.
%       STRBUFSIZE is the length of the comma-separated fieldname
%       string.  NUMFIELDS is -1 and STRBUFSIZE is [] if the
%       operation fails.
%   
%   PTlevelinfo
%       [NUMFIELDS,FIELDLIST,FIELDTYPE,FIELDORDER] = ...
%                        HDFPT('levelinfo',POINT_ID,LEVEL)
%       Returns information on fields for a specified level.
%       FIELDLIST is a string containing a comma-separated list
%       of field names.  FIELDTYPE is a cell array of strings
%       that defined the data type for each field.  FIELDORDER is
%       a vector containing the order (number of scalar values)
%       associated with each field.  If the operation fails,
%       NUMFIELDS is -1 and the other outputs are empty.
%   
%   PTlevelindx
%       LEVEL = HDFPT('levelindx',POINT_ID,LEVELNAME)
%       Returns the level index (zero-based) of the level with
%       the specified name.  LEVEL is -1 if the operation fails.
%   
%   PTbcklinkinfo
%       [LINKFIELD,STATUS] = HDFPT('bcklinkinfo',POINT_ID,LEVEL)
%       Returns the linkfield to the previous level.  STATUS is
%       -1 and LINKFIELD is [] if the operation fails.
%   
%   PTfwdlinkinfo
%       [LINKFIELD,STATUS] = HDFPT('fwdlinkinfo',POINT_ID,LEVEL)
%       Returns the linkfield to the following level.  STATUS is
%       -1 and LINKFIELD is [] if the operation fails.
%   
%   PTgetlevelname
%       [LEVELNAME,STATUS] = HDFPT('getlevelname',POINT_ID,LEVEL)
%       Returns the name of a level given the level index.
%       STATUS is -1 and LEVELNAME is [] if the operation fails.
%   
%   PTsizeof
%       [BYTESIZE,FIELDLEVELS] = HDF('sizeof',POINT_ID,FIELDLIST)
%       Returns the size in bytes and field levels of the
%       specified fields.  FIELDLIST is a string containing a
%       comma-separated list of field names.  BYTESIZE is the
%       total size of bytes of the specified fields, and
%       FIELDLEVELS is a vector containing the level index
%       corresponding to each field.  BYTESIZE is -1 and
%       FIELDLEVELS is [] if the operation fails.
%   
%   PTattrinfo
%       [NUMBERTYPE,COUNT,STATUS] = HDFPT('attrinfo',POINT_ID,ATTRNAME)
%       Returns the number type and size in bytes of the
%       specified attribute.  ATTRNAME is the name of the
%       attribute.  NUMBERTYPE is a string corresponding to the
%       HDF data type of the attribute.  COUNT is the number of
%       bytes used by the attribute data.  STATUS is -1 and
%       NUMBERTYPE and COUNT are [] if the operation fails.
%   
%   PTinqattrs
%       [NATTRS,ATTRNAMES] = HDFPT('inqattrs',POINT_ID)
%       Retrieve information about attributes defined in a point
%       data set.  NATTRS and ATTRNAMES are the number and names
%       of all the defined attributes, respectively.  If the
%       operation fails, NATTRS is -1 and ATTRNAMES is [].
%   
%   PTinqpoint
%       [NUMPOINTS,POINTNAMES] = HDFPT('inqpoint',FILENAME)
%       Retrieve number and names of point data sets defined in
%       an HDF-EOS file.  POINTNAMES is a string containing a
%       comma-separated list of point names.  NUMPOINTS is -1 and
%       POINTNAMES is [] if the operation fails.
%   
%   Utility routines
%   ----------------
%   PTgetrecnums
%       [OUTRECORDS,STATUS] = HDFPT('getrecnums',...
%                           POINT_ID,INLEVEL,OUTLEVEL,INRECORDS)
%       Returns the record numbers in OUTLEVEL corresponding the
%       group of records specified by INRECORDS in level INLEVEL.
%       INLEVEL and OUTLEVEL are zero-based level indices.
%       INRECORDS is a vector of zero-based record indices.
%       STATUS is -1 and OUTRECORDS is [] if the operation fails.
%   
%   Subset routines
%   ---------------
%   PTdefboxregion
%       REGION_ID = HDFPT('defboxregion',POINT_ID,...
%                            CORNERLON,CORNERLAT)
%       Defines a longitude-latitude box region for a point.
%       CORNERLON is a two-element vector containing the
%       longitudes of opposite box corners.  CORNERLAT is a
%       two-element vector containing the latitudes of opposite
%       box corners.  REGION_ID is -1 if the operation fails.
%   
%   PTdefvrtregion
%       PERIOD_ID = HDFPT('defvrtregion',POINT_ID,REGION_ID,,...
%                            VERT_FIELD,RANGE)
%       Defines a vertical region for a point.  VERT_FIELD is the
%       name of the field to subset.  RANGE is a two-element vector
%       containing the minimum and maximum vertical values.
%       PERIOD_ID is -1 if the operation fails.
%
%   PTregioninfo
%       [BYTESIZE,STATUS] = HDFPT('regioninfo',POINT_ID,...
%                           REGION_ID,LEVEL,FIELDLIST)
%       Returns the data size in bytes of the subset period of
%       the specified level.  FIELDLIST is a string containing a
%       comma-separated list of fields to extract.  STATUS and BYTESIZE
%       are -1 if the operation fails.
%   
%   PTregionrecs
%       [NUMREC,RECNUMBERS,STATUS] = HDFPT('regionrecs',...
%                                     POINT_ID,REGION_ID,LEVEL)
%       Returns the records numbers within the subsetted region
%       of the specified level.  STATUS and NUMREC are -1 and 
%       RECNUMBERS is [] if the operation fails.
%   
%   PTextractregion
%       [DATA,STATUS] = HDFPT('extractregion',POINT_ID,...
%                                REGION_ID,LEVEL,FIELDLIST)
%       Reads data from the specified subset region.  FIELDLIST
%       is a string containing a comma-separated list of
%       requested fields.  DATA is a P-by-1 cell array where P is
%       the number of requested fields.  Each cell of DATA
%       contains an M(k)-by-N matrix of data where M(k) is the
%       order of the k-th field and N is the number of records.
%       STATUS is -1 and DATA is [] if the operation fails.
%   
%   PTdeftimeperiod
%       PERIOD_ID = HDFPT('deftimeperiod',POINT_ID,...
%                            STARTTIME,STOPTIME)
%       Defines a time period for a point data set.  PERIOD_ID is
%       -1 if the operation fails.
%   
%   PTperiodinfo
%       [BYTESIZE,STATUS] = HDFPT('periodinfo',POINT_ID,...
%                           PERIOD_ID,LEVEL,FIELDLIST)
%       Retrieves the size in bytes of the subsetted period.
%       FIELDLIST is string containing a comma-separated list of
%       desired field names.  BYTESIZE and STATUS are -1 if the 
%       operation fails.
%   
%   PTperiodrecs
%       [NUMREC,RECNUMBERS,STATUS] = HDFPT('periodrecs',...
%                             POINT_ID,PERIOD_ID,LEVEL)
%       Returns the records numbers within the subsetted time
%       period of the specified level.  NUMREC and STATUS are -1
%       if the operation fails.
%   
%   PTextractperiod
%       [DATA,STATUS] = HDFPT('extractregion',...
%                       POINT_ID,REGION_ID,LEVEL,FIELDLIST)
%       Reads data from the specified subsetted time period.
%       FIELDLIST is a string containing a comma-separated list
%       of requested fields.  DATA is a P-by-1 cell array where P
%       is the number of requested fields.  Each cell of DATA
%       contains an M(k)-by-N matrix of data where M(k) is the
%       order of the k-th field and N is the number of records.
%       STATUS is -1 and DATA is [] if the operation fails.
%   
%   See also HDF, HDFSW, HDFGD.
   
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:19 $
   
% Call HDF.MEX to do the actual work.
ans = [];
if nargout>0
  [varargout{1:nargout}] = hdf('PT',varargin{:});
else
  hdf('PT',varargin{:});
end
if ~isempty(ans)
  varargout{1} = ans;
end
