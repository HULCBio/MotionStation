function id=toxpcmaskinit(appname,paramname,blockpath)
%TOXPCMASKINIT To xPC Target Block Mask Initialization function
%  TOXPCMASKINIT is called from the To xPC Target Block 
%  Mask Initialization function

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $


if  strcmp(appname,'''''')
    id=0;
    return
end

if ~strcmp(xpcgate('getname'),appname)
    id=0;
	error([appname, ' is not loaded on Target PC.']);
end
if ~isempty(blockpath)
	paramid=xpcgate('getparid',blockpath, paramname,appname);
    if length(paramid)==1, id=0; error('parameter not found'); end;
   	id=str2num(paramid(2:end));
end
