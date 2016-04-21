function out=execute(c)
%EXECUTE generates report contents
%   OUT=EXECUTE(C)

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:20 $

currContext=getparentloop(c);
blkList = searchblocktype(c.zslmethods,...
    {'MaskType','DocBlock'},...
    currContext);


if ~isempty(blkList)
    importComp = c.rptcomponent.comps.crg_import_file;
    
    if c.att.LinkingAnchor
        linkComp=c.rptcomponent.comps.cfrlink;
        linkComp.att.LinkText='';
        linkComp.att.LinkType='Anchor';
    else
        linkComp = [];
    end

    out={};
    
    for i=1:length(blkList)
        if ~isempty(linkComp)
            linkComp.att.LinkID=linkid(c.zslmethods,blkList{i},'sys');
            out{end+1} = runcomponent(linkComp,0);
        end
        fName = [tempname,'.txt'];
        docblock('blk2file',blkList{i},fName);
        
        importComp.att.FileName = fName;
        importComp.att.ImportType = c.att.ImportType;

        out{end+1} = execute(importComp);
    end
else
    out=[];
end