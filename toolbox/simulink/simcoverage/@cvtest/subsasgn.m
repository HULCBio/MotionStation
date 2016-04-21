function junction = subsasgn( junction, property, value)


%   Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/03/23 03:01:43 $

id = junction.id;

switch length(property)
case 1
	if ~isequal(property.type,'.'), invalid_subscript; end
	
	% If this is a settings. property check that the metric is 
	% visible
    if strncmp('settings.',lower(property.subs),10)
        metric = lower(property.subs(11:end))
        enumVal = cv('Private','cv_metric_names',metric);
        if enumVal>-1
            cv('set',id,['testdata.settings.' metric],value);
        end
    else
    	switch lower(property.subs)
    	case 'id'
    		read_only(property.subs);
    	case 'label',
    		cv('set',id,'testdata.label',value);
    	case 'modelcov',
    		read_only(property.subs);
    	case 'setupcmd',
    		cv('set',id,'testdata.mlSetupCmd',value);
    	case 'settings',
    	    metNames = fieldnames(value)
    	    for metric = metNames
                enumVal = cv('Private','cv_metric_names',metric);
                if enumVal>-1
                    cv('set',id,['testdata.settings.' metric],getfield(value,metric));
                end
            end
    	otherwise
    		error(sprintf('Invalid cvtest property name: "%s"',sprintf('.%s',property.subs)));
    	end
    end
case 2
	if ~isequal(property(1).type,'.'), invalid_subscript; end
	switch lower(property(1).subs)
	case 'settings'  
    	if ~isequal(property(2).type,'.'), invalid_subscript; end
    	metric = property(2).subs;
        enumVal = cv('Private','cv_metric_names',metric);
        if enumVal>-1
            cv('set',id,['testdata.settings.' metric],value);
        else
    	    invalid_subscript;
        end
    otherwise
    	invalid_subscript;
    end
otherwise
	invalid_subscript
end

function invalid_subscript
	error('Invalid subscripted reference to a cvtest object.');

function read_only(propName)
    error(sprintf('The property "%s" is read only',sprintf('.%s',propName)));