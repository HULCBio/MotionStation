function varargout = staticrespengine(fcn, varargin)
%STATICRESPENGINE   Engine for drawing the static responses.
%   STATICRESPENGINE(FCN, HAX, VARARGIN)
%
%   SETUPAXIS
%   DRAWPASSBAND
%   DRAWSTOPBAND
%   DRAWFREQLABELS

%   CONSTRAINT
%   WHITEOUT

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:32:51 $

error(nargchk(2,inf,nargin))

if nargout,
    [varargout{1:nargout}] = feval(fcn, varargin{1:end});
else
    feval(fcn, varargin{1:end});
end

% -------------------------------------------------------------------------
function setupaxis(hax, frequnits, magunits)
% SETUPAXIS Sets up the Axis for the static filter response drawing.
% Inputs:
%	hax		- handle to the axis

% Clean up the axes
delete(allchild(hax));
tag = get(hax, 'Tag');
reset(hax);
set(hax, 'Tag', tag);

% Make the Y- and X-axis a little longer to make room for the arrow head.
xlim = [0 1.1];
ylim = [0 1.7];

% Setup the X-axis properties.
xtick = [0 1];
switch lower(frequnits)
    case {'hz','khz','mhz','ghz'}, xticklabel = {'','Fs/2'};
    case 'normalized (0 to 1)',    xticklabel = {'','1'};
end

% Setup the Y-axis; magnitude units, etc.
ytick = [];
yticklabel = '';
switch lower(magunits)
    case 'db',      ytick = [-1 1]; yticklabel = [0];
    case 'linear',  ytick = [.5 1]; yticklabel = [.5 1];
    case 'squared', ytick = [0 1];  yticklabel = [0 1];
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
text(.01,-.1,'0','Parent',hax);

switch lower(frequnits)
    case 'hz',  xaxStr = 'f (Hz)';  yaxStr = '|H(f)|';
    case 'khz', xaxStr = 'f (kHz)'; yaxStr = '|H(f)|';
    case 'mhz', xaxStr = 'f (MHz)'; yaxStr = '|H(f)|';
    case 'ghz', xaxStr = 'f (GHz)'; yaxStr = '|H(f)|';
    case 'normalized (0 to 1)',
        xaxStr = '\omega (normalized)';
        yaxStr = '|H(\omega)|';
        % Shift xlim over a little bit, for this case only
        % because "normalized" is longer than "Hz"
        xlim(2) = xlim(2) - .05;
end

switch lower(magunits)
    case 'db',      yaxStr = 'Mag. (dB)';
    case 'squared', yaxStr = [yaxStr,'^2'];
end

% Label X-axis units.
text(xlim(2),-.1,xaxStr,'Parent',hax);

% Label Y-axis units.
text(.015,ylim(2)-.1,yaxStr,'Parent',hax);

setappdata(hax, 'magunits', magunits);
setappdata(hax, 'frequnits', frequnits);

% -------------------------------------------------------------------------
function drawpassband(hax, f, a, lbl, pos)

if nargin < 4, lbl = ''; end

% Make sure that the frequencies are in ascending order.
f = sort(f(:)');
a = sort(a(:)');

bf = [f fliplr(f)];
ba = [a(1) a(1) 0 0];

constraint(hax, bf, ba);

ta = a(2) + [.15 .15 0 0];
constraint(hax, bf, ta);
whiteout(hax, bf, ta);

if ~isempty(lbl),
    if nargin < 5
        if f(1) == 0, pos = 'right';
        else,         pos = 'left';  end
    end
    ytop = a(2);
    ybot = a(1);

    w = .01;
    h = .07;

    % Assume that "left/right" for linear/squared goes in the margins.
    
    switch lower(getappdata(hax, 'magunits'))
        case 'db'
            switch lower(pos)
                case 'right', xpos = f(2)+.05;
                case 'left',  xpos = f(1)-.15;
            end
            % Draw the Apass arrows and label.
            hl1 = line([xpos-.02 xpos+.02], [ytop ytop], 'Parent', hax);
            hl2 = line([xpos-.02 xpos+.02], [ybot ybot], 'Parent', hax);
            arrow_w_line(hax, [xpos xpos], [.6  ybot], w, h, 'up');
            arrow_w_line(hax, [xpos xpos], [1.3 ytop], w, h, 'down');
            set([hl1 hl2], 'color', 'black');

            % Draw the String
            text(xpos+.03, .98, lbl, 'Parent', hax);
        case 'linear'
            if ischar(lbl),
                lbl = {sprintf('1+%s',lbl), sprintf('1-%s', lbl)};
            end

            switch lower(pos)
                case 'right'
                    % Passband ripple 1+delta_pass and 1-delta_pass
                    text(1.025,ytop+.15,lbl{1},'Parent',hax);
                    arrow_w_line(hax,[1.06 1],[ytop ytop],w,h,'left');

                    text(1.025,ybot-.15,lbl{2},'Parent',hax);
                    arrow_w_line(hax,[1.06 1],[ybot ybot],w,h,'left');

                case 'left'
                    % Passband ripple 1+delta_pass and 1-delta_pass
                    text(-.155,ytop+.2,lbl{1},'Parent',hax);
                    arrow_w_line(hax,[-.06 0],[ytop ytop],w,h,'right');

                    text(-.155,ybot-.1,lbl{2},'Parent',hax);
                    arrow_w_line(hax,[-.06 0],[ybot ybot],w,h,'right');

            end
            
        case 'squared'
            
            switch lower(pos)
                case 'left'
                    text(-.155,ybot-.1,lbl,'Parent',hax);
                    arrow_w_line(hax,[-.06 0],[ybot ybot],w,h,'right');
                case 'right'
                    text(1.05,ybot-.15,lbl,'Parent',hax);
                    arrow_w_line(hax,[1.06 1],[ybot ybot],w,h,'left');
            end
        case 'weights'
            text(mean(f), yop+.15, lbl, 'Parent', hax);
    end
end

% -------------------------------------------------------------------------
function drawstopband(hax, f, lbl, pos)

if nargin < 3, lbl = ''; end

% Make sure that the frequencies are in ascending order.
f = sort(f(:)');

bf = [f fliplr(f)];
ba = [.25 .25 .1 .1];
constraint(hax, bf, ba);
whiteout(hax, bf, ba);

if ~isempty(lbl)
    %The length and width of the lines and arrows
    w = .01;
    h = .07;
    ytop = 1;
    ybot = .11;

    switch lower(getappdata(hax, 'magunits'))
        case 'db'

            xpos = mean(f);

            % Draw the Astop labels and arrows
            hl1 = line([xpos-.02 xpos+.02],[ytop ytop],'Parent',hax);
            set(hl1,'color','black');
            arrow_w_line(hax,[xpos xpos],[.65 ytop],w,h,'up');
            arrow_w_line(hax,[xpos xpos],[.45 ybot],w,h,'down');
            %Draw the string
            text(xpos-.02,.55,lbl,'Parent',hax);

        case 'linear'
            switch lower(pos)
                case 'left'
                    % Stopband ripple; delta_stop
                    text(-.155,.11,lbl,'Parent',hax);
                    arrow_w_line(hax,[-.06 0],[.11 .11],w,h,'right');
                case 'right'
                    text(1.05,.21,lbl,'Parent',hax);
                    arrow_w_line(hax,[1.06 1],[.11 .11],w,h,'left');
            end

        case 'squared'

            switch lower(pos)
                case 'left'
                    % Stopband ripple; delta_stop
                    text(-.145,.11,lbl,'Parent',hax);
                    arrow_w_line(hax,[-.06 0],[.11 .11],w,h,'right');
                case 'right'
                    % Right edge
                    text(1.05,.21,lbl,'Parent',hax);
                    arrow_w_line(hax,[1.06 1],[.11 .11],w,h,'left');
            end
        case 'weights'
            text(mean(f), yop+.15, lbl, 'Parent', hax);
    end
end

% -------------------------------------------------------------------------
function drawfreqlabels(hax, f, lbl)

% Make sure that the labels are in a cell of strings.
lbl = cellstr(lbl);

for indx = 1:min(length(f), length(lbl))
    w = largestuiwidth(lbl(indx));

    text(f(indx)-.0022,       0,    '|',       'Parent', hax);
    text(f(indx)-w/1000-.005, -.17, lbl{indx}, 'Parent', hax);
end

%----------------------------------------------------------------------------
function drawtransition(hax,f)
% Draw the arrows and text showing the transition bandwidth (don't care)

arrow_w_line(hax, f(1)-[.05 0], [.5 .5], .02, .03, 'right');
arrow_w_line(hax, f(2)+[.05 0], [.5 .5], .02, .03, 'left');

text(f(1)+.02, .5, 'TW', 'fontsize', 8, 'Parent', hax);

% -------------------------------------------------------------------------
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

%------------------------------------------------------------------------------------
function whiteout(hax,xd,yd,type)
% WHITEOUT draws a white line over the constrained region
% 
% Inputs:
%	hax 	- handle to the axis
%	xd 	- x dimensions for the line
%	yd    	- y dimensions for the line
% 	type    - whether the line drawn is a to be over a passband or stopband

line([xd(1) xd(2)],[yd(1) yd(1)],...
    'color','white',...
    'Parent',hax);

% -------------------------------------------------------------------------
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

panpatch = patch(x, y, ...
    [.8 .8 .8], ...
    'erasemode', 'none', ...
    'facecolor',[0 0 0], ...
    'edgecolor','black', ...
    'clipping','off', ...
    'Parent',hax);

% [EOF]
