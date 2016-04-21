function B = bwtraceboundary(varargin)
%BWTRACEBOUNDARY Trace object in a binary image.
%   B = BWTRACEBOUNDARY(BW,P,FSTEP) traces the outline of an object in a 
%   binary image BW, in which nonzero pixels belong to an object and 
%   0-pixels constitute the background. P is a two-element vector specifying
%   the row and column coordinates of the initial point on the object 
%   boundary. FSTEP is a string specifying the initial search direction 
%   for the next object pixel connected to P. FSTEP can be any of the 
%   following strings: 'N','NE','E','SE','S','SW','W','NW', where N stands
%   for north, NE stands for northeast, etc. B is a Q-by-2 matrix, where 
%   Q is the number of boundary pixels for the region. B holds the row and
%   column coordinates of the boundary pixels.
%
%   B = BWTRACEBOUNDARY(BW,P,FSTEP,CONN) specifies the connectivity to use 
%   when tracing the boundary. CONN may be either 8 or 4. The default value 
%   for CONN is 8. For CONN equal to 4, FSTEP is limited to 'N','E','S' and 
%   'W'.
%
%   B = BWTRACEBOUNDARY(...,N,DIR) provides the option to specify the maximum
%   number of boundary pixels, N, to extract and direction, DIR, in which to 
%   trace the boundary.  DIR can be either 'clockwise' or 'counterclockwise'.
%   By default, or when N is set to Inf, the algorithm extracts all of the 
%   pixels from the boundary and, if DIR is not specified, it searches in 
%   the clockwise direction.
%
%   Class Support
%   -------------
%   BW can be logical or numeric and it must be real, 2-D, and nonsparse.
%   B, P, CONN and N are double. DIR and FSTEP are strings.
%
%   Example
%   -------
%   Read in and display binary image blobs.png. Starting from the top left,
%   project a 'beam' across the image searching for the first nonzero 
%   pixel. Use the location of that pixel as the starting point for the
%   boundary tracing. Including the starting point, extract 50 pixels of
%   the boundary and overlay them on the image.  Mark the starting points 
%   with a green "x". Mark beams which missed their targets with a red "x". 
%
%      BW = imread('blobs.png');
%      imshow(BW,[]);
%      s=size(BW);
%      for row = 2:55:s(1)
%        for col=1:s(2)
%          if BW(row,col), 
%            break;
%          end
%        end
%
%        contour = bwtraceboundary(BW, [row, col], 'W', 8, 50,...
%                                  'counterclockwise');
%        if(~isempty(contour))
%          hold on; plot(contour(:,2),contour(:,1),'g','LineWidth',2);
%          hold on; plot(col, row,'gx','LineWidth',2);
%        else
%          hold on; plot(col, row,'rx','LineWidth',2);
%        end
%      end
%
%   See also BWBOUNDARIES.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/05/03 17:50:14 $

[BW, P, FSTEP, CONN, N, DIR] = parseInputs(varargin{:});

B = bwtraceboundarymex(BW,P,CONN,FSTEP,N,DIR);

%-----------------------------------------------------------------------------

function [BW, P, FSTEP, CONN, N, DIR] = parseInputs(varargin)

checknargin(3,6,nargin,mfilename);

% BW
BW = varargin{1};
checkinput(BW, {'numeric', 'logical'}, ...
           {'real', '2d', 'nonsparse','nonempty'}, ...
           mfilename, 'BW', 1);
if ~islogical(BW)
  BW = BW ~= 0;
end

% P
P = varargin{2};
checkinput(P, {'double'}, {'real', 'vector', 'nonsparse','integer',...
                    'positive'}, mfilename, 'P', 2);
if (any(size(P) ~= [1,2]))
  eid = sprintf('Images:%s:invalidStartingPoint', mfilename);
  msg   = 'Input parameter P must be a two element vector.';
  error(eid, msg);
end

% CONN
CONN = 8;
if nargin > 3
  CONN = varargin{4};
  checkinput(CONN, {'double'}, {}, mfilename, 'CONN', 4);
  if (CONN~=4 & CONN~=8)
    eid = sprintf('Images:%s:badScalarConn', mfilename);
    msg   = 'A scalar connectivity specifier CONN must either be 4 or 8';
    error(eid, msg);
  end
end

% FSTEP
FSTEP = varargin{3};
if CONN == 8
  validStrings = {'n','ne','e','se','s','sw','w','nw'};
else
  validStrings = {'n','e','s','w'};
end
string = checkstrs(FSTEP, validStrings, mfilename, 'FSTEP', 3);
for i=1:CONN
  if strmatch(string, validStrings{i})
    FSTEP = i-1;
    break;
  end
end

if ~isa(FSTEP,'double') || any(size(FSTEP) ~=1) || any(floor(FSTEP) ~= FSTEP) ...
      || any(~isfinite(FSTEP))
  % should never be here
  displayInternalError('FSTEP');
end

DIR = true;
N = -1; %tell mex function to trace the entire boundary by default

% N
if nargin > 4
  N = varargin{5};
  checkinput(N, {'double'}, {'real','nonnan','nonnegative','nonzero'}, ...
             mfilename, 'N', 5);
  if ~isinf(N)
    checkinput(N, {'double'}, {'integer','scalar'}, ...
               mfilename, 'N', 5);
    if N<2
      eid = sprintf('Images:%s:invalidMaxNumPixels', mfilename);
      msg = 'Maximum number of pixels to collect, N, must be greater than 1.';
      error(eid, msg);   
    end
  else
    N = -1;
  end
  
  % DIR
  if nargin > 5
    DIR = varargin{6};
    validStrings = {'clockwise', 'counterclockwise'};    
    string = checkstrs(DIR, validStrings, mfilename, 'DIR', 6);
    switch string
     case 'clockwise'
      DIR = true;
     case 'counterclockwise'
      DIR = false;
     otherwise
      error('Images:bwtraceboundary:unexpectedError', '%s', ...
            'Unexpected logic error.')
    end
    
    if ~islogical(DIR) || any(size(DIR) ~=1)
      displayInternalError('DIR');
    end
  end
end


%-------------------------------
function displayInternalError(string)

eid = sprintf('Images:%s:internalError',mfilename);
msg = sprintf('Internal error: %s is not valid.',upper(string));
error(eid,'%s',msg);
