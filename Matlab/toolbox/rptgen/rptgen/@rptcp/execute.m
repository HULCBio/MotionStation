function out=execute(p)
%EXECUTE an interface to the component's EXECUTE method

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:35 $

out=execute(get(p.h,'UserData'));
