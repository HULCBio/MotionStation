function comp = showplottool (varargin)
% SHOWPLOTTOOL Show or hide one of the plot-editing components for a figure.
%    SHOWPLOTTOOL ('figurepalette') shows the palette for the current figure.
%    SHOWPLOTTOOL ('on', 'figurepalette') also shows the palette for the current figure.
%    SHOWPLOTTOOL ('off', 'figurepalette') hides it.
%    SHOWPLOTTOOL ('toggle', 'figurepalette') toggles its visibility.
%
% The first argument may be the handle to a figure, like so:
%    SHOWPLOTTOOL (h, 'on', 'figurepalette')
%
% The last argument should be one of 'figurepalette', 'plotbrowser', or 'propertyeditor'.

% Copyright 2003-2004 The MathWorks, Inc.


error (nargchk (1,3,nargin))
if nargin == 1                  % ('plotbrowser')
    hfig = gcf;
    arg = 'on';
    compName = lower (varargin{1});
elseif nargin == 2
    if ischar (varargin{1})      % ('off', 'plotbrowser')
        hfig = gcf;
        arg = lower (varargin{1});
    else
        hfig = varargin{1};      % (h, 'plotbrowser')
        arg = 'on';
    end
    compName = lower (varargin{2});
else
    hfig = varargin{1};          % (h, 'off', 'plotbrowser')
    arg = lower (varargin{2});
    compName = lower (varargin{3});
end

if isempty (get (hfig, 'JavaFrame'))
    error (sprintf ('The plot tools are not supported on this platform.'));
end

oldptr = get(hfig,'Pointer');
set (hfig, 'Pointer', 'watch');
compTmp = getplottool (hfig, compName);
switch (arg)
case {'on', 'show'}
    compTmp.setVisible (true);
    plotedit (hfig, 'on');  % very fast if it's already on
case {'off', 'hide'}
    compTmp.setVisible (false);
case 'toggle'
     if compTmp.isVisible == 1
        compTmp.setVisible (false);
     else
        compTmp.setVisible (true);
        plotedit (hfig, 'on');
     end
case 'get'
    % do nothing; just return it
end
figure (hfig);


% Check to see if all the components are either hidden or showing,
% and enable/disable the toolbar buttons accordingly.
% (The pause is there because the AWT thread may not have finished
% building the Java components and making them visible.)
pause (0.1);
fpVisible = isCompVisible (hfig, 'figurepalette');
pbVisible = isCompVisible (hfig, 'plotbrowser');
peVisible = isCompVisible (hfig, 'propertyeditor');
onBtn  = uigettool (hfig, 'Plottools.PlottoolsOn');
offBtn = uigettool (hfig, 'Plottools.PlottoolsOff');
if (fpVisible == false) && ...
   (pbVisible == false) && ...
   (peVisible == false)
     set (onBtn, 'enable', 'on');
     set (offBtn, 'enable', 'off');
elseif (fpVisible == true) && ...
       (pbVisible == true) && ...
       (peVisible == true)
     set (onBtn, 'enable', 'off');
     set (offBtn, 'enable', 'on');
else
     set (onBtn, 'enable', 'on');
     set (offBtn, 'enable', 'on');
end 
set (hfig, 'Pointer', oldptr);

if (nargout > 0)
    comp = compTmp;
end


%% -----------------------------------------------------
function isVisible = isCompVisible (hfig, compName)
if (~isprop (hfig, compName))
    isVisible = false;
else
    comp = getplottool (hfig, compName);
    isVisible = comp.isVisible;
end
