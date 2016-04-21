function idText=linkid(m,object,type)
%LINKID returns a DocBook link ID
%   ID=LINKID(ZSLMETHODS,OBJECTHANDLE);
%   ID=LINKID(ZSLMETHODS,OBJECTHANDLE,OBJECTTYPE);
%
%   ID is of the form 'link-SL-type-handle'
%
%   OBJECTHANDLE is the handle to a model, system, block, or signal
%   OBJECTTYPE is 'mdl','sys','blk',or 'sig' respectively

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:39 $

if iscell(object)
   object=object{1};
end

if ischar(object)
   try
      object=get_param(object,'Handle');
   catch
      object=[];
   end
end

if nargin<3
   try
      type=get_param(object,'type');
   catch
      type='';
   end
   if strcmp(type,'block') & ...
           strcmp(get_param(object,'BlockType'),'SubSystem') & ...
           isempty(get_param(object,'MaskType'))
       type = 'system';
   end
end

switch type
case {'mdl' 'blk' 'sig' 'sys'}
   %do nothing 
case {'Model' 'block_diagram'}
   type='mdl';
case {'System' 'system'}
   type='sys';
case {'Signal' 'signal' 'port'}
   type='sig';
case {'Block' 'block'}
   type='blk';
otherwise
   type='';
end

idText=sprintf('link-SL-%s-%0.14f',type,object);