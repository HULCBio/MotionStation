%HGRC Master startup M-file for Handle Graphics.
%   HGRC is automatically executed by MATLAB during startup.
%   It establishes the default figure size and sets a few uicontrol defaults.
%
%	On multi-user or networked systems, the system manager can put
%	any messages, definitions, etc. that apply to all users here.
%
%   HGRC also invokes a STARTUPHG command if the file 'startupHG.m'
%   exists on the MATLAB path.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/01/15 21:05:52 $

% Set the default figure position, in pixels.
% On small screens, make figure smaller, with same aspect ratio.
monitors = get(0, 'MonitorPositions');
screen = monitors(1,:);
if size(monitors,1) > 1
  for i = 1:size(monitors,1)
    if monitors(i,1) < screen(1) && monitors(i,2) < screen(2)
      screen = monitors(i,:);
    end
  end
end
width = screen(3) - screen(1);
height = screen(4) - screen(2);
if any(screen(3:4) ~= 1)  % don't change default if screensize == [1 1]
  if all(cname(1:2) == 'PC')
    if height >= 500
      mwwidth = 560; mwheight = 420;
      if(get(0,'screenpixelsperinch') == 116) % large fonts
        mwwidth = mwwidth * 1.2;
        mwheight = mwheight * 1.2;
      end
    else
      mwwidth = 560; mwheight = 375;
    end
    left = screen(1) + (width - mwwidth)/2;
    bottom = height - mwheight -100 - screen(2);
  else
    if height > 768
      mwwidth = 560; mwheight = 420;
      left = screen(1) + (width-mwwidth)/2;
      bottom = height-mwheight -100 - screen(2);
    else  % for screens that aren't so high
      mwwidth = 512; mwheight = 384;
      left = screen(1) + (width-mwwidth)/2;
      bottom = height-mwheight -76 - screen(2);
    end
  end
  % round off to the closest integer.
  left = floor(left); bottom = floor(bottom);
  mwwidth = floor(mwwidth); mwheight = floor(mwheight);

  rect = [ left bottom mwwidth mwheight ];
  set(0, 'defaultfigureposition',rect);
end

colordef(0,'white') % Set up for white defaults

%% Uncomment the next group of lines to make uicontrols, uimenus
%% and lines look better on monochrome displays.
%if get(0,'ScreenDepth')==1,
%   set(0,'DefaultUIControlBackgroundColor','white');
%   set(0,'DefaultAxesLineStyleOrder','-|--|:|-.');
%   set(0,'DefaultAxesColorOrder',[0 0 0]);
%   set(0,'DefaultFigureColor',[1 1 1]);
%end

%% Uncomment the next line to use Letter paper and inches
%defaultpaper = 'usletter'; defaultunits = 'inches';

%% Uncomment the next line to use A4 paper and centimeters
%defaultpaper = 'A4'; defaultunits = 'centimeters';

%% If neither of the above lines are uncommented then guess
%% which papertype and paperunits to use based on ISO 3166 country code.
if usejava('jvm') && ~exist('defaultpaper','var')
  if any(strncmpi(char(java.util.Locale.getDefault.getCountry), ...
		  {'gb', 'uk', 'fr', 'de', 'es', 'ch', 'nl', 'it', 'ru',...
		   'jp', 'kr', 'tw', 'cn', 'cz', 'sk', 'au', 'dk', 'fi',...
           'gr', 'hu', 'ie', 'il', 'in', 'no', 'pl', 'pt',...
           'ru', 'se', 'tr', 'za'},2))
    defaultpaper = 'A4';
    defaultunits = 'centimeters';
  end
end

%% Set the default if requested
if exist('defaultpaper','var') && exist('defaultunits','var')
  % Handle Graphics defaults
  set(0,'DefaultFigurePaperType',defaultpaper);
  set(0,'DefaultFigurePaperUnits',defaultunits);
end

%% For Japan, set default fonts
lang = lower(get(0,'language'));
if strncmp(lang, 'ja', 2)
   if strncmp(cname,'PC',2)
      set(0,'defaultuicontrolfontname',get(0,'factoryuicontrolfontname'));
      set(0,'defaultuicontrolfontsize',get(0,'factoryuicontrolfontsize'));
      set(0,'defaultaxesfontname',get(0,'factoryuicontrolfontname'));
      set(0,'defaultaxesfontsize',get(0,'factoryuicontrolfontsize'));
      set(0,'defaulttextfontname',get(0,'factoryuicontrolfontname'));
      set(0,'defaulttextfontsize',get(0,'factoryuicontrolfontsize'));

      %% You can control the fixed-width font
      %% with the following command
      % set(0,'fixedwidthfontname','MS Gothic');
   end
end

%% CONTROL OVER FIGURE TOOLBARS:
%% The new figure toolbars are visible when appropriate,
%% by default, but that behavior is controllable
%% by users.  By default, they're visible in figures
%% whose MenuBar property is 'figure', when there are
%% no uicontrols present in the figure.  This behavior
%% is selected by the figure ToolBar property being
%% set to its default value of 'auto'.

%% to have toolbars always on, uncomment this:
%set(0,'defaultfiguretoolbar','figure')

%% to have toolbars always off, uncomment this:
%set(0,'defaultfiguretoolbar','none')

% Clean up workspace.
clear

% Execute startup M-file, if it exists.
if (exist('startuphg','file') == 2) ||...
   (exist('startuphg','file') == 6)
  startuphg
end
