function varargout = info2mask(str, hax)
%INFO2MASK(S) Draws a filter mask specified in the structure S
%   INFO2MASK(S, HAX) Draws a filter mask specified in the structure S to
%   the axes HAX.  If HAX is not specified GCA will be used.  S has the
%   following required fields:
%
%   fs          - This field is the sampling frequency.
%   response    - This field is a string which maps to the valid FVTool
%                 response that can show the masks.
%   bands       - This field contains a cell array of structures.  Each of
%                 these structures specifies information for a single band.
%                 These structures are described below.
%
%   If the response is 'magnitude', the optional field 'magunits' is also
%   required to specify what units the mask will be drawn in.  {'dB',
%   'squared', 'linear', 'zerophase'} are the options.
%
%   Each structure in the bands field of the main structure must have the
%   following fields:
%
%   function    - This field specifies what type of band to draw.  Valid
%                 values are 'pass', 'cpass', 'wpass', 'stop', 'wstop',
%                 'invsinc', and 'rolloff'.  This field determines which
%                 additional fields are necessary.
%   frequency   - This field is a 2 element vector that specifies the range
%                 of the band.
%   filtertype  - This field specifies what type of filter the band
%                 corresponds to.  Valid values are 'lowpass', 'highpass',
%                 'bandpass', and 'bandstop'.
%   properties  - This field is used as additional inputs to the lines
%                 drawn for the mask.  This value must be a cell of
%                 parameter/value pairs.  If this field is not specified {}
%                 is used.
%   
%   Fields for {'pass', 'cpass', 'invsinc'}
%
%   amplitude   - This field specifies how large the ripples are.
%   magunits    - This field specified the magnitude units to draw in.
%   astop       - This field specifies how low to draw the frequency bars.
%
%   Additional Fields for 'invsinc'
%
%   freqfactor  - This field specifies the frequency factor to use when
%                 drawing the inverse sinc part of the passband.
%   sincpower   - This field specifies the power to raise the inverse sinc
%                 part of the passband.
%
%   Fields for {'stop', 'rolloff'}
%
%   amplitude   - This field specifies how much attenuation to illustrate
%   magunits    - This field specifies the magnitude units to draw in.
%
%   Additional Fields for 'rolloff'
%
%   slope       - This field specifies the slope to draw.
%   
%   Fields for {'wstop', 'wpass'}
%
%   weight      - The value of the weight for the band.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/13 00:31:57 $

error(nargchk(1,2,nargin));

if nargin < 2, hax = gca; end

for indx = 1:length(str.bands),
    
    sndx = str.bands{indx};
    
    % Convert the fs and frequency vector to the units used by the axes
    sndx.fs        = lclengunits(hax, str.fs, str.frequnits);
    sndx.frequency = lclengunits(hax, sndx.frequency, str.frequnits);
    sndx.axes = hax; 
    sndx = lclcompletestructure(sndx);
    
    if ~isfield(sndx, 'magfcn'), sndx.magfcn = sndx.freqfcn; end
       
    h{indx} = feval(sndx.magfcn, sndx);
    for jndx = 1:length(h{indx}),
        setappdata(h{indx}(jndx), 'zoomable', 'off');
    end
end

if nargout, varargout = {[h{:}]}; end

% ----------------------------------------------------------------------
function h = pass(str)

% drawpass expects an amplitude of min and max
if length(str.amplitude) == 1,
    str.amplitude = str.amplitude*[.5 -.5];
end
if strcmpi(str.magunits, 'linear'),
    str.amplitude = 1+str.amplitude*2;
end
str = fixupastop(str);

h = drawpass(str);

% ----------------------------------------------------------------------
function h = wpass(str)

% Make sure that magunits are 'weights' and that the patches are not drawn.
str.drawpatch = false;
str.magunits  = 'weights';
str.amplitude = [1 1];
str.astop     = 0;

h = drawpass(str);

% Add the weight label
if isfield(str, 'weight'),
    h(end+1) = text(mean(str.frequency),1-.05,...
        ['(' num2str(str.weight) ')'], ...
        'Parent', str.axes);
end

% ----------------------------------------------------------------------
function h = cpass(str)

if strcmpi(str.magunits, 'squared'),
    str.amplitude = [str.amplitude 1];
    str.astop = 0;
else
    str.amplitude = [0 -str.amplitude];
    str = fixupastop(str);
end

h = drawpass(str);

% ----------------------------------------------------------------------
function h = wstop(str)

str.magunits  = 'weights';
str.drawpatch = false;
str.amplitude = 0;

h = stop(str);

% Add the weight label
if isfield(str, 'weight'),
    h(end+1) = text(mean(str.frequency),.05,...
        ['(' num2str(str.weight) ')'], ...
        'Parent', str.axes);
end

% ----------------------------------------------------------------------
function h = stop(str)

F     = str.frequency;
A     = str.amplitude;
Astop = str.astop;
hax   = str.axes;
props = str.properties;

% If no tag is supplied use 'stop';
if ~isfield(str, 'tag'), tag = 'stop'; 
else,                    tag = str.tag; end

% The height of the frequency bars for a stop band are 1/2 the maximum
% attenuation.  Calculate the top based on this.
if strcmpi(str.magunits, 'db'), Amax = -A/2; A = -A;
else,                           Amax = mean([1,A]); end

Fm = F;
if length(A) > 1,
    Fm = [Fm NaN Fm];
    Am = [A(1) A(1) NaN A(2) A(2)];
else
    Am = [A A];
end
Af    = [A Amax];
plot2 = false;

switch lower(str.filtertype)
    case 'lowpass'
        Ff   = [F(1) F(1)];
        tag1 = [tag 'freq'];
    case 'highpass'
        Ff   = [F(2) F(2)];
        tag1 = [tag 'freq'];
    case 'bandstop'
        Ff    = [F(1) F(1)];
        Ff2   = [F(2) F(2)];
        tag1  = [tag 'freq1'];
        plot2 = true;
    otherwise
        % There is no stopband for bandpass.  it just uses lowpass and
        % highpass for its stopbands (since they can have different Apass
        % values).
end

h = [];

% if str.drawpatch,
%     Fp   = [F fliplr(F)];
%     h(end+1) = lclpatch(hax, Fp, [A A Amax Amax]);
% end

h(end+1) = line(Fm, Am, ...
    'Parent', hax, ...
    'Color', 'red', ...
    'Tag', [tag 'mag'], ...
    'LineStyle', '--', ...
    props{:});

if str.drawfreqbars,
    h(end+1) = line(Ff, Af, ...
        'Parent', hax, ...
        'Color', 'red', ...
        'Tag', tag1, ...
        'LineStyle', '--', ...
        props{:});
    if plot2,
        h(end+1) = line(Ff2, Af, ...
            'Parent', hax, ...
            'Color', 'red', ...
            'LineStyle', '--', ...
            'Tag', [tag 'freq2'], ...
            props{:});
    end
end

% ----------------------------------------------------------------------
function h = aline(str)

F     = str.frequency;
A     = str.amplitude;
hax   = str.axes;

h = line(F, A, 'Parent', hax, str.properties{:});

% ----------------------------------------------------------------------
function h = rolloff(str)

h = stop(str);

slope = str.slope;
fs    = str.fs;
F     = str.frequency;

% If the magunits are not dB convert the slope, which is always specified
% in decibels.
if ~strcmpi(str.magunits, 'db') & str.slope ~= 0,
    slope = 10^(slope/20);
end

y = get(h(1), 'YData');
switch lower(str.filtertype)
    case 'highpass'
        y(1) = y(1)-slope*F(2)/(fs/2);
    case 'lowpass'
        y(end) = y(end)-slope*(fs/2-F(1))/(fs/2);
end
set(h(1), 'YData', y);

% ----------------------------------------------------------------------
function h = invsinc(str)

F     = str.frequency;
A     = str.amplitude;
Astop = str.astop;
hax   = str.axes;
Fs    = str.fs;
C     = str.freqfactor;
p     = str.sincpower;

switch lower(str.filtertype)
    case 'lowpass'
        f = linspace(0, F/(Fs/2), 1000);
        P = isinc(C*f).^p;
        f = f*(Fs/2);
        str.frequency = [0 F];
    case 'highpass'
        f = linspace(0, (Fs/2-F)/(Fs/2), 100);
        P = isinc(C*f).^p;
        f = Fs/2-f*(Fs/2);
        str.frequency = [F Fs/2];
    otherwise
        error('%s is not a valid filtertype for inverse sinc.', filtertype);
end

if strcmpi(str.magunits, 'db'), tweak = 5; P = 20*log10(P);
else,                           tweak = .1; A = 2*A; end
uppr = P+A/2;
lowr = P-A/2;

xdata = [f NaN f];
ydata = [uppr NaN lowr];

% Draw a normal pass band
h = pass(str);

% Change the lines to be invsinc
hf = findobj(h, 'tag', 'passfreq');
hm = findobj(h, 'tag', 'passmag');
set(hm, 'Xdata', xdata, 'YData', ydata);
set(hf, ...
    'Ydata', [lowr(end) min(get(hf, 'YData')) NaN uppr(end) uppr(end)+tweak]);

% Change the patches to be invsinc
htop = findobj(h, 'tag', 'passtop');
hbot = findobj(h, 'tag', 'passbottom');

topy = get(htop, 'ydata');
boty = get(hbot, 'ydata');

switch lower(str.filtertype)
    case 'lowpass'
        
        set(htop, ...
            'XData', [min(f) min(f) f max(f)], ...
            'YData', [uppr(end)+tweak min(topy) uppr uppr(end)+tweak]);
        
        set(hbot, ...
            'XData', [min(f) min(f) f max(f)], ...
            'YData', [min(boty) max(boty) lowr min(boty)]);
    case 'highpass'
        set(htop, ...
            'XData', [min(f) max(f) max(f) f], ...
            'YData', [uppr(end)+tweak uppr(end)+tweak min(topy) uppr]);
        
        set(hbot, ...
            'XData', [min(f) max(f) max(f) f], ...
            'YData', [min(boty) min(boty) max(boty) lowr]);
end

% ----------------------------------------------------------------------
function h = drawpass(str)

if ~isfield(str, 'tag'), tag = 'pass'; 
else,                    tag = str.tag; end

F     = str.frequency;
A     = str.amplitude;
Astop = str.astop;
hax   = str.axes;
props = str.properties;

% Get the x and y for the magnitude
Fm    = [F NaN fliplr(F)];
Am    = [A(1) A(1) NaN A(2) A(2)];

% get the y for the freqbars
Af    = [min(A) Astop];
plot2 = false;

% Get the x for the freqbars depending on the filter type
switch lower(str.filtertype)
    case 'lowpass'
        tag1 = [tag 'freq'];
        Ff   = [F(2) F(2)];
    case 'highpass'
        tag1 = [tag 'freq'];
        Ff   = [F(1) F(1)];
    case 'bandpass'
        tag1 = [tag 'freq1'];
        Ff   = [F(1) F(1)];
        Ff2  = [F(2) F(2)];
        plot2 = true;
    otherwise
        % There is no passband for bandstop.  it just uses lowpass and
        % highpass as its passband (since they can have different Apass
        % values).
end

h = [];

Fp   = [F fliplr(F)];

topPa = [max(A) max(A)];
switch lower(str.magunits)
    case 'db'
        topPa = [topPa topPa+Astop/10];
        Ff    = [Ff NaN Ff];
        Af    = [Af NaN max(A) + [0 -Astop/10]];
        if plot2,
            Ff2 = [Ff2 NaN Ff2];
        end
    case 'weights'
        %NO OP
    otherwise % squared or linear
        topPa = [topPa topPa+.1];
        Ff    = [Ff NaN Ff];
        Af    = [Af NaN max(A) + [0 .1]];
        if plot2,
            Ff2 = [Ff2 NaN Ff2];
        end
end

% % Only draw the patches if they are requested (they are by default)
% if str.drawpatch,
%     h(end+1) = lclpatch(hax, Fp, [Astop Astop min(A) min(A)], 'tag', 'passbottom');
%     h(end+1) = lclpatch(hax, Fp, topPa, 'tag', 'passtop');
% end

h(end+1) = line(Fm, Am, ...
    'Parent', hax, ...
    'Tag', [tag 'mag'], ...
    'LineStyle', '--', ...
    'Color', 'red', ...
    props{:});

if str.drawfreqbars,
    
    h(end+1) = line(Ff, Af, ...
        'Parent', hax, ...
        'Tag', tag1, ...
        'Color', 'red', ...
        'LineStyle', '--', ...
        props{:});
    
    if plot2,
        h(end+1) = line(Ff2, Af, ...
            'Parent', hax, ...
            'COlor', 'red', ...
            'Tag', [tag 'freq2'], ...
            'LineStyle', '--', ...
            props{:});
    end
end

% ----------------------------------------------------------------------
%   Utility Functions
% ----------------------------------------------------------------------

% ----------------------------------------------------------------------
function h = lclpatch(hax, F, A, varargin)

h = patch(F, A, [.8 .8 .8],  ...
    'Parent', hax, 'EdgeColor', 'none', ...
    'FaceAlpha', .5, 'FaceColor', [.85 .85 .85], ...
    'HitTest', 'Off', varargin{:});


% ----------------------------------------------------------------------
function str = lclcompletestructure(str)

if ~isfield(str, 'axes'), str.axes = gca; end

field = {'filtertype', 'drawpatch', 'magunits', ...
        'astop', 'fs', 'properties', 'drawfreqbars'};
value = {'lowpass', true, 'db', -60, 2, {}, true};

for indx = 1:length(field)
    if ~isfield(str, field{indx}),
        str.(field{indx}) = value{indx};
    end
end

% ----------------------------------------------------------------------
function y = isinc(x)
% Inverse-sinc function

x = x*pi;
y = ones(size(x));
i = find(x & sin(x));
y(i) = (x(i))./sin(x(i));

% ----------------------------------------------------------------------
function str = fixupastop(str)

% Make sure that the Astop goes all the way to the bottom.
ylim = get(str.axes, 'YLim');
if min(ylim) < str.astop,
    str.astop = min(ylim);
end
d = max(diff(get(str.axes, 'YTick')));
str.astop = sign(str.astop)*d*ceil(abs(str.astop/d));

% ----------------------------------------------------------------------
function F = lclengunits(hax, F, funits)

if isappdata(hax, 'EngUnitsFactor'),
    m = getappdata(hax, 'EngUnitsFactor');
else
    m = 1;
end

% if strncmpi(funits, 'Normalized', 10),
    F = F*m;
% else
%     F = convertfrequnits(F*m, funits, 'Hz');
% end

% [EOF]
