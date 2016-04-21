function	varargout = cv_metric_names(varargin)
%CV_METRIC_NAMES Gateway for selecting and verifying coverage metrics.
%   This function is the gateway for adding a coverage metric.
%
%   MSTRUCT = CV_METRIC_NAMES - Return a structure with the enumeration
%   names and values used within the data dictionary.
%
%   ENUMVAL = CV_METRIC_NAMES(METRIC) - Convert the metric name to its 
%   data dictionary enumeration value.  Will return -1 if the metric 
%   does not exist.  If a METRIC is a cell array then ENUMVAL will be a
%   vector.
%
%   [ENUMVAL,ABBR] = CV_METRIC_NAMES(METRIC) - Return a single letter 
%   abbreviation used when encoding the metric settings in the model.
%
%   NAMES = CV_METRIC_NAMES('all') - Return a cell array of strings with 
%   the field names for all the possible coverage metrics.
%
%   NAMES = CV_METRIC_NAMES([],ABBREV) - Decode the metric string ABBREV
%   and return the enabled metrics in a cell array of strings.
%
%   [NAMES,UITABLE] = CV_METRIC_NAMES('all') Return a table to populate a
%   GUI for selecting the coverage settings.
%
%   ENUM_STRUCT = CV_METRIC_NAMES('all','struct') Return a structure
%   with all of the metric enumeration values.
%
     
%   Bill Aldrich
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.12.2.5 $

persistent ddEnumVals apiTable

if isempty(ddEnumVals)
	[prop,names]=cv('subproperty','modelcov.metric_enum');
	[r,c] = size(names{1});
	args = cell(2*r,1);
	args(1:2:2*r,1) = names{1};
	args(2:2:2*r,1) = num2cell(0:r-1');
	ddEnumVals= struct(args{:});
	
	% Table of coverage metrics visible to users.  This function
	% is the main gateway to turn metrics on and off. Each entry
	% has the form:
	%
	% 'UI name', ...
	% 'single letter abbr.', ...
	% 'dd field name', ...
	% dd enum value, ...
	% 'description'; ...
	
	apiTable = { ...
	    xlate('Decision Coverage'), ...
	    'd', ...
	    'decision', ...
	    ddEnumVals.MTRC_DECISION, ...
	    'Record the execution of model decisions'; ...
        ...
	    xlate('Condition Coverage'), ...
	    'c', ...
	    'condition', ...
	    ddEnumVals.MTRC_CONDITION, ...
	    'Record the execution of conditions, the predicates used in decisions and boolean equations'; ...
        ...
	    xlate('MCDC Coverage'), ...
	    'm', ...
	    'mcdc', ...
	    ddEnumVals.MTRC_MCDC, ...
	    'Record the execution of conditional combinations used within boolean equations'; ...
        ...
	    xlate('Look-up Table Coverage'), ...
	    't', ...
	    'tableExec', ...
	    ddEnumVals.MTRC_TABLE_EXEC, ...
	    'Record the execution table lookups to determine the frequency of each interpolation interval'; ...
        ...
	    xlate('Signal Range Coverage'), ...
	    'r', ...
	    'sigrange', ...
	    ddEnumVals.MTRC_SIGRANGE, ...
	    'Record the maximum and minimum values assigned to signals and Stateflow variables'};
        	    
end


% Switch yard to determine the use scenario

switch(nargin),
case 0
    varargout{1} = ddEnumVals;

case 1
    switch(class(varargin{1}))
	case 'char'
        if strcmp(varargin{1},'all')
            varargout{1} = apiTable(:,3);
            if nargout > 1
                varargout{2} = apiTable;
            end
        else
            Ind = name_to_index(varargin{1},apiTable); 
    	    if (Ind < 1)
                varargout{1} = -1;
                if nargout > 1
                    varargout{2} = [];
                end
    	    else	
                varargout{1} = cat(2,apiTable{Ind,4});
                if nargout > 1
                    varargout{2} = cat(2,apiTable{Ind,2});
                end
            end
        end
    case 'cell'
    	names = varargin{1};
    	l = length(names);
    	Ind = -1*ones(1,l);
    	for i=1:l
    		Ind(i)=name_to_index(names{i},apiTable); 
    	end
        Ind = Ind(Ind>0);
        varargout{1} = cat(2,apiTable{Ind,4});
        if nargout > 1
            varargout{2} = cat(2,apiTable{Ind,2});
        end
    otherwise,
        error('Unrecognized useage');
    end
	
case 2
    if (isempty(varargin{1}) & ischar(varargin{2}))
        Ind = abbrev_to_index(varargin{2},apiTable);
        Ind = Ind(Ind>0);
        varargout{1} = apiTable(Ind,3);
        if nargout > 1
            varargout{2} = apiTable(Ind,:);
        end
    elseif(strcmp(lower(varargin{1}),'all') & strcmp(lower(varargin{2}),'struct'))
        out = struct;
        cnt = size(apiTable,1);
        for i=1:cnt
            out = setfield(out,apiTable{i,3},apiTable{i,4});
        end
        varargout{1} = out;
    else
        error('Unrecognized useage');
    end
        
end


function index = name_to_index(name,apiTable)

    [r,c] = size(apiTable);

    for index = 1:r
        if strcmp(name,apiTable(index,3))
            return;
        end
    end

    index = -1;
     


function index = abbrev_to_index(abbrev,apiTable)

    index = -1*ones(1,length(abbrev));
    [r,c] = size(apiTable);

    for i=1:length(abbrev)    
        for j = 1:r
            if isequal(abbrev(i),apiTable{j,2})
                index(i) = j;
            end
        end
    end
    





