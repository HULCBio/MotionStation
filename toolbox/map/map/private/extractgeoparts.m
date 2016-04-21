function parts = extractgeoparts(varargin)
%EXTRACTGEOPARTS Extract coordinate parts from a geographic data structure.
%
%   PARTS = EXTRACTGEOPARTS(X,Y) returns all the NaN separated values of X
%   and Y into the output structure array PARTS.  X and Y must be numeric 
%   arrays of equal size.  PARTS has field names 'X' and 'Y'. 
%   
%   PARTS = EXTRACTGEOPARTS(S) returns all the coordinate parts of the
%   geographic data structure S into the output structure PARTS, which is
%   also a geographic data structure.  Parts are NaN separated coordinate
%   values within an element of S. The output PARTS size may be greater
%   than the size of S.
%
%   PARTS = EXTRACTGEOPARTS(S, FIELD) returns all the parts from the
%   fieldname of S defined by the case sensitive string FIELD. 
%
%   PARTS = EXTRACTGEOPARTS(S, FIELDNAMES) returns all the parts from the
%   fieldname of S defined by the cell array FIELDNAMES.  The strings of
%   FIELDNAMES are case sensitive.
%
%   Example
%   -------
%      % Extract all the patches of the United States of the world
%      patches = worldlo('POpatch');
%      [lat, lon, id] = extractm(patches,'United States');
%      parts = extractgeoparts(patches(id));
%
%   See also EXTRACTM, SHAPEREAD, WORLDLO.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2003/12/13 02:52:32 $

% Verify inputs
checknargin(1,2,nargin,mfilename);
[S, fields] = verifyInputs(varargin{:});

% Create the shapes
parts = makeParts(S, fields);

%---------------------------------------------------------------------------
function [S, fields] = verifyInputs(varargin)

if nargin == 2 && isnumeric(varargin{1}) && isnumeric(varargin{2})
   S.X = varargin{1};
   S.Y = varargin{2};
   fields = fieldnames(S);
   return;
end

% Verify and obtain the inputs
S = varargin{1};
if ~isstruct(S)
    eid = sprintf('%s:%s:invalidGeoStruct', getcomp, mfilename);
    error(eid, '%s', 'Input argument ''S'' must be a struct.');
end

if nargin == 2
   fields = varargin{2};
   if ~iscell(fields)
      if ~ischar(fields) 
         eid = sprintf('%s:%s:invalidInput', getcomp, mfilename);
         error(eid, '%s', 'FIELDNAMES must be a string or a cell array of strings.');
      else
         % char, set fields as a cell
         fields = {varargin{2}};
      end
   else
      % cell, copy to fields
      fields = varargin{2};
   end
   for i=1:length(fields)
       if ~isfield(S,fields{i})
          eid = sprintf('%s:%s:invalidFieldname', getcomp, mfilename);
          error(eid, 'Fieldname ''%s'' does not exist.', fields{i});
       end
   end
else
   % fieldname is not an input, 
   %  return all the fieldnames
   fields = fieldnames(S);
end

%---------------------------------------------------------------------------
function parts = makeParts(gstruct, fields)

% Define allowed x and y names
%  and get the name the structure defined
xName = {'X','Lon','long'};
yName = {'Y','Lat','lat'};
xName = getCoordName(gstruct, xName);
yName = getCoordName(gstruct, yName);
if isequal(xName, 'X')
   mapType = true;
else
   mapType = false;
end
if isempty(xName) || isempty(yName)
   eid = sprintf('%s:%s:invalidGeoStruct', getcomp, mfilename);
   error(eid, '%s', 'Input argument ''S'' must be a geographic data struct.');
end

% Set the initial parts structure to empty
%  and obtain the attribute data
parts = [];
attribData  = geoattribstruct(gstruct);
attribNames = geoattribnames(gstruct);

% Loop through the structure, 
%  create a parts struct out of each member
for j = 1:length(gstruct);
   S = getNaNSepValues(gstruct(j).(xName), gstruct(j).(yName));
   sz = size(gstruct(j).(xName));
   if isfield(gstruct(j),'Geometry')
      tmpS.Geometry = gstruct(j).Geometry;
   end
   for i = 1:length(S)
     % add NaN separator
     if sz(1) == 1
        if mapType
          tmpS.(xName) = [S(i).x NaN];
          tmpS.(yName) = [S(i).y NaN];
        else
          tmpS.(yName) = [S(i).y NaN];
          tmpS.(xName) = [S(i).x NaN];
        end
     else
        if mapType
          tmpS.(xName) = [S(i).x; NaN];
          tmpS.(yName) = [S(i).y; NaN];
        else
          tmpS.(yName) = [S(i).y; NaN];
          tmpS.(xName) = [S(i).x; NaN];
        end
     end
     % Recompute the bounding box for each part if present
     %  and requested
     if isfield(gstruct, 'BoundingBox')
        if ~isempty(strmatch('BoundingBox', fields, 'exact'))
           tmpS.BoundingBox = calcBBox(gstruct(j).(xName), ...
                                       gstruct(j).(yName));
        end
     end
     if ~isempty(attribData)
        for k = 1:length(attribNames)
          tmpS.(attribNames{k}) = attribData(j).(attribNames{k});
        end
     end
     if isempty(parts)
        parts = tmpS;
     else
        parts(end+1) = tmpS;
     end
   end
end


% Remove unwanted fieldnames
if ~isempty(parts)
  fnames = fieldnames(parts);
  for i=1:length(fnames)
     if isempty(strmatch(fnames{i},fields,'exact'))
        parts = rmfield(parts,fnames{i});
     end
  end

  % Reshape to input shape
  sz = size(gstruct);
  if sz(1) ~= 1
     szParts = size(parts);
     parts = reshape(parts,[szParts(2) 1]);
  end
end


%---------------------------------------------------------------------------
function name = getCoordName(S, names)
name = [];
for i=1:length(names)
   if isfield(S, names{i})
      name = names{i};
      break
   end
end

%---------------------------------------------------------------------------
function S = getNaNSepValues(x, y)
indx = find( isnan(x) | isnan(y) );
if isempty(indx)
   S.x = x;
   S.y = y;
   return
end
startloc = 1;
count = 1;
for i=1:length(indx)
   endloc = indx(i);
   [S(count).x S(count).y] = removeDuplicates(x(startloc:endloc), ...
                                              y(startloc:endloc));
   startloc = endloc;
   if ~isempty(S(count).x) && ~isempty(S(count).y) 
     count = count + 1;
   else
     S(count) = [];
   end
end
[S(count).x S(count).y] = removeDuplicates(x(startloc:end), y(startloc:end));
if isempty(S(count).x) || isempty(S(count).y) 
   S(count) = [];
end

%---------------------------------------------------------------------------
function [x, y] = removeDuplicates(x, y)
dupindx = find(diff(x) == 0 & diff(y) == 0 );
x(dupindx) = [];
y(dupindx) = [];
[x,y] = fixgeocoords(x,y,NaN,[]);

%---------------------------------------------------------------------------
function BoundingBox = calcBBox(X, Y)
BoundingBox = [ min(X(:)'), ...
                min(Y(:)'); ...
                max(X(:)'), ... 
                max(Y(:)')];
  

