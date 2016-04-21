function out=getinfo(c)
%GETINFO returns a structure containing information about the component
%   I=GETINFO(CSL_BLK_BUS)
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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:14 $

out=getprotocomp(c);

out.Name = xlate('Block Type: Bus');
out.Type = 'SL';
out.Desc = xlate('Displays a list of signals connected to a bus block');

%================================

out.att.isHierarchy=logical(0);

out.att.BusAnchor=logical(0);
out.att.SignalAnchor=logical(0);
out.att.ListTitle='';

%================================

out.attx.ListTitle.String='Title';
out.attx.ListTitle.isParsedText=logical(1);

out.attx.isHierarchy.String='Show bus hierarchy';

out.attx.BusAnchor.String='Insert linking anchor for bus blocks';
out.attx.SignalAnchor.String='Insert linking anchor for signals';