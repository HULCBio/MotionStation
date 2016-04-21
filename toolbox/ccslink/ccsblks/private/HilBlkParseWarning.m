function [pass, msg, decl] = HilBlkParseWarning(msg)
% Check for expected warning that may occur during
% function constructor or function.declare.
% This warning indicates an unknown typedef and should
% be re-issued as an error for the HIL Block.

% "pass" is false if this warning occurs, and the
% faulty function declaration is returned as "decl".
% "msg" is the error message to be issued by the caller.

% The expected message is:
% A problem occurred while parsing the function declaration:
%   'type1 tgtFunction6(const double scalarVal)'
%   Error is: Type 'type1' cannot be resolved. If a typedef, add 'type1' 
% and its equivalent type to the TYPE list using ADD.
% Use DECLARE to enter the correct function declaration string.

% Copyright 2003-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/08 20:44:45 $

expectedWarning = ['A problem occurred while parsing ' ...
        'the function declaration:'];
if ~isempty(findstr(msg, expectedWarning)),
    % Extract string for error message
    ind = findstr(msg,'If a typedef');
    if isempty(ind),
        ind = findstr(msg,'over-specified type');
    end
    if ~isempty(ind),
        msg = msg(1:(ind(1)-1));
        msg = strrep(msg,'Error is: ','');
        msg = [msg sprintf('\n\n')  ...
                'Please update the block''s type list or ' ...
                'the prototype. ' sprintf('\n\n') ...
                'All data types must be recognized by ' ...
                'Link for Code Composer Studio ' ...
                'and have equivalent Simulink native ' ...
                'data types.'];
    end
    pass = false;
    % Extract declaration from within quotes (')
    ind = findstr(msg,'''');
    if length(ind)>=2,
        decl_start = ind(1);
        decl_end = ind(2);
        decl = msg( (decl_start+1):(decl_end-1) );
        % xxx   Consider checking for \n
    else
        decl = '';
    end
else
    pass = true;
    decl = '';
    % Re-issue the warning
    warning(msg);
end

