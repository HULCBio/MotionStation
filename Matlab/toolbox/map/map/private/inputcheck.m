function msg = inputcheck(varargin)
%INPUTCHECK checks for proper mapping toolbox inputs
%
% msg = INPUTCHECK('type',arg1,arg1,...) returns an error 
% message string if the arguments are inconsistent with the
% mapping toolbox datatype. The following calling forms list 
% the datatypes checked by INPUTCHECK.
%
% msg = INPUTCHECK('scalar',lat,lon)
% msg = INPUTCHECK('vector',lat,lon)
% msg = INPUTCHECK('xyvector',lat,lon)
% msg = INPUTCHECK('cellvector',latc,lonc);
% msg = INPUTCHECK('cellxyvector',latc,lonc);
% msg = INPUTCHECK('rmm',map,maplegend);
% msg = INPUTCHECK('gmm',lat,lon,map)  general matrix map

% As needed, add
% msg = INPUTCHECK('xycellvector',latc,lonc);
% msg = INPUTCHECK('geostruct',s) geographic data structure
% msg = INPUTCHECK('mstruct',mstruct) map projection structure
%

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.3.4.1 $    $Date: 2003/08/01 18:19:31 $

if nargin < 2; error('Incorrect number of input arguments'); end

type = varargin{1};
varargin(1) = [];

switch type
case 'scalar'
   msg = checkscalar(varargin{:});
case 'vector'
   msg = checkvector(varargin{:});
case 'xyvector'
   msg = checkxyvector(varargin{:});
case 'cellvector'
   msg = checkcellvector(varargin{:});
case 'cellxyvector'
   msg = checkxycellvector(varargin{:});
case 'rmm' % regular matrix map
   msg = checkrmm(varargin{:});
case 'gmm' % general matrix map
   msg = checkgmm(varargin{:});
case 'geostruct' % geographic data structure
   msg = checkgeostruct(varargin{:});
case 'mstruct' % map projection structure
   msg = checkcellmstruct(varargin{:});
otherwise
   error('Unrecognized argument type')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg = checkscalar(varargin);

if nargin ~= 2; 
   error('Incorrect number of input arguments');
elseif nargin == 2
   [lat,lon]= deal(varargin{:});
end


msg = [];

if ~isa(lat,'numeric') | ~isa(lon,'numeric') | ...
      length(lat) > 1 | length(lon) > 1
   
   msg = 'Latitude and longitude must be scalars';
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg = checkvector(varargin);

if nargin ~= 2; 
   error('Incorrect number of input arguments');
elseif nargin == 2
   [lat,lon]= deal(varargin{:});
end


msg = [];

if ~isa(lat,'numeric') | ~isa(lon,'numeric')
   
   msg = 'Latitude and longitude must be numeric vectors';
   
elseif any([min(size(lat))    min(size(lon))]    ~= 1) | ...
      any([ndims(lat) ndims(lon)] > 2)
   
   msg = 'Latitude and longitude inputs must be vectors';
   
elseif ~isequal(size(lat),size(lon))
   
   msg = 'Inconsistent dimensions on latitude and longitude input';
   
elseif ~isequal(find(isnan(lat)),find(isnan(lon)))
   
   msg = 'Inconsistent NaN locations in latitude and longitude input';
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg = checkxyvector(varargin);

if nargin ~= 2; 
   error('Incorrect number of input arguments');
elseif nargin == 2
   [lat,lon]= deal(varargin{:});
end


msg = [];

if ~isa(lat,'numeric') | ~isa(lon,'numeric')
   
   msg = 'x and y must be numeric vectors';
   
elseif any([min(size(lat))    min(size(lon))]    ~= 1) | ...
      any([ndims(lat) ndims(lon)] > 2)
   
   msg = 'x and y inputs must be vectors';
   
elseif ~isequal(size(lat),size(lon))
   
   msg = 'Inconsistent dimensions on x and y input';
   
elseif ~isequal(find(isnan(lat)),find(isnan(lon)))
   
   msg = 'Inconsistent NaN locations in x and y input';
   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg = checkcellvector(varargin);

if nargin ~= 2; 
   error('Incorrect number of input arguments');
elseif nargin == 2
   [lat,lon]= deal(varargin{:});
end


msg = [];

if ~isa(lat,'cell') | ~isa(lon,'cell')
   
   msg = 'Latitude and longitude must be cell arrays';
   return
   
elseif ~isequal(size(lat),size(lon))
   
   msg = 'Inconsistent dimensions on latitude and longitude input';
end


for i=1:length(lat)
   if ~isequal(size(lat{i}),size(lon{i}))
      msg = 'Inconsistent latitude and longitude dimensions within a cell';
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg = checkxycellvector(varargin);

if nargin ~= 2; 
   error('Incorrect number of input arguments');
elseif nargin == 2
   [lat,lon]= deal(varargin{:});
end


msg = [];

if ~isa(lat,'cell') | ~isa(lon,'cell')
   
   msg = 'X and y must be cell arrays';
   return
   
elseif ~isequal(size(lat),size(lon))
   
   msg = 'Inconsistent dimensions on x and y input';
end


for i=1:length(lat)
   if ~isequal(size(lat{i}),size(lon{i}))
      msg = 'Inconsistent x and y dimensions within a cell';
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg = checkrmm(varargin);

msg = [];

[map,maplegend] = deal(varargin{1:2});

if ndims(map) > 2
    msg = 'Input map can not have pages';
end
 
if ~isequal(sort(size(maplegend)),[1 3])
    msg = 'Input maplegend must be a 3 element vector';
end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg = checkgmm(varargin);

if nargin ~= 3; 
   error('Incorrect number of input arguments');
elseif nargin == 3
   [lat,lon,map]= deal(varargin{:});
end


msg = [];

if ~isa(lat,'numeric') | ~isa(lon,'numeric') | ~isa(map,'numeric')
   
   msg = 'Latitude and longitude  and map matrices must be numeric vectors';
   
elseif any([min(size(lat))    min(size(lon))]    < 2) | ...
      any([ndims(lat) ndims(lon)] > 2)
   
   msg = 'Latitude and longitude inputs must be two-dimensional matrices';
   
elseif ~isequal(size(lat),size(lon))
   
   msg = 'Inconsistent dimensions on latitude and longitude input';
   
elseif ~isequal(find(isnan(lat)),find(isnan(lon)))
   
   msg = 'Inconsistent NaN locations in latitude and longitude input';
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg = checkgeostruct(varargin);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function msg = checkcellmstruct(varargin);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
