function [I2,locations] = imfill(varargin)
%IMFILL Fill image regions.
%   BW2 = IMFILL(BW1,LOCATIONS) performs a flood-fill operation on
%   background pixels of the input binary image BW1, starting from the
%   points specified in LOCATIONS.  LOCATIONS can be a P-by-1 vector, in
%   which case it contains the linear indices of the starting locations.
%   LOCATIONS can also be a P-by-NDIMS(IM1) matrix, in which case each row
%   contains the array indices of one of the starting locations.
%
%   BW2 = IMFILL(BW1,'holes') fills holes in the input image.  A hole is
%   a set of background pixels that cannot be reached by filling in the
%   background from the edge of the image.
%
%   I2 = IMFILL(I1) fills holes in an intensity image, I1.  In this
%   case a hole is an area of dark pixels surrounded by lighter pixels.
%
%   Interactive use
%   ---------------
%   BW2 = IMFILL(BW1) displays BW1 on the screen and lets you select the
%   starting locations using the mouse.  Use normal button clicks to add
%   points. Press <BACKSPACE> or <DELETE> to remove the previously selected
%   point.  A shift-click, right-click, or double-click selects a final
%   point and then starts the fill; pressing <RETURN> finishes the selection
%   without adding a point.  Interactive use is supported only for 2-D images.
%
%   The syntax [BW2,LOCATIONS] = IMFILL(BW1) can be used to get the starting
%   points selected using the mouse.  The output LOCATIONS is always in the
%   form of a vector of linear indices into the input image.
%
%   Specifying connectivity
%   -----------------------
%   By default, IMFILL uses 4-connected background neighbors for 2-D
%   inputs and 6-connected background neighbors for 3-D inputs.  For
%   higher dimensions the default background connectivity is
%   CONNDEF(NUM_DIMS,'minimal').  You can override the default
%   connectivity with these syntaxes:
%
%       BW2 = IMFILL(BW1,LOCATIONS,CONN)
%       BW2 = IMFILL(BW1,CONN,'holes')
%       I2  = IMFILL(I1,CONN)
%
%   To override the default connectivity and interactively specify the
%   starting locations, use this syntax:
%
%       BW2 = IMFILL(BW1,0,CONN)
%
%   CONN may have the following scalar values:
%
%       4     two-dimensional four-connected neighborhood
%       8     two-dimensional eight-connected neighborhood
%       6     three-dimensional six-connected neighborhood
%       18    three-dimensional 18-connected neighborhood
%       26    three-dimensional 26-connected neighborhood
%
%   Connectivity may be defined in a more general way for any dimension by
%   using for CONN a 3-by-3-by- ... -by-3 matrix of 0s and 1s.  The 1-valued
%   elements define neighborhood locations relative to the center element of
%   CONN.  CONN must be symmetric about its center element.
%
%   Class Support
%   -------------
%   The input image can be numeric or logical, and it must be real and
%   nonsparse.  It can have any dimension.  The output image has the
%   same class as the input image.
%
%   Examples
%   --------
%   Fill in the background of a binary image from a specified starting
%   location:
%
%       BW1 = logical([1 0 0 0 0 0 0 0
%                      1 1 1 1 1 0 0 0
%                      1 0 0 0 1 0 1 0
%                      1 0 0 0 1 1 1 0
%                      1 1 1 1 0 1 1 1
%                      1 0 0 1 1 0 1 0
%                      1 0 0 0 1 0 1 0
%                      1 0 0 0 1 1 1 0]);
%       BW2 = imfill(BW1,[3 3],8)
%
%   Fill in the holes of a binary image:
%
%       BW4 = im2bw(imread('coins.png'));
%       BW5 = imfill(BW4,'holes');
%       imview(BW4), imview(BW5)
%
%   Fill in the holes of an intensity image:
%
%       I = imread('tire.tif');
%       I2 = imfill(I,'holes');
%       imview(I), imview(I2)
%
%   See also BWSELECT, IMRECONSTRUCT, ROIFILL.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.10.4.5 $  $Date: 2003/08/23 05:52:30 $
    
% Grandfathered syntaxes:
% IMFILL(I1,'holes') - no longer necessary to use 'holes'
% IMFILL(I1,CONN,'holes') - no longer necessary to use 'holes'

% Testing notes
% =============
% I            - real, full, nonsparse, numeric array, any dimension
%              - Infs OK
%              - NaNs not allowed
%
% CONN         - valid connectivity specifier
%
% LOCATIONS    - the value 0 is used as a flag to indicate interactive
%                selection
%              - can be either a P-by-1 double vector containing
%                valid linear indices into the input image, or a 
%                P-by-ndims(I) array.  In the second case, each row
%                of LOCATIONS must contain a set of valid array indices
%                into the input image.
%              - can be empty.
%
% 'holes'      - match is case-insensitive; partial match allowed.
%
% If 'holes' argument is not provided, then the input image must be
% binary.

[I,locations,conn,do_fillholes] = parse_inputs(varargin{:});

if do_fillholes
    if islogical(I)
        mask = uint8(I);
    else
        mask = I;
    end
    mask = padarray(mask, ones(1,ndims(mask)), -Inf, 'both');

    marker = mask;
    idx = cell(1,ndims(I));
    for k = 1:ndims(I)
        idx{k} = 2:(size(marker,k) - 1);
    end
    marker(idx{:}) = Inf;

    mask = imcomplement(mask);
    marker = imcomplement(marker);
    I2 = imreconstruct(marker, mask, conn);
    I2 = imcomplement(I2);
    I2 = I2(idx{:});

    if islogical(I)
        I2 = I2 ~= 0;
    end

else    
    mask = imcomplement(I);
    marker = mask;
    marker(:) = 0;
    marker(locations) = mask(locations);
    marker = imreconstruct(marker, mask, conn);
    I2 = I | marker;
end

%%%
%%% Subfunction ParseInputs
%%%
function [IM,locations,conn,do_fillholes] = parse_inputs(varargin)
    
checknargin(1,3,nargin,mfilename);

IM = varargin{1};
checkinput(IM, {'numeric' 'logical'}, {'nonsparse' 'real'}, ...
           mfilename, 'I1 or BW1', 1);

do_interactive = false;
do_fillholes = false;

conn = conndef(ndims(IM),'minimal');
do_conn_check = false;

locations = [];
do_location_check = false;

switch nargin
  case 1
    if islogical(IM)
        % IMFILL(BW1)
        do_interactive = true;
    else
        % IMFILL(I1)
        do_fillholes = true;
    end
    
  case 2
    if islogical(IM)
        if ischar(varargin{2})
            % IMFILL(BW1, 'holes')
            checkstrs(varargin{2}, {'holes'}, mfilename, 'OPTION', 2);
            do_fillholes = true;
            
        else
            % IMFILL(BW1, LOCATIONS)
            locations = varargin{2};
            do_location_check = true;
        end
        
    else
        if ischar(varargin{2})
            % IMFILL(I1, 'holes')
            checkstrs(varargin{2}, {'holes'}, mfilename, 'OPTION', 2);
            do_fillholes = true;
            
        else
            % IMFILL(I1, CONN)
            conn = varargin{2};
            do_conn_check = true;
            conn_position = 2;
        end
        
    end
    
  case 3
    if islogical(IM)
        if ischar(varargin{3})
            % IMFILL(BW1,CONN,'holes')
            checkstrs(varargin{3}, {'holes'}, mfilename, 'OPTION', 3);
            do_fillholes = true;
            conn = varargin{2};
            do_conn_check = true;
            conn_position = 2;
            
        else
            if isequal(varargin{2}, 0)
                % IMFILL(BW1,0,CONN)
                do_interactive = true;
                conn = varargin{3};
                do_conn_check = true;
                conn_position = 2;
                
            else
                % IMFILL(BW1,LOCATIONS,CONN)
                locations = varargin{2};
                do_location_check = true;
                conn = varargin{3};
                do_conn_check = true;
                conn_position = 3;
            end
            
        end
        
    else
        % IMFILL(I1,CONN,'holes')
        checkstrs(varargin{3}, {'holes'}, mfilename, 'OPTION', 3);
        do_fillholes = true;
        conn = varargin{2};
        do_conn_check = true;
        conn_position = 2;
    end
end

if do_conn_check
    checkconn(conn, mfilename, 'CONN', conn_position);
end

if do_location_check
    checkinput(locations, {'double'}, {'real' 'positive' 'integer' '2d'}, ...
               mfilename, 'LOCATIONS', 2);

    locations = check_locations(locations, size(IM));
    
elseif do_interactive
    locations = get_locations_interactively(IM);
end

% Convert to linear indices if necessary.
if ~do_fillholes && (size(locations,2) ~= 1)
    idx = cell(1,ndims(IM));
    for k = 1:ndims(IM)
        idx{k} = locations(:,k);
    end
    locations = sub2ind(size(IM), idx{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locations = check_locations(locations, image_size)
%   Checks validity of LOCATIONS.  Converts LOCATIONS to linear index
%   form.  Warns if any locations are out of range.

checkinput(locations, {'double'}, {'real' 'positive' 'integer' '2d'}, ...
           mfilename, 'LOCATIONS', 2);

num_dims = length(image_size);
if (size(locations,2) ~= 1) && (size(locations,2) ~= num_dims)
    msgId = sprintf('Images:%s:badLocationSize', mfilename);
    error(msgId,'Function %s expected its %s input argument, LOCATIONS, to have either 1 or NDIMS(IM) columns.', ...
          mfilename, num2ordinal(2));
end

if size(locations,2) == 1
    bad_pix = (locations < 1) | (locations > prod(image_size));
else
    bad_pix = zeros(size(locations,1),1);
    for k = 1:num_dims
        bad_pix = bad_pix | ((locations(:,k) < 1) | ...
                             (locations(:,k) > image_size(k)));
    end
end
    
if any(bad_pix)
    msgId = sprintf('Images:%s:outOfRange', mfilename);
    warning(msgId, '%s', 'Ignoring out-of-range locations.');
    locations(bad_pix,:) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locations = get_locations_interactively(BW)
%   Display image and give user opportunity to select locations with the mouse.

if ndims(BW) > 2
    msgId = sprintf('Images:%s:badInteractiveDimension', mfilename);
    error(msgId, 'Function %s only supports interactive location selection for 2-D images.', ...
          mfilename);
end

if isempty(BW)
    msgId = sprintf('Images:%s:emptyImage', mfilename);
    error(msgId, 'Function %s does not support interactive location selection for empty images.', ...
          mfilename);
end

imshow(BW)
[xi,yi] = getpts;
c = round(axes2pix(size(BW,2), [1 size(BW,2)], xi));
r = round(axes2pix(size(BW,1), [1 size(BW,1)], yi));
locations = sub2ind(size(BW),r,c);



