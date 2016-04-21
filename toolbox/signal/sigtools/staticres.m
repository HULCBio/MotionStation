function staticres(hax, filtType, filtMethod, activeFrames)
%STATICRESP Renders the static responses for the Filter Design & Analysis GUI.
%   HAX         -   Handle of the axes into which to plot the static response
%   FREQUNITS   -   The freqUnits of the current filter
%   MAGUNITS    -   The magUnits of the current filter
%   FILTORDTYPE -   The filter order mode
%   FILTTYPE    -   The filter type
%   FILTMETHOD  -   The filter method
%   
%   MAGUNITS is a string taking on any of the following values 'db' 'linear' 'squared' 'weights'
%   FILTORDTYPE is a string taking on one of two possible values 'specify' or 'minimum'


%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.4 $  $Date: 2004/04/13 00:32:50 $ 

% Test for valid filter type, return if filter type is not vaild
if (filterNotValid(filtType))
    notavalmessage(hax,filtType);
    return
end

% For FIRCEQRIP special cases need developing.
% Add the frequency specification type
if strcmp(filtMethod,'firceqrip'),
    filtType = concatenateFreqSpecType(activeFrames, filtType);
end

freqUnits = localGetFreqUnits(activeFrames);
magUnits  = localGetMagUnits(activeFrames);
filtOrdType = getmode(activeFrames);

% Use lower case for comparisons.
freqUnits = lower(freqUnits);
magUnits = lower(magUnits);

% Set up axis, tick marks, tick labels, etc.
[xlim,ylim] = setupAxis(hax,magUnits,freqUnits, filtMethod);

% Label X- and Y-axis with proper units.
xyUnits(hax,magUnits,freqUnits,xlim,ylim);

if strcmpi(filtMethod, 'cremez')
    switch filtType
        case 'lp'
            filtType = 'bp';
        case 'hp'
            filtType = 'bs';
    end
end

% Draw the ideal filter response
fc = idealFilterRes(hax,filtType, filtMethod, filtOrdType);

% Draw the filter response forbidden regions 
constraints = filterConstraints(hax,filtType,fc,filtMethod, filtOrdType, activeFrames);

% Draw a static filter response.
%drawFilterMagResp(hax,filtType,filtMethod);

% Draw arrows and display text indicating passband ripple stopband
% attenuation etc.
annotate(hax,filtType,constraints,magUnits,freqUnits,filtMethod, filtOrdType)


%--------------------------------------------------------------------------
function notValid = filterNotValid(filtType)
% FILTERNOTVALID returns 1 if the filter method is not valid, 0 if the filter type
% is valid. 
%
% Inputs:
%     filtMethod   - the filter design method being used, cheby1, butter etc.
% Outputs:
%     notValid   - 1 if the filter design method is not valid

switch filtType
case {'lp','hp','bp','bs','diff','multiband', 'hilb', 'arbitrarymag','arbitrarygrp',...
			'halfbandlp','halfbandhp','nyquist','rcos','invsinclp','invsinchp','notch','peak'}
    notValid = false;
otherwise
    notValid = true;
end

%--------------------------------------------------------------------------
function [xlim,ylim] = setupAxis(hax,magUnits,freqUnits,filtMethod)
% SETUPAXIS Sets up the Axis for the static filter response drawing.
% Inputs:
%	hax		- handle to the axis
%	magUnits 	- units of the magnitude axis
%	freqUnits	- units of the frequency axis
%
% Outputs:
%   xlim        - the limits of the x axis
%   ylim        - the limits of the y axis

% Make the Y- and X-axis a little longer to make room for the arrow head.
xlim = [0 1.1];
ylim = [0 1.7];

% Setup the X-axis properties.
[xtick,xticklabel] = xaxis_props(freqUnits);

% Setup the Y-axis; magnitude units, etc.
[ytick,yticklabel] = yaxis_props(magUnits);

if strcmpi(filtMethod, 'cremez'),
    xzero = .51;
    xticklabel{1} = sprintf('-%s', xticklabel{end});
else
    xzero = .01;
end

%Set up axis 
set(hax,...
    'Color','white',...
    'Xlim',xlim,...
    'Ylim',ylim,...
    'Xtick',xtick,...
    'Xticklabel',xticklabel,...
    'Ytick',ytick,...
    'Yticklabel',yticklabel,...
    'Box','off',...
    'Clipping','off',...
    'Layer','Top',...
    'Plotboxaspectratio',[2 .8 1])

% Draw arrow heads at the end of the X- and Y-axis.
w = .015;
h = .08;
arrow_w_line(hax,[0 0],[ylim(2) ylim(2)],w,h,'up')
arrow_w_line(hax,[xlim(2) xlim(2)],[0 0],w,h,'right')

% Place a 0 to mark the 0 frequency
text(xzero,-.1,'0','Parent',hax);

%--------------------------------------------------------------------------
function [xtick,xticklabel] = xaxis_props(freqUnits)
% XAXIS_PROPS Returns the X tick marks and X tick labels depending on the
% units of the frequency.
% Inputs:
%	freqUnits	- units of the frequency axis
% Outputs:
%
%   xtick       - the location of the x tick
%   xticklabel  - the label of the x tick

% Place ticks at the unit and half way point
xtick = [0 1];

switch freqUnits
case {'hz','khz','mhz','ghz'},
    xticklabel = {'','Fs/2'};
case 'normalized (0 to 1)'
    xticklabel = {'','1'};
end

%--------------------------------------------------------------------------
function [ytick,yticklabel] = yaxis_props(magUnits)
% YAXIS_PROPS Returns the Y tick marks and Y tick labels depending on the
% units of the magnitude.
% Inputs:
%   magUnits	-units of the magnitude axis
% Outputs:
%   ytick       - the location of the y tick
%   yticklabel  - the label of the y tick

ytick = [];
yticklabel = '';
switch lower(magUnits)
case 'db',
    ytick = [-1 1];
    yticklabel = [0];
    
case 'linear',
    ytick = [.5 1];
    yticklabel = [.5 1];
    
case 'squared'
    ytick = [0 1];  
    yticklabel = [0 1];
end

%--------------------------------------------------------------------------
function xyUnits(hax,magUnits,freqUnits,xlim,ylim)
% XYUNITS Puts the labels on the Axes
% Inputs:
% hax			- handle to the axis
% magUnits		- units of the magnitude
% freqUnits             - units of the frequency
% xlim			- limit of the x axis
% ylim			- limit of the y axis


switch freqUnits
case 'hz',
    xaxStr = 'f (Hz)';
    yaxStr = '|H(f)|';
    
case 'khz',
    xaxStr = 'f (kHz)';
    yaxStr = '|H(f)|';
    
case 'mhz',
    xaxStr = 'f (MHz)';
    yaxStr = '|H(f)|';
    
case 'ghz'
    xaxStr = 'f (GHz)';
    yaxStr = '|H(f)|';
    
case 'normalized (0 to 1)',
    xaxStr = '\omega (normalized)';
    yaxStr = '|H(\omega)|';
    % Shift xlim over a little bit, for this case only
    % because "normalized" is longer than "Hz"
    xlim(2) = xlim(2) - .05;
    
end

switch magUnits
case 'db',
    yaxStr = 'Mag. (dB)';
case 'squared',
    yaxStr = [yaxStr,'^2'];
end

% Label X-axis units.
text(xlim(2),-.1,xaxStr,'Parent',hax);

% Label Y-axis units.
text(.015,ylim(2)-.1,yaxStr,'Parent',hax);

%--------------------------------------------------------------------------
function constraint(hax,x,y,faceColor,eraseMode)
% CONSTRAINT Draws a gray patch indicating where the filter response should
% not be.
%
% Inputs:
% 	hax 		- handle to the axis
%	x    		- X coordinates for the patch
%	y		    - Y coordinates for the patch
%	faceColor	- the color of the patch
%	eraseMode 	- the eraseMode of the patch

if nargin < 4,
    faceColor = get(0,'defaultuicontrolbackgroundcolor') * 1.07;
    faceColor(faceColor > 1) = 1;
    eraseMode = 'background';
end
if nargin < 5,
    eraseMode = 'background';
end
panpatch = patch(x,y, ...
    [.8 .8 .8],...
    'erasemode', eraseMode, ...
    'facecolor',faceColor,...
    'edgecolor','black',...
    'Parent',hax);

%--------------------------------------------------------------------------
function fc = idealFilterRes(hax,filtType, filtMethod, filtOrdType)
% IDEALFILTERRES Renders an ideal magnitude filter response, if neccessary, using a 
%                dotted line. Returns the ideal cutoff frequencies for a given filter type
% Inputs:
%   hax          - handle to the axis
%   type         - filter type (lowpass, higpass, etc.).
%   filtMethod   - the filter design method being used, butter, cheyb1 etc...
%   filtOrdType  - the filter order type, minimum or specify order
% Outputs:
%   fc	         -cuttoff frequency.

% Assigning arbitrary values for the cutoff frequencies
% For low pass and high pass filters, Fc = .45
% For bandpass and bandstop filters, Fc1 = 1/3 and Fc2 = 2/3

switch filtType
case {'lp','lpcutoff','lppassedge','lpstopedge'},
    fc(1) = .45;
    fc(2) = 0; % Not needed
    idealFiltResMag =  [1 1     1     0];
    idealFiltResFreq = [0 fc(1) fc(1) fc(1)];    
case {'hp','hpcutoff','hppassedge','hpstopedge'},
    fc(1) = .45;
    fc(2) = 0; % Not needed
    idealFiltResMag =  [0     1     1     1];
    idealFiltResFreq = [fc(1) fc(1) fc(1) 1];   
case 'bp',   
    fc(1) = 1/3;
    fc(2) = 2/3;
    idealFiltResMag =  [0     1     1     0];
    idealFiltResFreq = [fc(1) fc(1) fc(2) fc(2)];    
case 'peak'
    fc(1) = .45;
    fc(2) = .55;
    idealFiltResMag =  [0     1     1     0];
    idealFiltResFreq = [fc(1) fc(1) fc(2) fc(2)];    
case 'bs',  
    fc(1) = 1/3;
    fc(2) = 2/3;
    idealFiltResMag =  [1 1     0     0     1 1 ];
    idealFiltResFreq = [0 fc(1) fc(1) fc(2) fc(2) 1];    
    
    % These filter types don't use constaints
    % Assigning zero values as stubs.
case 'notch'
    fc(1) = .45;
    fc(2) = .55;
    idealFiltResMag =  [1 1     0     0     1 1 ];
    idealFiltResFreq = [0 fc(1) fc(1) fc(2) fc(2) 1];    
    
case 'diff',
    fc(1) = 0;
    fc(2) = 0;
    idealFiltResMag = 0;
    idealFiltResFreq = 0;
case 'hilb',
    fc(1) = 0;
    fc(2) = 0; 
    idealFiltResMag = 0;
    idealFiltResFreq = 0;
case 'multiband', 
    fc(1) =  0;
    fc(2) = 0; 
    idealFiltResMag = 0;
    idealFiltResFreq = 0;
case 'arbitrarymag',
    fc(1) = 0;
    fc(2) = 0;
    idealFiltResMag = 0;
    idealFiltResFreq = 0;
case {'halfbandlp','rcos'},
	fc(1) = .5;
    fc(2) = 0; % Not needed
    idealFiltResMag =  [1 1     1     0];
    idealFiltResFreq = [0 fc(1) fc(1) fc(1)];
case 'halfbandhp',
	fc(1) = .5;
    fc(2) = 0; % Not needed
    idealFiltResMag =  [0 1 1     1];
    idealFiltResFreq = [fc(1) fc(1) fc(1) 1];
case 'nyquist',
	fc(1) = .25;
    fc(2) = 0; % Not needed
    idealFiltResMag =  [1 1     1     0];
    idealFiltResFreq = [0 fc(1) fc(1) fc(1)];   
otherwise
    fc(1) = 0;
    fc(2) = 0;
    idealFiltResMag = 0;
    idealFiltResFreq = 0;
end

% Plot the ideal response, if the filter does not have a cutoff frequency
if(filterHasCutoff(filtType,filtMethod, filtOrdType))
    hl = line(idealFiltResFreq , idealFiltResMag,...
        'Parent',hax,...
        'LineStyle',':');
end

%-------------------------------------------------------------------------
function hasCutoff = filterHasCutoff(filtType,filtMethod, filtOrdType, activeFrames)
% FILTERHASCUTOFF Returns 1 if the filter has a cutoff frequency, 0 if the filter
% has band edges
%
% Inputs:
%   filterMethod   - the filter design method being used, butter, cheby1, cheby2 etc...
%   filtOrdType    - the order type of the filter, minimum or specify order.
% Output:
%  hasCutoff       - 1 if the filter has a cutoff, 0 it has band edges

switch filtType,
case {'nyquist'},
	hasCutoff = 1;
otherwise,
	% Remez and Firls filters do not have cutoff frequencies
	if any(strcmpi(filtMethod, {'cremez', 'remez','firls'}))
        hasCutoff = 0;
		
		% This can be determined for all other filter types based on the order type  
    elseif any(strcmpi(filtMethod, {'iirmaxflat', 'firmaxflat'}))
        hasCutoff = 1;
    elseif strcmpi(filtMethod,'firceqrip')
        if strcmpi(filtType(3:end),'cutoff')
            hasCutoff = 1;
        else
            hasCutoff = 0;
        end
    elseif any(strcmpi(filtType, {'notch', 'peak'}))
        hasCutoff = 0;
	else
		switch filtOrdType
		case 'specify', hasCutoff = 1;
		case 'minimum',  hasCutoff = 0;
		end    
	end
end

%--------------------------------------------------------------------------
function constraints = filterConstraints(hax,filterType, fc, filtMethod, filtOrderType, activeFrames)
% CONSTRAINTS Draws gray boxes to illustrate the constrained regions
% of the filter, based on the filter type.
%
% Inputs:
%   hax         - handle to the axis
%   filterType	- the type of filter being drawn
%   fc          - the cutoff frequencies for the filter being drawn
%   filtMethod  - the filter method being used, butter, remez, etc...
%
% Outputs:
%   constraints - a structure constaining all of the frequency and amplitude restraints

% Set up the band edges
constraints = setBandEdges(hax,filterType, fc);

% Add the Amplitude Edges
constraints = setAmplitudeEdges(constraints,filtMethod);

% Draw constrained regions (using patches)
drawRegions(hax, filterType, constraints, fc, filtOrderType, filtMethod);


%--------------------------------------------------------------------------

function constraints = setBandEdges(hax,filterType, fc)
% SETBANDCONSTRAINTS defines the band edges based on the filter type
%
% Inputs:
%   filterType - Filter type being drawn(lowpass, highpass, etc...)
%   hax        - Handle to the axis
% Output:
%   constraints - a structure containing all of the band edges

switch filterType
case {'lp','lpcutoff','lppassedge','lpstopedge'},
    constraints.passbandEdge = fc(1)-.05;   % Frequency edges
    constraints.stopbandEdge = fc(1)+.05;
    constraints.passband_leftEdge = 0;
    constraints.stopband_rightEdge = 1;
    constraints.passbandEdge1 = [];
    constraints.stopbandEdge1 = [];
    
case {'hp','hpcutoff','hppassedge','hpstopedge'},
    constraints.passbandEdge = fc(1)+.05;   % Frequency edges
    constraints.stopbandEdge = fc(1)-.05;
    constraints.passband_leftEdge = 1;
    constraints.stopband_rightEdge = 0;
    constraints.passbandEdge1 = [];
    constraints.stopbandEdge1 = [];
    
    
case 'bp',       
    constraints.stopband_leftEdge = 0;  	% Frequency Edges
    constraints.stopbandEdge = fc(1) -.05;
    constraints.passbandEdge = fc(1) +.05;
    constraints.passbandEdge1 = fc(2) -.05;
    constraints.stopbandEdge1 = fc(2) +.05;
    constraints.stopband_rightEdge = 1;
    
case 'peak'
    constraints.stopband_leftEdge = 0;  	% Frequency Edges
    constraints.stopbandEdge = fc(1) -.01;
    constraints.passbandEdge = fc(1) +.01;
    constraints.passbandEdge1 = fc(2) -.01;
    constraints.stopbandEdge1 = fc(2) +.01;
    constraints.stopband_rightEdge = 1;
case 'bs',  
    constraints.passband_leftEdge = 0;  	% Frequency Edges
    constraints.passbandEdge = fc(1)-.05;
    constraints.stopbandEdge = fc(1) +.05;
    constraints.stopbandEdge1 = fc(2) -.05;
    constraints.passbandEdge1 = fc(2) +.05;
    constraints.passband_rightEdge = 1;
    
    % Some These have not yet been implemented. Assigning arbitrary values so 
    % that staticresp will not error out in case they are referenced
case 'notch'
    constraints.passband_leftEdge = 0;  	% Frequency Edges
    constraints.passbandEdge = fc(1)-.01;
    constraints.stopbandEdge = fc(1) +.01;
    constraints.stopbandEdge1 = fc(2) -.01;
    constraints.passbandEdge1 = fc(2) +.01;
    constraints.passband_rightEdge = 1;
case 'diff',
    constraints.passbandEdge = [];
    constraints.stopbandEdge = [];
    constraints.stopbandEdge1 = [];
    constraints.passbandEdge1 = [];
    constraints.passband_rightEdge = [];
    
case 'hilb',
    constraints.passbandEdge = 0;
    constraints.stopbandEdge = 0;
    constraints.stopbandEdge1 = 0;
    constraints.passbandEdge1 = 0;
    constraints.passband_rightEdge = 0;
    
case 'multiband',
    constraints.passbandEdge = 0;
    constraints.stopbandEdge = 0;
    constraints.stopbandEdge1 = 0;
    constraints.passbandEdge1 = 0;
    constraints.passband_rightEdge = 0;
    
case 'arbitrarymag',
    constraints.passbandEdge = 0;
    constraints.stopbandEdge = 0;
    constraints.stopbandEdge1 = 0;
    constraints.passbandEdge1 = 0;
    constraints.passband_rightEdge = 0;
case {'halfbandlp','nyquist','rcos'}
	constraints.passbandEdge = fc(1)-.05;   % Frequency edges
    constraints.stopbandEdge = fc(1)+.05;
    constraints.passband_leftEdge = 0;
    constraints.stopband_rightEdge = 1;
    constraints.passbandEdge1 = [];
    constraints.stopbandEdge1 = [];
case 'halfbandhp',
	constraints.passbandEdge = 1;   % Frequency edges
    constraints.stopbandEdge = 0;
    constraints.passband_leftEdge = fc(1)+.05;
    constraints.stopband_rightEdge = fc(1)-.05;
    constraints.passbandEdge1 = [];
    constraints.stopbandEdge1 = [];
otherwise
    constraints.passbandEdge = 0;
    constraints.stopbandEdge = 0;
    constraints.stopbandEdge1 = 0;
    constraints.passbandEdge1 = 0;
    constraints.passband_rightEdge = 0;  
end

% Asssign fc to constraints
constraints.fc = fc;

%---------------------------------------------------------------------------------------

function constraints = setAmplitudeEdges(constraints,filtMethod)
% SETAMPLITUDEEDGES Adds the amplitude edges to the filter constraints
%
% Inputs:
%  constraints - a structure containing only the frequency edges
%  filMethod   - the method used to design the filter being drawn, butter, cheby1 etc...
% Outputs:
%  constraints - a structure containins the frequency and amplitude edges

% The maximum passband will be higher for FIR filters, the amplitude is not constrained
if(~amplitudeIsContrained(filtMethod))
    constraints.passbandMax = 1.25; % Amplitude edges 
else  
    %IIR Filters
    constraints.passbandMax = 1.15;     
end
constraints.passbandMin = 0.9;
constraints.stopbandMax = .1;

% Height of constrained area in passband and in stopband.
constraints.dy = .15;
%---------------------------------------------------------------------------------
function isConstrained = amplitudeIsContrained(filtMethod)
% AMPLITDUEISCONSTRAINED Returns 1 if the filter has a constrained magnitude(the magnitude
% of the filter cannot be greater than 1).
% 
% Inputs:
%    filtMethod    - the filter design method being used, butter, cheby1 etc..
% Outputs:
%    isConstrained - 1 if the amplitde is constrained, 0 otherwise

if any(strcmpi(filtMethod,{'remez','fir1','firls','firceqrip','ifir','gremez','fircband','fircls'}))
    isConstrained = 0;
else 
    isConstrained = 1;
end

%---------------------------------------------------------------------------------
function drawRegions(hax,filterType,constraints,fc, filtOrderType, filtMethod)
% DRAWREGIONS draws the appropriate constrained region, based on filter type
%
% Inputs:
%    hax         - handle to the axis
%    filterType  - the type of filter being drawn
%    constraints - structure containing all of the frequency and amplitude edges
%    fc          - the cutoff frequency of the filter

switch filterType,
case {'lp','lpcutoff','lppassedge','lpstopedge'}, drawLowHigh(hax,constraints);    
case {'hp','hpcutoff','hppassedge','hpstopedge'}, drawLowHigh(hax,constraints);    
case 'bp', drawBandpass(hax,constraints);    
case 'bs', drawBandstop(hax,constraints);
case 'notch', 
    drawBandstop(hax,constraints); 
    constraints.stopbandEdge = constraints.passbandEdge1;
    drawTransitionBandwidth(hax, constraints);
case 'peak', 
    drawBandpass(hax,constraints); 
    constraints.stopbandEdge = constraints.passbandEdge1;
    drawTransitionBandwidth(hax, constraints);
    
case 'diff',drawDiff(hax);
case 'hilb',drawHilb(hax);
case 'multiband', drawMultiBand(hax);
case 'arbitrarymag',drawArbMag(hax, filtMethod);    
case 'arbitrarygrp', drawArbGrp(hax);
case 'halfbandlp', drawHalfbandlp(hax,constraints);
case 'halfbandhp', drawHalfbandhp(hax,constraints);
case 'nyquist', drawNyquist(hax,constraints,filtOrderType, filtMethod);
case 'rcos', drawRcos(hax,constraints);
end

%--------------------------------------------------------------------------------
function drawLowHigh(hax,C)
% DRAWLOWHIGH	Draws the constraints for low pass and high pass filters
% Inputs:
%
%   hax	  - handle to the axis
%   C     - structure containing the frequency and band edges(constraints)


% Passband upper limit
xd = [C.passband_leftEdge C.passbandEdge C.passbandEdge C.passband_leftEdge];
yd = [C.passbandMax-C.dy  C.passbandMax-C.dy C.passbandMax  C.passbandMax];
constraint(hax,xd,yd);
whiteOut(hax,xd,yd,'stopband');

% Passband lower limit
xd = [C.passband_leftEdge C.passbandEdge C.passbandEdge C.passband_leftEdge ];
yd = [0 0  C.passbandMin C.passbandMin];
constraint(hax,xd,yd);
whiteOut(hax,xd,yd,'passband');

% Stopband attenuation
xd = [C.stopband_rightEdge C.stopbandEdge C.stopbandEdge C.stopband_rightEdge];
yd = [C.stopbandMax C.stopbandMax  C.stopbandMax+C.dy  C.stopbandMax+C.dy ];
constraint(hax,xd,yd);
whiteOut(hax,xd,yd,'stopband');

%------------------------------------------------------------------------------
function drawBandpass(hax, C)
% DRAWBANDPASS Draws the constraints for a bandpass filter
%
% Inputs:
%   hax	 - handle to the axis
%   C    - a structure containing all of the frequency and band edges(contraints)

% Right stopband lower limit 
xd = [C.stopband_leftEdge C.stopbandEdge C.stopbandEdge C.stopband_leftEdge];
yd = [C.stopbandMax C.stopbandMax C.stopbandMax+C.dy C.stopbandMax+C.dy];
constraint(hax,xd,yd);
whiteOut(hax,xd,yd,'stopband');

% Pass band lower limit
xd = [C.passbandEdge C.passbandEdge1 C.passbandEdge1 C.passbandEdge];
yd = [ 0 0 C.passbandMin C.passbandMin];
constraint(hax,xd,yd);

% Pass band upper limit
xd = [C.passbandEdge C.passbandEdge1 C.passbandEdge1 C.passbandEdge];
yd = [C.passbandMax C.passbandMax C.passbandMax-C.dy C.passbandMax-C.dy];
constraint(hax,xd,yd);
whiteOut(hax,xd,yd,'passband');

% left stopband lower limit
xd = [C.stopbandEdge1  C.stopband_rightEdge C.stopband_rightEdge C.stopbandEdge1];
yd = [C.stopbandMax C.stopbandMax C.stopbandMax+C.dy C.stopbandMax+C.dy];
constraint(hax,xd,yd);
whiteOut(hax,xd,yd,'stopband'); 
%-------------------------------------------------------------
function drawBandstop(hax,C)
% DRAWBANDSTOP Draw the constrints for a bandstop filter
% 
% Inputs:
%   hax	 - handle to the axis
%   C    - a structure containing all of the frequency and band edges(constraints)

% Right passband lower limit
xd = [C.passband_leftEdge C.passbandEdge C.passbandEdge C.passband_leftEdge];
yd = [0 0 C.passbandMin C.passbandMin];
constraint(hax,xd,yd);

% Right passband upper limit
xd = [C.passband_leftEdge C.passbandEdge C.passbandEdge C.passband_leftEdge];
yd = [C.passbandMax C.passbandMax C.passbandMax-C.dy C.passbandMax-C.dy];
constraint(hax,xd,yd);
whiteOut(hax,xd,yd,'passband');
% stopband lower limit

xd = [C.stopbandEdge C.stopbandEdge1 C.stopbandEdge1 C.stopbandEdge];
yd = [C.stopbandMax C.stopbandMax C.stopbandMax+C.dy C.stopbandMax+C.dy];
constraint(hax,xd,yd);
whiteOut(hax,xd,yd, 'stopband');

% Left passband lower limit   
xd = [C.passbandEdge1 C.passband_rightEdge C.passband_rightEdge C.passbandEdge1];
yd = [0 0 C.passbandMin C.passbandMin];
constraint(hax,xd,yd);

% Left passband upper limit
xd = [C.passbandEdge1 C.passband_rightEdge C.passband_rightEdge C.passbandEdge1];
yd = [C.passbandMax C.passbandMax C.passbandMax-C.dy C.passbandMax-C.dy];
constraint(hax,xd,yd);
whiteOut(hax,xd,yd,'passband');
%-----------------------------------------------------------------------------------
function drawDiff(hax)
% DRAWDIFF Draws the static response for the differentiator filter.
% Inputs:
%   hax           - handle to the axis

% width and height of arrows
w = .01;
h = .07;

% Arbitrary Frequency and magnitude vector, taken from the the default filter

freqVec = [0 .5 .55 1];
magVec = [0 1 0 0 ];

% Draw the response, two options, a line or a gray region:

% Line
%hl = line(freqVec, magVec,'Parent',hax);

% Gray Region
constraint(hax,freqVec,magVec);

% Draw the legend
drawLegend(hax,1);

% Annotate

% Draw the frequency labels
text(0,-.3,'f_{1}', 'Parent',hax);
for i = 2:length(freqVec)-1 
    text(freqVec(i),0, '|','Parent',hax);
    text(freqVec(i),-.3,['f_{',num2str(i),'}'], 'Parent',hax);
end

% Draw the amplitude labels
text(freqVec(1)-.1,magVec(1)+.1,'A_{1}','Parent',hax);
arrow_w_line(hax,[-.07 0],[0 0],w,h,'right');

text(freqVec(2)-.1,magVec(2)+.1,'A_{2}','Parent',hax);
arrow_w_line(hax,[freqVec(2)-.1,freqVec(2)],[1 1],w,h,'right');

text(freqVec(3)+.1,magVec(3)+.1,'A_{3}','Parent',hax);
arrow_w_line(hax,[freqVec(3)+.08,freqVec(3)],[.1 0],w,h,'left');

text(freqVec(4)-.05,magVec(4)+.1,'A_{4}','Parent',hax);
arrow_w_line(hax,[freqVec(4),freqVec(4)],[.2 0],w,h,'down');

% Draw the Weight labels
text(.25,.75, 'W_{1}', 'Parent',hax);
text(.75,.15,'W_{2}','Parent',hax);

%------------------------------------------------------------------------------
function drawHilb(hax)
% DRAWHILB Draws the static response for the Hilber filter
% Inputs: 
%   hax          - handle to the axis

% width and height of arrows
w = .01;
h = .07;

% Arbitrary Frequency and magnitude vector, taken from the the default filter
freqVec = [0 0.05 0.95 1];
magVec =  [0 1 1 0];


% Gray Region
constraint(hax,freqVec,magVec);

% Annotate

% Draw the frequency labels
for i = 2:length(freqVec)-1 
    text(freqVec(i),0, '|','Parent',hax);
    text(freqVec(i),-.3,['f_{',num2str(i-1),'}'], 'Parent',hax);
end

% Draw the amplitude labels
text(freqVec(2),magVec(2)+.25,'A_{1}','Parent',hax);
arrow_w_line(hax,[freqVec(2),freqVec(2)],[1.2 1],w,h,'down');

text(freqVec(3)+.1,magVec(3)-.1,'A_{2}','Parent',hax);
arrow_w_line(hax,[freqVec(3)+.1,freqVec(3)],[1 1],w,h,'left');


% Draw the Weight labels
text(.5,1.1, 'W_{1}', 'Parent',hax);

% Draw the legend
drawLegend(hax,1);

%--------------------------------------------------------------------------------
function drawMultiBand(hax)
% DRAWMULTIBAND Draws the static response for the multiband filter
% Inputs: 
%   hax          - handle to the axis

% width and height of arrows
w = .01;
h = .07;

% Arbitrary Frequency and magnitude vector, taken from the the default filter
freqVec = [0 .28 .3 .48 .5 .69 .7 .8 .81 1];
magVec = [0 0 1 1 0 0 1 1 0 0];

% Gray Region
constraint(hax,freqVec,magVec);

% Annotate

% Draw the frequency labels
text(0,-.3,'f_{1}', 'Parent',hax);
text(freqVec(2)-.03,-.3,'f_{2}', 'Parent',hax);
text(freqVec(3)+.03,-.3,'f_{3}', 'Parent',hax);
text(freqVec(4)-.03,-.3,'f_{4}', 'Parent',hax);
text(freqVec(5)+.03,-.3,'f_{5}', 'Parent',hax);
text(freqVec(6)-.03,-.3,'f_{6}', 'Parent',hax);
text(freqVec(7)+.03,-.3,'f_{7}', 'Parent',hax);
text(freqVec(8)-.03,-.3,'f_{8}', 'Parent',hax);
text(freqVec(9)+.03,-.3,'f_{9}', 'Parent',hax);

for i = 2:length(freqVec)-1 
    text(freqVec(i),0, '|','Parent',hax);
end

% Draw the amplitude labels and arrows
text(freqVec(1)-.1,magVec(1)+.1,'A_{1}','Parent',hax);
arrow_w_line(hax,[-.07 0],[0 0],w,h,'right');

text(freqVec(2)-.1,magVec(2)+.2,'A_{2}','Parent',hax);
arrow_w_line(hax,[freqVec(2)-.1,freqVec(2)],[.1 0],w,h,'right');

text(freqVec(3)-.05,magVec(3)+.1,'A_{3}','Parent',hax);
arrow_w_line(hax,[freqVec(3)-.075,freqVec(3)],[ 1, 1],w,h,'right');

text(freqVec(4)+.01,magVec(4)+.1,'A_{4}','Parent',hax);
arrow_w_line(hax,[freqVec(4)+.075,freqVec(4)],[1 1],w,h,'left');

text(freqVec(5)+.025,magVec(5)+.2,'A_{5}','Parent',hax);
arrow_w_line(hax,[freqVec(5)+.05,freqVec(5)],[.1 0],w,h,'left');

text(freqVec(6)-.05,magVec(6)+.2,'A_{6}','Parent',hax);
arrow_w_line(hax,[freqVec(6)-.07,freqVec(6)],[.1 0],w,h,'right');

text(freqVec(7)-.05,magVec(7)+.1,'A_{7}','Parent',hax);
arrow_w_line(hax,[freqVec(7)-.075,freqVec(7)],[ 1 1],w,h,'right');

text(freqVec(8)+.01,magVec(8)+.1,'A_{8}','Parent',hax);
arrow_w_line(hax,[freqVec(8)+.075,freqVec(8)],[1 1],w,h,'left');

text(freqVec(9)+.05,magVec(9)+.2,'A_{9}','Parent',hax);
arrow_w_line(hax,[freqVec(9)+.1,freqVec(9)],[.1 0],w,h,'left');



% Draw the weights
text(.1,.3, 'W_{1}', 'Parent',hax);
text(.355,1.15,'W_{2}','Parent',hax);
text(.575,.3, 'W_{3}', 'Parent',hax);
text(.725,1.075,'W_{4}','Parent',hax);
text(.9,.3, 'W_{5}', 'Parent',hax);

% Draw the legend
drawLegend(hax,1);

%-------------------------------------------------------------------------------
function drawArbMag(hax, filtMethod)
% DRAWARBMAG Draws the static response for the arbitrary magnitude filter
% Inputs: 
%   hax   - handle to the axis

% Determine if the filter is FIR or IIR, call the appropriate function.
hFig = get(hax,'Parent');
ud = get(hFig,'UserData');

if(any(strcmpi(filtMethod,{'remez','firls'})))
    drawArbMagFIR(hax);
else
    drawArbMagIIR(hax); 
end
%---------------------------------------------------------------------------------
function drawArbMagIIR(hax)
% DRAWARBMAG Draws the static response for the arbitrary magnitude filter for the FIR case
% Inputs: 
%   hax   - handle to the axis

% width and height of arrows
w = .01;
h = .07;

% Arbitrary Frequency and magnitude vector, slightly different from the the default filter, 
% so that the picture will fit in the analaysis frame


freqVec = [0:.05:.5 .55 0];
magVec = [1./sinc(0:.05:.5) 0 0];

% Tweak the mag vector a little bit, to make the front lower
magVec(1) = magVec(1)-.25;
magVec(2) = magVec(2) -0.1;
magVec(4) = magVec(4) -.049;
% tweak the freq. vector
freqVec(2) = freqVec(2)+.05;
freqVec(3) = freqVec(3)+.075;
freqVec(4) = freqVec(4)+.025;

% outline the respone, just draw the non zero part of the response
freqVec1 = freqVec(1:11);
magVec1 = magVec(1:11);
%Solid line
line(freqVec1(1:3),magVec1(1:3),'Parent',hax);
% Dotted line
line(freqVec1(4:10),magVec1(4:10),'Parent',hax,'LineStyle', ':');
%Solid line
line(freqVec1(10:11),magVec1(10:11),'Parent',hax);

%Annotate

% Draw the first few freq. lines
for(i=[1,2,3,10,11])
    line([freqVec(i),freqVec(i)],[0,magVec(i)],'Parent',hax);   
end
line([freqVec(12),freqVec(12)],[0,1.5],'Parent',hax);

% Draw the freq. labels
for(i=[1,2,3,10,11])
    text(freqVec(i)-.001,0, '|','Parent',hax);
end
% Draw the ...
text(.3,.6, '...','Fontsize',25,'Parent',hax);

% Draw the first few freq. labels
for(i=1:3)
    text(freqVec(i),-.3,['f_{',num2str(i),'}'], 'Parent',hax);
end
% Draw the ...
text(freqVec(6)-.01,-.3,'...','Parent',hax)

% Draw Fr
text(freqVec(11),-.3,['f_{r}'], 'Parent',hax);
text(freqVec(12),-.3,['f_{r+1}'], 'Parent',hax);


% Draw the last freq. label
text(1,-.3,['f_{n}'], 'Parent',hax);


% Draw the amplitudes and weights
text(-.1,magVec(1)-.11,'A_{1}','Parent',hax);
arrow_w_line(hax,[-.09,0],[magVec(1),magVec(1)],w,h,'right');

text(freqVec(2)+.1,magVec(2)-.1,'A_{2}','Parent',hax);
arrow_w_line(hax,[freqVec(2)+.1,freqVec(2)],[magVec(2),magVec(2)],w,h,'left');

text(freqVec(10)-.14,magVec(10)-.012,'A_{r-1}','Parent',hax);
arrow_w_line(hax,[freqVec(10)-.1,freqVec(10)],[magVec(10),magVec(10)],w,h,'right');

text(freqVec(11)-.14,magVec(11)+.01,'A_{r}','Parent',hax);
arrow_w_line(hax,[freqVec(11)-.1,freqVec(11)],[magVec(11),magVec(11)],w,h,'right');

text(freqVec(1)+.05,magVec(1)+.55,'W_{1}','Parent',hax);
arrow_w_line(hax,[freqVec(1)+.05,freqVec(1)],[magVec(1)+.55,magVec(1)],w,h,'down');

text(freqVec(2)-.01,magVec(2)+.2,'W_{2}','Parent',hax);
arrow_w_line(hax,[freqVec(2),freqVec(2)],[magVec(2)+.15,magVec(2)],w,h,'down');
 
text(freqVec(11)-.01,magVec(11)+.2,'W_{r}','Parent',hax);
arrow_w_line(hax,[freqVec(11),freqVec(11)],[magVec(11)+.15,magVec(11)],w,h,'down');

text(freqVec(12)+.05,magVec(12)+.3,'W_{r+1}','Parent',hax);
text(freqVec(12)+.05,magVec(12)+.15,'A_{r+1}','Parent',hax);
arrow_w_line(hax,[freqVec(12)+.05,freqVec(12)],[magVec(12)+.1 magVec(12)],w,h,'left');

text(1.05,.45,'W_{n}','Parent',hax);
text(1.05,.3,'A_{n}','Parent',hax);
arrow_w_line(hax,[1.05 1],[.2 0],w,h,'left');

% Draw and label the don't care region #1
drawDontCare(hax,[freqVec(11),freqVec(12)],[0:.1:1.5])

% Draw and label don't care region #2 
drawDontCare(hax,[.8 .85],[0:.1:.9]);
line([.8 .8],[0,.9],'Parent',hax);
line([.85 .85],[0,.9],'Parent',hax);

% Label the don't care #2 region frequeuncies,amplitudes and weights
text(.7,.3,'W_{r+2}','Parent',hax);
text(.7,.15,'A_{r+2}','Parent',hax);
arrow_w_line(hax,[.75 .8],[.075 0],w,h,'right');

text(.8-.001,0, '|','Parent',hax);
text(.85-.001,0, '|','Parent',hax);
text(.75,-.3,['f_{r+2}'], 'Parent',hax);
text(.85,-.3,['f_{r+3}'], 'Parent',hax);


text(.9,.3,'W_{r+3}','Parent',hax);
text(.9,.15,'A_{r+3}','Parent',hax);
arrow_w_line(hax,[.9 .85],[.075 0],w,h,'left');

text(.6,.7,'Don''t Care','Parent',hax);
arrow_w_line(hax,[.6,.52],[.7,.7],w,h,'left');
arrow_w_line(hax,[.76,.83],[.7,.7],w,h,'right');

drawLegend(hax,3);
%-----------------------------------------------------------------------------------------
function drawArbMagFIR(hax)
% DRAWARBMAG Draws the static response for the arbitrary magnitude filter for the FIR case
% Inputs: 
%   hax   - handle to the axis

% width and height of arrows
w = .01;
h = .07;

% Arbitrary Frequency and magnitude vector, slightly different from the the default filter, 
% so that the picture will fit in the analaysis frame


freqVec = [0:.05:.5 .55 0];
magVec = [1./sinc(0:.05:.5) 0 0];

% Tweak the mag vector a little bit, to make the front lower
magVec(1) = magVec(1)-.25;
magVec(2) = magVec(2) -0.1;
magVec(4) = magVec(4) +.1 ;
% tweak the freq. vector
freqVec(2) = freqVec(2)+.05;
freqVec(3) = freqVec(3)+.075;
freqVec(4) = freqVec(4)+.12;

% outline the respone, just draw the non zero part of the response
freqVec1 = freqVec(1:11);
magVec1 = magVec(1:11);
%Solid line
line(freqVec1(1:4),magVec1(1:4),'Parent',hax);
% Dotted line
line(freqVec1(6:10),magVec1(6:10),'Parent',hax,'LineStyle', ':');
%Solid line
line(freqVec1(10:11),magVec1(10:11),'Parent',hax);

%Annotate

% Draw the first few freq. lines
for(i=[1,2,3, 4,10,11])
    line([freqVec(i),freqVec(i)],[0,magVec(i)],'Parent',hax);   
end
line([freqVec(12),freqVec(12)],[0,1.5],'Parent',hax);
    
% Draw the freq. labels
for(i=[1,2,3,4 ,10,11])
     text(freqVec(i)-.001,0, '|','Parent',hax);
end
% Draw the ...
text(.3,.7, '...','Fontsize',25,'Parent',hax);

% Draw the first few freq. labels
for(i=1:4)
    text(freqVec(i),-.3,['f_{',num2str(i),'}'], 'Parent',hax);
end;
% Draw the ...
text(freqVec(7)+.01,-.3,'...','Parent',hax)

% Draw F11,13
text(freqVec(10),-.3,['f_{11}'], 'Parent',hax);
text(freqVec(11),-.3,['f_{12}'], 'Parent',hax);
text(freqVec(12),-.3,['f_{13}'], 'Parent',hax);

% Draw the last freq. label
text(1,-.3,['f_{14}'], 'Parent',hax);


% Draw the amplitudes and weights
text(-.1,magVec(1)-.11,'A_{1}','Parent',hax);
arrow_w_line(hax,[-.09,0],[magVec(1),magVec(1)],w,h,'right');

text(freqVec(2)-.075,magVec(2)+.35,'A_{2}','Parent',hax);
arrow_w_line(hax,[freqVec(2)-.06,freqVec(2)],[magVec(2)+.29,magVec(2)],w,h,'right');

text(freqVec(3)+.075,magVec(3)-.25,'A_{3}','Parent',hax);
arrow_w_line(hax,[freqVec(3)+.06,freqVec(3)],[magVec(3)-.19,magVec(3)],w,h,'left');

text(freqVec(4)+.075,magVec(4)-.25,'A_{4}','Parent',hax);
arrow_w_line(hax,[freqVec(4)+.06,freqVec(4)],[magVec(4)-.19,magVec(4)],w,h,'left');

text(freqVec(10)-.15,magVec(10)-.012,'A_{11}','Parent',hax);
arrow_w_line(hax,[freqVec(10)-.1,freqVec(10)],[magVec(10),magVec(10)],w,h,'right');

text(freqVec(11)-.16,magVec(11)+.01,'A_{12}','Parent',hax);
arrow_w_line(hax,[freqVec(11)-.1,freqVec(11)],[magVec(11),magVec(11)],w,h,'right');

text(freqVec(1)+.02,magVec(1)+.17,'W_{1}','Parent',hax);

text(freqVec(3)+.01,magVec(3)+.17,'W_{2}','Parent',hax);
 
text(freqVec(10)-.01,magVec(10)+.325,'W_{6}','Parent',hax);
arrow_w_line(hax,[freqVec(10)+.02,freqVec(10)+.02],[magVec(10)+.23,magVec(10)+.04],w,h,'down');

text(freqVec(12)+.05,magVec(12)+.15,'A_{13}','Parent',hax);
arrow_w_line(hax,[freqVec(12)+.05,freqVec(12)],[magVec(12)+.1 magVec(12)],w,h,'left');

text(.75,.1,'W_{7}','Parent',hax);
text(1.05,.3,'A_{14}','Parent',hax);
arrow_w_line(hax,[1.05 1],[.2 0],w,h,'left');

% Draw and label the don't care region #1
drawDontCare(hax,[freqVec(2),freqVec(3)],[0:.1:magVec(2)])

% Draw and label the don't care region #2
drawDontCare(hax,[freqVec(11),freqVec(12)],[0:.1:1.5])

text(.227,.4,'Don''t Care','Parent',hax);
arrow_w_line(hax,[.2,.12],[.4,.4],w,h,'left');
arrow_w_line(hax,[.4,.52],[.4,.4],w,h,'right');

drawLegend(hax,2);

%--------------------------------------------------------------------------------
function drawHalfbandhp(hax,C)
% DRAWHALFBANDLP    Draws the constraints for halfbandlp filters
% Inputs:
%
%   hax	  - handle to the axis
%   C     - structure containing the frequency and band edges(constraints)

% Use same code as for lowpass,highpass
drawLowHigh(hax,C);


%--------------------------------------------------------------------------------
function drawHalfbandlp(hax,C)
% DRAWHALFBANDLP    Draws the constraints for halfbandlp filters
% Inputs:
%
%   hax	  - handle to the axis
%   C     - structure containing the frequency and band edges(constraints)

% Use same code as for lowpass,highpass
drawLowHigh(hax,C);
%--------------------------------------------------------------------------------
function drawNyquist(hax,C, filtOrderType, filtMethod)
% DRAWNYQUIST	Draws the constraints for Nyquist filters
% Inputs:
%
%   hax	  - handle to the axis
%   C     - structure containing the frequency and band edges(constraints)


% Use same code as for lowpass,highpass
drawLowHigh(hax,C);

% Draw the transition bandwitdh limits when it can be specified
% filtOrderType = getOrderType(hax);
hFig = get(hax,'Parent');
ud = get(hFig,'UserData');
if ~(strcmpi(filtMethod,'fir1') & strcmpi(filtOrderType,'specify')),
	
	drawTransitionBandwidth(hax,C);
end

%--------------------------------------------------------------------------------
function drawRcos(hax,C)
% DRAWNYQUIST	Draws the constraints for raised cosine filters
% Inputs:
%
%   hax	  - handle to the axis
%   C     - structure containing the frequency and band edges(constraints)


% Use same code as for lowpass,highpass
drawLowHigh(hax,C);

% Draw the transition bandwitdh limits 
drawTransitionBandwidth(hax,C);

%-------------------------------------------------------------------------------------------
function drawDontCare(hax,x,y)
% DRAWDONTCARE draws a Don't Care Region, based on the specified coordinates
%
% Inputs:
%   hax  - handle to the axis
%   x    - the x coordinates
%   y    - the y coordinates

%draw the horizonatal lines.
for(i=1:length(y))
    line([x(1),x(2)],[y(i)-.05,y(i)],'Parent',hax)
    line([x(1),x(2)],[y(i),y(i)-.05],'Parent',hax)
end
%-----------------------------------------------------
function drawLegend(hax, legendType)
% DRAWLEGEND Draws the legend for the differentiator, arbitrary mag. and multiband
% filter types
%
% Input:
%   hax        - handle to the axis
%   legendType - the type of legend to draw: 
%                1 = No Freq. Edges, No F_r for intermediate freqencies 
%                2 = No Freq. Edges, F_r for intermediate freqencies 
%                3 = Freq. Edges, F_r for intermediate freqencies 
%                4 = The Group Delay legend
% X and Y position of the legend
xpos = .6;
ypos = 1.58;
legWidth =.5;

switch legendType
case 1
    
    text(xpos,ypos,'Freq. vector  = [f_{1} f_{2} ... f_{2n}]', 'fontsize',7,'Parent',hax);
    text(xpos,ypos-.15,'Mag. vector  = [A_{1} A_{2} ... A_{2n}]','fontsize',7, 'Parent',hax);
    text(xpos,ypos-.3,'Weight vector = [W_{1} W_{2} .. W_{n}]','fontsize',7,'Parent',hax);
    line([xpos-.01, xpos+.5],[ypos+.12, ypos+.12], 'Parent',hax);
    line([xpos-.01, xpos+.5],[ypos-.37, ypos-.37], 'Parent',hax);
    line([xpos-.01,xpos-.01],[ypos-.37, ypos+.12], 'Parent',hax);
    line([xpos+legWidth,xpos+legWidth],[ypos-.37, ypos+.12], 'Parent',hax);
    
    
case 2
    
    text(xpos,ypos,'Freq. vector  = [f_{1} f_{2} .. f_{r} ... f_{2n}]', 'fontsize',7,'Parent',hax);
    text(xpos,ypos-.15,'Mag. vector  = [A_{1} A_{2} .. A_{r} ... A_{2n}]','fontsize',7, 'Parent',hax);
    text(xpos,ypos-.3,'Weight vector = [W_{1} W_{2} .. W_{r} .. W_{n}]','fontsize',7,'Parent',hax);
    line([xpos-.01, xpos+.5],[ypos+.12, ypos+.12], 'Parent',hax);
    line([xpos-.01, xpos+.5],[ypos-.37, ypos-.37], 'Parent',hax);
    line([xpos-.01,xpos-.01],[ypos-.37, ypos+.12], 'Parent',hax);
    line([xpos+legWidth,xpos+legWidth],[ypos-.37, ypos+.12], 'Parent',hax);
    
case 3
    
    text(xpos,ypos,'Freq. vector  = [f_{1} f_{2} .. f_{r} ... f_{n}]', 'fontsize',7,'Parent',hax);
    text(xpos,ypos-.15,'Freq. edges = [f_{1} f_{r} f_{r+1} f_{r+2} f_{r+3} f_{n}]','fontsize',7,'Parent',hax);
    text(xpos,ypos-.3,'Mag. vector  = [A_{1} A_{2} .. A_{r} ... A_{n}]','fontsize',7, 'Parent',hax);
    text(xpos,ypos-.43,'Weight vector = [W_{1} W_{2} .. W_{r} .. W_{n}]','fontsize',7,'Parent',hax);
    
    line([xpos-.01, xpos+.5],[ypos+.12, ypos+.12], 'Parent',hax);
    line([xpos-.01, xpos+.5],[ypos-.5, ypos-.5], 'Parent',hax);
    line([xpos-.01,xpos-.01],[ypos-.5, ypos+.12], 'Parent',hax);
    line([xpos+legWidth,xpos+legWidth],[ypos-.5, ypos+.12], 'Parent',hax);
	
case 4 % The Group delay legend
 text(xpos,ypos,'Freq. vector  = [f_{1} f_{2} .. f_{r} ... f_{n}]', 'fontsize',7,'Parent',hax);
    text(xpos,ypos-.15,'Grpdelay vector  = [G_{1} G_{2} ... G_{n}]','fontsize',7, 'Parent',hax);
    text(xpos,ypos-.3,'Weight vector = [W_{1} W_{2} ... W_{n}]','fontsize',7,'Parent',hax);
    line([xpos-.01, xpos+.5],[ypos+.12, ypos+.12], 'Parent',hax);
    line([xpos-.01, xpos+.5],[ypos-.37, ypos-.37], 'Parent',hax);
    line([xpos-.01,xpos-.01],[ypos-.37, ypos+.12], 'Parent',hax);
    line([xpos+legWidth,xpos+legWidth],[ypos-.37, ypos+.12], 'Parent',hax);		
end

%-----------------------------------------------------------------------------
function drawArbGrp(hax)
% DRAWARBGRP Draw the static response for the arbitrary group delay filter
% Inputs:
% 
% hax - handle to the axis

% width and height of arrows
w = .01;
h = .07;

%Set up axis 
set(hax,'YtickLabel',{'1', '2'})

% Change the Ylabel
H = get(hax,'YLabel');
set(H,'String','Relative Group Delay')

% Delete the H|w| or H|f|
H = findobj('Type','Text','String','|H(\omega)|');
if(exist('H'))
	delete(H)
end 
H = findobj('Type','Text','String','|H(f)|');
if(exist('H'))
	delete(H)
end 
 
% Set up vectors
freqVec = [ 0 0 0.1 1];
grpDelayVec = [0 1 1.5 0];

% plot the Gray Region
constraint(hax,freqVec,grpDelayVec);

% Draw all labels
 for(i=2:3)
    text(freqVec(i),-.3,['f_{',num2str(i-1),'}'], 'Parent',hax);
	text(freqVec(i)-.001,0, '|','Parent',hax);
end;
text(freqVec(4),-.3,['f_{3}'], 'Parent',hax);

% Draw the Group Delay's
text(.075,grpDelayVec(2),'G_{1}','Parent',hax);
arrow_w_line(hax,[freqVec(2)+.065 freqVec(2)],[grpDelayVec(2),grpDelayVec(2)],w,h,'left');

text(freqVec(3)+.1,grpDelayVec(3),'G_{2}','Parent',hax);
arrow_w_line(hax,[freqVec(3)+.065 freqVec(3)],[grpDelayVec(3),grpDelayVec(3)],w,h,'left');

text(freqVec(4)+.025,grpDelayVec(4)+.15,'G_{3}','Parent',hax);
arrow_w_line(hax,[freqVec(4)+.05 freqVec(4)],[grpDelayVec(4),grpDelayVec(4)],w,h,'left');

% Draw the Weights;
text(freqVec(2)+.015,grpDelayVec(2)+.4,'W_{1}','Parent',hax);
arrow_w_line(hax,[freqVec(2)+.02 freqVec(2)],[grpDelayVec(2)+.35,grpDelayVec(2)],w,h,'down');

text(freqVec(3),grpDelayVec(3)+.3,'W_{2}','Parent',hax);
arrow_w_line(hax,[freqVec(3) freqVec(3)],[grpDelayVec(3)+.25,grpDelayVec(3)],w,h,'down');

 text(freqVec(4)-.075,grpDelayVec(4)+.35,'W_{3}','Parent',hax);
 arrow_w_line(hax,[freqVec(4)-.065 freqVec(4)],[grpDelayVec(4)+.3,grpDelayVec(4)],w,h,'down');
 
 % Draw the legend
 drawLegend(hax,4);
 
%------------------------------------------------------------------------------------
function whiteOut(hax,xd,yd,type)
% WHITEOUT draws a white line over the constrained region
% 
% Inputs:
%	hax 	- handle to the axis
%	xd 	- x dimensions for the line
%	yd    	- y dimensions for the line
% 	type    - whether the line drawn is a to be over a passband or stopband

if(strcmpi(type, 'passband'))
    hl = line([xd(1) xd(2)],[yd(1) yd(1)],...
        'color','white',...
        'Parent',hax);
end

if(strcmpi(type, 'stopband'))
    hl = line([xd(1) xd(2)],[yd(3) yd(3)],...
        'color','white',...
        'Parent',hax);
end

%--------------------------------------------------------------------------
function annotate(hax,filtType,constraints,magUnits,freqUnits,filtMethod,filtOrdType)
% ANNOTATE Draw arrows and display text indicating passband ripple stopband
% attenuation etc.
%
% Inputs:
% hax 	 	     - handle to the axis
% filtType 	     - the filter type(lowpass, highpass, bandpass or bandstop)
% constraints 	 - the constraints of the filter
% magUnits  	 - the units of the magnitude
% freqUnits  	 - the units of the frequency
% filtMethod     - the method used to desing the filter, butter cheby1 etc...
% filtOrdTye     - the order type of the filter(specify or minimum order)

% Draw the amplitude labels
drawAmplitudeLabels(hax, filtType, constraints,magUnits,filtMethod,filtOrdType);

% Draw the Frequency labels
drawFrequencyLabels(hax, filtType,filtMethod, constraints,freqUnits,  filtOrdType);

%--------------------------------------------------------------------------
function drawAmplitudeLabels(hax, filtType, constraints,magUnits, filtMethod, filtOrdType)
% DRAWARROWS Draw the arrows labels as approptiate for all of the Apass and Astop, delta, 
% Epass/stop or Wpass/stop regions
%
% Inputs:
%   hax          - handle to the axis
%   filtType     - the type of filter being used (highpass, lowpass, etc)
%   constraints  - a structure containing all of the band and amplitude edges
%   magUnits     - the units of the magnitude axis(dB, Log)

% If the magnitude units is empty then we don't want to annotate anything.
if isempty(magUnits), return; end

% Two special cases, no amplitude labels are needed
if(strcmpi(filtMethod,'butter')&strcmpi(filtOrdType,'specify')),return,end;
if(strcmpi(filtMethod,'fir1')&strcmpi(filtOrdType,'specify')), return,end;

switch magUnits
case 'db',      drawAarrows(hax, filtType, constraints,filtMethod, filtOrdType)    
case 'linear',  drawDeltaArrows(hax, filtType, constraints,filtMethod)  
case 'squared', drawEPassStop(hax, filtType, constraints,filtMethod, filtOrdType)    
case 'weights', drawWPassStop(hax, filtType, constraints)            
end    

%-----------------------------------------------------------------------------
function   drawAarrows(hax, filtType, constraints, filtMethod, filtOrdType)
% DRAWAARROWS Sets up the positions for the Astop and AWpass arrows, and then calls 
% the appropriate function to draw the arrows
% 
% Inputs:
%    hax          - handle to the axis
%    filtType     - the type of filter being drawn
%    constraints  - structure containing the filter constraints

% Handle the special cases, Cheby1 and Cheby2, and Ellip with the order specified
if(strcmpi(filtOrdType,'specify'))
    if(strcmpi(filtMethod,'cheby1'))
        drawCheb1(hax, filtType, constraints,filtMethod);
        return;
    end  
    if(strcmpi(filtMethod,'cheby2'))
        drawCheb2(hax, filtType, constraints);
        return;    
    end    
    if(strcmpi(filtMethod,'ellip'))
        drawEllip(hax, filtType, constraints,filtMethod);
        return
    end
end

switch filtType
case {'lp','lpcutoff','halfbandlp','lppassedge','lpstopedge'}
    xpos = constraints.fc(1)+.07;  % A little bit after the ideal cutoff freq.
    drawApass(hax,xpos, 0, filtMethod);
    
case 'halfbandhp'
    xpos = constraints.fc(1)-.09;  % A little bit before the ideal cutoff freq.
    drawApass(hax,xpos, 0, filtMethod);
    
case {'hp','hpcutoff','hppassedge','hpstopedge'},
    xpos = constraints.fc(1)-.09;  % A little bit before the ideal cutoff freq.
    drawApass(hax,xpos, 0, filtMethod);
    
case 'bp',
    xpos = constraints.fc(2)+.07;	% A little bit after the second cutoff freq.
    drawApass(hax,xpos, 0, filtMethod);
    
case 'bs'
    xpos = constraints.fc(1);	% the first cutoff freq.
    drawApass(hax,xpos, 1, filtMethod);
    
    xpos = 1.05; 					% Just outside, on the left of the graph
    drawApass(hax,xpos,2, filtMethod);       
case 'notch'
    
    xpos = 1.05; 					% Just outside, on the left of the graph
    drawApass(hax,xpos,0, filtMethod);       
case 'peak'
    xpos = .57; 					% Just outside, on the left of the graph
    drawApass(hax,xpos,0, filtMethod);       
end

% Stopband attenutation; Astop 
% Draw the Astop regions
switch filtType
case {'lp','nyquist','lpcutoff','lppassedge','lpstopedge'}
    xpos = constraints.fc(1)+.4;  % A little bit after the ideal cutoff freq.
    drawAstop(hax,xpos,0);
    
case {'hp','hpcutoff','hppassedge','hpstopedge'},
    xpos = constraints.fc(1)-.35;  % A little bit before the ideal cutoff freq.
    drawAstop(hax,xpos,0);
    
case 'bp'
    xpos = constraints.fc(1)-.2;   % A little bit before the first cutoff freq.
    drawAstop(hax,xpos,1);
    
    xpos = constraints.fc(2) +.2;	% A little bit after the second cutoff freq.
    drawAstop(hax,xpos+.02,2);
    
case 'bs',
    xpos = .5;% near the middle 
    drawAstop(hax, xpos,0);
    
end

%-------------------------------------------------------------------------------
function drawCheb1(hax, filtType, constraints,filtMethod)
% DRAWCHEB1  Draws arrows for Chebyshev 1 filters. Should only be called if order is specified.
%
% Inputs: 
%   hax        - handle to the axis
%   filtType   - the type of filter, lowpass, highpass etc...
%   constaints - structure containing the filter constraints

% All chebyschev filters have arrow type A
arrowType = 'a';

switch filtType
case 'lp',
    xpos = constraints.fc(1)+.1;  % A little bit after the ideal cutoff freq.
    drawApass(hax,xpos,0, filtMethod);
    
case 'hp',
    xpos = constraints.fc(1)-.1;  % A little bit before the ideal cutoff freq.
    drawApass(hax,xpos,0, filtMethod);
    
case 'bp'
    xpos = constraints.fc(1)-.2;   % A little bit before the first cutoff freq.
    drawApass(hax,xpos,0, filtMethod);
    
    xpos = constraints.fc(2) +.2;	% A little bit after the second cutoff freq.
    drawApass(hax,xpos,0,  filtMethod);
    
case 'bs',
    xpos = .55;% near the middle 
    drawApass(hax, xpos,0, filtMethod);
end

%---------------------------------------------------------------------------------
function drawCheb2(hax, filtType, constraints)
% DRAWCHEB1  Draws arrows for Chebyshev 1 filters. Should only be called if order is specified.
%
% Inputs: 
%   hax        - handle to the axis
%   filtType   - the type of filter, lowpass, highpass etc...
%   constaints - structure containing the filter constraints


switch filtType
case 'lp',
    xpos = constraints.fc(1)+.40;  % A little bit after the ideal cutoff freq.
    drawAstop(hax,xpos,0);
    
case 'hp',
    xpos = constraints.fc(1)-.35;  % A little bit before the ideal cutoff freq.
    drawAstop(hax,xpos,0);
    
case 'bp'
    xpos = constraints.fc(1)-.2;   % A little bit before the first cutoff freq.
    drawAstop(hax,xpos,0);
    
    xpos = constraints.fc(2) +.2;	% A little bit after the second cutoff freq.
    drawAstop(hax,xpos,0);
    
case 'bs',
    xpos = .55;% near the middle 
    drawAstop(hax, xpos,0);
end   

%---------------------------------------------------------------------------------
function drawEllip(hax, filtType, constraints,filtMethod)
% DRAWELLIP Draws the arrows for ellip filter. Should only be called if order is specified.
% Inputs: 
%   hax        - handle to the axis
%   filtType   - the type of filter, lowpass, highpass etc...
%   constaints - structure containing the filter constraints

switch filtType
case 'lp',
    xpos = constraints.fc(1)+.40;  % A little bit after the ideal cutoff freq.
    drawAstop(hax,xpos,0);
    xpos = constraints.fc(1);  % A little bit after the ideal cutoff freq.
    drawApass(hax,xpos+.1,0, filtMethod);
    
    
case 'hp',
    xpos = constraints.fc(1)-.35;  % A little bit before the ideal cutoff freq.
    drawAstop(hax,xpos,0);
    
    xpos = constraints.fc(1)-.2;  % A little bit before the ideal cutoff freq.
    drawApass(hax,xpos,0,  filtMethod);
    
case 'bp'
    xpos = constraints.fc(1)-.2;   % A little bit before the first cutoff freq.
    drawAstop(hax,xpos,0);
    
    xpos = constraints.fc(2) +.2;	% A little bit after the second cutoff freq.
    drawAstop(hax,xpos,0);
    
    xpos = constraints.fc(2) +.2;	% A little bit after the second cutoff freq.
    drawApass(hax,xpos-.1 ,0, filtMethod);
    
    
case 'bs',
    xpos = .55;% near the middle 
    drawAstop(hax, xpos,0);
    
    xpos = .40;% near the middle 
    drawApass(hax, xpos,0, filtMethod);
end   

%-------------------------------------------------------------------------------------------
function drawDeltaArrows(hax, filtType, constraints, filtMethod)  
% DRAWDELTARROWS  Draws the delta arrows 
% Inputs: 
%   hax        - handle to the axis
%   filtType   - the type of filter, lowpass, highpass etc...
%   constaints - structure containing the filter constraints

switch filtType
case {'lp','lpcutoff','lppassedge','lpstopedge','hp','hpcutoff','hppassedge','hpstopedge'}
    % Passband ripple 1+delta_pass and 1-delta_pass
    drawDeltaPass(hax,'left',0, filtMethod);
    
    % Stopband ripple; delta_stop
    drawDeltaStop(hax, 'left',0);
case 'bp'
    % Passband ripple 1+delta_pass and 1-delat_pass
    drawDeltaPass(hax, 'left', 0, filtMethod);
    
    % Stopband ripple 1; delta_stop1     
    drawDeltaStop(hax,'left', 1);
    
    % Stopband ripple 2; delta_stop2
    drawDeltaStop(hax, 'right', 2);
case 'bs'
    % Passband ripple 1 1+delta_pass1 and 1-delta_pass1
    drawDeltaPass(hax,'left', 1, filtMethod);
    
    % Passband ripple 2; 1+delta_pass2 and 1-delta_pass2
    drawDeltaPass(hax,'right',2, filtMethod);
    
    % Stopband ripple 1; delta_stop
    drawDeltaStop(hax,'left', 0);
case {'halfbandlp'}
    % Passband ripple 1+delta_pass and 1-delta_pass
    drawDeltaPass(hax,'left',0);
case {'nyquist'}
    % Passband ripple 1+delta_pass and 1-delta_pass
    drawDeltaStop(hax,'left',0);
end

%-----------------------------------------------------------------------
function drawDeltaPass(hax,side, number, filtMethod)
% DRAWDELTAPASS Draws the delta_pass text and arrows
%
% Inputs:
%   hax    - handle to the axis
%   side   - the side the D_pass arrow should be drawn on, left or right
%   number - the subscipt for the D_pass: D_pass, D_pass1 or D_pass2

if nargin < 4, filtMethod = ''; end

% Width and height of arrow head
w = .01;
h = .07;

% Starting x coordinates of ripple anotation text and arrow line
% Left edge
xBeginTextLE = -0.18;
xBeginArrowLE = -0.06;
% Right edge
xBeginTextRE = 1;
xBeginArrowRE = 1;

% Starting y coordinates of ripple annotation and arrow line
% Passband
ytopPB = 1.1;
ybotPB = .9;
% Stopband
ybotSB = .11;

if(strcmpi(side, 'left'))
    switch number
    case 0
        
        str = '1+D_{pass}';
        if strcmpi(filtMethod, 'fircls')
            str = '1+D_{passu}';
        end
        
        % Passband ripple 1+delta_pass and 1-delta_pass
        text(xBeginTextLE+.025,ytopPB+.2,str,'Parent',hax);
        arrow_w_line(hax,[xBeginArrowLE 0],[ytopPB ytopPB],w,h,'right');

        str = '1-D_{pass}';
        if strcmpi(filtMethod, 'fircls')
            str = '1-D_{passl}';
        end

        text(xBeginTextLE+.025,ybotPB-.1,str,'Parent',hax);
        arrow_w_line(hax,[xBeginArrowLE 0],[ybotPB ybotPB],w,h,'right');
        
    case 1
        
        str = '1+D_{pass1}';
        if strcmpi(filtMethod, 'fircls')
            str = '1+D_{pass1u}';
        end

        text(xBeginTextLE+.025,ytopPB+.2,str,'Parent',hax);
        arrow_w_line(hax,[xBeginArrowLE 0],[ytopPB ytopPB],w,h,'right');

        str = '1-D_{pass1}';
        if strcmpi(filtMethod, 'fircls')
            str = '1-D_{pass1l}';
        end

        text(xBeginTextLE+.025,ybotPB-.1,str,'Parent',hax);
        arrow_w_line(hax,[xBeginArrowLE 0],[ybotPB ybotPB],w,h,'right');
        
    end
end

if(strcmpi(side, 'right'))
    
    str = '1+D_{pass2}';
    if strcmpi(filtMethod, 'fircls')
        str = '1+D_{pass2u}';
    end
    text(xBeginTextRE+.050,ytopPB+.15,str,'Parent',hax);
    arrow_w_line(hax,[xBeginArrowRE+.06 xBeginArrowRE],[ytopPB ytopPB],w,h,'left');
    
    str = '1-D_{pass2}';
    if strcmpi(filtMethod, 'fircls')
        str = '1-D_{pass2l}';
    end
    text(xBeginTextRE+.05,ybotPB-.15,str,'Parent',hax);
    arrow_w_line(hax,[xBeginArrowRE+.06 xBeginArrowRE],[ybotPB ybotPB],w,h,'left');
    
end

%-----------------------------------------------------------------------------
function drawDeltaStop(hax,side, number)
% DRAWDELTASTOP Draws the D_stop arrows and text
% Inputs  
%   hax    - handle to the axis
%   side   - the side the D_stop arrow should be drawn on, left or right
%   number - the subscipt for D_stop: D_stop, D_stop1 or D_stop2

% Width and height of arrow head
w = .01;
h = .07;

% Starting x coordinates of ripple anotation text and arrow line
% Left edge
xBeginTextLE = -0.18;
xBeginArrowLE = -0.06;
% Right edge
xBeginTextRE = 1;
xBeginArrowRE = 1;

% Starting y coordinates of ripple annotation and arrow line
% Passband
ytopPB = 1.1;
ybotPB = .9;
% Stopband
ybotSB = .11;

if strcmpi(side,'left')
    switch number
    case 0
        % Stopband ripple; delta_stop
        text(xBeginTextLE+.035,ybotSB,'D_{stop}','Parent',hax);
        arrow_w_line(hax,[xBeginArrowLE 0],[ybotSB ybotSB],w,h,'right');
        
    case 1
        % Stopband ripple delta_stop1
        text(xBeginTextLE+.030,ybotSB-.05,'D_{stop1}','Parent',hax);
        arrow_w_line(hax,[xBeginArrowLE 0],[ybotSB ybotSB],w,h,'right');
        
    end
end

if strcmpi(side, 'right')
    text(xBeginTextRE+.050,ybotSB+.1,'D_{stop2}','Parent',hax);
    arrow_w_line(hax,[xBeginArrowRE+.06 xBeginArrowRE],[ybotSB ybotSB],w,h,'left');
end

%--------------------------------------------------------------------------
function drawEPassStop(hax, filtType, constraints,filtMethod, filtOrdType)  
% DRAWEPASSSTOP Calls drawEpass and drawEstop to placelabels on the sides of the static response
% Inputs: 
%   hax        - handle to the axis
%   filtType   - the type of filter, lowpass, highpass etc...
%   constaints - structure containing the filter constraints

switch filtType
case {'lp','hp'}        
    % Passband ripple 1+delta_pass and 1-delta_pass
    drawEPass(hax,'left',0);
    
    % Stopband ripple; delta_stop
    drawEStop(hax, 'left',0);            
case 'bp'
    % Passband ripple 1+delta_pass and 1-delat_pass
    drawEPass(hax, 'left', 0);
    
    % Stopband ripple 1; delta_stop1              
    drawEStop(hax,'left', 1);
    
    % Stopband ripple 2; delta_stop2
    drawEStop(hax, 'right', 2);
case 'bs'
    % Passband ripple 1 1+delta_pass1 and 1-delta_pass1
    drawEPass(hax,'left', 1);
    
    % Passband ripple 2; 1+delta_pass2 and 1-delta_pass2
    drawEPass(hax,'right',2);
    
    % Stopband ripple 1; delta_stop
    drawEStop(hax,'left', 0)        
    
end    

%-----------------------------------------------------------------------------------------
function drawEPass(hax,side, number)
% DRAWEPASS Draws the Epass text and arrows
%
% Inputs:
%   hax    - handle to the axis
%   side   - the side the delta_pass arrow should be drawn on, left or right
%   number - the subscipt for delta_pass: delta_pass, delta_pass1 or delta_pass2


% Width and height of arrow head
w = .01;
h = .07;

% Starting x coordinates of ripple anotation text and arrow line
% Left edge
xBeginTextLE = -0.18;
xBeginArrowLE = -0.06;
% Right edge
xBeginTextRE = 1;
xBeginArrowRE = 1;

% Starting y coordinates of ripple annotation and arrow line
% Passband
ybotPB = .9;
% Stopband
ybotSB = .11;

if(strcmpi(side, 'left'))
    switch number
    case 0        
        text(xBeginTextLE+.025,ybotPB-.1,'E_{pass}','Parent',hax);
        arrow_w_line(hax,[xBeginArrowLE 0],[ybotPB ybotPB],w,h,'right');
    case 1        
        text(xBeginTextLE+.025,ybotPB-.1,'E_{pass1}','Parent',hax);
        arrow_w_line(hax,[xBeginArrowLE 0],[ybotPB ybotPB],w,h,'right');
    end
end

if(strcmpi(side, 'right'))   
    text(xBeginTextRE+.05,ybotPB-.15,'E_{pass2}','Parent',hax);
    arrow_w_line(hax,[xBeginArrowRE+.06 xBeginArrowRE],[ybotPB ybotPB],w,h,'left');
    
end
%---------------------------------------------------------------------------------------
function drawEStop(hax,side,number)
% DRAWESTOP Draws the Estop arrows and text
%
% Inputs  
%   hax    - handle to the axis
%   side   - the side the delta_stop arrow should be drawn on, left or right
%   number - the subscipt for delta_stop: delta_stop, delta_stop1 or delta_stop2

% Width and height of arrow head
w = .01;
h = .07;

% Starting x coordinates of ripple anotation text and arrow line
% Left edge
xBeginTextLE = -0.18;
xBeginArrowLE = -0.06;
% Right edge
xBeginTextRE = 1;
xBeginArrowRE = 1;

% Starting y coordinates of ripple annotation and arrow line
% Passband
ytopPB = 1.1;
ybotPB = .9;
% Stopband
ybotSB = .11;

if strcmpi(side,'left')
    switch number
    case 0
        % Stopband ripple; delta_stop
        text(xBeginTextLE+.035,ybotSB,'E_{stop}','Parent',hax);
        arrow_w_line(hax,[xBeginArrowLE 0],[ybotSB ybotSB],w,h,'right');
        
    case 1
        % Stopband ripple delta_stop1
        text(xBeginTextLE+.030,ybotSB-.05,'E_{stop1}','Parent',hax);
        arrow_w_line(hax,[xBeginArrowLE 0],[ybotSB ybotSB],w,h,'right');
        
    end
end

if strcmpi(side, 'right')
    text(xBeginTextRE+.050,ybotSB+.1,'E_{stop2}','Parent',hax);
    arrow_w_line(hax,[xBeginArrowRE+.06 xBeginArrowRE],[ybotSB ybotSB],w,h,'left');
end

%--------------------------------------------------------------------------------------
function drawApass(hax,xpos, num,filtMethod)
% drawApass Draws the Apass label, lines and arrows, in the position specified
%
% Inputs:
%  hax 	     - handle to the axis
%  xpos	     - the position to draw the label
%  num 	     - the number of the label: Apass, Apass1 or Apass2

% if the filter is FIR, the amplitude is not constrained, the top line is at ytop = 1.1;
if(~amplitudeIsContrained(filtMethod))
    ytop = 1.1;
else % IIR filters, the amplitude is constrained and the top line is at ytop =1;
    ytop = 1;    
end
% The length and width of the lines and arrows
ybot = .9;
w = .01;
h = .07;

% Decide which string to draw
switch num
case 0, String = 'A_{pass}';
case 1, String = 'A_{pass1}';
case 2, String = 'A_{pass2}';    
end

% Draw the Apass arrows and label.
hl1 = line([xpos-.02 xpos+.02],[ytop ytop],'Parent',hax);
arrow_w_line(hax,[xpos xpos],[.6 ybot],w,h,'up');
arrow_w_line(hax,[xpos xpos],[1.3 ytop],w,h,'down');
hl2 = line([xpos-.02 xpos+.02],[ybot ybot],'Parent',hax);
set([hl1 hl2],'color','black');    

% Draw the String
text(xpos+.03,.98,String,'Parent',hax)

%----------------------------------------------------------------------------
function drawAstop(hax,xpos,num)
% DRAWASTOP Draws the Astop, lines and arrows, in the position specified
%
% Inputs:
%  hax        - handle to the axis
%  xpos	      - the position to draw the label
%  num        - the number of the label: Astop, Astop1 or Astop2

%The length and width of the lines and arrows
w = .01;
h = .07;
ytop = 1;
ybot = .11;

% Decide which string to draw
switch num
case 0, String = 'A_{stop}';
case 1, String = 'A_{stop1}';
case 2, String = 'A_{stop2}';    
end

% Draw the Astop labels and arrows
hl1 = line([xpos-.02 xpos+.02],[ytop ytop],'Parent',hax);
set(hl1,'color','black');
arrow_w_line(hax,[xpos xpos],[.65 ytop],w,h,'up');
arrow_w_line(hax,[xpos xpos],[.45 ybot],w,h,'down');
%Draw the string
text(xpos-.02,.55,String,'Parent',hax);

%---------------------------------------------------------------------------
function drawWPassStop(hax, filtType, constraints)
% DRAWWPASSSTOP Draws the Wpass and Wstop labels above the passband and stopbands
%
% Inputs
%   hax           - handle to the axis
%   filtType      - the filter type being drawn, low pass, highpass etc.
%   constraints   - structure containing all of the filter constraints

% Set up the strings needed
WpStr0 = 'W_{pass}';
WpStr1 = 'W_{pass1}';
WpStr2 = 'W_{pass2}';
  
WsStr0 = 'W_{stop}';
WsStr1 = 'W_{stop1}';
WsStr2 = 'W_{stop2}';

% Get the x position from the filters ideal cutoff frequency
xpos = constraints.fc(1);

% Draw the labels based on the filter type
switch filtType
case 'lp'    
    text(xpos-.3,1.35,WpStr0,'Parent',hax);
    text(xpos+.3,.35, WsStr0,'Parent',hax);
case 'hp'
    text(xpos-.3, .35,WsStr0,'Parent',hax);
    text(xpos+.3, 1.35, WpStr0, 'Parent',hax);
    
case 'bp'
    text(xpos-.3, .35,WsStr1,'Parent',hax);
    text(.45, 1.35,WpStr0,'Parent',hax);
    text(xpos+.5, .35,WsStr2,'Parent',hax);
    
case 'bs'
    text(xpos-.3, 1.35,WpStr1,'Parent', hax);
    text(.45,.35,WsStr0,'Parent',hax);
    text(xpos+.5,1.35,WpStr2,'Parent',hax);   
end
%-----------------------------------------------------------------------------------
function drawFrequencyLabels(hax, filtType,filtMethod, constraints,freqUnits,filtOrdType)
% DRAWFREQUENCYLABELS  Selects the appropritate function to draw the frequency labels
% Inputs:
%
%   hax          - handle to the axis
%   filtType     - the type of filter being used (highpass, lowpass, etc)
%   constraints  - a structure containing all of the band and amplitude edges
%   freqUnits    - the units of the frequency axis(Hz, normalized)
%   filtOrdType  - the filter order type, specify order or minumn order

% If the filter type is FIR, always call drawFrequencyLabelsMin

if(filterHasCutoff(filtType,filtMethod, filtOrdType))
    drawFrequencyLabelsCutoff(hax, filtType, filtMethod, constraints,freqUnits) 
else
    drawFrequencyLabelsEdge(hax, filtType, filtMethod,constraints,freqUnits)
end

%---------------------------------------------------------------------------
function drawFrequencyLabelsEdge(hax, filtType, filtMethod,constraints,freqUnits)
% DRAWFREQUENCYLABELSCUTOFF  Draws the frequency labels for filters with frequency edges
%
% Inputs:
%   hax          - handle to the axis
%   filtType     - the type of filter being used (highpass, lowpass, etc)
%   constraints  - a structure containing all of the band and amplitude edges
%   freqUnits    - the units of the frequency axis(Hz, normalized)

switch lower(freqUnits)
case {'hz','khz','mhz','ghz'},    	% Labels for the Frequencies
    fpassStr0 = 'F_{pass}';
    fpassStr1 = 'F_{pass1}';
    fpassStr2 = 'F_{pass2}';
    fstopStr0 = 'F_{stop}';
    fstopStr1 = 'F_{stop1}';
    fstopStr2 = 'F_{stop2}';
    
case 'normalized (0 to 1)',
    fpassStr0 = '\omega_{pass}';
    fpassStr1 = '\omega_{pass1}';
    fpassStr2 = '\omega_{pass2}';
    fstopStr0 = '\omega_{stop}';
    fstopStr1 = '\omega_{stop1}';
    fstopStr2 = '\omega_{stop2}';    
end

% Passband frequency; vertical line on the x-axis
fpass = constraints.passbandEdge;
fpass1 = constraints.passbandEdge1;

% Draw the labels, according to filter type:
switch filtType
    case {'lp', 'hp', 'halfbandlp', 'lppassedge', 'hppassedge'},
        text(fpass-.0022,0, '|','Parent',hax);
        text(fpass-.035,-.17,fpassStr0,'Parent',hax);
    case 'halfbandhp',
        fpass_Left = constraints.passband_leftEdge;
        text(fpass_Left-.0022,0, '|','Parent',hax);
        text(fpass_Left-.035,-.17,fpassStr0,'Parent',hax);
    case 'bp',
        text(fpass-.0022,0, '|','Parent',hax);
        text(fpass-.025,-.17,fpassStr1,'Parent',hax);
        text(fpass1-.0022,0, '|','Parent',hax);
        text(fpass1-.05,-.17,fpassStr2,'Parent',hax);
    case 'bs',
        text(fpass-.0022,0, '|','Parent',hax);
        text(fpass-.04,-.17,fpassStr1,'Parent',hax);
        text(fpass1-.0022,0, '|','Parent',hax);
        text(fpass1-.025,-.17,fpassStr2,'Parent',hax);
    case 'peak'
    case 'notch'
end

if strcmpi(filtMethod, 'iirnotchpeak')
    text(.5-.0022,0,'|', 'Parent', hax);
    text(.5-.04,-.17,sprintf('F_{%s}', filtType), 'Parent', hax);
end


% Stopband frequency; vertical line on the x-axis
fstop = constraints.stopbandEdge;
fstop1 = constraints.stopbandEdge1;

% Draw the labels, according to filter type
switch filtType
    case {'lp','hp','lpstopedge','hpstopedge'}
        text(fstop-.0025,0, '|','Parent',hax);
        text(fstop-.025,-.17,fstopStr0,'Parent',hax);
    case 'bp' 
        text(fstop-.0025,0, '|','Parent',hax);
        text(fstop-.05,-.17,fstopStr1,'Parent',hax);
        text(fstop1-.0025,0, '|','Parent',hax);
        text(fstop1-.025,-.17,fstopStr2,'Parent',hax);
    case 'bs' 
        text(fstop-.0025,0, '|','Parent',hax);
        text(fstop-.025,-.17,fstopStr1,'Parent',hax);
        text(fstop1-.0025,0, '|','Parent',hax);
        text(fstop1-.035,-.17,fstopStr2,'Parent',hax);
end

%-------------------------------------------------------------------------
function drawFrequencyLabelsCutoff(hax, filtType, filtMethod, constraints,freqUnits)
% DRAWFREQUENCYLABELSCUTOFF  Draws the frequency labels for filters that have cutoff freq
%
% Inputs:
%   hax          - handle to the axis
%   filtType     - the type of filter being used (highpass, lowpass, etc)
%   constraints  - a structure containing all of the band and amplitude edges
%   freqUnits    - the units of the frequency axis(Hz, normalized)


% Decide which labels to draw
switch filtType,
case 'nyquist',
	switch lower(freqUnits)
	case {'hz','khz','mhz','ghz'},    	% Labels for the Frequencies
		fpassStr0 = 'Fs/(2*Band)';
		
	case 'normalized (0 to 1)',
		fpassStr0 = '1/Band';
	end    
otherwise,
	switch filtMethod
	case {'butter','fir1','iirmaxflat','firmaxflat','fircls'}
		switch lower(freqUnits)
		case {'hz','khz','mhz','ghz'},    	% Labels for the Frequencies
			fpassStr0 = 'F{_c}';
			fpassStr1 = 'F_{c1}';
			fpassStr2 = 'F_{c2}';
			fstopStr0 = 'F_{c}';
			fstopStr1 = 'F_{c1}';
			fstopStr2 = 'F_{c2}';
			
		case 'normalized (0 to 1)',
			fpassStr0 = '\omega_{c}';
			fpassStr1 = '\omega_{c1}';
			fpassStr2 = '\omega_{c2}';
			
			fstopStr0 = '\omega_{c}';
			fstopStr1 = '\omega_{c1}';
			fstopStr2 = '\omega_{c2}';
		end  
	case 'cheby1'
		switch lower(freqUnits)
		case {'hz','khz','mhz','ghz'},    	% Labels for the Frequencies
			fpassStr0 = 'F_{pass}';
			fpassStr1 = 'F_{pass1}';
			fpassStr2 = 'F_{pass2}';
			fstopStr0 = 'F_{pass}';
			fstopStr1 = 'F_{pass1}';
			fstopStr2 = 'F_{pass2}';
			
		case 'normalized (0 to 1)',
			fpassStr0 = '\omega_{pass}';
			fpassStr1 = '\omega_{pass1}';
			fpassStr2 = '\omega_{pass2}';
			
			fstopStr0 = '\omega_{pass}';
			fstopStr1 = '\omega_{pass1}';
			fstopStr2 = '\omega_{pass2}';
		end
		
	case 'cheby2'
		switch lower(freqUnits)
		case {'hz','khz','mhz','ghz'},    	% Labels for the Frequencies
			fpassStr0 = 'F_{stop}';
			fpassStr1 = 'F_{stop1}';
			fpassStr2 = 'F_{stop2}';
			fstopStr0 = 'F_{stop}';
			fstopStr1 = 'F_{stop1}';
			fstopStr2 = 'F_{stop2}';
			
		case 'normalized (0 to 1)',
			fpassStr0 = '\omega_{stop}';
			fpassStr1 = '\omega_{stop1}';
			fpassStr2 = '\omega_{stop2}';
			
			fstopStr0 = '\omega_{stop}';
			fstopStr1 = '\omega_{stop1}';
			fstopStr2 = '\omega_{stop2}';
		end
		
	otherwise
		switch lower(freqUnits)
		case {'hz','khz','mhz','ghz'},    	% Labels for the Frequencies
			fpassStr0 = 'F_{pass}';
			fpassStr1 = 'F_{pass1}';
			fpassStr2 = 'F_{pass2}';
			fstopStr0 = 'F_{stop}';
			fstopStr1 = 'F_{stop1}';
			fstopStr2 = 'F_{stop2}';
			
		case 'normalized (0 to 1)',
			fpassStr0 = '\omega_{pass}';
			fpassStr1 = '\omega_{pass1}';
			fpassStr2 = '\omega_{pass2}';
			
			fstopStr0 = '\omega_{stop}';
			fstopStr1 = '\omega_{stop1}';
			fstopStr2 = '\omega_{stop2}';
        end
	end
end

% Passband frequency; vertical line on the x-axis
fc = constraints.fc(1);
fc1 = constraints.fc(1);
fc2 = constraints.fc(2);

% Draw the labels, according to filter type:
switch filtType,
case {'lp','hp','halfbandlp','halfbandhp','nyquist',...
            'rcos'},

    text(fc,0, '|','Parent',hax);
    text(fc-.035,-.17,fpassStr0,'Parent',hax);
case {'lpcutoff',...
            'hpcutoff'},
    text(fc,0, '|','Parent',hax);
    text(fc-.035,-.17,'F{_c}','Parent',hax);
case 'bp',
    text(fc1-.0022,0, '|','Parent',hax);
    text(fc1-.025,-.17,fpassStr1,'Parent',hax);
    text(fc2-.0022,0, '|','Parent',hax);
    text(fc2-.05,-.17,fpassStr2,'Parent',hax);

case 'bs', 
    text(fc1-.0022,0, '|','Parent',hax);
    text(fc1-.04,-.17,fpassStr1,'Parent',hax);
    text(fc2-.0022,0, '|','Parent',hax);
    text(fc2-.025,-.17,fpassStr2,'Parent',hax);        
	
end

%--------------------------------------------------------------------------
function drawFilterMagResp(hax,filtType,filtMethod)
% DRAWFILTERMAGRESP: Draws the magnitude response of the filter, based on the type 
% type of filter(low pass, high pass, bandpass or bandstop), and the function used to 
% create it.(butter, remez, etc...)
%
% Inputs:
%	hax	     - handle to the axis
%	filtType     -	the filter type(low pass, high pass, bandpass or bandstop)
%	filtMethod   -	the function used to create the filter(butter, remez etc...)	


% This function needs to be finished

switch filtType
case 'lp',
    drawLowPassResp(hax,filtMethod)
case 'hp',
    filter_type = [0 0 1 1];  
case 'bp',
    filter_type = [0 0 1 1 0 0];
case 'bs',
    filter_type = [1 1 0 0 1 1];    
end

%--------------------------------------------------------------------------
function drawLowPassResp(hax,filtMethod)
% DRAWLOWPASSRESP Draws the Low pass filter response, based on the filter method
% 
% Inputs:
%    hax         - handle to the axis
%    filtMethod  - the method used to design the filter, butter, remez etc...

% Compute the magnitud response, using appropriate filter design function
switch filtMethod
case 'remez'
    filter_type = [1 1 0 0];    
    b=remez(17,[0 0.4 0.5 1], filter_type);
    a= 1;    
case 'firls'
    filter_type = [1 1 0 0];    
    b=firls(17,[0 0.43 0.47 1], filter_type);
    a= 1;
case 'fir1'
    b = fir1(45,.45);
    a = 1;
case 'butter'
    [b,a] = butter(15, .45);    
case 'cheby1'
    [b,a] = cheby1(10,1,.45);
case 'cheby2'
    [b,a] = cheby2(10,20,.45);
case 'ellip'
    [b,a] = ellip(10,1,20,.45);
otherwise 
    b = 0;
    a = 0;
end

% Draw the magnitude response
[H,W] = freqz(b,a,1024);
line(W/pi,abs(H),'Parent',hax)

%------------------------------------------------------------------------------
function arrow_w_line(hax,x,y,w,h,direction)
% ARROW_W_LINE Draws an line with an arrow head using patch.
% 
% Inputs: 
%   hax   - handle to the axis.
%   x     - 2 element vector specifying the x position of the start (tail) and 
%       	end point (head) of the arrow.
%   y     - 2 element vector specifying the y position of the start (tail) and 
%       	end point (head) of the arrow.

switch direction
case 'up',
    x = [x(1) x(2)   x(2)-w/2 x(2) x(2)+w/2 x(2)   x(1)];
    y = [y(1) y(2)-h y(2)-h   y(2) y(2)-h   y(2)-h y(1)]; 
case 'down',
    x = [x(1) x(2)   x(2)-w/2 x(2) x(2)+w/2 x(2)   x(1)];
    y = [y(1) y(2)+h y(2)+h   y(2) y(2)+h   y(2)+h y(1)]; 
case 'right',
    h = h/3;
    w = w*3.5;
    x = [x(1) x(2)-h  x(2)-h   x(2)  x(2)-h   x(2)-h  x(1)];
    y = [y(1) y(2)    y(2)+w/2 y(2)  y(2)-w/2 y(2)    y(1)]; 
case 'left'
    h = h/3;
    w = w*3.5;
    x = [x(1) x(2)+h  x(2)+h   x(2)  x(2)+h   x(2)+h  x(1)];
    y = [y(1) y(2)    y(2)-w/2 y(2)  y(2)+w/2 y(2)    y(1)];   
    
end

panpatch = patch( ...
    x, ...
    y, ...
    [.8 .8 .8],...
    'erasemode', 'none', ...
    'facecolor',[0 0 0],...
    'edgecolor','black',...
    'clipping','off',...
    'Parent',hax);

%--------------------------------------------------------------------------
function notavalmessage(hax,filtType)
% NOTAVALMESSAGE Display a "Not yet available message"
% 
% Inputs:
%   hax         - Handle to the axis
%   Filtertypes - Filter type that is not available.

switch filtType
    %case 'hilb', filtStr = 'Hilbert Transformer';
case 'arbitrarymag', filtStr = 'Arbitrary shape filter';
otherwise, filtStr = 'current filter';
end

str = ['The static response for the ' filtStr ' is not available.'];
text([.03,.03],[.5,.5],str);

%----------------------------------------------------------------------------
function drawTransitionBandwidth(hax,C)
% Draw the arrows and text showing the transition bandwidth (don't care)

width = 0.05;
arrowsize = [.02,.03];
ypos = .5;
arrow_w_line(hax,[C.passbandEdge-width,C.passbandEdge],[ypos,ypos],...
	arrowsize(1),arrowsize(2),'right');
arrow_w_line(hax,[C.stopbandEdge+width,C.stopbandEdge],[ypos,ypos],...
	arrowsize(1),arrowsize(2),'left');

text(C.passbandEdge+.02,ypos,'BW', 'fontsize',8,'Parent',hax);

%--------------------------------------------------------------------------
function freqUnits = localGetFreqUnits(activeFrames);

hA = find(activeFrames, '-class', 'siggui.specsfsspecifier');

if isempty(hA),
    freqUnits = 'Hz';
else
    freqUnits = get(hA,'units');
end

% ------------------------------------------------------------
function magUnits = localGetMagUnits(ha)

hm = find(ha, '-isa', 'siggui.magspecs');
if isempty(hm),
    if isempty(find(ha, '-isa', 'siggui.weightmagspecs')),
        magUnits = '';
    else
        magUnits = 'weights';
    end
else,
    magUnits = get(hm, hm.IRType);
end

% ------------------------------------------------------------
function mode = getmode(hObj)

mode = 'minimum';
hFO  = find(hObj, '-class', 'siggui.filterorder');
if ~isempty(hFO),
    mode = get(hFO, 'Mode');
end

% ------------------------------------------------------------
function filtType = concatenateFreqSpecType(activeFrames, filtType)

h = find(activeFrames, '-class', 'siggui.firceqripfreqspecs');
FreqSpecType = get(h, 'freqSpecType');

if strncmpi(filtType, 'invsinc', 7), filtType(1:7) = []; end

filtType = [filtType,FreqSpecType];

% [EOF] staticresp.m
