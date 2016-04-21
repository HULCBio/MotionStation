function convertedFrequency = convertfrequnits(varargin)
%CONVERTFREQUNITS converts between Normalized, Hz, kHz, etc
%   CONVERTFREQUNITS(FREQUENCY, FS, PREVIOUSUNITS, CURRENTUNITS, ALLUNITS) has inputs
%   FREQUENCY the frequency to be converted
%   FS              the sampling frequency (only needed if going to 
%                   or from Normalized units) is should be empty otherwise
%   PREVIOUSUNITS   the units in which FREQUENCY was given
%   CURRENTUNITS    the new units to convert to
%   ALLUNITS        is either a cell array of possible frequencies or the distance
%                   between the previous and current units given as an integer
%
%   Valid calls are:
%   CONVERTFREQUNITS(FREQUENCY, PREVIOUSUNITS, CURRENTUNITS, ALLUNITS)
%   CONVERTFREQUNITS(FREQUENCY, ALLUNITS) (where ALLUNITS is the distance between the units)
%
%   Example(s)
%   % converts 8000 by 10^(3*-1) (from 'hz' to 'khz')
%   cf = convertfrequnits(8000,-1) % Returns 8
%   
%   % converts 8000 from 'hz' to 'mhz' given the options in the cell array
%   cf = convertfrequnits(8000,'hz','mhz',{'hz','khz','mhz','ghz'}) % returns 0.008 (double)
%
%   % converts the string '8000' from 'hz' to 'mhz' given the options in the cell array
%   cf = convertfrequnits('8000','hz','mhz',{'hz','khz','mhz','ghz'}) % returns 0.008 (char)
%
%   % converts a cell array of strings 10^(3*-2) from 'hz' to 'mhz'
%   cf = convertfrequnits({'8000','9000'},'hz','mhz',-2) % returns '0.008'    '0.009' (cell)
%
%   % converts the mixed cell array from 'hz' to mhz' based on the cell array of possible units
%   cf = convertfrequnits({8000,'9000','myfs'},...
%       'hz','mhz',{'hz','khz','mhz','ghz'}) % returns  [0.0080]    '0.009'    'myfs' (cell)

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/04/13 00:31:30 $

% Parse the inputs
[Frequency, Fs, Previous, Current, All, err] = parse_inputs(varargin{:});
error(err)

% If normalized units are involved then check to see if Fs is non-empty
if strncmpi(Previous,'norm',4)
    temp = norm2hz(Frequency, Fs);
    convertedFrequency = convertbetween(temp, 'hz', Current, All);
elseif strncmpi(Current, 'norm', 4)
    temp = convertbetween(Frequency, Previous, 'hz', All);
    convertedFrequency = hz2norm(temp, Fs);
else
    convertedFrequency = convertbetween(Frequency, Previous, Current, All);
end


%---------------------------------------------------------------------------
function Normalized = hz2norm(Frequency, Fs)
%HZ2NORM converts frequencies from Hz to Normalized (0 to 1)
%   HZ2NORM(FREQUENCY, FS) Converts FREQUENCY to Norm based on FS
%   All Units must be in Hertz

Normalized = Local_HzNormConverter(Frequency, Fs, '2Norm');


%---------------------------------------------------------------------------
function Frequency = norm2hz(Normalized, Fs)
%NORM2HZ converts frequencies from Normalized to Hz
%   NORM2HZ(NORMALIZED, FS) Converts NORMALIZED to Frequency based on FS
%   All Units must be in Hertz

Frequency = Local_HzNormConverter(Normalized, Fs, '2Hz');


%-------------------------------------------------------------------------------
function convertedFrequency = Local_HzNormConverter(inputFrequency, Fs, direction)
%NORM2HZ converts frequencies from Normalized to Hz
%   NORM2HZ(NORMALIZED, FS) Converts NORMALIZED to Frequency based on FS
%   All Units must be in Hertz

% Check if Fs is empty since it is required for conversions involving
% normalized units
if isempty(Fs)
    error('Converting to or from normalized units requires that FS be specifed')
end


if strncmpi(direction,'2Norm',3)
    toNorm = logical(1);
elseif strncmpi(direction,'2Hz',3)
    toNorm = logical(0);
end

if isa(Fs,'char')
    Fs = str2num(Fs);
end

if ~isa(inputFrequency,'cell') & ~isa(inputFrequency,'double') & ~isa(inputFrequency,'char')
    error('Valid data types are ''cell'', ''double'' and ''char''')
end

% Determine the datatype of the frequency to be converted and switch on datatype
inputDataType = class(inputFrequency);
switch inputDataType,
    
case 'double',
    if toNorm,
        % If converting to normalized, divide by Fs/2
        convertedFrequency = inputFrequency./(Fs/2);
    else
        % If converting to Hz multiply by Fs/2 (or divide by 2/Fs)
        convertedFrequency = inputFrequency./(2/Fs);
    end
    
case 'char',
    temp = str2double(inputFrequency);
    if isempty(temp) | isnan(temp)
        % This means that the string has no double representation, just send it back
        convertedFrequency = inputFrequency;
    else
        % If a double representation exists, continue on
        inputFrequency = temp;
        temp = Local_HzNormConverter(inputFrequency,Fs,direction);
        convertedFrequency = num2str(temp);
    end
    
case 'cell',
    for n = 1:length(inputFrequency)
        convertedFrequency{n} = Local_HzNormConverter(inputFrequency{n},Fs,direction);
    end
    
end


%-------------------------------------------------------------------------------
function ConvertedFs = convertbetween(Frequency, Pu, Cu, Opts)
%CONVERTBETWEEN converts frequencies the specified units
%   CONVERTBETWEEN(FREQUENCY,PU,CU,OPTS)
%   Converts FREQ from PU (which is the units in which FREQ is given)
%   to CU based on the optional input list of all possible units
%   
%   FREQUENCY should be a cell array of frequencies
%   PU is the previous units given as a string
%   CU is the current units given as a string
%   OPTS is either a cell array of Possible units or is the distance
%   between the Previous and Current units

% Determine the distance between the units or check to see if given
if isa(Opts,'cell')
    PI = find(strcmpi(Pu,Opts));
    CI = find(strcmpi(Cu,Opts));
    dist = PI - CI;
elseif isa(Opts,'double')
    dist = Opts;
else
    error('OPTS should be a cell array of strings or a double')
end

if isa(Frequency,'double')
    ConvertedFs = Frequency.*power(10,dist*3);
elseif isa(Frequency,'char')
    strFrequency = str2double(Frequency);
    if ~isempty(strFrequency) & ~isnan(strFrequency)
        temp = strFrequency*power(10,dist*3);
        ConvertedFs = num2str(temp);
    else
        ConvertedFs = Frequency;
    end
elseif isa(Frequency,'cell')
    % Place holder in case of cell array
    for i = 1:length(Frequency)
        temp = convertbetween(Frequency{i}, Pu, Cu, Opts);
        ConvertedFs{i} = temp;
    end
else
    ConvertedFs = [];
end


%-------------------------------------------------------------------------------
function [freq,fs,pu,cu,au,err] = parse_inputs(varargin)

% The possible combinations are:
% 5 inputs: All
% 4 inputs: freq, pu, cu, au
% 2 inputs: freq, au(dist)
% 

err = '';

freq = varargin{1};

switch nargin
case 2
    fs = [];
    pu = '';
    cu = '';
    au = varargin{2};
case {3, 4}
    fs = [];
    pu = varargin{2};
    cu = varargin{3};
    if nargin > 3,
        au = varargin{4};
    else
        au = {'hz', 'khz', 'mhz', 'ghz'};
    end
case 5
    fs = varargin{2};
    pu = varargin{3};
    cu = varargin{4};
    au = varargin{5};
end

if strncmpi(pu,'norm',4) | strncmpi(cu,'norm',4)
    if isempty(fs)
        if isempty(err)
            err = 'Converting to or from normalized units requires that FS be specifed';
        end
    end
end

% [EOF]
