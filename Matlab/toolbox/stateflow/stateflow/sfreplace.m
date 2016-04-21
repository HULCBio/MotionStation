function varargout = sfreplace(varargin)
%SFREPLACE Performs a search and replace on an object.
%       SFREPLACE( OBJECT_HANDLE, 'SEARCH_EXPR', 'REPLACE_STR' )  replaces all occurances 
%           in the specified object
%       SFREPLACE( OBJECT_HANDLE, 'SEARCH_EXPR', 'REPLACE_STR', 'all' )  replaces all 
%           occurances in the object hierarchy parented by the specified object
%       IDS = SFREPLACE( OBJECT_HANDLE, 'SEARCH_EXPR', 'REPLACE_STR' )  replaces all occurances 
%           in the specified object and returns the object handle if it was changed
%       IDS = SFREPLACE( OBJECT_HANDLE, 'SEARCH_EXPR', 'REPLACE_STR', 'all' )  replaces all 
%           occurances in the object hierarchy parented by the specified object and returns
%           a vector of all the ids changed
%       SFREPLACE  with no arguments opens the interactive Search & Replace tool

%	J Breslau
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.9.2.1 $  $Date: 2004/04/15 01:01:46 $

% Parameters:
%   id              The object id to search upon
%   searchExpr      The expression(s) to search for
%   replaceStr      The string(s) to replace with
%   replaceScope    'all' to replace all (optional)
% Returns:
%   Vector of object IDs acted upon

    % set the default response
    ids = []; 

    % initialize output
    if nargout==1
        varargout{1} = [];
    elseif nargout>1
        usage_l;
        return;
    end

    switch nargin,
    case 0,
        sf('Private', 'sfsnr');
    case {3, 4}

        MACHINE = sf('get', 'default','machine.isa');
        CHART = sf('get', 'default','chart.isa');

        % parse the arguments
        id = varargin{1};
        searchExpr = varargin{2};
        replaceStr = varargin{3};

        % the type of object referenced by id
        type = 0;

        % flag for 'replace all'
        all = 0;        

        % for multiple replaces, a counter
        numReplaces = 0;
        
        % sanity check on the arguments
        if ~isnumeric(id)
            disp('<id> must be numeric');
            usage_l;
            return;
        else
            if isempty(sf('Private', 'filter_deleted_ids', id))
                disp('Replace object not found');        
                return;
            end
            type = sf('get', id, '.isa');
        end

        if iscell(searchExpr)
            numReplaces = length(searchExpr);
            if ~iscell(replaceStr) | length(replaceStr) ~= numReplaces
                disp('<search expression> and <replace string> must be the same size');
                usage_l;
                return
            end
            for i = 1:numReplaces
                if ~ischar(searchExpr{i})
                    disp('all <search expression>s must be strings');
                    usage_l;
                    return;
                end

                if ~ischar(replaceStr{i})
                    disp('all <replace string>s must be strings');
                    usage_l;
                    return;
                end
            end
        else
            if ~ischar(searchExpr)
                disp('<search expression> must be a string');
                usage_l;
                return;
            end
            if ~ischar(replaceStr)
                disp('<replace string> must be a string');
                usage_l;
                return;
            end
        end

        if nargin == 4
            if strcmp(varargin{4}, 'all')
                all = 1;
                if ~(type == MACHINE | type == CHART)
                    disp('Replace all only valid for ids of type chart or machine');
                    return;
                end
            else
                disp('fourth parameter can only be ''all''');
                usage_l;
                return;
            end
        end

        % OK, we have legal parameters!

        if numReplaces
            for i = 1:numReplaces
                ids = union(ids, replace_l(id, searchExpr{i}, replaceStr{i}, type, all));
            end
        else
            ids = replace_l(id, searchExpr, replaceStr, type, all);
        end

        if nargout==1
            varargout{1} = sort(ids);
        end

    otherwise,
        usage_l;
    end


%---------------------------------------------------------------------------------------
% The meat (or tofu) of the replace wrapper.
% Parameters:
%   id              The object id to search upon
%   searchExpr      The expression to search for
%   replaceStr      The string to replace with
%   type            The type of object id is
%   all             true to replace all
%---------------------------------------------------------------------------------------
function ids = replace_l(id, searchExpr, replaceStr, type, all)

    MACHINE = sf('get', 'default','machine.isa');

    ids = [];

    if all
        top = id;
        while (id)
            if sf('Private', 'sfsnr', 'inner_replace_this', id, searchExpr, replaceStr, type)
                ids = [ids id];
            end
            id = sf('Private', 'sfsnr', 'inner_search', id, top, searchExpr);
            type = sf('get', id, '.isa');
        end
    else
        if sf('Private', 'sfsnr', 'inner_replace_this', id, searchExpr, replaceStr, type)
            ids = id;
        end
    end



%---------------------------------------------------------------------------------------
% Helper function to display the usage string
%---------------------------------------------------------------------------------------
function usage_l
    disp('usage: [ids] = sfreplace(<id>, <search expression>, <replace string>, [''all''])');
    