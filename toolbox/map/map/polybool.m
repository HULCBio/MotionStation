function [x3,y3] = polybool(varargin)
%POLYBOOL  Polygon boolean operations.
%
%   [lat,lon] = POLYBOOL(FLAG,x1,y1,x2,y2) performs the polygon boolean
%   operation identified by FLAG. Valid flags strings are one of the following 
%   alternatives: ('intersection','and','&'), ('union','or','|','+','plus'), 
%   ('exclusiveor','xor') and ('subtraction','minus','-'). The polygon inputs
%   are NaN-delimited vectors, or cell arrays containing individual polygons in 
%   each element with the outer face separated from the subsequent inner faces 
%   by NaNs. The result is output as NaN-delimited vectors. 
%
%   [lat,lon] = POLYBOOL(FLAG,x1,y1,x2,y2,OUTPUTFORMAT) controls the 
%   format of the resulting polygons. If outputformat is 'vector', the result is
%   returned as vectors with NaNs separating the faces. No distinction is 
%   made between outer and inner faces of polygons. If outputformat is 
%   'cutvector', inner faces are connected to the enclosing polygon face by 
%   inserting a cut. If outputformat is 'cell', the result is returned as
%   cell arrays containing individual polygons in each element, with 
%   the outer face separated from the subsequent inner faces by NaNs. If 
%   omitted, 'vector' is assumed.
%
%   Use FLATEARTHPOLY to prepare polygons that encompass a pole for POLYBOOL
%
%   See also BUFFERM, POLYSPLIT, POLYJOIN, FLATEARTHPOLY

%  Written by:  W. Stumpf, A. Kim
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.4.4.1 $    $Date: 2003/08/01 18:17:34 $

% extract string input arguments
if nargin == 5;
   outputformat='vector';
elseif nargin == 6
   outputformat=varargin{6};
elseif nargin < 5 || nargin > 6
   error('Incorrect number of input arguments');
end

flag = varargin{1};

if ~ischar(outputformat); error('Output format flag must be a string'); end
if ~ischar(flag); error('Boolean operation flag must be a string'); end

flag=lower(flag);
outputformat = lower(outputformat);

% Check for valid output format before time consuming logical operation

switch outputformat
case {'vector','cutvector','cell'}
otherwise
   error('Unrecognized ouput format flag')
end


% convert NaN-clipped vectors to cell arrays of faces 
for i=2:2:4
   if ~iscell(varargin{i})
      msg = inputcheck('xyvector',varargin{i},varargin{i+1}); if ~isempty(msg); error(msg); end
      [varargin{i},varargin{i+1}]=polysplit(varargin{i},varargin{i+1});
   else
      
   end
end

% extract polygon data

[x1,y1,x2,y2]=deal(varargin{2:5});

msg = inputcheck('cellxyvector',x1,y1); if ~isempty(msg); error(msg); end
msg = inputcheck('cellxyvector',x2,y2); if ~isempty(msg); error(msg); end

% carry out boolean operations

switch flag
case {'intersection','and','&'}
   [x3,y3]=cpint(x1,y1,x2,y2);
case {'union','or','|','+','plus'}
   [x3,y3]=cpuni(x1,y1,x2,y2);
case {'exclusiveor','xor'}
   [x3,y3]=cpxor(x1,y1,x2,y2);
case {'subtraction','minus','-'}
   [x3,y3]=cpsub(x1,y1,x2,y2);
otherwise
   error('Unrecognized boolean operation')
end

% Convert result to requested output format

switch outputformat
case 'vector'
   [x3,y3]=polyjoin(x3,y3);
case 'cutvector'
   [x3,y3]=polycut(x3,y3);
case 'cell'
% no change required   

end


