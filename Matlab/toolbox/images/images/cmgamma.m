function map = cmgamma(cm,gtable)
%CMGAMMA Gamma correct colormap.
%   CMGAMMA(MAP,GTABLE) applies the gamma correction in the matrix
%   GTABLE to the colormap MAP and installs it as the current
%   colormap. GTABLE can be a m-by-2 or m-by-4 matrix.  If GTABLE 
%   is m-by-2, then CMGAMMA applies the same correction to all three
%   components of the colormap. If GTABLE is m-by-4, then CMGAMMA 
%   applies the correction in the columns of GTABLE to each component
%   of the colormap separately.
%
%   CMGAMMA(MAP) invokes the function CMGAMDEF(COMPUTER) to define the
%   gamma correction table.  You can install your own default table
%   by providing a CMGAMDEF M-file on your path before this toolbox.
%
%   CMGAMMA or CMGAMMA(GTABLE) applies either the default gamma
%   correction table or GTABLE to the current colormap.
%
%   NEWMAP = CMGAMMA(...) returns the corrected colormap but does
%   not apply it.
%
%   See also CMGAMDEF, INTERP1.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.12.4.2 $  $Date: 2003/08/01 18:08:39 $

error(nargchk(0,2,nargin,'struct'));
if nargin==0, cm = colormap; end
if nargin<2, 
  if size(cm,2)~=3, 
    gtable = cm; cm = colormap; 
  else
    gtable = cmgamdef(computer);
  end
end

if size(gtable,2)==2, gtable = [gtable(:,1) gtable(:,2)*ones(1,3)]; end
if size(gtable,2)~=4 
    eid = 'Images:cmgamma:invalidGTable';
    error(eid, '%s', 'GTABLE must be a N-by-2 or N-by-4 matrix.'); 
end
if size(cm,2)~=3 
    eid = 'Images:cmgamma:invalidColormap';
    error(eid, '%s', 'MAP must be a N-by-3 colormap.'); 
end
if min(min(gtable))< 0 | max(max(gtable))>1
    eid = 'Images:cmgamma:gtableValuesOutOfRange';
    error(eid, '%s', 'GTABLE must contain values between 0.0 and 1.0.');
end

% Apply gamma correction to each column of cm.
cm(:,1) = interp1(gtable(:,1),gtable(:,2),cm(:,1));
cm(:,2) = interp1(gtable(:,1),gtable(:,3),cm(:,2));
cm(:,3) = interp1(gtable(:,1),gtable(:,4),cm(:,3));

if nargout==0, colormap(cm), return, end 
map = cm;


