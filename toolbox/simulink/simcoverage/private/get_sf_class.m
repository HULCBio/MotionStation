function str = get_sf_class(isa,id)
% GET_SF_CLASS - Get the class name 
% corresponding to an isa value.
%

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/10/14 16:22:58 $

persistent sfClassNames;
persistent sfClassIsa;
persistent sfStateTypes;
persistent functionTypeIdx;
persistent canHaveTruthTables;

if isempty(sfClassNames)
    sfClassIsa = [ sf('get','default','machine.isa') ...
            sf('get','default','chart.isa') ...
            sf('get','default','state.isa') ...
            sf('get','default','transition.isa') ...
            sf('get','default','junction.isa') ...
            sf('get','default','data.isa') ...
            sf('get','default','event.isa') ...
            sf('get','default','target.isa') ...
            sf('get','default','note.isa')];

    sfClassNames = {   'Machine', ...
                'Chart', ...
                'State', ...
                'Transition', ...
                'Junction', ...
                'Data', ...
                'Event', ...
                'Target', ...
                'Note'      };

    sfStateTypes = {'State','State','Function','Box'};
    functionTypeIdx = find(strcmp(sfClassNames,'Function'));
    canHaveTruthTables = (sfversion('Full_Number') > 5.100e7);
end

if nargin>1 & isa==sf('get','default','state.isa') & ~isempty(id)
    type = sf('get',cv('get',id,'slsfobj.handle'),'state.type');
    if isempty(type)
        str = 'State';
    else
        if (canHaveTruthTables & type==functionTypeIdx)
            is_ttable = sf('get',cv('get',id,'slsfobj.handle'),'state.truthTable.isTruthTable');
            if is_ttable
                str = 'Truth Table';
            else
                str = sfStateTypes{type+1};
            end
        else
            str = sfStateTypes{type+1};
        end
    end
else
    str = sfClassNames{isa==sfClassIsa};
end