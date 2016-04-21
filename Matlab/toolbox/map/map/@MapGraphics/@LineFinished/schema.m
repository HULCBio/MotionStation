function schema
%SCHEMA Class definition for LineFinished event.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:43 $

pkg = findpackage('MapGraphics');
cEventData = findclass(findpackage('handle'),'EventData');

c = schema.class(pkg,'LineFinished',cEventData);



