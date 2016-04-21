function varname = genvarname(candidate,protected)
%GENVARNAME Construct a valid MATLAB variable name from a given candidate.
%   VARNAME = GENVARNAME(CANDIDATE) returns a valid variable name VARNAME
%   constructed from the string CANDIDATE.  CANDIDATE can be a string or a
%   cell array of strings.
%
%   A valid MATLAB variable name is a character string of letters, digits
%   and underscores, such that the first character is a
%   letter and the length of the string is <= NAMELENGTHMAX.
%
%   If CANDIDATE is a cell array of strings the resulting cell array of
%   strings in VARNAME are guaranteed to be unique from one another.
%
%   VARNAME = GENVARNAME(CANDIDATE, PROTECTED) returns a valid variable
%   name which is unique from the list of PROTECTED names.  PROTECTED may
%   be a string or cell array of strings.
%
%   Examples:
%       genvarname({'file','file'})     % returns {'file','file1'}
%       a.(genvarname(' field#')) = 1   % returns a.field0x23 = 1
%
%       okName = true;
%       genvarname('ok name',who)       % returns a string 'okName1'
%
%   See also ISVARNAME, ISKEYWORD, ISLETTER, NAMELENGTHMAX, WHO, REGEXP.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/09/24 23:35:35 $

% Argument check
error(nargchk(1, 2, nargin, 'struct'))

% Set up protected list if it exists
if nargin < 2
    protected = {};
elseif ~iscell(protected)
    protected = {protected};
end

% Set up inputs for loop
wasChar = true;    % flag to make sure char array is set back to char
if ~iscell(candidate)
    varnameCell = {candidate};
else
    varnameCell = candidate;
    wasChar = false;
end

% Check first input type
if ~isCellString(varnameCell)
    error('MATLAB:genvarname:wrongVarnameType',...
            ['First input argument, VARNAME, must be either a CHAR array '...
            'or a cell array of strings.']);
end


% Check second input type
if ~isCellString(protected)
    error('MATLAB:genvarname:wrongProtectedType',...
        ['Second input argument, PROTECTED, must be either a CHAR array '...
        'or a cell array of strings.']);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over all the candidates in varnameCell to make them valid names
for k = 1:numel(varnameCell)

    varname = varnameCell{k};

    if isvarname(varname) % Short-circuit if varname already legal
        varnameCell{k} = varname;
    elseif isempty(varname) % Make empty 'x'
        varnameCell{k} = 'x';
    else
        % Insert x if the first column is non-letter.
        varname = regexprep(varname,'^\s*+([^A-Za-z])','x$1', 'once');

        % Replace whitespace with camel casing.
        [StartSpaces, afterSpace] = regexp(varname,'\S\s+\S');
        for j=afterSpace
            varname(j) = upper(varname(j));
        end
        varname = regexprep(varname,'\s*','');

        % Replace non-word character with its HEXIDECIMAL equivalent
        illegalChars = unique(varname(regexp(varname,'\W')));
        for illegalChar=illegalChars
            if illegalChar <= intmax('uint8')
                width = 2;
            else
                width = 4;
            end
            replace = ['0x' dec2hex(illegalChar,width)];
            varname = strrep(varname, illegalChar, replace);
        end

        % Prepend keyword with 'x' and camel case.
        if iskeyword(varname)
            varname = ['x' upper(varname(1)) varname(2:end)];
        end

        % Truncate varname to NAMLENGTHMAX
        varname = varname(1:min(length(varname),namelengthmax));

        varnameCell{k} = varname;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following section is to uniquify
numPreceedDups = zeros(length(varnameCell));
for i = 1:length(varnameCell)
    varname = varnameCell{i};
    
    % Calc number of dups with in the candidates
    numPreceedDups(i) = ...
        length(find(strcmp(varname,varnameCell(1:i-1))));

    % Check if candidate dups with the protected
    if any(strcmp(varname,protected))
        numPreceedDups(i) = numPreceedDups(i) + 1;
    end

    % Update the protected to include other candidates that might clash
    protectedAll = {varnameCell{:},protected{:}};

    % See if unique candidate is indeed unique - if not up the
    % numPreceedDups
    if numPreceedDups(i)>0 
        uniqueName = appendNumToName(varname, numPreceedDups(i));
        while any(strcmp(uniqueName, protectedAll))
            numPreceedDups(i) = numPreceedDups(i) + 1;
            uniqueName = appendNumToName(varname, numPreceedDups(i));
        end

        % Replace the candidate with the unique string.
        varnameCell{i} = uniqueName;
    end
end

% Make sure return argument is the right type
if wasChar
    varname = varnameCell{1};
else
    varname = varnameCell;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions to make argument type checking more readable
function isIt = isString(content)
    if ischar(content)
        isIt = isvector(content) || isempty(content);
    else
        isIt = false;
    end
    
function isIt = isCellString(argin)
    if iscell(argin)
        for i = 1:numel(argin)
            if ~isString(argin{i})
                isIt = false;
                return;
            end
        end
        isIt = true;
    else 
        isIt = false;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper to append the unique numer to varname
function uniqueName = appendNumToName(name, num)
    numStr = sprintf('%d',num);
    uniqueName = [name numStr];
    if length(uniqueName) > namelengthmax
        uniqueName = [uniqueName(1:namelengthmax-length(numStr)) numStr];
    end
