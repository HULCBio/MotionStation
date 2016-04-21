function h = GriddedComponent(varargin)
%GRIDDEDCOMPONENT Constructor for a Grid component.
%
%   GRIDDEDCOMPONENT(R,Z) constructs an object to store gridded
%   data from the referencing matrix R and the 2D array of data 
%   values Z.  
%
%   GRIDDEDCOMPONENT(X,Y,Z)constructs an object to store the 
%   X and Y geolocation vectors and the 2D aray of data values Z.
%
%   For each of the above syntax, a colormap can be optionally
%   provided:
%   
%     GRIDDEDCOMPONENT(R,I,MAP);
%
%     GRIDDEDCOMPONENT(X,Y,Z,MAP);
%

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:10 $

h = MapModel.GriddedComponent;

[argType,dispType,eMsg] = localParseArgs(varargin{:});

if (argType < 0)
  [errStruct.message,errStruct.identifier] = deal(eMsg(2:-1:1));
  error(errStruct);
end

switch argType
 case {1,2}
  h.ReferenceMatrix = varargin{1};
  h.Xdata = [];
  h.Ydata = [];
  h.GriddedData = varargin{2};
  sz = size(h.GriddedData);
  h.BoundingBox = MapModel.BoundingBox(mapbbox(h.ReferenceMatrix,sz));
 case {3,4}
  h.ReferenceMatrix = [];
  h.Xdata = varargin{1};
  h.Ydata = varargin{2};
  h.GriddedData = varargin{3};
  width = max(h.Xdata(:))-min(h.Xdata(:));
  height = max(h.Ydata(:))-min(h.Ydata(:));
  lleftX = min(h.Xdata(:));
  lleftY = min(h.Ydata(:));
  h.BoundingBox = MapModel.BoundingBox([lleftX,lleftY,width,height]);
end

tst = [2,4];
chk = (argType == tst);
if (any(chk))
  h.Colormap = varargin{tst(chk)};
else
  h.Colormap = demcmap(h.GriddedData);
end
h.DisplayType = dispType;


function [inArgType,dispType,errMsg] = localParseArgs(varargin)
% The arg types are:
%  1   (R,Z)
%  2   (R,Z,MAP)
%  3   (X,Y,Z)
%  4   (X,Y,Z,MAP)
%      (R,Z,dispType)
%      (R,Z,MAP,dispType)
%      (X,Y,Z,dispType)
%      (X,Y,Z,MAP,dispType)

errMsg = {''};

if nargin < 2
  inArgType = -1;
  errMsg = {'minrhs:','Not enough input arguments,'};
  return
end

if ischar(varargin{end})
  numArgIn = nargin - 1;
  dispType = varargin{end};
else
  numArgIn = nargin;
  dispType = 'surf';
end

switch numArgIn
 case 2,
  if (isRefMatrix(varargin{1}))
    inArgType = 1;
  else
    inArgType = -1;
    errMsg = {'invalidArgs:','Invalid input arguments'};
  end
 case 3,
  % varargin{3} could be MAP or Z
  sz = size(varargin{3});
  if (sz(2) == 3 && isRefMatrix(varargin{1}))
    % Now it definitely should be the (R,Z,MAP) syntax
    inArgType = 2;
  elseif (all(sz > 1) && ~isRefMatrix(varargin{1})) 
    % Z is an M-by-N matrix
    inArgType = 3;
  else
    inArgType = -1;
    errMsg = {'invalidArgs:','Invalid input arguments.'};
  end
 case 4,
  sz = size(varargin{4});
  if (sz(2) == 3 && all(size(varargin{3}) > 1))
    inArgType = 4;
  else
    inArgType = -1;
    errMsg = {'invalidArgtype:','Invalid input arguments.'};
  end
 otherwise,
  inArgType = -1;
  errMsg = {'maxrhs:','Too many input arguments.'};
end

function out = isRefMatrix(possibleRefMat)
sz = size(possibleRefMat);
if (length(sz) == 2 && all(sz == [3,2]))
  out = true;
else
  out = false;
end