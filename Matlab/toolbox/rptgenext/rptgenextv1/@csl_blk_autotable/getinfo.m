function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CSL_BLK_AUTOTABLE)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:07 $

out=getprotocomp(c);

out.Name = xlate('Block Automatic Property Table');
out.Type = 'SL';
out.Desc = xlate('Automatically creates a property/value table for the current block');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.isNamePrompt=logical(1);

out.att.TitleType='blkname';
out.att.TitleString='Block Properties';

out.att.HeaderType='none';

out.att.isBorder=logical(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.HeaderType.String = 'Header row';
out.attx.HeaderType.enumValues={
   'none'
   'blkname'
   'namevalue'
};
out.attx.HeaderType.enumNames={
   'No header'
   'Block type and name'
   '"Name" and "Value"'
};
out.attx.HeaderType.UIcontrol='radiobutton';

out.attx.isNamePrompt.String='Display property names as prompts';

out.attx.TitleType.String = 'Table title';
out.attx.TitleType.enumValues={
   'none'
   'blkname'
   'other'
};
out.attx.TitleType.enumNames={
   'No title'
   'Use block name for title'
   'Other: '
};
out.attx.TitleType.UIcontrol='radiobutton';

out.attx.TitleString.String = '';

out.attx.isBorder.String = 'Show table border';