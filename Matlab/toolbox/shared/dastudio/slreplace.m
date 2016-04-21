function varargout = slreplace(varargin)
%SLREPLACE Performs a search and replace on an object.
%       SLREPLACE( OBJECT, 'SEARCH_EXPR', 'REPLACE_STR' )  replaces all occurances
%           in the specified object
%       SLREPLACE( OBJECT, 'SEARCH_EXPR', 'REPLACE_STR', 'all' )  replaces all
%           occurances in the object hierarchy parented by the specified object
%       OBJECTS = SLREPLACE( OBJECT, 'SEARCH_EXPR', 'REPLACE_STR' )  replaces all occurances
%           in the specified object and returns the object if it was changed
%       OBJECTS = SLREPLACE( OBJECT, 'SEARCH_EXPR', 'REPLACE_STR', 'all' )  replaces all
%           occurances in the object hierarchy parented by the specified object and returns
%           a vector of all the objects changed
%       SLREPLACE  with no arguments opens the interactive Search & Replace tool

%	J Breslau
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:32:21 $

% Parameters:
%   object          The object to search upon
%   searchExpr      The expression(s) to search for
%   replaceStr      The string(s) to replace with
%   replaceScope    'all' to replace all (optional)
% Returns:
%   Vector of objects acted upon

    % set the default response
    objects = [];

    % initialize output
    if nargout==1
        varargout{1} = [];
    elseif nargout>1
        usage_l;
        return;
    end

    switch nargin,
    case 0,
        slsnr;
    case {3, 4}

        % parse the arguments
        object = varargin{1};
        searchExpr = varargin{2};
        replaceStr = varargin{3};

        % flag for 'replace all'
        all = 0;

        % for multiple replaces, a counter
        numReplaces = 0;

        % sanity check on the arguments
        if ~ishandle(object)
            disp('<object> must be a valid handle');
            usage_l;
            return;
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
            else
                disp('fourth parameter can only be ''all''');
                usage_l;
                return;
            end
        end

        % OK, we have legal parameters!

        if numReplaces
            for i = 1:numReplaces
                objects = union(objects, replace_l(object, searchExpr{i}, replaceStr{i}, all));
            end
        else
            objects = replace_l(object, searchExpr, replaceStr, all);
        end

        if nargout==1
            varargout{1} = objects;
        end

    otherwise,
        usage_l;
    end


%---------------------------------------------------------------------------------------
% The meat (or tofu) of the replace wrapper.
% Parameters:
%   object          The object to search upon
%   searchExpr      The expression to search for
%   replaceStr      The string to replace with
%   all             true to replace all
% Returns:
%   Vector of objects acted upon
%---------------------------------------------------------------------------------------
function objects = replace_l(object, searchExpr, replaceStr, all)

    objects = [];

    if all
        top = object;
        while (~isempty(object))
            if slsnr('inner_replace_this', object, searchExpr, replaceStr)
                objects = [objects object];
            end
            object = slsnr('inner_search', object, top, searchExpr);
        end
    else
        if slsnr('inner_replace_this', object, searchExpr, replaceStr)
            objects = object;
        end
    end



%---------------------------------------------------------------------------------------
% Helper function to display the usage string
%---------------------------------------------------------------------------------------
function usage_l
    disp('usage: [objects] = slreplace(<object>, <search expression>, <replace string>, [''all''])');
    