function [L,num] = bwlabeln(varargin)
%BWLABELN Label connected components in N-D binary image.
%   L = BWLABELN(BW) returns a label matrix, L, containing labels for the
%   connected components in BW.  BW can have any dimension; L is the same
%   size as BW.  The elements of L are integer values greater than or equal
%   to 0.  The pixels labeled 0 are the background.  The pixels labeled 1
%   make up one object, the pixels labeled 2 make up a second object, and so
%   on.  The default connectivity is 8 for two dimensions, 26 for three
%   dimensions, and CONNDEF(NDIMS(BW),'maximal') for higher dimensions.
%
%   [L,NUM] = BWLABELN(BW) returns the number of connected objects found
%   in BW.
%
%   [L,NUM] = BWLABELN(BW,CONN) specifies the desired connectivity.  CONN
%   may have the following scalar values:
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
%   Note: Comparing BWLABEL and BWLABELN
%   ------------------------------------
%   BWLABEL supports 2-D inputs only, whereas BWLABELN support any 
%   input dimension.  In some cases you might prefer to use BWLABELN even
%   for 2-D problems because it can be faster.  If you have a 2-D input
%   whose objects are relatively "thick" in the vertical direction,
%   BWLABEL will probably be faster; otherwise BWLABELN will probably be
%   faster.
%
%   Class Support
%   -------------
%   BW can be numeric or logical, and it must be real and nonsparse.  L
%   is double.
%
%   Example
%   -------
%       BW = cat(3,[1 1 0; 0 0 0; 1 0 0],...
%                  [0 1 0; 0 0 0; 0 1 0],...
%                  [0 1 1; 0 0 0; 0 0 1])
%       bwlabeln(BW)
%
%   See also BWLABEL.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.8.4.2 $  $Date: 2003/01/26 05:54:26 $

[A,conn] = parse_inputs(varargin{:});

[L,num] = bwlabelnmex(A,conn);

%%%
%%% parse_inputs
%%%
function [A,conn] = parse_inputs(varargin)

checknargin(1,2,nargin,mfilename);

checkinput(varargin{1}, {'numeric', 'logical'}, {'real' 'nonsparse'}, ...
           mfilename, 'BW', 1);

A = varargin{1};
if ~islogical(A)
  A = A ~= 0;
end

if nargin < 2
    conn = conndef(ndims(A), 'maximal');
else
    conn = varargin{2};
    checkconn(conn,mfilename,'CONN',2);
end
