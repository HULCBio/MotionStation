function BeforeTLCBuild(h)
%   BEFORETLCBUILD is the method get called inside make_rtw method before TLC
%   process.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/15 00:23:43 $

%
% This is the 'before_tlc' point of make_rtw. If makeRTWHookMFile is
% existing call it with Method equal 'before_tlc'.
%
if ~isempty(h.MakeRTWHookMFile)
    feval(h.MakeRTWHookMFile,'before_tlc',h.ModelName,h.RTWRoot,...
              h.TemplateMakefile,h.BuildOpts,h.BuildArgs);
end
