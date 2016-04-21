function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CFRCELLTABLE)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:08 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Cell Table');
out.Type = 'FR';
out.Desc = xlate('Inserts a table based upon defined cells');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.TableTitle='';

out.att.TableCells={};
out.att.isArrayFromWorkspace=logical(0);
out.att.WorkspaceVariableName='';

out.att.isPgwide=logical(1);
out.att.ColumnWidths=[];

out.att.allAlign='l';
out.att.cellAlign={};

out.att.isBorder=logical(1);
out.att.cellBorders={};

out.att.isInverted=logical(0);

out.att.numHeaderRows=1;
out.att.Footer='NONE';
out.att.numFooterRows=1;

out.att.ShrinkEntries = logical(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%TABLETITLE
out.attx.TableTitle.String=...
   'Table title';
out.attx.TableTitle.isParsedText=logical(1);

%WORKSPACEVARIABLENAME
out.attx.WorkspaceVariableName.String=...
   'Create table from MxN cell array with workspace variable name';

%ALLALIGN
out.attx.allAlign.enumValues={'l' 'c' 'r' 'j'};
out.attx.allAlign.enumNames={'Left'
   'Center'
   'Right'
   'Double justified'};
out.attx.allAlign.String='Cell alignment';

%ISBORDER
out.attx.isBorder.String='Table grid lines';

%ISPGWIDE
%changes DocBook's Table:pgwide attribute. 
out.attx.isPgwide.String='Table spans page width';

%ISINVERTED
out.attx.isInverted.String='Rotate table 90 degrees';

%NUMHEADERROWS
out.attx.numHeaderRows.String='Number of header rows';

%FOOTER
out.attx.Footer.enumValues={'NONE' 'COPY_HEADER' 'LASTROWS' };
out.attx.Footer.enumNames={'No footer'
   'Footer is the same as header'
   'Last N rows are footer'};
out.attx.Footer.UIcontrol='radiobutton';
out.attx.Footer.String='';

%NUMFOOTERROWS
out.attx.numFooterRows.String='';

%COLUMNWIDTHS
out.attx.ColumnWidths.String = 'Column widths';

out.attx.ShrinkEntries = 'Collapse large cells to a simple description';
