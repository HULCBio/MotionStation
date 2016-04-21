function out=execute(c)
%EXECUTE generates report contents

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:23 $

if strcmp(c.att.ObjectType,'Automatic')
   oType=getparentloop(c);
   if isempty(oType)
      oType='Model';
   end
else
   oType=c.att.ObjectType;
end

object=subsref(c.zslmethods,substruct('.',oType));

linkObj=c.rptcomponent.comps.cfrlink;

linkObj.att.LinkType='Anchor';
linkObj.att.LinkID=linkid(c,object,oType);
linkObj.att.LinkText=c.att.LinkText;

out=runcomponent(linkObj,0);