function	varargout = cv_dialog_options(varargin)

     
%   Bill Aldrich
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.5.2.2 $

persistent optionsTable

if isempty(optionsTable)

	% Table of coverage options that are visible to users.  This function
	% is the main gateway to turn metrics on and off. Each entry
	% has the form:
	%
	% 'UI name', ...
	% 'single letter abbr.', ...
	% 'set true command', ...
	% 'set false command', ...
	% 'default value'
	
	optionsTable = { ...
	    xlate('Treat Simulink Logic blocks as short-circuited'), ...
	    's', ...
	    'cv(''Feature'',''short circuit'',''on'');', ...
	    'cv(''Feature'',''short circuit'',''off'');', ...
	    0; ...
        ...
	    xlate('Warn when unsupported blocks exist in model'), ...
	    'w', ...
	    'cv(''Feature'',''skip uninstrumented'',''on'');', ...
	    'cv(''Feature'',''skip uninstrumented'',''off'');', ...
	    1; ...
	    xlate('Disable coverage for blocks used in assertion checks'), ...
	    'a', ...
	    'cv(''Feature'',''disable assert coverage'',''on'');', ...
	    'cv(''Feature'',''disable assert coverage'',''off'');', ...
	    1; ...
	    };
        	    
end


% Switch yard to determine the use scenario

switch(nargin),
case 0
    varargout{1} = optionsTable;
case 2
    switch(varargin{1})
    case 'enabledTags'
        Ind = abbrev_to_index(varargin{2},optionsTable);
        Ind = Ind(Ind>0);
        varargout{1} = optionsTable(Ind,2);
        if nargout > 1
            varargout{2} = optionsTable(Ind,:);
        end
    case 'applyOptions'
        Ind = abbrev_to_index(varargin{2},optionsTable);
        Ind = Ind(Ind>0);
        [r,c] = size(optionsTable);  
        if isempty(Ind)
            for i=1:r
                eval(optionsTable{i,4});
            end
        else
            for i=1:r
                if any(Ind==i)
                    eval(optionsTable{i,3});
                else
                    eval(optionsTable{i,4});
                end
            end
        end
    end
end





function index = abbrev_to_index(abbrev,optionsTable)

    index = -1*ones(1,length(abbrev));
    [r,c] = size(optionsTable);

    for i=1:length(abbrev)    
        for j = 1:r
            if isequal(abbrev(i),optionsTable{j,2})
                index(i) = j;
            end
        end
    end
    



