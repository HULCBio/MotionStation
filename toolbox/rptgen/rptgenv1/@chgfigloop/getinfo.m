function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(C)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:05 $


out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Figure "For" Loop');
out.Type = 'HG';
out.Desc = xlate('Applies each subcomponent to a graphics figure.');
out.ValidChildren={logical(1)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.LoopType='CURRENT';

out.att.isDataFigureOnly=logical(1);

out.att.TagList={};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.LoopType=struct('String','',...
   'enumValues',{{'CURRENT' 'ALL' 'TAG'}},...
   'enumNames',{{'Current figure only'
      'Visible figures '
      'All figures with tags: '}},...
   'UIcontrol','radiobutton');

out.attx.isDataFigureOnly.String=...
   'Data figures only (Exclude applications)';

out.attx.TagList.String='';
out.attx.TagList.UIcontrol='listbox';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%a list of tags used by the report generator figures
out.ref.RptgenTagList=excludefiguretags(c.zhgmethods);