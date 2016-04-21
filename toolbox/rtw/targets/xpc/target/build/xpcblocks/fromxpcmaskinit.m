function id=fromxpcmaskinit(appname,blockpath)
%FROMXPCMASKINIT From xPC Target Block Mask Initialization function
%  FROMXPCMASKINIT is called from the From xPC Target Block 
%  Mask Initialization function

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $

if  strcmp(appname,'''''')
    id=0;
    return
end
if ~strcmp(xpcgate('getname'),appname)
	error([appname, ' is not loaded on Target PC.']);
end
if ~isempty(blockpath)
	id=xpcgate('getsignalid',blockpath,appname);
	if isempty(id),id=0; error('signal not found'); end;
end
