function B = subsref(A,S)
%FIGHANDLE/SUBSREF Subscripted reference for fighandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.13.4.1 $  $Date: 2004/01/15 21:12:32 $

B = [];
if ishandle(A.figStoreHGHandle)

    UD = getscribeobjectdata(A.figStoreHGHandle);

    switch S.subs
     case 'Figure'
      B = get(A.figStoreHGHandle,'Parent');
     case 'HGHandle'
      B = A.figStoreHGHandle;
     otherwise  % HandleStore, ObjectStore, or other
      if isfield(UD,S.subs)
          B = UD.(S.subs);
      end
    end
    
end
