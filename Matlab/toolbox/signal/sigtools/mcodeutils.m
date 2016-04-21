function str = mcodeutils(fcn, varargin)

str = feval(fcn, varargin{:});

% ------------------------------------------------------------------

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/13 00:32:03 $
function str = formatlongstring(str, token, spacetoken, extraspace)

if nargin < 3, token = ' '; end

if nargin > 3,
    
    % Get the first spacingtoken index
    eqindx  = min(findstr(str, spacetoken));
    if nargin > 4, eqindx = eqindx + extraspace; end
    eqspace = repmat(' ', 1, eqindx);
else
    eqspace = '';
end

cellstr = {str};

% Loop over the cell of strings, chop off the extra strings and move them
% to the next value in the cell.
sindx = findstr(cellstr{end}, token);
while max(sindx) > 80,
    mindx = sindx(min(find(sindx > 75)));
    cellstr = {cellstr{1:end-1}, ...
            sprintf('%s...', cellstr{end}(1:mindx)), ...
            sprintf('%s%s', eqspace, cellstr{end}(mindx+1:end))};
    sindx = findstr(cellstr{end}, token);
end

str = sprintf('%s\n', cellstr{:});

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
            formatlongstring(overstrs{indx}, ' ', '=', 2));
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
function desc = lclmap(param)

switch lower(param)
    case 'n'
        desc = 'Order';
    case 'nb'
        desc = 'Numerator Order';
    case 'na'
        desc = 'Denominator Order';
    case {'apass', 'apass1', 'apass2'}
        desc = 'Passband Ripple (dB)';
    case {'dpass', 'dpass1', 'dpass2'}
        desc = 'Passband Ripple';
    case {'astop', 'astop1', 'astop2'}
        desc = 'Stopband Attenuation (dB)';
    case {'dstop', 'dstop1', 'dstop2'}
        desc = 'Stopband Attenuation';
    case {'fpass', 'fpass1', 'fpass2'}
        desc = 'Passband Frequency';
    case {'fstop', 'fstop1', 'fstop2'}
        desc = 'Stopband Frequency';
    case {'fc', 'fc1', 'fc2'}
        desc = 'Cutoff Frequency';
    case 'fs'
        desc = 'Sampling Frequency';
    case 'fo'
        desc = 'Original Frequency';
    case 'ft'
        desc = 'Target Frequency';
    case {'wpass', 'wpass1', 'wpass2'}
        desc = 'Passband Weight';
    case {'wstop', 'wstop1', 'wstop2'}
        desc = 'Stopband Weight';
    case 'f'
        desc = 'Frequency Vector';
    case 'a'
        desc = 'Amplitude Vector';
    case 'w'
        desc = 'Weight Vector';
    case 'e'
        desc = 'Frequency Edges';
    case 'g'
        desc = 'Group Delay Vector';
    case 'dens'
        desc = 'Density Factor';
    case 'in'
        desc = 'Initial Denominator';
    case 'id'
        desc = 'Initial Numerator';
    case 'l'
        desc = 'Band';
    case 'bw'
        desc = 'Bandwidth';
end

indx = str2num(param(end));
if ~isempty(indx),
    if indx == 1,
        desc = sprintf('First %s', desc);
    else
        desc = sprintf('Second %s', desc);
    end
end
