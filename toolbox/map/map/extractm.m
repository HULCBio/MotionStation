function [lat,lon,indx] = extractm(mstruct,objects,method)
%EXTRACTM  Extracts vector data from geographic data structures
%
%  [lat,lon]=EXTRACTM(mstruct,'object') will extract vector data from
%  entries in the Mapping Toolbox Geographic Data structure whose
%  tag begins the 'object' string.  The output vectors use NaNs to
%  separate the individual entries in the map structure.  Matches of
%  the tag string must be vector data (lines and patches) to be
%  included in the output. The search is not case-sensitive.
%
%  [lat,lon]=EXTRACTM(mstruct,objects), where objects is a character
%  array or a cell array or strings, allows more than one object to
%  be the basis for the search. Character array objects will have 
%  trailing spaces stripped before matching.
%
%  [lat,lon]=EXTRACTM(mstruct,objects,'searchmethod') controls the method 
%  used to match the objects input.  Search method 'strmatch' searches for 
%  matches at the beginning of the tag, similar to the MATLAB STRMATCH 
%  function.  Search method 'findstr' searches within the tag, similar to 
%  the MATLAB FINDSTR function.  Search method 'exact' requires an exact 
%  match. If omitted, search method 'strmatch' is assumed. The search is 
%  case-sensitive.
%
%  [lat,lon]=EXTRACTM(mstruct) extracts all vector data from the
%  input map structure.
%
%  [lat,lon,indx]=EXTRACTM(...) also returns the vector indx identifying
%  the entries in the structure which meet the selection criteria.
%
%  mat = EXTRACTM(...) returns the vector data in a single
%  matrix, where mat = [lat lon].
%
%
%  See also MLAYERS, DISPLAYM

% Written by:  E. Byrns, E. Brown, W. Stumpf
% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/12/13 02:50:16 $




if nargin == 0;         
  error('Incorrect number of arguments')
elseif nargin == 1;  
  objects = [];
end


%  Determine the objects to extract

if isempty(objects)
  indx = 1:length(mstruct);
else
  indx = [];
  if iscell(objects)
    for i=1:length(objects)
      if nargin ==3
        thisindx = findstrmat(str2mat(mstruct(:).tag),objects{i},method);
      else
        thisindx = strmatch(lower(objects{i}), lower(strvcat(mstruct(:).tag)));
      end
      indx = [indx(:); thisindx(:)]; 
    end % for
  else
    for i=1:size(objects,1)
      if nargin ==3
        thisindx = findstrmat(str2mat(mstruct(:).tag),...
            deblank(objects(i,:)),method);
      else
        thisindx = strmatch( lower(deblank(objects(i,:))),...
            lower(strvcat(mstruct(:).tag)));
      end      
      indx = [indx(:); thisindx(:)]; 
    end % for i
  end % if iscell(objects)
  if isempty(indx);   error('Object string not found');  end
end

indx = unique(indx);

lat0 = [];  lon0 =[];
warned = 0;

%  Extract the map vector data

for i = 1:length(indx)
  switch mstruct(indx(i)).type
    case {'line','patch'}
      lat0 = [lat0; mstruct(indx(i)).lat(:);  NaN];
      lon0 = [lon0; mstruct(indx(i)).long(:); NaN];
    otherwise
      if warned ~=1; warning('Non-vector map data ignored'); warned = 1; end
  end
end
if ~isempty(indx) & length(lat0) > 0
  lat0(end)=[];
  lon0(end)=[];
end

%  Remove multiple sequential NaNs 

[lat0,lon0] = singleNaN(lat0,lon0);

%  Set output arguments

if nargout < 2;   
  lat = [lat0 lon0];
else;          
  lat = lat0;   
  lon = lon0;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function carray = uppercell(carray)
%UPPERCELL converts a cellarray of strings to uppercase

for i=1:length(carray);carray{i} = upper(carray{i});end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function carray = lowercell(carray)
%LOWERCELL converts a cellarray of strings to lowercase

for i=1:length(carray);carray{i} = lower(carray{i});end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lat,lon] = singleNaN(lat,lon)
% SINGLENAN removes duplicate nans in lat-long vectors

if ~isempty(lat)
  nanloc = isnan(lat);  [r,c] = size(nanloc);
  nanloc = find(nanloc(1:r-1,:) & nanloc(2:r,:));
  lat(nanloc) = [];  lon(nanloc) = [];
end

%*********************************************************************
%*********************************************************************
%*********************************************************************

function indx = findstrmat(strmat,searchstr,method)

% find matches in vector

switch method
  case 'findstr'
    strmat(:,end+1) = 13; % add a lineending character to prevent matches across rows
    % make string matrix a vector
    sz = size(strmat);
    strmat = strmat';
    strvec = strmat(:)';
    vecindx = findstr(searchstr,strvec);
    % vector indices to row indices
    indx = unique(ceil(vecindx/sz(2)));
  case 'strmatch'
    indx = strmatch(searchstr,strmat);
  case 'exact'
    indx = strmatch(searchstr,strmat,'exact');
  otherwise
    error('Recognized methods are ''exact'', ''strmatch'' and ''findstr''')
end

