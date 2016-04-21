function xpcdldlm(filename)

%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $   $Date: 2004/04/08 21:04:40 $

xpcgate('stopsess');
xpcdldlmrs232(filename,1);
i=0; while i<5, pause(1); if ~strcmp(xpcgate('getname'),filename), i=i+1; else, i=10; end; end; if i==5, error('xPC Target-application initialization error'); end;
