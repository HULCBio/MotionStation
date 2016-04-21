function [att,attx]=get_summ_attribute(r)
%GET_SUMM_ATTRIBUTE create prototype .att and .attx fields
%   [att,attx]=get_summ_attribute(r)
%   Used during component creation.  Returns appropriate
%   fields for the child component's "att" and "attx"
%   structures.
% 

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:42 $

att.ObjectType=r.Table(1).id;
attx.ObjectType=[];


att.TitleType='$auto';

attx.TitleType.String='Table title ';
attx.TitleType.enumValues={'$auto','$manual'};
attx.TitleType.enumNames={
   'Automatic (         )'
   'Manual ';
};
attx.TitleType.UIcontrol='radiobutton';

att.TableTitle='';
attx.TableTitle.String='';
attx.TableTitle.isParsedText=logical(1);

idValues={r.Table.id};

for i=length(r.Table):-1:1   
   if isempty(r.Table(i).btnImg)
      idNames{i}=r.Table(i).displayName;
   else
      idNames{i}='';
   end
   
   if iscell(r.Table(i).componentName)
      constructorArgs=r.Table(i).componentName;
   else
      constructorArgs={r.Table(i).componentName};
   end
   
   att=setfield(att,[r.Table(i).id 'Component'],...
      struct(unpoint(feval(constructorArgs{:}))));
   
   att=setfield(att,[r.Table(i).id 'Parameters'],...
      r.Table(i).defaultParams);
   
   att=setfield(att,['is' r.Table(i).id 'Anchor'],logical(1));
   
   attx=setfield(attx,['is' r.Table(i).id 'Anchor'],...
      struct('UIcontrol','checkbox'));
end

attx.ObjectType=struct('String', '',...
   'enumValues'                , {idValues},...
   'enumNames'                 , {idNames},...
   'UIcontrol'                 ,'togglebutton');

