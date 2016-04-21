function vrclose(p)
%VRCLOSE Closes Virtual Reality figures.
%   VRCLOSE closes all Virtual Reality figures.
%   VRCLOSE ALL does the same thing.

%   Copyright 1998-2003 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.4.4.1 $ $Date: 2003/10/30 18:45:40 $ $Author: batserve $

if nargin==0 || (ischar(p) && strcmpi(p,'all'))
  close(vrfigure(vrsfunc('GetAllFigures')));
else
  error('VR:invalidinarg','Invalid input argument.');
end

