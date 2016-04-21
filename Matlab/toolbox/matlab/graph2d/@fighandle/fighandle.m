function h = fighandle(HG);
%FIGHANDLE/FIGHANDLE Make fighandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:12:29 $

if nargin==0
   h.Class = 'fighandle';
   h.figStoreHGHandle = [];
   h = class(h,'fighandle');
   return
end

h.Class = 'fighandle';
h.figStoreHGHandle = HG;
h = class(h,'fighandle');

