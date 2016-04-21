function value = subsref( cvtest, property)

%   Bill Aldrich
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/03/23 03:01:40 $

id = cvtest.id;

switch length(property)
case 1
	if ~isequal(property.type,'.'), invalid_subscript; end
	switch lower(property.subs)
	case 'id'
		value = id;
	case 'rootPath',
		value = cv('get',id,'testdata.rootPath');
	case 'label',
		value = cv('get',id,'testdata.label');
	case 'modelcov',
		value = cv('get',id,'testdata.modelcov');
	case 'setupcmd',
		value = cv('get',id,'testdata.mlSetupCmd');
	case 'settings',
	    metricNames = cv('Private','cv_metric_names','all');
	    value = [];
	    for metric = metricNames(:)'
	        value = setfield(value,metric{1},cv('get',id,['testdata.settings.' metric{1}]));
        end
	otherwise
		error(sprintf('Invalid  cvtest property name: "%s"',sprintf('.%s',property.subs)));
	end
case 2
	if ~isequal(property(1).type,'.'), invalid_subscript; end
	switch lower(property(1).subs)
	case 'settings'  
    	if ~isequal(property(2).type,'.'), invalid_subscript; end
    	metric = property(2).subs;
        enumVal = cv('Private','cv_metric_names',metric);
        if enumVal>-1
            value = cv('get',id,['testdata.settings.' metric]);
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


