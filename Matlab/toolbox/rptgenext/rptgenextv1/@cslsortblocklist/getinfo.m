function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CSLSORTBLOCKLIST)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:01 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Block Execution Order');
out.Type = 'SL';
out.Desc = xlate('Displays a list of blocks in execution order');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

out.att.ListTitle='';
out.att.LinkTo='none';
out.att.isBlockType=logical(1);
out.att.RenderAs='cfrlist';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.isBlockType.String='Include block type information';

out.attx.LinkTo=struct('String','Link to: ',...
   'enumValues',{{'none' 'System' 'Block'}},...
   'enumNames',{{'No linking' ...
         'Link to block''s parent system' ...
         'Link to block'}},...
   'UIcontrol','radiobutton');

out.attx.RenderAs=struct('String','Present blocks as ',...
   'enumValues',{{'cfrlist' 'cfrcelltable'}},...
   'enumNames',{{'Numbered list' 'Table'}},...
   'UIcontrol','radiobutton');
