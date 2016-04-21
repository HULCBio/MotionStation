function val = isfield(A, fieldname)
%FIGHANDLE/ISFIELD test for field of fighandle
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2004/01/15 21:12:30 $

switch fieldname
case {'HandleStore' 'ObjectStore' 'Figure' 'HGHandle'}
   val = 1;
otherwise
   UD = getscribeobjectdata(A.figStoreHGHandle);
   val = isfield(UD,fieldname);
end
      

