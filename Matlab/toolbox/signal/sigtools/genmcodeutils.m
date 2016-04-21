function str = genmcodeutils(fcn, varargin)
%GENMCODEUTILS Formats a string for use with generated M-code
%   GENMCODEUTILS(FCN, STR, VARARGIN) Format STR using the function FCN.
%
%   FORMATLONGSTRING(STR, SPACETOKEN, ESPACE) format the string STR to be
%   less than 80 characters wide by adding new line feeds preceded by '...'
%   after commas or spaces.  SPACETOKEN is a character which will determine
%   how far inset the extra lines are by its index in the first line.  If
%   this is not passed in no extra spaces are added.  ESPACE is a number
%   which adds extra spaces in addition to those from SPACETOKEN.
%
%   FORMATPARAMS(PARAMS, VALUES, DESCS) format the cells of strings PARAMS,
%   VALUES, and DESCS so that "PARAMS{:} = VALUES{:};  % DESCS{:}" and the
%   '=' and '%' line up.  The cell arrays must all be of the same length,
%   but DESCS can have empty entries in it.  In this case a local map will
%   be used which will determine the description from the parameter name.
%
%   EXAMPLE:
%   % #1
%   params = {'N', 'Fpass', 'Fstop'};
%   values = {'8', '9600', '12000'};
%
%   % When all parameters can be mapped, the descriptions are not needed.
%   genmcodeutils('formatparams', params, values)
%
%   % #2
%   params = {params{:}, 'interp'};
%   values = {values{:}, '10'};
%   descs  = {'', '', '', 'Interpolation Factor'};
%
%   genmcodeutils('formatparams', params, values, descs)

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2004/04/13 00:31:53 $

str = feval(fcn, varargin{:});

% ------------------------------------------------------------------
function str = formatlongstring(str, spacetoken, extraspace)

if nargin > 1,
    
    % Get the first spacingtoken index
    eqindx  = min(findstr(str, spacetoken));
    if nargin > 2, eqindx = eqindx + extraspace; end
    
    eqspace = repmat(' ', 1, eqindx);
else
    eqspace = '';
end

cellstr = {str};

% Loop over the cell of strings, chop off the extra strings and move them
% to the next value in the cell.
while length(cellstr{end}) > 80,
    
    indx = findtokenindex(cellstr{end});
    
    % Remove leading spaces
    while strcmpi(cellstr{end}(indx+1), ' '),
        cellstr{end}(indx+1) = [];
    end
    
    % Make sure there is ONE space after the token.
    if strcmpi(cellstr{end}(indx), ','),
        cellstr{end} = [cellstr{end}(1:indx) ' ' cellstr{end}(indx+1:end)];
        indx = indx + 1;
    end
    
    cellstr = {cellstr{1:end-1}, ...
            sprintf('%s...', cellstr{end}(1:indx)), ...
            sprintf('%s%s', eqspace, cellstr{end}(indx+1:end))};
end

str = sprintf('%s\n', cellstr{:});
str(end) = [];

% ------------------------------------------------------------------
function str = formatparams(params, values, descs)

lv = length(values);

if nargin < 3,
    descs = cell(size(params));
end

if lv ~= length(params) | lv ~= length(descs)
    error(generatemsgid('lengthMismatch'), ...
        'Parameters, values and descriptions must be the same length.');
end

% Look for empty descriptions and fill them in from the map
for indx = 1:length(descs),
    if isempty(descs{indx}),
        descs{indx} = lclmap(params{indx});
    end
end

for indx = 1:lv
    values{indx} = [values{indx} ';'];
end

tempstr = [strvcat(params) repmat(' = ', lv, 1) strvcat(values)];

% If any of the strings is already over 50 characters we need to move that
% line to the bottom of the list and make its comment on the above line.
if size(tempstr, 2) > 50,
    
    % Break out the strings and deblank them so we can see which is over 50
    % characters
    ondx = []; % overflow index
    for indx = 1:size(tempstr, 1),
        cellstr{indx} = deblank(tempstr(indx, :));
        if length(cellstr{indx}) > 50,
            ondx = [ondx, indx];
        end
    end
    
    % Divide the over and under strings and their descriptions
    overstrs   = cellstr(ondx);
    overdescs  = descs(ondx);
    understrs  = setdiff(cellstr, overstrs);
    underdescs = setdiff(descs, overdescs);
    
    % All of the under strings can just be combined with their descriptions
    tempstr = [strvcat(understrs) repmat('  % ', length(understrs), 1) strvcat(underdescs)];
    
    % The over strings have their descriptions on the line above the
    % variable declaration.
    for indx = 1:length(overstrs),
        overstrs{indx} = sprintf('\n%% %s\n%s', overdescs{indx}, ...
            formatlongstring(overstrs{indx}, '=', 2));
    end
    
    tempstr = strvcat(tempstr, overstrs{:});
    
else
    tempstr = [tempstr repmat('  % ', lv, 1) strvcat(descs)];
end

str = '';
for indx = 1:size(tempstr,1)
    str = sprintf('%s\n%s', str, deblank(tempstr(indx,:)));
end
str(1) = [];

% -------------------------------------------------------------------------
function v = array2str(v, prec)

if nargin < 2, prec = 11; end

[r c] = size(v);

if r > 1
    if c > 1
        
        for indx = 1:r
            cstr{indx} = array2str(v(indx, :), prec);
        end
        
        cstr{1}(end) = [];
        for indx = 2:r-1
            cstr{indx}(1)   = ' ';
            cstr{indx}(end) = [];
        end
        cstr{end}(1) = ' ';

        v = sprintf('%s\n', cstr{:});
        v(end) = [];
        
    else
        cstr{1} = sprintf('[%s', array2str(v(1), prec));
        for indx = 2:r
            cstr{indx} = sprintf(' %s', array2str(v(indx), prec));
        end
        cstr{end} = sprintf('%s]', cstr{end});
        v = sprintf('%s\n', cstr{:});
        v(end) = [];
    end
else
    if c > 1,
        cstr = cell(1, length(v));
        
        for indx = 1:c
            cstr{indx} = [array2str(v(indx), prec) ' '];
        end
        
        v = ['[' deblank([cstr{:}]) ']'];
    else
        v = num2str(v, prec);
    end
end


% -------------------------------------------------------------------------
function s = formatnumplace(n, str)

error(nargchk(1,2,nargin))

if nargin < 2, str = 'partial'; end

switch str
    case 'partial'
        if n > 4 && n < 20,
            s = sprintf('%dth', n);
        else
            switch rem(n, 10)
                case 1,    s = sprintf('%dst', n);
                case 2,    s = sprintf('%dnd', n);
                case 3,    s = sprintf('%drd', n);
                otherwise, s = sprintf('%dth', n);
            end
        end
    case 'full'
        switch rem(n, 10)
            case 1, s = '-first';
            case 2, s = '-second';
            case 3, s = '-third';
            case 4, s = '-fourth';
            case 5, s = '-fifth';
            case 6, s = '-sixth';
            case 7, s = '-seventh';
            case 8, s = '-eighth';
            case 9, s = '-ninth';
            case 0, s = 'th';
        end
        
        % Get the 10s place
        switch rem(floor(n/10), 10)
            case 1
                % Special case
                switch rem(n, 100)
                    case 11,   s = ' eleventh';
                    case 12,   s = ' twelfth';
                    case 13,   s = ' thirteenth';
                    otherwise, s = strrep(s, 'th', 'teenth');
                end
            otherwise
                s = gettens(n, s);
        end
        
        if rem(n,10) == 0 && rem(n,100) > 19, s(end-2) = 'i'; end
        
        if n > 99
            s = gethundreds(n, s);
            if n > 999
                s = getthousands(n, s);
            end
        end
        
        s(1) = [];
    otherwise
        error(generatemsgid('invalidArgument'), 'Unrecognized option %s', str);
    end

% -------------------------------------------------------------------------
function str = formatcellstr(cstr)

str = sprintf('{%s}', sprintf('''%s'', ', cstr{:}));

% Get rid of the extra comma.
str(end-2:end-1) = [];

% -------------------------------------------------------------------------
%   Utility Functions
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
function indx = findtokenindex(str)

% Find the last comma before where we want to put the carriage return.
indx = findstr(str, ',');
indx = indx(find(indx < 77));

if isempty(indx), indx = 0; end

mindx = max(indx);

%
if mindx < 60,
    sindx = findstr(str, ' ');
    sindx = sindx(find(sindx < 77));
    
    % If the space is more than 15 characters towards 80 use it.
    if max(sindx) > mindx + 15
        indx = max(sindx);
    else
        indx = mindx;
    end
else
    indx = mindx;
end

% -------------------------------------------------------------------------
function desc = lclmap(param)
%Map the known parameter names to their descriptions.

indx = regexp(param, '\d');

% Only handles a single number.
if isempty(indx),
    pre = '';
else
    switch str2num(param(indx))
        case 1
            pre = 'First ';
        case 2
            pre = 'Second ';
        case 3
            pre = 'Third ';
        case 4
            pre = 'Fourth ';
    end
end

param(indx) = [];
if length(param) > 5,
    switch param(end)
        case 'L'
            pre = sprintf('%sLower ', pre);
            param(end) = [];
        case 'U'
            pre = sprintf('%sUpper ', pre);
            param(end) = [];
    end
end

switch lower(param)
    case 'n'
        desc = 'Order';
    case 'nb'
        desc = 'Numerator Order';
    case 'na'
        desc = 'Denominator Order';
    case 'apass'
        desc = 'Passband Ripple (dB)';
    case 'dpass'
        desc = 'Passband Ripple';
    case 'astop'
        desc = 'Stopband Attenuation (dB)';
    case 'dstop'
        desc = 'Stopband Attenuation';
    case 'fpass'
        desc = 'Passband Frequency';
    case 'fstop'
        desc = 'Stopband Frequency';
    case 'fc'
        desc = 'Cutoff Frequency';
    case 'fs'
        desc = 'Sampling Frequency';
    case 'fo'
        desc = 'Original Frequency';
    case 'ft'
        desc = 'Target Frequency';
    case 'wpass'
        desc = 'Passband Weight';
    case 'wstop'
        desc = 'Stopband Weight';
    case 'f'
        desc = 'Frequency Vector';
    case 'a'
        desc = 'Amplitude Vector';
    case 'w'
        desc = 'Weight Vector';
    case 'r'
        desc = 'Ripple Vector';
    case 'e'
        desc = 'Frequency Edges';
    case 'g'
        desc = 'Group Delay Vector';
    case 'dens'
        desc = 'Density Factor';
    case 'in'
        desc = 'Initial Numerator';
    case 'id'
        desc = 'Initial Denominator';
    case 'l'
        desc = 'Band';
    case 'bw'
        desc = 'Bandwidth';
    case 'q'
        desc = 'Q-factor';
    otherwise
        desc = '';
end

desc = sprintf('%s%s', pre, desc);

% --------------------------------------------------------------
function s = getthousands(n, s)

switch rem(floor(n/1000), 1000)
    case 0
    otherwise
        s = gethundreds(floor(n/1000), ...
            gettens(floor(n/1000), ...
            getones(floor(n/1000), sprintf('-thousand%s', s))));
end

% --------------------------------------------------------------
function s = gethundreds(n, s)

switch rem(floor(n/100), 10)
    case 0
    otherwise
        s = getones(rem(floor(n/100), 10), sprintf('-hundred%s', s));
end

% --------------------------------------------------------------
function s = gettens(n, s)

switch rem(floor(n/10), 10)
    case 1, s = sprintf(' ten%s', s);
    case 2, s = sprintf(' twenty%s', s);
    case 3, s = sprintf(' thirty%s', s);
    case 4, s = sprintf(' forty%s', s);
    case 5, s = sprintf(' fifty%s', s);
    case 6, s = sprintf(' sixty%s', s);
    case 7, s = sprintf(' seventy%s', s);
    case 8, s = sprintf(' eighty%s', s);
    case 9, s = sprintf(' ninety%s', s);
end

% --------------------------------------------------------------
function s = getones(n, s)

switch rem(n, 10)
    case 1, s = sprintf(' one%s', s);
    case 2, s = sprintf(' two%s', s);
    case 3, s = sprintf(' three%s', s);
    case 4, s = sprintf(' four%s', s);
    case 5, s = sprintf(' five%s', s);
    case 6, s = sprintf(' six%s', s);
    case 7, s = sprintf(' seven%s', s);
    case 8, s = sprintf(' eight%s', s);
    case 9, s = sprintf(' nine%s', s);
end

% [EOF]
