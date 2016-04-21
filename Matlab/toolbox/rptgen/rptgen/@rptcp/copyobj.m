function pDuplicate=copyobj(pOriginal)
%COPYOBJ creates a copy of a component pointer object
%   C = COPYOBJ(H)
%   All pointers are copied to the Clipboard.
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:28 $

pDuplicate=rptcp(...
   copyobj(pOriginal.h,...
   subsref(rptsp('clipboard'),substruct('.','h'))));