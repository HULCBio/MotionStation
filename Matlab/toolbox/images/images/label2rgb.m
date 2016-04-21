function RGB = label2rgb(varargin) 
%LABEL2RGB converts label matrix to RGB image.
%   RGB = LABEL2RGB(L) converts a label matrix L, such as returned by
%   BWLABEL or WATERSHED, into a color RGB image for the purpose of
%   visualizing the labeled regions.
%
%   RGB = LABEL2RGB(L, MAP) defines the colormap to be used in the RGB
%   image.  MAP can either be an n x 3 colormap matrix, a string containing
%   the name of a colormap function (such as 'jet' or 'gray'), or a function
%   handle of a colormap function (such as @jet or @gray). LABEL2RGB
%   evaluates MAP so that there is a different color for each region in L.
%   If MAP is not specified, 'jet' is used as the default.
%
%   RGB = LABEL2RGB(L, MAP, ZEROCOLOR) defines the RGB color of the elements
%   labeled 0 in the input label matrix L.  ZEROCOLOR can either be an RGB
%   triple, or one of the following: 'y' (yellow), 'm', (magenta), 'c'
%   (cyan), 'r'(red), 'g' (green), 'b' (blue), 'w' (white), or 'k'
%   (black). If ZEROCOLOR is not specified, [1 1 1] is used as the default.
%   
%   RGB = LABEL2RGB(L, MAP, ZEROCOLOR, ORDER), controls how colormap colors
%   are assigned to regions in the label matrix.  If ORDER is 'noshuffle'
%   (the default), then colormap colors are assigned to the label matrix
%   regions in numerical order.  If ORDER is 'shuffle', then colormap colors
%   are pseudorandomly shuffled.
%   
%   Class Support
%   -------------
%
%   The input label matrix L can have any nonsparse numeric class. It must
%   contain finite nonnegative integers.  The output of LABEL2RGB is of
%   class uint8.
%
%   See also BWLABEL, BWLABELN, ISMEMBER, WATERSHED, COLORMAP.
%
%   Example
%   -------
%   I = imread('rice.png');
%   imview(I)
%   BW = im2bw(I, graythresh(I));
%   L = bwlabel(BW);
%   RGB = label2rgb(L);
%   RGB2 = label2rgb(L, 'spring', 'c', 'shuffle');
%   imview(RGB), imview(RGB2)

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.5.4.5 $  $Date: 2003/08/01 18:09:21 $

[label,map,zerocolor,order,fcnflag] = parse_inputs(varargin{:});

% Determine the number of regions in the label matrix.
numregion = double(max(label(:)));

% If MAP is a function, evaluate it.  Make sure that the evaluated function
% returns a valid colormap.
if  fcnflag == 1
    cmap = feval(map, numregion);
    if ~isreal(cmap) || any(cmap(:) > 1) || any(cmap(:) < 0) || ...
            ~isequal(size(cmap,2),3) || size(cmap,1) < 1
        eid = sprintf('Images:%s:functionReturnsInvalidColormap',mfilename);
        msg = 'function handle MAP must return a n x 3 colormap array';
        error(eid,'%s',msg);
    end
else
    cmap = map;
end

% If ORDER is set to 'shuffle', save original state.  The SHUFFLE keyword
% uses the same state every time it is called. After shuffling is completed,
% go back to original state.
if isequal(order,'shuffle')
    S = rand('state');
    rand('state', 0);
    index = randperm(numregion);
    cmap = cmap(index,:,:);
    rand('state', S);
end

% Issue a warning if the zerocolor (boundary color) matches the color of one
% of the regions. 
for i=1:numregion
  if isequal(zerocolor,cmap(i,:))
    wid= sprintf('Images:%s:zerocolorSameAsRegionColor',mfilename);
    msg= sprintf('Region number %d has the same color as the ZEROCOLOR.',i);
    warning(wid,'%s',msg);
  end
end
cmap = [zerocolor;cmap];

% if label is of type double, need to pass 'label + 1' into IND2RGB.
% IND2RGB does not like double arrays containing zero values.
if isa(label, 'double')
    RGB = im2uint8(ind2rgb(label + 1, cmap));
else
    RGB = im2uint8(ind2rgb(label, cmap));
end
 
%  Function: parse_inputs
%  ----------------------
function [L, Map, Zerocolor, Order, Fcnflag] = parse_inputs(varargin) 
% L         label matrix: matrix containing non-negative values.  
% Map       colormap: name of standard colormap, user-defined map, function
%           handle.
% Zerocolor RGB triple or Colorspec
% Order     keyword if specified: 'shuffle' or 'noshuffle'
% Fcnflag   flag to indicating that Map is a function

valid_order = {'shuffle', 'noshuffle'};
checknargin(1,4,nargin,mfilename);

% set defaults
L = varargin{1};
Map = 'jet';    
Zerocolor = [1 1 1]; 
Order = 'noshuffle';
Fcnflag = 0;

% parse inputs
if nargin > 1
    Map = varargin{2};
end
if nargin > 2
    Zerocolor = varargin{3};
end
if nargin > 3
    Order = varargin{4};
end

% error checking for L
checkinput(L,'numeric logical','real 2d nonsparse finite nonnegative integer', ...
           mfilename,'L',1);

% error checking for Map
[fcn, fcnchk_msg] = fcnchk(Map);
if isempty(fcnchk_msg)
    Map = fcn;
    Fcnflag = 1;
else
    if isnumeric(Map)
        if ~isreal(Map) || any(Map(:) > 1) || any(Map(:) < 0) || ...
                    ~isequal(size(Map,2), 3) || size(Map,1) < 1
          eid = sprintf('Images:%s:invalidColormap',mfilename);
          msg = 'Invalid entry for MAP.';
          error(eid,'%s',msg);
        end
    else
        eid = sprintf('Images:%s:invalidFunctionforMAP',mfilename);
        error(eid,'%s',fcnchk_msg);
    end
end    
    
% error checking for Zerocolor
if ~ischar(Zerocolor)
    % check if Zerocolor is a RGB triple
    if ~isreal(Zerocolor) || ~isequal(size(Zerocolor),[1 3]) || ...
                any(Zerocolor> 1) || any(Zerocolor < 0)
      eid = sprintf('Images:%s:invalidZerocolor',mfilename);
      msg = 'Invalid RGB triple entry for ZEROCOLOR.';
      error(eid,'%s',msg);
    end
else    
    [cspec, msg] = cspecchk(Zerocolor);
    if ~isempty(msg)
        eid = sprintf('Images:%s:notInColorspec',mfilename); 
        error(eid,'%s',msg);
    else
        Zerocolor = cspec;
    end
end

% error checking for Order
idx = strmatch(lower(Order), valid_order);
eid = sprintf('Images:%s:invalidEntryForOrder',mfilename);
if isempty(idx)
    msg = 'Valid entries for ORDER are ''shuffle'' or ''noshuffle''.';
    error(eid,'%s',msg);
elseif length(idx) > 1
    msg = sprintf('Ambiguous string for ORDER: %s.', Order);
    error(eid,'%s',msg);
else
    Order = valid_order{idx};
end





