function pj = preparehg( pj, h )
%PREPAREHG Method to ready a Figure for printing.
%   Modify properties of a Figure and its children based on property values 
%   and PrintJob state. Changes include color of objects and size of Figure 
%   on screen if a ResizeFcn needs to be called.
%   Creates and returns a structure with fields containing various data
%   we have to save for restoration of the Figure and its children.
%
%   Ex:
%      pj = PREPAREHG( pj, h ); %modifies PrintJob object pj and Figure h
%
%   See also PRINT, PREPARE, RESTORE, RESTOREHG.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.7 $  $Date: 2004/04/10 23:29:10 $

%   Uses structure because of the danger of not clearing out state variables
%   in the PrintJob object between renderings of different Figures.
%   ResizeFcn          %Original value of ResizeFcn, nulled out during print
%   ResizedWindow      %True if had to resize Figure on screen because of ResizeFcn
%   WindowUnits        %Original Window units while we work in points
%   WindowPos          %Original Window position in original units
%   PixelObjects       %Vector of handles to objects positioned in pixel units
%   FontPixelObjects   %Vector of handles to objects with FontUnits of pixels
%   Inverted           %1 = Force white background 2 = force transparent background
%   Undithered         %True if changed foreground colors of Text and Lines to black
%   Renderer           %Save original renderer if using different one while printing
%   RendererAutoMode   %If setting different renderer, don't change mode as a result
%   PrintTemplate      %Copy of Figure's template for output formating with saved state for later restoration

error( nargchk(2,2,nargin) )

if ~isequal(size(h), [1 1]) | ~isfigure( h )
    error( 'Need a handle to a Figure object.' )
end

fireprintbehavior(h,'PrePrintCallback');

%Early exit, want to save Figure as is.
if strcmp(pj.Driver, 'mfile')
    pj.hgdata = [];
    return
end

%Figures can be formatted for output via a PrintTemplate object
pt = getprinttemplate(h);
if isempty( pt )
    hgdata.PrintTemplate = [];
else
    hgdata.PrintTemplate = ptpreparehg( pt, h );
end

%Fun with resize functions.
%--------------------------
%Make Figure the size it is going to be while printing (i.e. PaperPosition).
%This will cause the user's ResizeFcn to be called while the Figure is
%still at screen resolution. This gives the user a chance to move and
%resize things the way s/he wants. Afterwards the ResizeFcn is nulled,
%always, so that the resizing of the Figure that happens internally
%when changing to the driver resolution does not cause any 
%weird results. For the same reason, objects in Pixel units are
%set to Points so they do not draw screenDPI/driverDPI too small or big.

adjustResizeFcn = 1;
rf = get( h, 'ResizeFcn' );
if isstr(rf)
  if strcmp( rf, 'legend(''ResizeLegend'')' ) ...
		| strcmp( rf, 'doresize(gcbf)')
   
    %This is a known good ResizeFcn, can handle being called during
    %printing, so let's not resize on screen and output the warning.
    hgdata.ResizeFcn = '';
    hgdata.ResizedWindow = 0;
	adjustResizeFcn = 0;
  end
end
if adjustResizeFcn
  hgdata.ResizeFcn = rf;
  if isempty(hgdata.ResizeFcn) | strcmp( 'auto', get( h, 'paperpositionmode' ) )
    hgdata.ResizedWindow = 0;
  else    
    hgdata.ResizedWindow = 1;
    hgdata.WindowUnits = get( h, 'units' );
    hgdata.WindowPos = get( h, 'position' );
    set( h, 'units', 'points' )
    pointsWindowPos = get( h, 'position' );
    pointsPaperPos = getget( h, 'paperposition' ); %already in points units
    set( h, 'units', hgdata.WindowUnits )
    
    if (pointsWindowPos(3)~=pointsPaperPos(3)) | ...
	  (pointsWindowPos(4)~=pointsPaperPos(4))
      warning(sprintf([ ...
	  'Positioning Figure for ResizeFcn.  ',...
	  'Set PaperPositionMode to ''auto''\n',...
	  '         (match figure screen size) to ',...
	  'avoid resizing and this warning.']))
      screenpos( h, [ pointsWindowPos(1:2) pointsPaperPos(3:4) ] );
      %Implicit drawnow in getframe not reliable, may not have any UIControls
      drawnow
    end
  end
  if ~isempty(hgdata.ResizeFcn )
    set( h, 'ResizeFcn', '' );
  end
end

%%%Capture images to stand in place of uicontrols which do not print.
pj = prepareui(pj, h);

%PrintUI stuff may have made, or there already existed, Pixel position Axes.
%Set all Pixel objects to Points so they handle being printed at driver DPI.
hgdata.PixelObjects = [findall(h,'type','axes','units','pixels')
    findall(h,'type','text','units','pixels') ];
if ~isempty( hgdata.PixelObjects )
    set( hgdata.PixelObjects, 'units', 'points' )
end
%Same thing for Axes and Text objects with FontUnits set to pixels.
hgdata.FontPixelObjects = [findall(h,'type','axes','fontunits','pixels')
    findall(h,'type','text','fontunits','pixels') ];
if ~isempty( hgdata.FontPixelObjects )
    set( hgdata.FontPixelObjects, 'fontunits', 'points' )
end


% Possibly invert B&W color properties of Figure and child objects
% The following should be changed when we add "transparent" as a "Inverted" option
% CopyOptions is set in uiw\menu_w.c as a flag to let us know where we came from

hgdata.Inverted = 0;
hasPrefs = 0;
honorPrefs = 0;
if usejava('awt')
  try
    honorPrefs = javaMethod('getIntegerPref', 'com.mathworks.services.Prefs', ...
			     ['CopyOptions.HonorCOPrefs']) ~= 0;
    hasPrefs = 1;
  end
end
if (hasPrefs & honorPrefs)
	figbkcolor = javaMethod('getIntegerPref', 'com.mathworks.services.Prefs', ['CopyOptions.FigureBackground']);
	if isequal(figbkcolor, 0)  % "none"
		hgdata.Inverted = 2;
		colornone('save', h);
	elseif isequal(figbkcolor, 1)
	    hgdata.Inverted = 1;
	    savtoner( 'save', h );
	end
else
 	if strcmp('on', get(h,'InvertHardcopy'))
	    hgdata.Inverted = 1;
	    savtoner( 'save', h );
	end
end

% Possibly set Lines and Text to B or W, what contrasts with background
if blt(pj,h)
    hgdata.Undithered = 0;
else
    hgdata.Undithered = 1;
    nodither( 'save', h );
end

%Deselect all objects so that we do not print their selection handles.
noselection('save',h);

% if printing to JPEG or TIFF file, then we need to convert animated
% objects to 'erasemode','normal' so that they will render into the
% Z-Buffer. Same if producing TIFF for EPS preview of printed Figure.
if strcmp(pj.DriverClass, 'IM') | ((pj.PostScriptPreview == pj.TiffPreview) & ~pj.GhostImage)
    noanimate('save',h);
end

%If not using Painters renderer (i.e. Figure is not set to Painters or user asked for Z) ...
if strcmp(get(h,'rendererMode'),'manual') & ~(strcmp( 'painters', get(h,'renderer')) | strcmp(pj.Renderer,'painters') )                            
    %and if using a driver or on an X system that can not create Zbuffer ...
    if (strcmp(pj.Driver, 'hpgl') | strcmp(pj.Driver, 'ill')) | pj.XTerminalMode
        %just use Painters
        if ~strcmp(pj.Renderer,'painters') & ~isempty(pj.Renderer)
          ren = pj.Renderer;
        else
          ren = get(h,'renderer');
        end
		if ~pj.XTerminalMode
		  warning(sprintf([ ...
			'The %s device option does not support the %s renderer.\n', ...
			'         Printing Figure with Painters renderer.  Figures with \n',...
			'         interpolated shading or images may not print correctly.'], ...
						upper(pj.Driver),ren))
		end
        pj.Renderer = 'painters';
    end
end

% Temporary workaround for opengl printing problem - use zbuffer  - now
% turned off
%if (~isempty( pj.Renderer )  && strcmpi(pj.Renderer, 'opengl')) || ...
%        (isempty( pj.Renderer ) && strcmpi( get(h, 'renderer'), 'opengl'))
%    pj.Renderer = 'zbuffer';
%end

% If renderer is None, set it to painters for the print rendering, then
% set it back.
if strcmp(get(h,'renderer'),'None')
  pj.Renderer = 'painters';
end

% Set render to use while printing now
if ~isempty( pj.Renderer )
    hgdata.Renderer = get( h, 'renderer' );
    hgdata.RendererAutoMode = strcmp( get( h, 'renderermode' ), 'auto' );    
    set( h, 'renderer', pj.Renderer )
end

%Save it in object for later retrevial
pj.hgdata = hgdata;

