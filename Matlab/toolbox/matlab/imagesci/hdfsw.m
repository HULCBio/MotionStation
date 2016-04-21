function varargout = hdfsw(varargin)
%HDFSW MATLAB interface to the HDF-EOS Swath object.
%
%   HDFSW is the MATLAB interface to the HDF-EOS Swath
%   object. HDF-EOS is an extension of NCSA (National Center for
%   Supercomputing Applications) HDF (Hierarchical Data Format).
%   HDF-EOS is the scientific data format standard selected by
%   NASA as the baseline standard for EOS (Earth Observing
%   System).
%   
%   HDFSW is a gateway to the Swath functions in the HDF-EOS C
%   library, which is developed and maintained by EOSDIS (Earth
%   Observing System Data and Information System).  A swath data
%   set consists of data fields, geolocation fields, dimensions,
%   and dimension maps.  The data field is the raw data of the
%   file.  Geolocation fields are used to tie the swath to
%   particular points on the Earth's surface.  Dimensions define
%   the axes of the data and geolocation fields, and dimension
%   maps define the relationship between the dimensions of the
%   data and geolocation fields.  The file may optionally have a
%   fifth part called an index for cases in which the geolocation
%   information does not repeat at regular intervals throughout
%   the swath (the index was specifically designed for Landsat 7
%   data products).
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
%   There is a one-to-one mapping between Swath functions in the
%   HDF-EOS C library and HDFSW syntaxes.  For example, the C
%   library contains this function for getting the size of a
%   specific dimension:
%   
%       int32 SWdiminfo(int32 swathid, char *dimname)
%   
%   The equivalent MATLAB usage is:
%   
%       DIMSIZE = HDFSW('diminfo',SWATH_ID,DIMNAME)
%   
%   SWATH_ID is the identifier (or handle) to a particular swath
%   data set.  DIMNAME is a string containing the name of the
%   specified dimension.  DIMSIZE is the size of the specified
%   dimension, or -1 if the operation fails.
%
%   Some of the C library functions accept input values that are
%   defined in terms of C macros.  For example, the C SWopen()
%   function requires an access mode input that can be
%   DFACC_READ, DFACC_RDWR, or DFACC_CREATE, where these symbols
%   are defined in the appropriate C header file.  Where macro
%   definitions are used in the C library, the equivalent MATLAB
%   syntaxes use strings derived from the macro names.  You can
%   either use a string containing the entire macro name, or you
%   can omit the common prefix.  You can use either upper or
%   lower case.  For example, this C function call:
%   
%       status = SWopen("SwathFile.hdf",DFACC_CREATE)
%   
%   is equivalent to these MATLAB function calls:
%   
%       status = hdfsw('open','SwathFile.hdf','DFACC_CREATE')
%       status = hdfsw('open','SwathFile.hdf','dfacc_create')
%       status = hdfsw('open','SwathFile.hdf','CREATE')
%       status = hdfsw('open','SwathFile.hdf','create')
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
%   The programming model for accessing a swath data set through
%   HDFSW is as follows:
%   
%   1. Open the file and initialize the SW interface by
%      obtaining a file id from a file name.
%   2. Open or create a swath data set by obtaining a swath id
%      from a swath name.
%   3. Perform desired operations on the data set.
%   4. Close the swath data set by disposing of the swath id.
%   5. Terminate swath access to the file by disposing of the
%      file id. 
%   
%   To access a single swath data set that already exists in an
%   HDF-EOS file, use the following MATLAB commands:
%   
%       fileid = hdfsw('open',filename,access);
%       swathid = hdfsw('attach',fileid,swathname);
%   
%       % Optional operations on the data set...
%   
%       status = hdfsw('detach',swathid);
%       status = hdfsw('close',fileid);
%   
%   To access several files at the same time, obtain a separate
%   file identifier for each file to be opened.  To access more
%   than one swath data set, obtain a separate swath identifier
%   for each data set.
%   
%   It is important to properly dispose of swath and file
%   identifiers so that buffered operations are written 
%   completely to disk.  If you quit MATLAB or clear all 
%   MEX-files with SW identifiers still open, MATLAB will 
%   issue a warning and automatically dispose of them.
%
%   Note that file identifiers returned by HDFSW are not
%   interchangeable with file identifiers returned by any
%   other HDF or HDF function.
%   
%   Function categories
%   -------------------
%   Swath data set routines are classified into the following
%   categories:
%   
%   - Access routines initialize and terminate access to the SW
%     interface and swath data sets (including opening and closing
%     files).  
%   
%   - Definition routines allow the user to set key features of 
%     a swath data set.  
%   
%   - Basic I/O routines read and write data and metadata to a
%     swath data set.
%   
%   - Inquiry routines return information about data contained
%     in a swath data set.
%   
%   - Subset routines allow reading of data from a specified
%     geographic region.
%   
%   Access Routines
%   ---------------
%   SWopen
%       FILE_ID = HDFSW('open',FILENAME,ACCESS)
%       Given the FILENAME and desired access mode, opens or
%       creates HDF file in order to create, read, or write a
%       swath data set.  ACCESS can be 'read', 'rdwr', or
%       'create'.  FILE_ID is -1 if the operation fails.
%     
%   SWcreate
%       SWATH_ID = HDFSW('create',FILE_ID,SWATHNAME)
%       Creates a swath dataset within the file.  SWATHNAME is a
%       string containing the name of the swath data set.
%       SWATH_ID is -1 if the operation fails.
%
%   SWattach
%       SWATH_ID = HDFSW('attach',FILE_ID,SWATHNAME)
%       Attaches to an existing swath data set within the file.
%       SWATH_ID is -1 if the operation fails.
%
%   SWdetach
%       STATUS = HDFSW('detach',SWATH_ID)
%       Detaches from swath dataset.
%
%   SWclose
%       STATUS = HDFSW('close',FILE_ID)
%       Closes file.
%   
%   Definition Routines
%   -------------------
%   SWdefdim
%       STATUS = HDFSW('defdim',SWATH_ID,FIELDNAME,DIM)
%       Defines a new dimension within the swath.  FIELDNAME is a
%       string specifying the name of the dimension to be
%       defined.  DIM is the size of the new dimension.  To
%       specify an unlimited dimension, DIM should be either 0 or
%       Inf.
%
%   SWdefdimmap
%       STATUS = HDFSW('defdimmap',SWATH_ID,GEODIM, ...
%                         DATADIM,OFFSET,INCREMENT);
%       Defines monotonic mapping between the geolocation and
%       data dimensions.  GEODIM is the geolocation dimension
%       name, and DATADIM is the data dimension name.  OFFSET and
%       INCREMENT specify the offset and increment of the
%       geolocation dimension with respect to the data dimension.
%   
%   SWdefidxmap
%       STATUS = HDFSW('defidxmap',SWATH_ID,GEODIM, ...
%                         DATADIM,INDEX)
%       Defines a nonregular mapping between the geolocation and
%       the data dimension.  GEODIM is the geolocation dimension
%       name, and DATADIM is the data dimension name.  INDEX is
%       the array containing the indices of the data dimension to
%       which each geolocation element corresponds.
%
%   SWdefgeofield
%       STATUS = HDFSW('defgeofield',SWATH_ID,FIELDNAME, ...
%                         DIMLIST,NTYPE,MERGE)
%       Defines a new geolocation field within the swath.
%       FIELDNAME is a string containing the name of the field to
%       be defined.  DIMLIST is a string containing a comma
%       separated list of geolocation dimensions defining the
%       field.  NTYPE is a string containing the HDF number type
%       of the field.  MERGE, the merge code, is either 'nomerge'
%       or 'automerge'.
% 
%   SWdefdatafield
%       STATUS = HDFSW('defdatafield',SWATH_ID,FIELDNAME, ...
%                         DIMLIST,NTYPE,MERGE)
%       Defines a new data field within the swath.  FIELDNAME is
%       a string containing the name of the field to be
%       defined. DIMLIST is a string containing a comma-separated
%       list of geolocation dimensions defining the field.  NTYPE
%       is a string containing the HDF number type of the field.
%       MERGE, the merge code, is either 'nomerge' or
%       'automerge'.
%     
%   SWdefcomp
%       STATUS = HDFSW('defcomp',SWATH_ID,COMPCODE,COMPPARM) 
%       Sets the field compression for all subsequent field
%       definitions.  COMPCODE, the HDF compression code, can be
%       'rle', 'skphuff', 'deflate', or 'none'.  COMPPARM is an
%       array of compression parameters, if applicable.  If no
%       parameters are applicable, COMPPARM should be [].
%   
%   SWwritegeometa
%       STATUS = HDFSW('writegeometa',SWATH_ID,FIELDNAME, ...
%                         DIMLIST,NTYPE)
%       Writes field metadata for an existing swath geolocation
%       field named FIELDNAME.  DIMLIST is a string containing a
%       comma-separated list of geolocation dimensions defining
%       the field.  NTYPE is a string containing the HDF number
%       type of the data stored in the field.
%   
%   SWwritedatameta
%       STATUS = HDFSW('writedatameta',SWATH_ID,FIELDNAME, ...
%                         DIMLIST,NTYPE)
%       Writes field metadata for an existing swath data field
%       named FIELDNAME.  DIMLIST is a string containing a comma
%       separated list of geolocation dimensions defining the
%       field.  NTYPE is a string containing the HDF number type
%       of the data stored in the field.
%
%   Basic I/O Functions
%   -------------------
%   SWwritefield
%       STATUS = HDFSW('writefield',SWATH_ID,FIELDNAME,...
%                         START,STRIDE,EDGE,DATA)
%       Writes data to a swath field.  FIELDNAME is the a string
%       containing the name of the field to write to. START is an
%       array specifying the starting location within each
%       dimension (default is 0).  STRIDE is an array specifying
%       the number of values to skip along each dimension
%       (default is 1).  EDGE is an array specifying the number
%       of values to write along each dimension (default is {dim
%       - start}/stride).  To use default values for start,
%       stride, or edge, pass in an empty matrix ([]).  
% 
%       The class of DATA must match the HDF number type defined
%       for the given field.  A MATLAB string will be
%       automatically converted to match any of the HDF char
%       types; other data types must match exactly.
%
%       NOTE: HDF files use C-style ordering for
%       multidimensional arrays, while MATLAB uses
%       FORTRAN-style ordering.  This means that the size of
%       the MATLAB array must be flipped relative to the
%       defined dimension sizes of the HDF data field.  For
%       example, if the swath field has been defined to have
%       dimensions 3-by-4-by-5, then DATA must have size
%       5-by-4-by-3.  The PERMUTE command is useful for making
%       any necessary conversions.
%
%   SWreadfield
%       [DATA,STATUS] = HDFSW('readfield',SWATH_ID,...
%                             FIELDNAME,START,STRIDE,EDGE)
%       Reads data from a swath field.  FIELDNAME is the a string
%       containing the name of the field to read from.  START is
%       an array specifying the starting location within each
%       dimension (default is 0).  STRIDE is an array specifying
%       the number of values to skip along each dimension
%       (default is 1).  EDGE is an array specifying the number
%       of values to write along each dimension (default is {dim
%       - start}/stride).  To use default values for start,
%       stride, or edge, pass in an empty matrix ([]).  The data
%       values are returned in the array DATA.
% 
%       NOTE: HDF files use C-style ordering for multidimensional
%       arrays, while MATLAB uses FORTRAN-style ordering.  This
%       means that the size of the MATLAB array is flipped
%       relative to the defined dimension sizes of the HDF data
%       field.  For example, if the grid field has been defined
%       to have dimensions 3-by-4-by-5, then DATA will have size
%       5-by-4-by-3.  The PERMUTE command is useful for making
%       any necessary conversions.
%
%       DATA is [] and STATUS is -1 if the operation fails.
%
%   SWwriteattr
%       STATUS = HDFSW('writeattr',SWATH_ID,ATTRNAME,DATA)
%       Writes/Updates attribute in a swath.  ATTRNAME is a
%       string containing the name of the attribute.  DATA is
%       an array containing the attribute values.
%   
%   SWreadattr
%       [DATA,STATUS] = HDFSW('readattr',SWATH_ID,ATTRNAME)
%       Reads attribute from a swath.  ATTRNAME is a string
%       containing the name of the attribute.  The attribute
%       values are returned in the array DATA.  DATA is [] and
%       STATUS is -1 if the operation fails.
%
%   SWsetfillvalue
%       STATUS = HDFSW('setfillvalue',SWATH_ID,FIELDNAME,...
%                             FILLVALUE)
%       Sets fill value for the specified field.  FILLVALUE is a
%       scalar whose class must match the HDF number type of the
%       specified field.  A MATLAB string will be automatically
%       converted to match any of the HDF char types; other data
%       types must match exactly.
%
%   SWgetfillvalue
%       [FILLVALUE,STATUS] = HDFSW('getfillvalue',SWATH_ID,...
%                              FIELDNAME)
%       Retrieves fill value for the specified field. FILLVALUE
%       is [] and STATUS is -1 if the operation fails.
%   
%   Inquiry Functions
%   -----------------
%   SWinqdims
%       [NDIMS,DIMNAME,DIMS] = HDFSW('inqdims',SWATH_ID)
%       Retrieve information about all of the dimensions defined
%       in swath.  NDIMS is the number of dimensions.  DIMNAME is
%       a string containing a comma-separated list of dimension
%       names.  DIMS is an array containing the size of each
%       dimension.  If the routine fails, NDIMS is -1 and the
%       other output arguments are [].
%       
%   SWinqmaps
%       [NMAPS,DIMMAP,OFFSET,INCREMENT] = HDFSW('inqmaps',...
%                                          SWATH_ID)
%       Retrieve information about all of the (non-indexed)
%       geolocation relations defined in swath.  The scalar NMAPS
%       is the number of geolocation relations found.  DIMMAP is
%       a string containing a comma-separated list of the
%       dimension map names.  The two dimensions in each mapping
%       are separated by a slash (/).  OFFSET and INCREMENT are
%       arrays which contain the offset and increment of the
%       geolocation dimensions with respect to the data
%       dimensions.  If the routine fails, NMAPS is -1 and the
%       other output arguments are [].
%
%   SWinqidxmaps
%       [NIDXMAPS,IDXMAP,IDXSIZES] = HDFSW('inqidxmaps',...
%                                        SWATH_ID)
%       Retrieve information about all of the indexed
%       geolocation/data mappings defined in swath.  NIDXMAPS is
%       the number of mappings.  IDXMAP is a string containing a
%       comma-separated list of the mappings.  IDXSIZES is an
%       array containing the sizes of the corresponding index
%       arrays.  If the routine fails, NIDXMAPS is -1 and the
%       other output arguments are [].
%  
%   SWinqgeofields
%       [NFLDS,FIELDLIST,RANK,NTYPE] = HDFSW('inqgeofields',...
%                                       SWATH_ID)
%       Retrieve information about all of the geolocation fields
%       defined in swath.  NFLDS is the number of geolocation
%       fields found.  FIELDLIST is a string containing a comma
%       separated list of the field names.  RANK is an array
%       containing the rank (number of dimensions) for each
%       field.  NTYPE is a cell array of strings that denote the
%       number type of each field.  If the routine fails, NFLDS
%       is -1 and the other output arguments are [].
% 
%   SWinqdatafields
%       [NFLDS,FIELDLIST,RANK,NTYPE] = HDFSW('inqdatafields',...
%                                         SWATH_ID)
%       Retrieve information about all of the data fields defined
%       in swath.  NFLDS is the number of geolocation fields
%       found.  FIELDLIST is a string containing a comma
%       separated list of the field names.  RANK is an array
%       containing the rank (number of dimensions) for each
%       field.  NTYPE is a cell array of strings that denote the
%       number type of each field.  If the routine fails, NFLDS
%       is -1 and the other output arguments are [].
% 
%   SWinqattrs
%       [NATTR,ATTRLIST] = HDFSW('inqattrs',SWATH_ID)
%       Retrieve information about attributes defined in swath.
%       NATTR is the number of attributes found.  ATTRLIST is a
%       string containing a comma-separated list of attribute
%       names.  If the routine fails, NATTR is -1 and ATTRLIST is
%       [].
% 
%   SWnentries
%       [NENTS,STRBUFSIZE] = HDFSW('nentries',SWATH_ID,ENTRYCODE)
%       Retrieve number of entries and descriptive string buffer
%       size for a specified entity.  ENTRYCODE can be one of the
%       following: 'HDFE_NENTDIM' (dimensions), 'HDFE_NENTMAP'
%       (dimension mappings), 'HDFE_NENTIMAP' (indexed dimension
%       mappings), 'HDFE_NENTGFLD' (geolocation fields), or
%       'HDFE_NENTDFLD' (data fields).  NENTS is the number of
%       entries found, and STRBUFSIZE is the descriptive string
%       size.  If the routine fails, NENTS is -1 and STRBUFSIZE
%       is [].
%
%   SWdiminfo
%       DIMSIZE = HDFSW('diminfo',SWATH_ID,DIMNAME)
%       Retrieve size of specified dimension.  DIMNAME is the
%       dimension name.  DIMSIZE is the size of the dimension.
%       If the routine fails, DIMSIZE is -1.
%
%   SWmapinfo
%       [OFFSET,INCREMENT,STATUS] = HDFSW('mapinfo',...
%                                 SWATH_ID,GEODIM,DATADIM)
%       Retrieve offset and increment of specific monotonic
%       geolocation mapping.  GEODIM is the geolocation dimension
%       name.  DATADIM is the data dimension name.  OFFSET and
%       INCREMENT are the offset and increment of the geolocation
%       dimension with respect to the data dimension. STATUS
%       is -1 and other outputs are [] if the operation fails.
%
%   SWidxmapinfo
%       [IDXSZ,INDEX] = HDFSW('idxmapinfo',SWATH_ID,GEODIM,...
%                                   DATADIM)
%       Retrieve indexed array of specified geolocation mapping.
%       GEODIM is the geolocation dimension name.  DATADIM is the
%       data dimension name.  IDXSZ is the size of the indexed
%       array.  INDEX is the index array of the mapping.  If the
%       routine fails IDXSZ is -1 and INDEX is [].
% 
%   SWattrinfo
%       [NTYPE,COUNT,STATUS] = HDFSW('attrinfo',SWATH_ID,...
%                                       ATTRNAME)
%       Returns information about a swath attribute.  ATTRNAME is
%       a string containing the name of the attribute.  NTYPE is
%       a string containing the HDF number type of the attribute.
%       COUNT is the number of bytes in the ATTRIBUTE.  STATUS
%       is -1 and other outputs are [] if the operation fails.
%
%   SWfieldinfo
%       [RANK,DIMS,NTYPE,DIMLIST,STATUS] = HDFSW('fieldinfo',...
%                               SWATH_ID,FIELDNAME)
%       Returns information about a specific geolocation or data
%       field in the swath.  FIELDNAME is a string containing the
%       name of the field.  RANK is the rank (number of
%       dimensions) of the field.  DIMS is an array containing
%       the dimension sizes of the field.  NTYPE is a string
%       containing the HDF number type of the field.  DIMLIST is
%       a string containing a comma-separated list of the
%       dimensions in a field. STATUS is -1 and other outputs
%       are [] if the operation fails.
%
%   SWcompinfo
%       [COMPCODE,COMPPARM,STATUS] = HDFSW('compinfo',...
%                                 SWATH_ID,FIELDNAME)
%       Retrieves compression information about a field.
%       FIELDNAME is a string containing the field name.
%       COMPCODE is the HDF compression code, and can be 'rle',
%       'skphuff', 'deflate', or 'none'.  COMPPARM is an array of
%       compression parameters.  STATUS is -1 and other
%       outputs are [] if the operation fails.
% 
%   SWinqswath
%       [NSWATH,SWATHLIST] = HDFSW('inqswath',FILENAME)
%       Retrieves number and names of swaths defined in HDF-EOS
%       file.  FILENAME is a string containing the file name.
%       NSWATH is the number of swath data sets found in the
%       file.  SWATHLIST is a string containing a comma-separated
%       list of swath names.  If the routine fails, NSWATH is -1
%       and SWATHLIST is [].
%   
%   SWregionindex
%       [REGIONID, GEODIM, IDXRANGE] = HDFSW('defboxregion',... 
%	        		 SWATHID, CORNERLON, CORNERLAT, MODE); 
%       Defines a longitude-latitude box region for a swath.  The difference
%       between this routine and SWdefboxregion is the geolocation track
%       dimension name and the range of that dimension are returned in
%       addition to a regionID. See the help for SWdefboxregion for a
%       description of valid inputs.
%       
%   SWupdateidxmap
%	[INDEXOUT, INDICES, IDXSZ] = HDFSW('updateidxmap',SWATHID,...
%					   REGIONID,INDEXIN);
%	Retrieves an indexed array of specified geolocation mapping for 
%	a specified region.  REGIONID is the swath region identifier. 
%	INDEXIN is the array containing the indices of the data dimension
%	to which each geolocation element corresponds.  INDEXOUT is an 
%	array containing the indices of the data dimension to which 
%	each geolocation corresponds in the subsetted region.  INDICES 
%	is an array containing the indices for the start and stop of the 
%	region. IDXSZ is the size of the INDICES array or -1 for failure.
%
%   SWgeomapinfo
%	REGMAP = HDFSW('geomapinfo',SWATHID, GEODIM)
%	Retrieves type of dimension mapping for the dimension with the 
%	name GEODIM. The return value REGMAP will be: 0 for no mapping 
%	1 for regular mapping, 2 for indexed mapping, 3 for both regular
%	and indexed, or -1 for failure.  
%
%   Subset Functions
%   ----------------
%   SWdefboxregion
%       REGIONID = HDFSW('defboxregion',SWATH_ID,CORNERLON,...
%                           CORNERLAT,MODE)
%       Defines a longitude-latitude box region for a swath.
%       CORNERLON and CORNERLAT are two-element arrays containing
%       the longitude and latitude in decimal degrees of the box
%       corners.  MODE is the cross track inclusion mode, and can
%       be 'HDFE_MIDPOINT', 'HDFE_ENDPOINT', or 'HDFE_ANYPOINT'.
%       REGIONID is the swath region identifier if the routine
%       succeeds or -1 if it fails.
%      
%   SWregioninfo
%       [NTYPE,RANK,DIMS,SIZE,STATUS] = HDFSW('regioninfo',...
%                               SWATH_ID,REGIONID,FIELDNAME)
%       Retrieves information about the subsetted region.
%       REGIONID is the swath region identifier.  FIELDNAME is a
%       string containing the name of the field to subset.  NTYPE
%       is a string containing the HDF number type of the field.
%       RANK is the RANK of the field.  DIMS is an array giving
%       the dimensions of the subset region.  SIZE is the size in
%       bytes of the subset region.
%
%   SWextractregion
%       [DATA,STATUS] = HDFSW('extractregion',SWATH_ID,...
%                         REGIONID,FIELDNAME,EXTERNAL_MODE)
%       Extracts (reads) from subsetted region.  REGIONID is the
%       swath region identifier.  FIELDNAME is a string
%       containing the name of the field to subset.
%       EXTERNAL_MODE is a string containing the external
%       geolocation mode, which can be 'external' (data and
%       geolocation fields can be in different swaths), or
%       'internal' (data and geolocation fields must be in
%       the same swath structure).  DATA is the data contained
%       in the subsetted region.
%
%   SWdeftimeperiod
%       PERIODID = HDFSW('deftimeperiod',SWATH_ID,STARTTIME,...
%                           STOPTIME,MODE)
%       Defines a time period for a swath.  STARTTIME and
%       STOPTIME are the start and stop time of the period.  MODE
%       is the Cross Track inclusion mode, and can be 'midpoint',
%       'endpoint', or 'anypoint'.  PERIODID is the time period
%       identifier.  If the routine fails, PERIODID is -1.
%
%   SWperiodinfo
%       [NTYPE,RANK,DIMS,SIZE,STATUS] = HDFSW('periodinfo',...
%                            SWATH_ID,PERIODID,FIELDNAME)
%       Retrieves information about the subsetted period.
%       PERIODID is the period identifier, and FIELDNAME is a
%       string containing the name of the field to subset.
%       NTYPE is a string containing the HDF number type of the
%       field.  RANK is the rank of the field.  DIMS is an array
%       containing the dimensions of the subsetted period.  SIZE
%       is the size in bytes of the subset period. STATUS is
%       -1 and other outputs are [] if the operation fails.
%
%   SWextractperiod
%       [DATA,STATUS] = HDFSW('extractperiod',SWATH_ID,...
%                            PERIODID,FIELDNAME,EXTERNAL_MODE)
%       Extracts (reads) from subsetted time period.  PERIODID is
%       the period identifier.  FIELDNAME is a string containing
%       the name of the field to subset.  EXTERNAL_MODE is the
%       external geolocation mode, which can be 'external' (data
%       and geolocation fields can be in different swaths), or
%       'internal' (data and geolocation fields must be in the
%       same swath structure).  DATA is the data contained in
%       the subsetted time period.
%
%   SWdefvrtregion 
%       ID2 = HDFSW('defvrtregion',SWATH_ID,ID,VERTOBJ,RANGE)
%       Subsets on a monotonic field or contiguous elements of a
%       dimension.  ID is the region or period identifier from a
%       previous subset call, or -1 if this is the first call.
%       VERTOBJ is a string containing the name of the dimension
%       or field to subset by.  RANGE is a two element vector
%       containing the range to subset on.  ID2 is the new region
%       or period identifier if the routine succeeds, or -1 if it
%       fails.
%
%   SWdupregion
%       ID2 = HDFSW('dupregion',ID)
%       Duplicates a region or period.  ID is the region or
%       period identifier.  ID2 is the new region or period
%       identifier.  If the routine fails, ID2 is -1.
%
%	See also HDF, HDFPT, HDFGD.

%	Copyright 1984-2003 The MathWorks, Inc. 
%	$Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:22 $

%	Call HDF.MEX to do the actual work.

ans = [];
if nargout>0
  [varargout{1:nargout}] = hdf('SW',varargin{:});
else
  hdf('SW',varargin{:});
end
if ~isempty(ans)
  varargout{1} = ans;
end
