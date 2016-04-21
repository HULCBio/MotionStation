function BeforeMake(h)
%   BEFOREMAKE is the method get called inside make_rtw method before make
%   process.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/15 00:23:42 $

%
% This is the 'before_make' point of image building.
% If makeRTWHookMFile is existing call it with Method equal 'before_make'.
%
if ~isempty(h.MakeRTWHookMFile)
    feval(h.MakeRTWHookMFile,'before_make',h.ModelName,h.RTWRoot,...
	      h.TemplateMakefile,h.BuildOpts,h.BuildArgs);
end
