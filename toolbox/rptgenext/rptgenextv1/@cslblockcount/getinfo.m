function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CSLBLOCKCOUNT)
%
%   I.Name - component informal name
%   I.Type - component general category 2-letter code
%   I.Desc - short description of the component
%   I.ValidChildren - shows whether or not component can have children
%          ValidChildren={logical(0)} for no children
%          ValidChildren={logical(1)} if children are allowed
%   I.att - component attributes
%   I.attx - information an about component attributes
%   I.ref - reference structure
%   I.x - temporary attribute page handle structure

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:21:10 $

out=getprotocomp(c);

out.Name = xlate('Block Type Count');
out.Type = 'SL';
out.Desc = xlate('Counts number of each block type in model or system');

%================================

out.att.IncludeBlocks='all';
out.att.TableTitle='Block Type Count';

%out.att.isImage=logical(0);
out.att.isBlockName=logical(1);

out.att.SortOrder='alpha';

%================================

out.attx.TableTitle.String='Table title';

out.attx.IncludeBlocks=struct(...
   'String','',...
   'enumValues',{{'all' 'reported'}},...
   'enumNames',{{'All blocks in model       '
      'All blocks in reported systems         '}},...
   'UIcontrol','radiobutton');

out.attx.SortOrder=struct(...
   'String','Sort table ',...
   'enumValues',{{'alpha' 'numblocks'}},...
   'enumNames',{{'Alphabetically by block type' 'By number of blocks'}},...
   'UIcontrol','radiobutton');

out.attx.isBlockName.String='Show block names in table';
