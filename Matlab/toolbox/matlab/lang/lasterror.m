function le = lasterror(new_le)
%LASTERROR  Last error message and related information.
%   LASTERROR returns a structure containing the last error message issued by
%   MATLAB as well as other last error-related information. The LASTERROR
%   structure is guaranteed to contain at least the following fields:
%
%       message    : the text of the error message
%       identifier : the message identifier of the error message 
%   
%   LASTERROR(ERR) sets the LASTERROR function to return the information stored
%   in ERR as the last error. The only restriction on ERR is that it must be a
%   structure. Fields in ERR whose names appear in the list above are used as
%   is, while suitable defaults are used for missing fields (for example, if
%   ERR doesn't have an 'identifier' field, then the empty string is used
%   instead).
%
%   LASTERROR is usually used in conjunction with the RETHROW function in
%   TRY-CATCH statements. For example:
%
%       try
%           do_something
%       catch
%           do_cleanup
%           rethrow(lasterror)
%       end
%
%   Note that do_cleanup might optionally take a LASTERROR-type input if the
%   cleanup operation is dependent on what error actually occurred.
%
%   See also ERROR, RETHROW, TRY, CATCH, LASTERR.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1 $ $Date: 2002/01/09 21:45:10 $

if nargin == 0 || nargout > 0
    [le.message, le.identifier] = lasterr;
end

if nargin > 0
    % Update lasterr state with information from new_le.
    if isstruct(new_le)
        if isfield(new_le, 'message');
            message = new_le.message;
        else
            message = '';
        end
        
        if isfield(new_le, 'identifier')
            identifier = new_le.identifier;
        else
            identifier = '';
        end
    else
        error('Input must be a structure.');
    end
    
    lasterr(message, identifier);
end
