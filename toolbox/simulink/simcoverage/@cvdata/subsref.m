function value = subsref( cvdata, property)

%   Bill Aldrich
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.12.2.2 $  $Date: 2004/04/15 00:37:07 $

id = cvdata.id;

if (id ~= 0) && (~cv('ishandle', id) || cv('get',id,'.isa')~= cv('get','default','testdata.isa'))
	error(sprintf('%d is no longer a valid data dictionary ID', id));	
elseif id>0,
    switch length(property)
    case 1
    	if ~isequal(property.type,'.'), invalid_subscript; end
    	switch lower(property.subs)
    	case 'id'               
    		value = id;
    	case 'test'             
    	 	value = cvtest(id);
    	case 'rootid'   
            rootId = get_root(id);
            if rootId
                value = rootId;
            else
                value = [];
            end
    	case 'checksum'  
            rootId = get_root(id);
            if rootId
                value.u1 = cv('get',rootId,'root.checksum.u1');
                value.u2 = cv('get',rootId,'root.checksum.u2');
                value.u3 = cv('get',rootId,'root.checksum.u3');
                value.u4 = cv('get',rootId,'root.checksum.u4');
            else
                value = [];
            end         
    	case 'starttime'  
            value = cv('get',id,'testdata.startTime');     
    	case 'stoptime'         
            value = cv('get',id,'testdata.stopTime');     
    	case 'metrics'
    	    metricNames = cv('Private','cv_metric_names','all');
    	    value = [];
    	    for metric = metricNames(:)'
    	        value = setfield(value,metric{1},cv('get',id,['testdata.data.' metric{1}]));
            end
    	otherwise
    		error(sprintf('Invalid  cvtest property name: "%s"',sprintf('.%s',property.subs)));
    	end
    case 2
    	if ~isequal(property(1).type,'.'), invalid_subscript; end
    	switch lower(property(1).subs)
    	case 'checksum'  
        	if ~isequal(property(2).type,'.'), invalid_subscript; end
            rootId = get_root(id);
        	switch lower(property(2).subs)
            case 'u1'
                if rootId
                    value = cv('get',rootId,'root.checksum.u1');
                else
                    value = [];
                end
            case 'u2'
                if rootId
                    value = cv('get',rootId,'root.checksum.u2');
                else
                    value = [];
                end
            case 'u3'
                if rootId
                    value = cv('get',rootId,'root.checksum.u3');
                else
                    value = [];
                end
            case 'u4'
                if rootId
                    value = cv('get',rootId,'root.checksum.u4');
                else
                    value = [];
                end
        	otherwise
                invalid_subscript
            end
    	case 'metrics'
        	if ~isequal(property(2).type,'.'), invalid_subscript; end
        	metric = property(2).subs;
            enumVal = cv('Private','cv_metric_names',metric);
            if enumVal>-1
                value = cv('get',id,['testdata.data.' metric]);
            else
        	    invalid_subscript
            end
    	otherwise
            invalid_subscript
        end
    otherwise
    	invalid_subscript
    end
else    % id==0
    switch length(property)
    case 1
    	if ~isequal(property.type,'.'), invalid_subscript; end
    	switch lower(property.subs)
    	case 'id'               
    		value = id;
    	case 'test'             
    		value = [];
    	case 'rootid'   
            value = cvdata.localData.rootId;
    	case 'checksum'  
            value = cvdata.localData.checksum;
    	case 'starttime'  
            value = cvdata.localData.startTime;     
    	case 'stoptime'         
            value = cvdata.localData.stopTime;     
    	case 'metrics'
            value = cvdata.localData.metrics; 
    	otherwise
    		error(sprintf('Invalid  cvtest property name: "%s"',sprintf('.%s',property.subs)));
    	end
    case 2
    	if ~isequal(property(1).type,'.'), invalid_subscript; end
    	switch lower(property(1).subs)
    	case 'checksum'  
        	if ~isequal(property(2).type,'.'), invalid_subscript; end
            rootId = get_root(id);
        	switch lower(property(2).subs)
            case 'u1'
                value = cvdata.localData.checksum.u1;
           case 'u2'
                value = cvdata.localData.checksum.u2;
            case 'u3'
                value = cvdata.localData.checksum.u3;
            case 'u4'
                value = cvdata.localData.checksum.u4;
        	otherwise
                invalid_subscript
            end
    	case 'metrics'
        	if ~isequal(property(2).type,'.'), invalid_subscript; end

        	metric = property(2).subs;
            enumVal = cv('Private','cv_metric_names',metric);
            if enumVal>-1
                value = getfield(cvdata.localData.metrics,metric);
            else
        	    invalid_subscript
            end
    	otherwise
            invalid_subscript
        end
    otherwise
    	invalid_subscript
    end
end



function invalid_subscript
	error('Invalid subscripted reference to a cvtest object.');


function rootId = get_root(id)
    rootId = cv('get',id,'.linkNode.parent');
    if ~cv('ishandle',rootId) | cv('get','default','root.isa') ~= cv('get',rootId,'.isa')
        warning('Root block not resolved');
        rootId = 0;
    end
