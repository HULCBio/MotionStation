function M = moviein(n,h,rect)
%MOVIEIN Initialize movie frame memory.
%   MOVIEIN is no longer needed as of MATLAB Release 11 (5.3).  
%   In previous revisions, pre-allocating a movie increased 
%   performance, but there is no longer a need to pre-allocate 
%   movies. To create a movie, use something like the 
%   following example:
%
%     for j=1:n
%        plot_command
%        M(j) = getframe;
%     end
%     movie(M)
%
%   For code that is compatible with all versions of MATLAB, 
%   including versions before Release 11 (5.3), use:
%
%     M = moviein(n);
%     for j=1:n
%        plot_command
%        M(:,j) = getframe;
%     end
%     movie(M)
%
%   See also MOVIE, GETFRAME.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.12 $  $Date: 2002/02/11 06:37:22 $

if nargin == 1
   f = getframe;
elseif nargin == 2
   f = getframe(h);
else
   f = getframe(h,rect);
end

if isa(f, 'double') 
   M = zeros(length(f),n);
else
   M = struct('cdata', {}, 'colormap', {});
end
