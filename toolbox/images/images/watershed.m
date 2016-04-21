function L = watershed(varargin)
%WATERSHED Find image watershed regions.
%   L = WATERSHED(A) computes a label matrix identifying the watershed
%   regions of the input matrix A.  A can have any dimension.  The elements
%   of L are integer values greater than or equal to 0.  The elements
%   labeled 0 do not belong to a unique watershed region.  These are called
%   "watershed pixels."  The elements labeled 1 belong to the first
%   watershed region, the elements labeled 2 belong to the second watershed
%   region, and so on.
%
%   By default, WATERSHED uses 8-connected neighborhoods for 2-D inputs
%   and 26-connected neighborhoods for 3-D inputs.  For higher
%   dimensions, WATERSHED uses the connectivity given by
%   CONNDEF(NDIMS(A),'maximal').
%
%   L = WATERSHED(A,CONN) computes the watershed transform using the
%   specified connectivity.  CONN may have the following scalar values:
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
%   CONN.  If specified this way, CONN must be symmetric about its center.
%
%   Class Support
%   -------------
%   A can be a numeric or logical array of any dimension, and it must be
%   nonsparse.  The output array L is double. 
%
%   Example (2-D)
%   -------------
%   1. Make a binary image containing two overlapping circular objects.
%
%       center1 = -10;
%       center2 = -center1;
%       dist = sqrt(2*(2*center1)^2);
%       radius = dist/2 * 1.4;
%       lims = [floor(center1-1.2*radius) ceil(center2+1.2*radius)];
%       [x,y] = meshgrid(lims(1):lims(2));
%       bw1 = sqrt((x-center1).^2 + (y-center1).^2) <= radius;
%       bw2 = sqrt((x-center2).^2 + (y-center2).^2) <= radius;
%       bw = bw1 | bw2;
%       figure, imshow(bw,'n'), title('bw')
%
%   2. Compute the distance transform of the complement of the binary
%      image. 
%
%       D = bwdist(~bw);
%       figure, imshow(D,[],'n'), title('Distance transform of ~bw')
%
%   3. Complement the distance transform, and force pixels that don't
%      belong to the objects to be at -Inf.
%
%       D = -D;
%       D(~bw) = -Inf;
%
%   4. Compute the watershed transform, and display the resulting label
%      matrix as an RGB image.
%
%       L = watershed(D); 
%       rgb = label2rgb(L,'jet',[.5 .5 .5]);
%       figure, imshow(rgb,'n'), title('Watershed transform of D')
%
%   Example (3-D)
%   -------------
%   1. Make a 3-D binary image containing two overlapping spheres.
%
%       center1 = -10;
%       center2 = -center1;
%       dist = sqrt(3*(2*center1)^2);
%       radius = dist/2 * 1.4;
%       lims = [floor(center1-1.2*radius) ceil(center2+1.2*radius)];
%       [x,y,z] = meshgrid(lims(1):lims(2));
%       bw1 = sqrt((x-center1).^2 + (y-center1).^2 + ...
%           (z-center1).^2) <= radius;
%       bw2 = sqrt((x-center2).^2 + (y-center2).^2 + ...
%           (z-center2).^2) <= radius;
%       bw = bw1 | bw2;
%       figure, isosurface(x,y,z,bw,0.5), axis equal, title('BW')
%       xlabel x, ylabel y, zlabel z
%       xlim(lims), ylim(lims), zlim(lims)
%       view(3), camlight, lighting gouraud
%
%   2. Compute the distance transform.
%
%       D = bwdist(~bw);
%       figure, isosurface(x,y,z,D,radius/2), axis equal
%       title('Isosurface of distance transform')
%       xlabel x, ylabel y, zlabel z
%       xlim(lims), ylim(lims), zlim(lims)
%       view(3), camlight, lighting gouraud
%
%   3. Complement the distance transform, force nonobject pixels to be
%      -Inf, and then compute the watershed transform.
%
%       D = -D;
%       D(~bw) = -Inf;
%       L = watershed(D);
%       figure, isosurface(x,y,z,L==2,0.5), axis equal
%       title('Segmented object')
%       xlabel x, ylabel y, zlabel z
%       xlim(lims), ylim(lims), zlim(lims)
%       view(3), camlight, lighting gouraud
%       figure, isosurface(x,y,z,L==3,0.5), axis equal
%       title('Segmented object')
%       xlabel x, ylabel y, zlabel z
%       xlim(lims), ylim(lims), zlim(lims)
%       view(3), camlight, lighting gouraud
%
%   See also BWLABEL, BWLABELN, REGIONPROPS.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2003/08/23 05:54:47 $

% Input-output specs
% ==================
% A    - full, real, numeric, logical
%        +/- Inf OK, but NaNs not allowed
%        empty OK
%        required
%
% CONN - connectivity; see connectivity spec
%        optional; if not specified = ones(repmat(3,1,ndims(A)))
%
% L      full, double array, same size as A

[A,conn] = parse_inputs(varargin{:});
try
    [junk,idx] = sort(A(:));
catch
    % If there's no sort method, convert to double.
    [junk,idx] = sort(double(A(:)));
end

% check idx
if ~isa(idx,'double') || ~isreal(idx) || issparse(idx)
  eid = sprintf('Images:%s:internalError',mfilename);
  msg = 'Internal error: IDX is not valid.';
  error(eid,'%s',msg);
end
  
L = watershed_vs(A,conn,idx-1);

% Post-process result to remove gaps in watershed lines.  Change any
% labeled pixel with a higher labeled neighbor to a watershed pixel.
conn = conn2array(conn);
L(imdilate(L,conn) > L) = 0;

function [A,conn] = parse_inputs(varargin)
  
checknargin(1,2,nargin,mfilename);

A = varargin{1};
checkinput(A,{'numeric' 'logical'}, {'real' 'nonsparse'}, ...
           mfilename, 'A', 1);

if nargin < 2
    conn = conndef(ndims(A), 'maximal');
else
    conn = varargin{2};
    if isa(conn,'strel')
        conn = getnhood(conn);
    else
        checkconn(conn, mfilename, 'CONN', 2);
    end
end
