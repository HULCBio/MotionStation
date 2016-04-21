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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:10 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.Name = xlate('Stateflow Loop');
out.Type = 'SF';
out.Desc = xlate('Decides which Stateflow charts are included in the report');

out.ValidChildren={logical(1)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.att.legibleFontSize = 8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.attx.legibleFontSize.String = 'Minimum legible font size';