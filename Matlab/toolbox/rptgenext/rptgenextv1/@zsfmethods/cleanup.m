function cleanup(c)
%CLEANUP removes persistent information after generation

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:17 $

sfPortal = subsref(c,substruct('.','sfportal'));
try
    sf('delete',sfPortal);
end

if mislocked( 'zsfmethods/rgstoredata' )
    %? Should we get rid of the portal?
    munlock zsfmethods/rgstoredata;
    clear zsfmethods/rgstoredata;
else
    subsasgn(c,substruct('.','initialized'),logical(0));
    subsasgn(c,substruct('.','reportList'),[]);
end