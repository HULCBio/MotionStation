function out = horzcat(varargin)
%HORZCAT Horizontal concatenation of device group objects.
%

%   MP 6-25-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/01/16 19:59:51 $


% Initialize variables.
c=[];

% Loop through each java object and concatenate.
for i = 1:nargin
    if ~isempty(varargin{i}),
        if isempty(c),
            % Must be an instrument object otherwise error.
            if ~isa(varargin{i},'icgroup'),
                error('icgroup:horzcat:invalidConcat', 'Device group objects can only be concatenated with other device group objects.')
            end
            c=varargin{i};
        else
            typeForError = char(c.jobject(1).getType);
            
            % Extract needed information.
            try
                info = struct(varargin{i});
                appendJObject = info.jobject;
                appendType     = info.type;
               
                % Verify the object types are the same.
                if mclass(c.jobject(1)) ~= mclass(appendJObject(1))
                    error('icgroup:horzcat:notSameType', 'The device group objects must have the same type.');
                end
            catch
                % Rethrow error from above.
                [msg, id] = lasterr;
                if strcmp(id, 'icgroup:horzcat:notSameType')
                    rethrow(lasterror);
                end

                % This will fail if not an instrument object.
                error('icgroup:horzcat:invalidConcat', 'Device group objects can only be concatenated with other device group objects.')
            end
            
            % Verify that the outputs have the same parent.
            if ~isequal(appendJObject(1).getParent, c.jobject(1).getParent)
                error('icgroup:horzcat:notSameParent', 'The device group objects must have the same parent.');    
            end
            
            % Append the jobject field.
            try
                c.jobject = [c.jobject appendJObject];
            catch
                localCleanupErrorMessage;
                rethrow(lasterror);
            end
            
            % Append the type field.
            if ischar(c.type)
                if ischar(appendType)
                    c.type = {c.type appendType};
                else
                    c.type = {c.type appendType{:}};
                end
            else
                if ischar(appendType)
                    c.type = {c.type{:} appendType};
                else
                    c.type = {c.type{:} appendType{:}};
                end
            end
        end 
    end
end

% Verify that a matrix was not created.
if length(c.jobject) ~= numel(c.jobject)
   error('icgroup:horzcat:nonMatrixConcat', ['Only a row or column vector of device group objects can be created.'])
end

% Output the array of objects.
out = c;

% ------------------------------------------------
function localCleanupErrorMessage

% Initialize variables.
[out, id] = lasterr;

% Remove the "Error using ..." message.
if findstr(out, 'Error using') == 1
    index = findstr(out, sprintf('\n'));
    if (index ~= -1)
        out = out(index+1:end);
    end
end

% Define an ID if one isn't defined.
if isempty(id)
    id = 'icgroup:horzcat:opfailed';
end

% Reset the error and it's id.
lasterr(out, id);
