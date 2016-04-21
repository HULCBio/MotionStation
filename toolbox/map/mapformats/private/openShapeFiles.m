function [shpFileId, shxFileId, dbfFileId, headerTypeCode] = ...
    openShapeFiles(filename,callingFcn)
%OPENSHAPEFILES Try to open .SHP, .SHX, and .DBF files.
%   Deconstruct a shapefile name that may include any of the standard
%   extensions (in either all lower of all upper case). Try to open the
%   corresponding SHP, SHX, and DBF files, returning a file ID for each one
%   if successful, -1 if not. Check the header file type, shapefile
%   version, and the shape type code found in the header.

%   Copyright 1996-2003  The MathWorks, Inc.  
%   $Revision: 1.1.10.3 $  $Date: 2003/12/13 02:56:55 $
        
% See if filename has an extension and extract basename.
[basename, shapeExtensionProvided] = deconstruct(filename);

% Open the SHP file, check shapefile code and version, and construct a
% qualified basename to ensure consistency in the event of duplicate
% filenames on the path.
[basename, ext] = checkSHP(basename,shapeExtensionProvided);

% Open the SHP file with the qualified basename and read/check the shape
% type code in the file header.
shpFileId = fopen([basename ext]);
headerTypeCode = readHeaderTypeCode(shpFileId,callingFcn);

% Open the SHX and DBF files with the qualified basename.
shxFileId = openSHX(basename,callingFcn);
dbfFileId = openDBF(basename);

%--------------------------------------------------------------------------
function [basename, shapeExtensionProvided] = deconstruct(filename)

shapefileExtensions = {'.shp','.shx','.dbf'};
[pathstr,name,ext] = fileparts(filename);

if isempty(ext)
    basename = filename;
    shapeExtensionProvided = false;
else
    if any(strcmp(lower(ext),shapefileExtensions))
        basename = fullfile(pathstr,name);
        shapeExtensionProvided = true;
    else
        % Make sure to allow filename  = 'test.jnk' where the full
        % shapefile name is actually 'test.jnk.shp'.
        basename = filename;
        shapeExtensionProvided = false;
    end
end

%--------------------------------------------------------------------------
function [basename, ext] = checkSHP(basename,shapeExtensionProvided)

shpFileId = fopen([basename '.shp']);
if (shpFileId == -1)
    shpFileId = fopen([basename '.SHP']);
end;

if (shpFileId == -1)
    if shapeExtensionProvided == false
        [pathstr,name,ext] = fileparts(basename);
        if ~isempty(ext)
            eid = sprintf('%s:%s:invalidExtension', getcomp, mfilename);
            msg = sprintf('Filename %s has an invalid extension. %s', basename,...
                  'If included must be .shp, .shx, or .dbf.');
            error(eid,msg)
        else
            eid = sprintf('%s:%s:failedToOpenSHP1', getcomp, mfilename);
            msg = sprintf('Failed to open both %s.shp and %s.SHP.',basename,basename);
            error(eid,msg)
        end
    else
        eid = sprintf('%s:%s:failedToOpenSHP2', getcomp, mfilename);
        msg = sprintf('Failed to open both %s.shp and %s.SHP.',basename,basename);
        error(eid,msg)
    end
end

standardShapefileCode = 9994;
fileCode = fread(shpFileId,1,'uint32','ieee-be');
if fileCode ~= standardShapefileCode
    fname = fopen(shpFileId);
    fclose(shpFileId);
    eid = sprintf('%s:%s:notAShapefile', getcomp, mfilename);
    msg = sprintf('Invalid shapefile %s.', fname);
    error(eid,msg)
end

versionSupported = 1000;
fseek(shpFileId,28,'bof');
version = fread(shpFileId,1,'uint32','ieee-le');
if version ~= versionSupported
    fclose(shpFileId);
    eid = sprintf('%s:%s:unsupportShapefileVersion', getcomp, mfilename);
    msg = sprintf('Unsupported shapefile version %d.', version);
    error(eid,msg)
end

% Construct fully qualified basename and get SHP extension.
[pathstr,name,ext] = fileparts(fopen(shpFileId));
if ~isempty(pathstr)
    basename = fullfile(pathstr,name);
else
    basename = fullfile('.',name);
end

fclose(shpFileId);

%--------------------------------------------------------------------------
function shxFileId = openSHX(basename,callingFcn)

if strcmp(callingFcn,'shaperead')
    msgForMissingSHX = 'Will build index from SHP file.';
else
    msgForMissingSHX = 'Depending on DBF file to get number of records.';
end

shxFileId = fopen([basename '.shx'],'r','ieee-be');
if (shxFileId == -1)
    shxFileId = fopen([basename '.SHX'],'r','ieee-be');
end

if (shxFileId == -1)
    wid = sprintf('%s:%s:missingSHX', getcomp, mfilename);
    msg = sprintf('Failed to open file %s.shx or file %s.SHX. %s',...
            basename, basename, msgForMissingSHX);
    warning(wid,msg)
end

%--------------------------------------------------------------------------
function dbfFileId = openDBF(basename)

dbfFileId = fopen([basename '.dbf'],'r','ieee-le');
if (dbfFileId == -1)
    dbfFileId = fopen([basename '.DBF'],'r','ieee-le');
end

if (dbfFileId == -1)
    wid = sprintf('%s:%s:missingDBF', getcomp, mfilename);
    msg = sprintf('Failed to open file %s.dbf or file %s.DBF. %s',...
            basename, basename,...
            'Shape output structure will have no attribute fields.');
    warning(wid,msg)
end

%--------------------------------------------------------------------------
function headerTypeCode = readHeaderTypeCode(shpFileId,callingFcn)

% Read the type code from a shapefile header and check to see if it's (1)
% valid and (2) supported by shaperead.  If it's not supported by
% shaperead, generate an error if called from shaperead but only a warning
% if called by shapeinfo.

fseek(shpFileId,32,'bof');
headerTypeCode = fread(shpFileId,1,'uint32','ieee-le');

if ~getShapeTypeInfo(headerTypeCode,'IsValid')
    eid = sprintf('%s:%s:invalidShapeTypeCode', getcomp, mfilename);
    msg = sprintf('Invalid shape type (type code = %g).',headerTypeCode);
    fclose(shpFileId);
    error(eid, msg);
end

if ~getShapeTypeInfo(headerTypeCode,'IsSupported')
    typeString = getShapeTypeInfo(headerTypeCode,'TypeString');
    eid = sprintf('%s:%s:unsupportedShapeType', getcomp, mfilename);
    msg = sprintf('Unsupported shape type %s (type code = %g).',...
                  typeString,headerTypeCode);
    if strcmp(callingFcn,'shaperead')
        fclose(shpFileId);
        error(eid, msg);
    else
        warning(eid, msg);
    end
end
