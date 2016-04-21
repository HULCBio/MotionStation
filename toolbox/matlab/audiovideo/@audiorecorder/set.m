function output = set(obj,varargin)
%SET Configure or display audiorecorder object properties.
%
%    SET(OBJ) displays property names and their possible values for all 
%    configurable properties of audiorecorder object OBJ. OBJ must be a 1-by-1
%    audiorecorder object.
%
%    PROP_STRUCT = SET(OBJ) returns the property names and their 
%    possible values for all configurable properties of audiorecorder object OBJ. 
%    The return value, PROP_STRUCT, is a structure whose field names are the
%    property names of OBJ, and whose values are cell arrays of possible
%    property values or empty cell arrays if the property does not have a
%    finite set of possible string values.
%
%    SET(OBJ,'PropertyName') displays the possible values
%    for the specified property, PropertyName, of audiorecorder object OBJ. 
%
%    PROP_CELL = SET(OBJ,'PropertyName') returns the possible values
%    for the specified property, PropertyName, of audiorecorder object OBJ. 
%    The returned array, PROP_CELL, is a cell array of possible value strings
%    or an empty cell array if the property does not have a finite set of
%    possible string values.
%
%    SET(OBJ,'PropertyName',PropertyValue,...) configures the property, 
%    PropertyName, to the specified value, PropertyValue, for audiorecorder 
%    object OBJ. You can specify multiple property name/property
%    value pairs in a single statement.
%
%    SET(OBJ,S) configures the properties of OBJ, with the values specified
%    in S, where S is a structure whose field names are object 
%    property names.
%
%    SET(OBJ,PN,PV) configures the properties specified in the cell array  
%    of strings, PN, to the corresponding values in the cell array
%    PV, for the audiorecorder object OBJ. PN must be a vector. 
%
%    Param-value string pairs, structures, and param-value cell array pairs 
%    may be used in the same call to SET.
%
%    Example:
%       r = audiorecorder(22050, 16, 1);
%       set(r) % Display all configurable properties and their possible values
%       set(r, 'Tag', 'My audiorecorder object')
%
%    See also AUDIORECORDER, AUDIORECORDER/GET.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision $  $Date: 2003/12/04 19:01:02 $

if ~isa(obj,'audiorecorder')
    builtin('set',obj,varargin{:})
    return;
end

if ( (nargin==1) && (nargout == 0) ) % e.g., 'set(OBJ)'
    % calling builtin set function
    out = set(obj.internalObj);
    fields = fieldnames(out); % get settable property names
    for lcv=1:length(fields) % foreach property, print line in std. 'set' output
        field = out.(fields{lcv});
        fprintf([blanks(4) fields{lcv}]); % print the prop. name
        if ~isempty(strfind(fields{lcv}, 'Fcn')),
            % We have an '...Fcn' property.
            fprintf(': string -or- function handle -or- cell array\n');
        elseif (isempty(field)) % if field enum values is [], must not be enum; end line here.
            fprintf('\n');
        else
            % list enum values in format [ {default} option2 option3... ]
            fprintf([': ' formatEnum(field) '\n']);
        end
    end
else 
    backTraceState = warning('query','backtrace');
    warning off backtrace;
    [pNames pVals] = getSettableValues(obj); % store off the values in case of error
    try
        if (nargout == 0) % e.g., "set(OBJ,'PN',PV,....)"
            if nargin == 2 && ischar(varargin{1}) % e.g., "set(OBJ,'PN')"
                jObj = obj.internalObj;
                out = set(jObj, varargin{:});
                % Get fully qualified property name.
                hProp = findprop(jObj, varargin{:});
                if ~isempty(strfind(hProp.Name, 'Fcn')),
                    % We have an '...Fcn' property.
                    fprintf('string -or- function handle -or- cell array\n');
                elseif isempty(out),
                    fprintf(audiorecordererror('MATLAB:audiorecorder:propnotenumtype', hProp.Name));
                else
                    fprintf([formatEnum(out) '\n']);
                end
            else
                set(obj.internalObj,varargin{:});
            end
        else % e.g., "OPT=set(OBJ)"
            output = set(obj.internalObj,varargin{:});
        end
    catch
        % restore the original backtrace state
        warning(backTraceState);
        lerr = fixlasterr;
        resetValues(obj,pNames, pVals); % restore previous values upon error
        error(lerr{:});
    end
    % restore the original backtrace state
    warning(backTraceState);
end

function out = formatEnum(field)
out = ['[ {' field{1} '}' ];
for lcv2=2:length(field)
    out = [out ' | ' field{lcv2} ];
end
out = [out ' ]'];
