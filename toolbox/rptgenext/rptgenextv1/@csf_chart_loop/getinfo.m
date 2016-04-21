function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CSL_SIG_LOOP)
%
%   I.Name - component informal name
%   I.Type - component general category 2-letter code
%   I.Desc - short description of the component
%   I.ValidChildren - shows whether or not component can have children
%          ValidChildren={logical(0)} for no children
%          ValidChildren={logical(1)} if children are allowed
%   I.att - component attributes
%   I.attx - information about component attributes
%   I.ref - reference structure
%   I.x - temporary attribute page handle structure


%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:02 $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Chart Loop');
out.Type = 'SF';
out.Desc = xlate('Applies all subcomponents to desired Stateflow blocks.');
out.ValidChildren={logical(1)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.LoopType='$auto';
out.att.ObjectList={''};

out.att.isSortList=logical(0);
out.att.SortBy='$alphabetical';

out.att.isSFFilterList=logical(0);
out.att.isSLFilterList=logical(0);
out.att.FilterTerms={{'',''},{'',''}} ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loopInfo=loopblock(c.zslmethods);

out.attx.SortBy=struct('String','Sort charts ',...
   'enumValues',{loopInfo.sortCode},...
   'enumNames',{loopInfo.sortName},...
   'UIcontrol','popupmenu');

out.attx.LoopType=struct('String','',...
   'enumValues',{{'$auto','$list'}},...
   'enumNames',{{'All charts','Manual - use chart list:'}},...
   'UIcontrol','radiobutton');

out.attx.ObjectList=struct('String','',...
   'UIcontrol','multiedit',...
   'isParsedText',logical(1));

out.attx.isSortList.String='Sort charts in list';

out.attx.isSLFilterList.String='Search Simulink:';

out.attx.isSFFilterList.String='Search Stateflow:';

