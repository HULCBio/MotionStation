function varargout = hdfgd(varargin)
%HDFGD MATLAB interface to the HDF-EOS Grid object.
%
%   HDFGD is the MATLAB interface to the HDF-EOS Grid
%   object. HDF-EOS is an extension of NCSA (National Center for
%   Supercomputing Applications) HDF (Hierarchical Data Format).
%   HDF-EOS is the scientific data format standard selected by
%   NASA as the baseline standard for EOS (Earth Observing
%   System).
%   
%   HDFGD is a gateway to the Grid functions in the HDF-EOS C
%   library, which is developed and maintained by EOSDIS (Earth
%   Observing System Data and Information System).  A grid
%   data set consists of a rectilinear array of two or more
%   dimensions, dimension definitions, and an associated map
%   projections. 
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
%   There is a one-to-one mapping between Grid functions in the
%   HDF-EOS C library and HDFGD syntaxes.  For example, the C
%   library contains this function for getting the size of a
%   specific dimension:
%   
%       int32 GDdiminfo(int32 gridid, char *dimname)
%   
%   The equivalent MATLAB usage is:
%   
%       DIMSIZE = HDFGD('diminfo',GRID_ID,DIMNAME)
%   
%   GRID_ID is the identifier (or handle) to a particular grid
%   data set. DIMNAME is a string containing the name of the
%   specified dimension.  DIMSIZE is the size of the specified
%   dimension, or -1 if the operation fails.
%   
%   Some of the C library functions accept input values that are
%   defined in terms of C macros.  For example, the C GDopen()
%   function requires an access mode input that can be
%   DFACC_READ, DFACC_RDWR, or DFACC_CREATE, where these symbols
%   are defined in the appropriate C header file.  Where macro
%   definitions are used in the C library, the equivalent MATLAB
%   syntaxes use strings derived from the macro names.  You can
%   either use a string containing the entire macro name, or you
%   can omit the common prefix.  You can use either upper or
%   lower case.  For example, this C function call:
%   
%       status = GDopen("GridFile.hdf",DFACC_CREATE)
%   
%   is equivalent to these MATLAB function calls:
%   
%       status = hdfgd('open','GridFile.hdf','DFACC_CREATE')
%       status = hdfgd('open','GridFile.hdf','dfacc_create')
%       status = hdfgd('open','GridFile.hdf','CREATE')
%       status = hdfgd('open','GridFile.hdf','create')
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
%   The programming model for accessing a grid data set through
%   HDFGD is as follows:
%   
%   1. Open the file and initialize the GD interface by
%      obtaining a file id from a file name.
%   2. Open or create a grid data set by obtaining a grid id
%      from a grid name.
%   3. Perform desired operations on the data set.
%   4. Close the grid data set by disposing of the grid id.
%   5. Terminate grid access to the file by disposing of the
%      file id. 
%   
%   To access a single grid data set that already exists in an
%   HDF-EOS file, use the following MATLAB commands:
%   
%       fileid = hdfgd('open',filename,access);
%       gridid = hdfgd('attach',fileid,gridname);
%   
%       % Optional operations on the data set...
%   
%       status = hdfgd('detach',gridid);
%       status = hdfgd('close',fileid);
%   
%   To access several files at the same time, obtain a separate
%   file identifier for each file to be opened.  To access more
%   than one grid data set, obtain a separate grid id for each
%   data set.
%   
%   It is important to properly dispose of grid id's and file
%   id's so that buffered operations are written completely to
%   disk.  If you quit MATLAB or clear all MEX-files with GD
%   identifiers still open, MATLAB will issue a warning and
%   automatically dispose of them.
%
%   Note that file identifiers returned by HDFGD are not
%   interchangeable with file identifiers returned by any
%   other HDF-EOS or HDF function.
%   
%   Function categories
%   -------------------
%   Grid data set routines are classified into the following
%   categories:
%   
%   - Access routines initialize and terminate access to the GD
%     interface and grid data sets (including opening and
%     closing files).
%   
%   - Definition routines allow the user to set key features
%     of a grid data set.
%   
%   - Basic I/O routines read and write data and metadata to a
%     grid data set.
%   
%   - Inquiry routines return information about data contained
%     in a grid data set.
%   
%   - Subset routines allow reading of data from a specified
%     geographic region.
%   
%   Access routines
%   ---------------
%   GDopen
%       FILE_ID = HDFGD('open',FILENAME,ACCESS)
%       Given the filename and desired access mode, opens or
%       creates an HDF file in order to create, read, or write
%       a grid data set.  ACCESS can be 'read', 'rdwr',
%       or 'create'.  FILE_ID is -1 if the operation fails. 
%   
%   GDcreate
%       GRID_ID = HDFGD('create',FILE_ID,GRIDNAME,...
%                          XDIMSIZE,YDIMSIZE,UPLEFT,LOWRIGHT)
%       Creates a grid data set. GRIDNAME is a string contain
%       the name of the grid data set. XDIMSIZE and YDIMSIZE
%       are scalars indicating the sizes of respective
%       dimensions. UPLEFT is a two-element vector containing
%       the X and Y coordinates of the upper left pixel of the
%       grid. LOWRIGHT is a two-element vector containing the
%       X and Y coordinates of the lower right pixel of the
%       grid.  GRID_ID is -1 if the operation fails.
%   
%   GDattach
%       GRID_ID = HDFGD('attach',FILE_ID,GRIDNAME)
%       Attaches to an existing grid data set within the file.
%       GRID_ID is -1 if the operation fails.
%   
%   GDdetach
%       STATUS = HDFGD('detach',GRID_ID)
%       Detaches from grid data set.
%   
%   GDclose
%       STATUS = HDFGD('close', FILE_ID)
%       Closes file.
%   
%   Definition syntaxes
%   -------------------
%   GDdeforigin
%       STATUS = HDFGD('deforigin',GRID_ID,ORIGIN)
%       Defines which corner of the grid is the origin.
%       ORIGIN can be 'ul', 'ur', 'll', or 'lr'.
%
%   GDdefdim
%       STATUS = HDFGD('defdim',GRID_ID,DIMNAME,DIM)
%       Defines a new dimension within the grid data
%       set. DIMNAME is a string containing the name of the
%       new dimension, and DIM is a scalar containing the size
%       of the new dimension.
%
%   GDdefproj
%       STATUS = HDFGD('defproj',GRID_ID,PROJCODE,...
%                 ZONECODE,SPHERECODE,PROJPARM)
%       Defines the map projection for a grid data
%       set. PROJCODE can be 'geo', 'utm', 'lamcc', 'ps',
%       'polyc', 'tm', 'lamaz', 'hom', 'som', 'good', or
%       'isinus'.  ZONECODE is the Universal Transverse
%       Mercator zone code; specify [] or 0 for other
%       projections. SPHERECODE is a scalar spheroid
%       code. PROJPARM is a vector of up to 13 elements
%       containing projection-specific parameters. For more
%       details about PROJCODE, ZONECODE, SPHERECODE, and
%       PROJPARM, see Chapter 6 of HDF-EOS Library Users Guide
%       for the ECS Project, Volume 1: Overview and Examples.
%
%   GDdefpixreg
%       STATUS = HDFGD('defpixreg',GRID_ID,PIXREG)
%       Defines pixel registration within grid cell.  PIXREG
%       can be 'center' or 'corner'.
%
%   GDdeffield
%       STATUS = HDFGD('deffield',GRID_ID,FIELDNAME,...
%                         DIMLIST,NUMBERTYPE,MERGE)
%       Defines data fields to be stored in a grid.  FIELDNAME
%       is a string containing the name of the dimension to be
%       defined.  DIMLIST is a string containing a
%       comma-separated list of dimension names.  NUMBERTYPE
%       is a string specifying the HDF number type.  MERGE can
%       be either 'nomerge' or 'automerge'.
%
%   GDdefcomp
%       STATUS = HDFGD('defcomp',GRID_ID,COMPCODE,COMPPARM)
%       Sets the field compression for all subsequent field
%       definitions.  COMPCODE can be 'rle', 'skphuff',
%       'deflate', or 'none'.  Deflate compression requires
%       that COMPPARM be an integer from one to nine, with
%       higher values corresponding to higher compression.
%       Specify 0 or [] for COMPPARM for other compression
%       methods.
%
%   GDwritefieldmeta
%       STATUS = HDFGD('writefieldmeta',GRID_ID,...
%                   FIELDNAME,DIMLIST,NUMBERTYPE)
%       Writes field metadata for an existing grid field that
%       was not defined using the Grid API.  FIELDNAME is a
%       string containing the name of the field.  DIMLIST is a
%       string containing a comma-separated list of dimension
%       names. NUMBERTYPE a string specifying the HDF number
%       type.
%
%   GDblkSOMoffset
%	STATUS = HDFGD('blksomoffset',GRID_ID,OFFSET)
%	Writes the block SOM offset values, in pixels, from 
%       a standard SOM projection. OFFSET is a vector of offset 
%       values for SOM projection data.  This routine can only 
%       be used with grids that use the SOM projection.  
%
%   GDsettilecomp
%	STATUS = HDFGD('settilecomp',GRIDID,FIELDNAME,...
%                   TILEDIMS,COMPCODE,COMPPARM)
%	Sets tiling and compression parameters for a field that has fill 
%	values.  This routine was introduced in HDF-EOS 2.5 to fix a 
%	bug in HDF-EOS 2.3.  FIELDNAME is the name of the specified grid. 
%       TILEDIMS is a vector containing the tile dimensions. COMPCODE 
%       can be 'rle', 'skphuff', 'deflate', or 'none'. Deflate compression
%       requires that COMPPARM be an integer from one to nine, with higher
%       values corresponding to higher compression. Specify 0 or [] for
%       COMPPARM for other compression methods. The order in which this
%       function must be called is 
%
%		   hdfgd('gddeffield'... 
%                  hdfgd('gdsetfillvalue'...
%		   hdfgd('gdsettilecomp'...
%	
%
%   Basic I/O syntaxes
%   ------------------
%   GDwritefield
%       STATUS = HDFGD('writefield',GRID_ID,FIELDNAME,...
%                   START,STRIDE,EDGE,DATA)
%       Writes data to the specified field of a grid data
%       set.  FIELDNAME is the name of the specified grid.
%       START is an vector specifying the starting location
%       (zero-based) within each dimension.  STRIDE is a
%       vector specifying the number of values to skip along
%       each dimension.  EDGE is the number of values to write
%       along each dimension.  DATA is the array of values to
%       be written.  Specifying [] for START is the same as
%       specifying ZEROS(1,NUMDIMS).  Specifying [] for STRIDE
%       is the same as specifying ONES(1,NUMDIMS).  Specifying
%       [] for EDGE is the same as specifying
%       FLIPLR(SIZE(DATA)).  
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
%       example, if the grid field has been defined to have
%       dimensions 3-by-4-by-5, then DATA must have size
%       5-by-4-by-3.  The PERMUTE command is useful for making
%       any necessary conversions.
%
%   GDreadfield
%       [DATA,STATUS] = HDFGD('readfield',GRID_ID,...
%                        FIELDNAME,START,STRIDE,EDGE)
%       Reads data from specified grid field.  FIELDNAME is
%       the name of the field to read.  START is a vector
%       specifying the starting location (zero-based) within
%       each dimension.  STRIDE is a vector specifying the
%       number of values to skip along each dimension.  EDGE
%       is a vector containing the number of values to read
%       along each dimension.  Specifying [] for START is the
%       same as specifying ZEROS(1,NUMDIMS).  Specifying []
%       for STRIDE is the same as specifying ONES(1,NUMDIMS).
%       Specifying [] for EDGE implies that the entire field
%       will be read.
%
%       NOTE: HDF files use C-style ordering for multidimensional
%       arrays, while MATLAB uses FORTRAN-style ordering.  This
%       means that the size of the MATLAB array must be flipped
%       relative to the defined dimension sizes of the HDF data
%       field.  For example, if the grid field has been defined
%       to have dimensions 3-by-4-by-5, then DATA will have size
%       5-by-4-by-3.  The PERMUTE command is useful for making
%       any necessary conversions.
%
%       DATA is [] and STATUS is -1 if the operation fails.
%
%   GDwriteattr
%       STATUS = HDFGD('writeattr',GRID_ID,ATTRNAME,DATA)
%       Writes or updates the grid data set attribute with the
%       specified name. If the attribute does not already exist,
%       it is created.
%   
%   GDreadattr
%       [DATA,STATUS] = HDFGD('readattr',GRID_ID,ATTRNAME)
%       Reads the attribute data from the specified
%       attribute.  DATA is [] and STATUS is -1 if the
%       operation fails.
%   
%   GDsetfillvalue
%       STATUS = HDFGD('setfillvalue',GRID_ID,...
%                                FIELDNAME,FILLVALUE)
%       Sets the fill value for the specified field.
%       FILLVALUE is a scalar whose class must match the
%       HDF number type of the specified field.  A MATLAB
%       string will be automatically converted to match any of
%       the HDF char types; other data types must match
%       exactly.
%
%   GDgetfillvalue
%       [FILLVALUE,STATUS] = HDFGD('getfillvalue',GRID_ID, ...
%                            FIELDNAME)
%       Retrieves the fill value for the specified field.
%       FILLVALUE is [] and STATUS is -1 if the operation
%       fails.
%
%   Inquiry routines
%   ----------------
%   GDinqdims
%       [NDIMS,DIMNAME,DIMS] = HDFGD('inqdims',GRID_ID)
%       Retrieves information about all of the dimensions
%       defined in a grid data set.  NDIMS is the number of
%       dimensions. DIMNAME is a string containing a
%       comma-separated list of dimension names. DIMS is a
%       vector containing the size of each dimension.  NDIMS
%       is -1 and DIMNAME and DIMS are [] if the operation
%       fails.
%
%   GDinqfields
%       [NFIELDS,FIELDLIST,RANK,NUMBERTYPE] = HDFGD( ...
%                'inqfields', GRID_ID)
%       Retrieves information about all of the fields defined
%       in a grid data set.  NFIELDS is the number of
%       fields. FIELDLIST is a string containing a
%       comma-separated list of field names.  RANK is a vector
%       containing the rank of each field.  NUMBERTYPE is a
%       cell array of strings containing the HDF number type
%       of each field.
%
%   GDinqattrs
%       [NATTRS,ATTRLIST] = HDFGD('inqattrs',GRID_ID)
%       Retrieves information about all of the attributes
%       defined in a grid. NATTRS is the number of
%       attributes. ATTRLIST is a string containing a
%       comma-separated list of attribute names. NATTRS is -1
%       and ATTRLIST is [] if the operation fails.
%
%   GDnentries
%       [NENTRIES,STRBUFSIZE] = HDFGD('nentries',GRID_ID,...
%                 ENTRYCODE)
%       Returns the number of entries for a specified entity.
%       ENTRYCODE can be either 'nentdim' to query the number
%       of dimensions, or 'nentdfld' to query the number of
%       fields. STRBUFSIZE is the length of the
%       comma-separated list of dimension or field names.
%
%   GDgridinfo
%       [XDIMSIZE,YDIMSIZE,UPLEFT,LOWRIGHT,STATUS] = ...
%                 HDFGD('gridinfo',GRID_ID)
%       Returns position and size of grid data set. XDIMSIZE
%       and YDIMSIZE are scalars containing the respective
%       dimension size. UPLEFT is a two-element vector
%       containing the X and Y coordinates of the upper-left
%       grid corner. LOWRIGHT is a two-element vector
%       containing the X and Y coordinates of the lower-right
%       grid corner. STATUS is -1 and all other outputs are []
%       if the operation fails.
%
%   GDprojinfo
%       [PROJCODE,ZONECODE,SPHERECODE,PROJPARM,STATUS] = ...
%                 HDFGD('projinfo',GRID_ID)
%       Retrieves projection information about a grid data
%       set.  See GDdefproj above for a description of the
%       output parameters.  STATUS is -1 and all other outputs
%       are [] if the operation fails.
%
%   GDdiminfo
%       DIMSIZE = HDFGD('diminfo',GRID_ID,DIMNAME)
%       Retrieves the size of the specified dimension.
%       DIMNAME is a string containing the dimension name.
%       DIMSIZE is -1 if the operation fails.
%
%   GDcompinfo
%       [COMPCODE,COMPPARM,STATUS] = HDFGD('compinfo',...
%                          GRID_ID,FIELDNAME)
%       Retrieves compression information about the specified
%       field.  See GDdefcomp above for a description of the
%       output parameters.  STATUS is -1 and the other outputs
%       are [] if the operation fails.
%
%   GDfieldinfo
%       [RANK,DIMS,NUMBERTYPE,DIMLIST,STATUS] = ...
%             HDFGD('fieldinfo',GRID_ID,FIELDNAME)
%       Retrieves information about a specified field. RANK is
%       the field rank. DIMS is a vector containing the
%       dimension sizes of the field. NUMBERTYPE is a string
%       containing the HDF number type of the field. DIMLIST
%       is a string containing a comma-separated list of
%       dimension names.  STATUS is -1 and all other outputs
%       are [] if the operation fails.
%
%   GDinqgrid
%       [NGRID,GRIDLIST] = HDFGD('inqgrid',FILENAME)
%       Retrieves information about the grid data sets in an
%       HDF-EOS file.  NGRID is the number of grids, and
%       GRIDLIST is a string containing a comma-separated list
%       of grid data set names.  NGRID is -1 and GRIDLIST is
%       [] if the operation fails.
%
%   GDattrinfo
%       [NUMBERTYPE,COUNT,STATUS] = HDFGD('attrinfo',...
%                   GRID_ID,ATTRNAME)
%       Returns the number type and size in bytes of the
%       specified attribute.  ATTRNAME is the name of the
%       attribute.  NUMBERTYPE is a string corresponding to
%       the HDF number type of the attribute.  COUNT is the
%       number of bytes used by the attribute data.  STATUS is
%       -1 and NUMBERTYPE and COUNT are [] if the operation
%       fails. 
%
%   GDorigininfo
%       ORIGINCODE = HDFGD('origininfo',GRID_ID)
%       Returns the origin code for a grid data set.
%       ORIGINCODE is 'ul', 'ur', 'll', or 'lr'.
%
%   GDpixreginfo
%       PIXREGCODE = HDFGD('pixreginfo',GRID_ID)
%       Returns the pixreg code for a grid data set.
%       PIXREGCODE is either 'center' or 'corner'.
%
%   Subset routines
%   ---------------
%   GDdefboxregion
%       REGION_ID = HDFGD('defboxregion',GRID_ID,...
%                            CORNERLON,CORNERLAT)
%       Defines a longitude-latitude box region for a grid data
%       set.  CORNERLON is a two-element vector containing the
%       longitudes of opposite box corners.  CORNERLAT is a
%       two-element vector containing the latitudes of opposite
%       box corners.  REGION_ID is -1 if the operation fails.
%   
%   GDregioninfo
%       [NUMBERTYPE,RANK,DIMS,BYTESIZE,UPLEFT,LOWRIGHT, ...
%           STATUS] = HDFGD('regioninfo',GRID_ID,...
%                              REGION_ID,FIELDNAME)
%       Returns information about the subsetted
%       region. NUMBERTYPE is the HDF number type of the
%       field. RANK is the rank of the field. DIMS is a vector
%       containing the dimension sizes of the subsetted
%       region. BYTESIZE is the size in bytes of the data in
%       the subsetted region. UPLEFT is a two-element vector
%       containing the X and Y coordinates of the upper-left
%       corner of the subsetted region. LOWRIGHT is a
%       two-element vector containing the X and Y coordinates
%       of the lower-right corner of the subsetted
%       region. STATUS is -1 and all other outputs are [] if
%       the operation fails.
%   
%   GDextractregion
%       [DATA,STATUS] = HDFGD('extractregion',GRID_ID,...
%                  REGION_ID,FIELDNAME)
%       Reads data from subsetted region of the specified
%       field.  STATUS is -1 and DATA is [] if the operation
%       fails.
%
%       NOTE: HDF files use C-style ordering for multidimensional
%       array, while MATLAB uses FORTRAN-style ordering.  This
%       means that the size of the MATLAB array is flipped
%       relative to the dimension sizes of the subsetted region.
%       For example, if the subsetted region has dimensions
%       3-by-4-by-5, then DATA will have size 5-by-4-by-3.  The
%       PERMUTE command is useful for making any necessary
%       conversions.
%
%   GDdeftimeperiod
%       PERIOD_ID2 = HDFGD('deftimeperiod',GRID_ID,...
%                   PERIOD_ID,STARTTIME,STOPID)
%       Defines a time period for a grid data set.  PERIOD_ID
%       can be the output PERIOD_ID from a previous call or
%       -1.  STARTIME and STOPTIME are scalars specifying the
%       start and stop time of the period.  The output
%       PERIOD_ID2 is -1 if the operation fails.
%
%   GDdefvrtregion
%       REGION_ID2 = HDFGD('defvrtregion',GRID_ID,...
%                   REGION_ID,VERTOBJ,RANGE)
%       Subsets on a monotonic field or contiguous elements of
%       a dimension.  REGION_ID is the region of period ID
%       from a previous subset call, or -1.  VERTOBJ is a
%       string containing the name of the dimension or field
%       to subset by.  RANGE is a two-element vector
%       containing the minimum and maximum range for the
%       subset.  REGION_ID2 is -1 if the operation fails.
%
%   GDgetpixels
%       [ROW,COL,STATUS] = HDFGD('getpixels',GRID_ID,...
%                            LON,LAT)
%       Get pixel coordinates corresponding to latitude and
%       longitude. LON and LAT are vectors containing
%       longitude and latitude coordinates in degrees.  ROW
%       and COL are vectors containing the corresponding
%       zero-based row and column coordinates.  STATUS is -1
%       and ROW and COL are [] if the operation fails.
%
%   GDgetpixvalues
%       [DATA,BYTESIZE] = HDFGD('getpixvalues',GRID_ID, ...
%                   ROW,COL,FIELDNAME)
%       Reads data from the specified field at the specified
%       row and column coordinates.  ROW and COL are vectors
%       containing zero-based row and column coordinates. All
%       entries along nongeographic dimensions (that is, not
%       XDim and YDim) are returned as a single column
%       vector.  DATA is [] and BYTESIZE is -1 if the
%       operation fails.
%
%   GDinterpolate
%       [DATA,BYTESIZE] = HDFGD('interpolate',GRID_ID,...
%                   LON,LAT,FIELDNAME)
%       Performs bilinear interpolation on a field grid.  LON
%       and LAT are vectors containing longitude and latitude
%       coordinates.  All grid data entries along
%       nongeographic dimensions (that is, not XDim and YDim)
%       are interpolated.  The resulting values are returned
%       as a double-precision column vector. DATA is [] and
%       BYTESIZE is -1 if the operation fails.
%
%   GDdupregion
%       REGION_ID2 = HDFGD('dupregion',REGION_ID)
%       Duplicates a region.  This routine copies the
%       information stored in a current region and generates a
%       new identifier.  It is useful when the user wants to
%       further set a region or period in multiple
%       ways. REGION_ID2 is -1 if the operation fails.
%       
%   Tiling routines
%   ---------------
%   GDdeftile
%       STATUS = HDFGD('deftile',GRID_ID,TILECODE,TILEDIMS)
%       Defines tiling dimensions for subsequent field
%       definitions. The number of tile dimensions and
%       subsequent field dimensions must be the same, and the
%       tile dimensions must be integral divisors of the
%       corresponding field dimensions. TILECODE can be 'tile'
%       or 'notile'.  TILEDIMS is a vector containing the tile
%       dimensions.
%
%   GDtileinfo
%       [TILECODE,TILEDIMS,TILERANK,STATUS] = HDFGD( ...
%                 'tileinfo',GRID_ID,FIELDNAME)
%       Retrieves tiling information about a field. STATUS is
%       -1 and other outputs are [] if the operation fails.
%
%   GDsettilecache
%       STATUS = HDFGD('settilecache',GRID_ID,FIELDNAME,...
%                      MAXCACHE)
%       Sets tile cache parameters.  MAXCACHE is a scalar
%       indicating the maximum number of tiles to cache in
%       memory.
%
%   GDreadtile
%       [DATA,STATUS] = HDFGD('readtile',GRID_ID, ...
%                FIELDNAME,TILECOORDS)
%       Reads from tile within the specified field.
%       TILECOORDS is a vector specifying the zero-based
%       coordinates of the tile to be read.  The coordinates
%       are specified in terms of tiles, not data
%       elements. STATUS is -1 and DATA is [] if the operation
%       fails.
%
%       NOTE: HDF files use C-style ordering for multidimensional
%       array, while MATLAB uses FORTRAN-style ordering.  This
%       means that the size of the MATLAB array is flipped
%       relative to the dimension sizes of the tile.  For
%       example, if the tile has dimensions 3-by-4, then DATA has
%       size 4-by-3.  The PERMUTE command is useful for making
%       any necessary conversions.
%
%   GDwritetile
%       STATUS = HDFGD('writetile',GRID_ID,FIELDNAME, ...
%                    TILECOORDS,DATA)
%       Writes to tile within a field. TILECOORDS is a vector
%       specifying the zero-based coordinates of the tile to
%       be written to.  The coordinates are specified in terms
%       of tiles, not data elements.  The class of DATA must
%       match the HDF number type of the specified field.  A
%       MATLAB string will be automatically converted to match
%       any of the HDF char types; other data types must match
%       exactly.
%
%       NOTE: HDF files use C-style ordering for multidimensional
%       array, while MATLAB uses FORTRAN-style ordering.  This
%       means that the size of the MATLAB array is flipped
%       relative to the dimension sizes of the tile.  For
%       example, if the tile has dimensions 3-by-4, then DATA
%       should have 4-by-3.  The PERMUTE command is useful for
%       making any necessary conversions.
%
%   See also HDF, HDFSW, HDFPT.
   
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:12 $
   
% Call HDF.MEX to do the actual work.
ans = [];
if nargout>0
  [varargout{1:nargout}] = hdf('GD',varargin{:});
else
  hdf('GD',varargin{:});
end
if ~isempty(ans)
  varargout{1} = ans;
end
