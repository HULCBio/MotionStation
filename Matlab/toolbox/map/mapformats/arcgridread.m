function [Z,R] = arcgridread( filename )
%ARCGRIDREAD Read a gridded data set in Arc ASCII Grid Format.
%   [Z, R] = ARCGRIDREAD(FILENAME) reads a grid from a file in Arc ASCII
%   Grid format.  Z is a 2D array containing the data values.  R is a
%   referencing matrix (see MAKEREFMAT).  NaN is assigned to elements of Z
%   corresponding to null data values in the grid file.
%
%   Example
%   -------
%   % Load and view Mount Washington terrain elevation
%   [Z,R] = arcgridread('MtWashington-ft.grd');
%   mapshow(Z,R,'DisplayType','surface');
%   xlabel('x (easting in meters)'); ylabel('y (northing in meters)')
%   colormap(demcmap(Z))
%
%   % View the terrain in 3D
%   axis normal; view(3); axis equal; grid on
%   zlabel('elevation in feet')
%
%   See also MAKEREFMAT, MAPSHOW, SDTSDEMREAD.

%   Copyright 1996-2003 The MathWorks, Inc.  
%   $Revision: 1.1.10.3 $  $Date: 2003/12/13 02:54:37 $

[filename, isURL] = checkfilename(filename, {'grd'}, mfilename, 1, true);

% Open file.
[fid, message] = fopen(filename,'r');
if fid == -1
    eid = sprintf('%s:%s:internalError', getcomp, mfilename);
    msg = sprintf('%s: Internal error (failed to open file).', mfilename);
    error(eid,msg);
end

% Read the 6-line header.
[ncols, nrows, xllcorner, yllcorner, cellsize, nodata, msg] = readHeader(fid);
if ~isempty(msg)
    fclose(fid);
    eid = sprintf('%s:%s:unexpectedItemInHeader', getcomp, mfilename);
    error(eid,msg);
end

% Read the matrix of data values, putting the k-th row in the data
% file into the k-th column of matrix Z.  Close file -- nothing left to
% read after this.
[Z, count] = fscanf(fid,'%d',[ncols,nrows]);
fclose(fid);

if (isURL)
  deleteDownload(filename);
end

% Replace each no-data value with NaN.
Z(Z == nodata) = NaN;
  
% Orient the data so that rows are parallel to the x-axis and columns
% are parallel to the y-axis (for compatibility with MATLAT functions
% like SURF and MESH).
Z = Z';

% Construct the referencing matrix.
R = makerefmat(xllcorner + cellsize/2,...
               yllcorner + (nrows - 1/2) * cellsize,...
               cellsize, -cellsize);

%----------------------------------------------------------------------
function [ncols, nrows, xllcorner, yllcorner,...
                        cellsize, nodata, msg] = readHeader(fid)

itemNames = cell(1,6);
value = cell(1,6);
for k = 1:6
    line = fgetl(fid);
    [token,rem] = strtok(line);
    itemNames{k} = token;
    value{k} = str2num(rem);
end

ncols     = value{1};
nrows     = value{2};
xllcorner = value{3};
yllcorner = value{4};
cellsize  = value{5};
nodata    = value{6};

msg = checkItemNames(itemNames);

%----------------------------------------------------------------------
function msg = checkItemNames(itemNames)

msg = [];
standardItems = {...
    'ncols',...
    'nrows',...
    'xllcorner',...
    'yllcorner',...
    'cellsize',...
    'nodata_value'};

for k = 1:6
    if ~strcmp(lower(itemNames{k}),standardItems{k})
        msg = sprintf('Unexpected item name ''%s'' in file header (line %d).',...
                      itemNames{k}, k);
        return;
    end
end
