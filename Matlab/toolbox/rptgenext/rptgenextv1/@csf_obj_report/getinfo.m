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
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:17 $

out=getprotocomp(c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out.Name = xlate('Object Report');
out.Type = 'SF';
out.Desc = xlate('Executes its children if current object is of a certain type');

out.ValidChildren={logical(1)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out.att.typeString = 'machine';
out.att.repMinChildren = 0;
out.att.addAnchor = logical(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out.attx.typeString.String = 'Object type';
out.attx.typeString.UIcontrol='popupmenu';
out.attx.typeString.Type='ENUM';
out.attx.typeString.enumValues = {
    'machine'
    'chart'
    'target'
    'state'
    'transition'
    'junction'
    'event'
    'data'
    'function'
    'box'
    'note'    
};
out.attx.typeString.enumNames = {
    'Machine'
    'Chart'
    'Target'
    'State'
    'Transition'
    'Junction'
    'Event'
    'Data'
    'Function'
    'Box'
    'Note'    
};
%hardcode this list to prevent loading stateflow at class load time
%out.attx.typeString.enumValues = rgsf('get_filter_list')


out.attx.repMinChildren.String = ...
   'Run only if Stateflow object has at least the following number of children:';

out.attx.addAnchor=struct('String','Automatically insert linking anchor');
