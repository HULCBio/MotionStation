function varargout = hgexport(H, filename, options, varargin)
%HGEXPORT  Export a figure.
%   HGEXPORT(H, FILENAME) writes the figure H to FILENAME.
%   
%   On MS Windows if the filename is '-clipboard' then the output
%   is put on the clipboard instead of saved to a file. The 
%   format of the output is determined by the renderer. The
%   painters renderer generates a metafile and zbuffer and opengl
%   generate a bitmap.
%
%   See also EXPORTSETUPDLG, PRINT 

%   STYLE = HGEXPORT('readstyle', NAME) reads and returns the style 
%   named NAME.
%   HGEXPORT('writestyle', STYLE, NAME) writes a STYLE file named NAME.
%   STYLE = HGEXPORT('factorystyle') returns the default style.
%   HGEXPORT(H, FILENAME, STYLE) writes the figure H to FILENAME
%   with options initially specified by the object STYLE. Styles
%   are created and edited using the function EXPORTSETUPDLG.
%
%   HGEXPORT(H,FILENAME,STYLE,PARAM1,VAL1,PARAM2,VAL2,...) specifies
%   parameters that control various characteristics of the output
%   file. Any parameter value can be the string 'auto' which means
%   the parameter uses the default factory behavior, overriding
%   any other default for the parameter.
%   Format Paramter:
%     'Format'  a string
%          specifies the output format. Defaults to 'eps'. For a
%          list of export formats type 'help print'.
%     'Preview' one of the strings 'none', 'tiff'
%          specifies a preview for EPS files. Defaults to 'none'.
%
%   Size Parameters:
%     'Width'   a positive scalar
%          specifies the width in the figure's PaperUnits
%     'Height'  a positive scalar
%          specifies the height in the figure's PaperUnits
%     'Units'   a string
%          specifies units for height and width
%     'Bounds' one of the strings 'tight', 'loose'
%          specifies a tight or loose bounding box. Defaults to 'tight'.
%
%     Specifying only one dimension sets the other dimension so that
%     the exported aspect ratio is the same as the figure's current
%     aspect ratio.  If neither dimension is specified the size
%     defaults to the width and height of the figure. Tight bounding
%     boxes are only computed for axes whose OuterPosition extends
%     to the figure boundary (this is true for the default axes and
%     those created by the subplot command).
%           
%   Rendering Parameters:
%     'Color'     one of the strings 'bw', 'gray', 'rgb', 'cmyk'
%         'bw'    specifies that lines and text are exported in
%                 black and all other objects in grayscale
%         'gray'  specifies that all objects are exported in grayscale
%         'rgb'   specifies that all objects are exported in color
%                 using the RGB color space
%         'cmyk'  specifies that all objects are exported in color
%                 using the CMYK color space
%     'Background'   a color specification
%     'Renderer'  one of 'painters', 'zbuffer', 'opengl'
%         specifies the renderer to use
%     'Resolution'   a positive scalar
%         specifies the resolution in dots-per-inch.
%     'LockAxes'  'on' or 'off'
%         specifies that all axes limits should be fixed while
%         exporting.
%     'PSLevel'   1 or 2
%         specifies Postscript language level for EPS format
%     'ShowUI' 'on' or 'off'
%         show uicontrols while exporting.
%     
%     The default color setting is 'rgb'. The default background is 'w'.
%
%   Font Parameters:
%     'FontMode'     one of the strings 'scaled', 'fixed', 'none'
%     'ScaledFontSize'  a percentage
%          in 'scaled' mode is the percentage of the font size of each
%          text object to obtain the exported font size
%     'FixedFontSize' a positive scalar
%          in 'fixed' mode specified the font size in points
%     'FontSizeMin' a positive scalar
%          specifies the minimum font size allowed after scaling
%     'FontName' a string
%     'FontWeight' one of 'light', 'normal', 'demi', 'bold'
%     'FontAngle' one of 'normal', 'italic', 'oblique'
%          specifies the font properties to use for all text
%     'FontEncoding' one of the strings 'latin1', 'adobe'
%          specifies the character encoding of the font
%     'SeparateText' 'on' or 'off'
%          specifies that the text objects are stored in separate
%          file as EPS with the base filename having '_t' appended.
%
%     If FontMode is 'scaled' but ScaledFontSize is not specified then a
%     scaling factor is computed from the ratio of the size of the
%     exported figure to the size of the actual figure.
%
%     The default 'FontMode' setting is 'scaled'.
%
%   Line Width Parameters:
%     'LineMode'     one of the strings 'scaled', 'fixed', 'none'
%     'ScaledLineWidth' a positive scalar
%     'FixedLineWidth' a positive scalar
%     'LineWidthMin' a positive scalar
%          specifies the minimum line width allowed after scaling
%     The semantics of 'Line' parameters are exactly the
%     same as the corresponding 'Font' parameters, except that
%     they apply to line widths instead of font sizes.
%
%   Style Map Parameter:
%     'LineStyleMap'    one of [], 'bw', or a function name or handle
%          specifies how to map line colors to styles. An empty
%          style map means styles are not changed. The style map
%          'bw' is a built-in mapping that maps lines with the same
%          color to the same style and otherwise cycles through the
%          available styles. A user-specified map is a function
%          that takes as input a cell array of lineseries objects and
%          outputs a cell array of line style strings. The default
%          map is []. The linestyle map is applied to all lineseries
%          that have the default linestyle.

%   Copyright 1984-2003 The MathWorks, Inc. 

error(nargchk(1,inf,nargin));

if ischar(H)
  switch H
   case 'readstyle'
    varargout{1} = LocalReadStyle(filename);
    return;
   case 'writestyle'
    LocalWriteStyle(filename,options);
    return;
   case 'factorystyle'
    varargout{1} = LocalFactoryStyle;
    return;
  end
end
if ~LocalIsHG(H,'figure')
  error('First argument must be a handle to a figure.');
end
if ~ischar(filename)
  error('Second argument must be a string.');
end
isClipboard = strcmp(filename,'-clipboard');
if ~ispc && isClipboard, 
  error('Copying to clipboard is not supported on this platform.'); 
end

auto = LocalFactoryStyle;

if nargin < 3
  template = getappdata(H,'Exportsetup');
  if isempty(template)
    try
      template = LocalReadStyle('Default');
    catch
      template = LocalFactoryStyle;
    end
  end
  paramPairs = LocalToCell(template,auto);
else
  paramPairs = LocalToCell(options,auto);
end

if ~isempty(varargin)
  paramPairs = {paramPairs{:}, varargin{:}};
end

opts = auto;

% Process param-value pairs
args = {};
for k = 1:2:length(paramPairs)
  param = lower(paramPairs{k});
  if ~ischar(param)
    error('Optional parameter names must be strings');
  end
  value = paramPairs{k+1};
  
  switch (param)
   case 'format'
    opts.Format = LocalCheckAuto(lower(value),auto.Format);
   case 'preview'
    opts.Preview = LocalCheckAuto(lower(value),auto.Preview);
    if ~strcmp(opts.Preview,{'none','tiff'})
      error('Preview must be ''none'' or ''tiff''.');
    end
   case 'width'
    opts.Width = LocalToNum(value, auto.Width);
    if ~ischar(value) || ~strcmp(value,'auto')
      if ~LocalIsPositiveScalar(opts.Width)
	error('Width must be a numeric scalar > 0');
      end
    end
   case 'height'
    opts.Height = LocalToNum(value, auto.Height);
    if ~ischar(value) || ~strcmp(value,'auto')
      if(~LocalIsPositiveScalar(opts.Height))
	error('Height must be a numeric scalar > 0');
      end
    end
   case 'units'
    opts.Units = LocalCheckAuto(lower(value),auto.Units);
   case 'color'
    opts.Color = LocalCheckAuto(lower(value),auto.Color);
    if ~strcmp(opts.Color,{'bw','gray','rgb','cmyk'})
      error('Color must be ''bw'', ''gray'',''rgb'' or ''cmyk''.');
    end
   case 'background'
    opts.Background = LocalCheckAuto(lower(value),auto.Background);
   case 'fontmode'
    opts.FontMode = LocalCheckAuto(lower(value),auto.FontMode);
    if ~strcmp(opts.FontMode,{'scaled','fixed','none'})
      error('FontMode must be ''scaled'', ''fixed'' or ''none''.');
    end
   case 'scaledfontsize'
    opts.ScaledFontSize = LocalToNum(value,auto.ScaledFontSize);
    if ~ischar(value) || ~strcmp(value,'auto')
      if ~LocalIsPositiveScalar(opts.ScaledFontSize)
	error('ScaledFontSize must be a numeric scalar > 0');
      end
    end
   case 'fixedfontsize'
    opts.FixedFontSize = LocalToNum(value,auto.FixedFontSize);
    if ~ischar(value) || ~strcmp(value,'auto')
      if ~LocalIsPositiveScalar(opts.FixedFontSize)
	error('FixedFontSize must be a numeric scalar > 0');
      end
    end
   case 'fontsizemin'
    opts.FontSizeMin = LocalToNum(value,auto.FontSizeMin);
    if ~ischar(value) || ~strcmp(value,'auto')
      if ~LocalIsPositiveScalar(opts.FontSizeMin)
	error('FontSizeMin must be a numeric scalar > 0');
      end
    end
   case 'fontname'
    opts.FontName = LocalCheckAuto(lower(value),auto.FontName);
    if ~isempty(opts.FontName) && ~ischar(opts.FontName)
      error('FontName must be a string.');
    end
   case 'fontweight'
    opts.FontWeight = LocalCheckAuto(lower(value),auto.FontWeight);
    if ~isempty(opts.FontWeight) && ~ischar(opts.FontWeight)
      error('FontWeight must be a string.');
    end
   case 'fontangle'
    opts.FontAngle = LocalCheckAuto(lower(value),auto.FontAngle);
    if ~isempty(opts.FontAngle) && ~ischar(opts.FontAngle)
      error('FontAngle must be a string.');
    end
   case 'fontencoding'
    opts.FontEncoding = LocalCheckAuto(lower(value),auto.FontEncoding);
    if ~strcmp(opts.FontEncoding,{'latin1','adobe'})
      error('FontEncoding must be ''latin1'' or ''adobe''.');
    end
   case 'pslevel'
    opts.PSLevel = LocalToNum(value,auto.PSLevel);
    if ~ischar(value) || ~strcmp(value,'auto')
      if ((opts.PSLevel ~= 1) && (opts.PSLevel ~= 2))
	error('PSlevel must be 1 or 2');
      end
    end
   case 'linemode'
    opts.LineMode = LocalCheckAuto(lower(value),auto.LineMode);
    if ~strcmp(opts.LineMode,{'scaled','fixed','none'})
      error('LineMode must be ''scaled'', ''fixed'' or ''none''.');
    end
   case 'scaledlinewidth'
    opts.ScaledLineWidth = LocalToNum(value,auto.ScaledLineWidth);
    if ~ischar(value) || ~strcmp(value,'auto')
      if ~LocalIsPositiveScalar(opts.ScaledLineWidth)
	error('ScaledLineWidth must be a numeric scalar > 0');
      end
    end
   case 'fixedlinewidth'
    opts.FixedLineWidth = LocalToNum(value,auto.FixedLineWidth);
    if ~ischar(value) || ~strcmp(value,'auto')
      if ~LocalIsPositiveScalar(opts.FixedLineWidth)
	error('FixedLineWidth must be a numeric scalar > 0');
      end
    end
   case 'linewidthmin'
    opts.LineWidthMin = LocalToNum(value,auto.LineWidthMin);
    if ~ischar(value) || ~strcmp(value,'auto')
      if ~LocalIsPositiveScalar(opts.LineWidthMin)
	error('LineWidthMin must be a numeric scalar > 0');
      end
    end
   case 'linestylemap'
    opts.LineStyleMap = LocalCheckAuto(value,auto.LineStyleMap);
   case 'renderer'
    opts.Renderer = LocalCheckAuto(lower(value),auto.Renderer);
    if ~ischar(value) || ~strcmp(value,'auto')
      if ~strcmp(opts.Renderer,{'painters','zbuffer','opengl'})
	error(['Renderer must be ''painters'', ''zbuffer'' or' ...
	       ' ''opengl''.']);
      end
    end
   case 'resolution'
    opts.Resolution = LocalToNum(value,auto.Resolution);
    if ~ischar(value) || ~strcmp(value,'auto')
      if ~(isnumeric(value) && (numel(value) == 1) && (value >= 0));
	error('Resolution must be a numeric scalar >= 0');
      end
    end
   case 'applystyle' % means to apply the options and not export
    opts.ApplyStyle = LocalToNum(value,auto.ApplyStyle);
   case 'bounds'
    opts.Bounds = LocalCheckAuto(lower(value),auto.Bounds);
    if ~strcmp(opts.Bounds,{'tight','loose'})
      error('Bounds must be ''tight'' or ''loose''.');
    end
   case 'lockaxes'
    opts.LockAxes = LocalCheckAuto(lower(value),auto.LockAxes);
    if ~strcmp(opts.LockAxes,{'on','off'})
      error('LockAxes must be ''on'' or ''off''.');
    end
   case 'showui'
    opts.ShowUI = LocalCheckAuto(lower(value),auto.ShowUI);
    if ~strcmp(opts.ShowUI,{'on','off'})
      error('ShowUI must be ''on'' or ''off''.');
    end
   case 'separatetext'
    opts.SeparateText = LocalCheckAuto(lower(value),auto.SeparateText);
    if ~strcmp(opts.SeparateText,{'on','off'})
      error('Separatetext must be ''on'' or ''off''.');
    end
   case 'version'
    % ignore
   otherwise
    error(['Unrecognized option ' param '.']);
  end
end

alreadyApplied = isappdata(H,'ExportsetupApplied') && ...
    (getappdata(H,'ExportsetupApplied') == true);

allLines  = findall(H, 'type', 'line');
allText   = findall(H, 'type', 'text');
allAxes   = findall(H, 'type', 'axes');
allImages = findall(H, 'type', 'image');
allLights = findall(H, 'type', 'light');
allPatch  = findall(H, 'type', 'patch');
allSurf   = findall(H, 'type', 'surface');
allRect   = findall(H, 'type', 'rectangle');
allFont   = [allText; allAxes];
allColor  = [allLines; allText; allAxes; allLights];
allMarker = [allLines; allPatch; allSurf];
allEdge   = [allPatch; allSurf];
allCData  = [allImages; allSurf];

% need to explicitly get ticks for some invisible figures
get(allAxes,'yticklabel'); 

old.objs = {};
old.prop = {};
old.values = {};

% Process format
if strncmp(opts.Format,'eps',3) && ~strcmp(opts.Preview,'none')
  args = {args{:}, ['-' opts.Preview]};
end

hadError = 0;
oldwarn = warning;
try
  
  if ~alreadyApplied
    % lock axes limits, ticks and labels if requested
    if strcmp(opts.LockAxes,'on')
      old = LocalManualAxesMode(old, allAxes, 'LimMode');
    end  

    % Process size parameters
    oldFigureUnits = get(H, 'Units');
    oldFigPos = get(H,'Position');
    set(H, 'Units', opts.Units);
    figPos = get(H,'Position');
    refsize = figPos(3:4);
    aspectRatio = refsize(1)/refsize(2);
    if strcmp(opts.Width,'auto') && strcmp(opts.Height,'auto')
      opts.Width = refsize(1);
      opts.Height = refsize(2);
    elseif strcmp(opts.Width,'auto')
      opts.Width = opts.Height * aspectRatio;
    elseif strcmp(opts.Height,'auto')
      opts.Height = opts.Width / aspectRatio;
    end
    wscale = opts.Width/refsize(1);
    hscale = opts.Height/refsize(2);
    sizescale = min(wscale,hscale);
    old = LocalPushOldData(old,H,'PaperPositionMode', ...
                           get(H,'PaperPositionMode'));
    set(H, 'PaperPositionMode', 'auto');
    newPos = [figPos(1) figPos(2)+figPos(4)*(1-hscale) ...
              wscale*figPos(3) hscale*figPos(4)];
    old = LocalPushOldData(old,H,'Units', oldFigureUnits);
    old = LocalPushOldData(old,H,'Position', oldFigPos);
    set(H, 'Position', newPos);
    set(H, 'Units', oldFigureUnits);

    old = LocalPushOldData(old,H,'Color', get(H,'Color'));
    old = LocalPushOldData(old,H,'InvertHardcopy', ...
                           get(H,'InvertHardcopy'));
    set(H,'InvertHardcopy','off');
    if ~isempty(opts.Background)
      if ischar(opts.Background) && (opts.Background(1) == '[')
        opts.Background = eval(opts.Background);
      end
      set(H,'Color',opts.Background);
    end

    % process line-style map
    styleAxes = findall(H,'Type','axes','LineStyleOrder','-');
    styleLines = [];
    for k1 = 1:length(styleAxes)
      ch = find(handle(styleAxes(k1)),'-isa','graph2d.lineseries');
      for k2 = 1:length(ch)
        series = ch(k2);
        if strcmp(get(series,'CodeGenLineStyleMode'),'auto')
          styleLines = [styleLines double(series)];
        end
      end
    end
    if ~isempty(opts.LineStyleMap) && ...
	  ~strcmp(opts.LineStyleMap,'none') && ...
	  ~isempty(styleLines)
      oldlstylemode = LocalGetAsCell(styleLines,'CodeGenLineStyleMode');
      old = LocalPushOldData(old, styleLines, {'CodeGenLineStyleMode'}, oldlstylemode);
      oldlstyle = LocalGetAsCell(styleLines,'LineStyle');
      old = LocalPushOldData(old, styleLines, {'LineStyle'}, oldlstyle);
      newlstyle = oldlstyle;
      if ischar(opts.LineStyleMap) && strcmpi(opts.LineStyleMap,'bw')
        newlstyle = LocalMapColorToStyle(styleLines);
      else
        try
          newlstyle = feval(opts.LineStyleMap,styleLines);
        catch
          warning(['Skipping stylemap. ' lasterr]);
        end
      end
      set(styleLines,{'LineStyle'},newlstyle);
    end
  end
  
  % Process rendering parameters
  if (opts.PSLevel==2) && strncmp(opts.Format,'eps',3)
    opts.Format = [opts.Format '2'];
  end
  switch (opts.Color)
   case {'bw', 'gray'}
    if ~strcmp(opts.Color,'bw') && strncmp(opts.Format,'eps',3)
      opts.Format = [opts.Format 'c'];
    end
    args = {args{:}, ['-d' opts.Format]};

    if ~alreadyApplied
      %compute and set gray colormap
      oldcmap = get(H,'Colormap');
      newgrays = 0.30*oldcmap(:,1) + 0.59*oldcmap(:,2) + 0.11*oldcmap(:,3);
      newcmap = [newgrays newgrays newgrays];
      old = LocalPushOldData(old, H, 'Colormap', oldcmap);
      set(H, 'Colormap', newcmap);

      %compute and set ColorSpec and CData properties
      old = LocalUpdateColors(allColor, 'Color', old);
      old = LocalUpdateColors(allAxes, 'XColor', old);
      old = LocalUpdateColors(allAxes, 'YColor', old);
      old = LocalUpdateColors(allAxes, 'ZColor', old);
      old = LocalUpdateColors(allMarker, 'MarkerEdgeColor', old);
      old = LocalUpdateColors(allMarker, 'MarkerFaceColor', old);
      old = LocalUpdateColors(allEdge, 'EdgeColor', old);
      old = LocalUpdateColors(allEdge, 'FaceColor', old);
      old = LocalUpdateColors(allCData, 'CData', old);

      if strcmp(opts.Color,'bw')
        tiny = 100*eps;
        loopProps = {allLines,'Color',allText,'Color',allAxes,'XColor',allAxes,'YColor',...
                     allAxes,'ZColor',allMarker,'MarkerEdgeColor', ...
                     allEdge,'EdgeColor'};
        N = length(loopProps)/2;
        for p = 1:N
          objs = loopProps{2*p-1};
          lcolor = LocalGetAsCell(objs,loopProps{2*p});
          n = length(lcolor);
          for k=1:n
            if isnumeric(lcolor{k})
              if (lcolor{k}(1) < 1-tiny)
                set(objs(k),loopProps{2*p},'k');
              end
            elseif ischar(lcolor{k}) && ~strcmp(lcolor{k},'none')
                set(objs(k),loopProps{2*p},'k');
            end
          end
        end
      end
    end
   case {'rgb','cmyk'}
    if strncmp(opts.Format,'eps',3)
      opts.Format = [opts.Format 'c'];
      args = {args{:}, ['-d' opts.Format]};
      if strcmp(opts.Color,'cmyk')
	args = {args{:}, '-cmyk'};
      end
    else
      args = {args{:}, ['-d' opts.Format]};
    end
   otherwise
    error('Invalid Color parameter');
  end
  if ~alreadyApplied
    if ~isempty(opts.Renderer) && ~strcmp(opts.Renderer,'auto')
      old = LocalPushOldData(old,H,'RendererMode', ...
                             get(H,'RendererMode'));
      old = LocalPushOldData(old,H,'Renderer', ...
                             get(H,'Renderer'));
      set(H,'Renderer',opts.Renderer);
    end
    if (~isempty(opts.ShowUI) && strcmp(opts.ShowUI,'off'))
      uicontrols = findall(H,'Type','uicontrol','Visible','on');
      old = LocalPushOldData(old,uicontrols,'Visible', 'on');
      set(uicontrols,'Visible','off');
    end
  end
  if ~strcmp(opts.Resolution,'auto') ||	~strncmp(opts.Format,'eps',3)
    if strcmp(opts.Resolution,'auto')
      opts.Resolution = 0;
    end
    args = {args{:}, ['-r' int2str(opts.Resolution)]};
  end

  if ~alreadyApplied
    % Process font parameters
    if ~isempty(opts.FontMode) && ~strcmp(opts.FontMode,'none')
      oldfonts = LocalGetAsCell(allFont,'FontSize');
      oldfontunits = LocalGetAsCell(allFont,'FontUnits');
      set(allFont,'FontUnits','points');
      switch (opts.FontMode)
       case 'fixed'
        set(allFont,'FontSize',opts.FixedFontSize);
       case 'scaled'
        if strcmp(opts.ScaledFontSize,'auto')
          scale = sizescale;
        else
          scale = opts.ScaledFontSize/100;
        end
        newfonts = LocalScale(oldfonts,scale,opts.FontSizeMin);
        set(allFont,{'FontSize'},newfonts);
       otherwise
        error('Invalid FontMode parameter');
      end
      old = LocalPushOldData(old, allFont, {'FontSize'}, oldfonts);
      old = LocalPushOldData(old, allFont, {'FontUnits'}, oldfontunits);
    end
    if ~isempty(opts.FontName) && ~strcmp(opts.FontName,'auto')
      oldnames = LocalGetAsCell(allFont,'FontName');
      set(allFont,'FontName',opts.FontName);
      old = LocalPushOldData(old, allFont, {'FontName'}, oldnames);
    end
    if ~isempty(opts.FontWeight) && ~strcmp(opts.FontWeight,'auto')
      oldweights = LocalGetAsCell(allFont,'FontWeight');
      set(allFont,'FontWeight',opts.FontWeight);
      old = LocalPushOldData(old, allFont, {'FontWeight'}, oldweights);
    end
    if ~isempty(opts.FontAngle) && ~strcmp(opts.FontAngle,'auto')
      oldangles = LocalGetAsCell(allFont,'FontAngle');
      set(allFont,'FontAngle',opts.FontAngle);
      old = LocalPushOldData(old, allFont, {'FontAngle'}, oldangles);
    end
  end
  if strcmp(opts.FontEncoding,'adobe') && strncmp(opts.Format,'eps',3)
    args = {args{:}, '-adobecset'};
  end

  if ~alreadyApplied
    % Process line parameters
    if ~isempty(opts.LineMode) && ~strcmp(opts.LineMode,'none')
      target = [allMarker; allAxes];
      oldlines = LocalGetAsCell(target,'LineWidth');
      old = LocalPushOldData(old, target, {'LineWidth'}, oldlines);
      switch (opts.LineMode)
       case 'fixed'
        set(target,'LineWidth',opts.FixedLineWidth);
       case 'scaled'
        if strcmp(opts.ScaledLineWidth,'auto')
          scale = sizescale;
        else
          scale = opts.ScaledLineWidth/100;
        end
        newlines = LocalScale(oldlines, scale, opts.LineWidthMin);
        set(target,{'LineWidth'},newlines);
      end
    end
  end

  % adjust figure bounds to surround axes
  if ~isempty(allAxes)
    args = {args{:}, '-loose'};
    if strcmp(opts.Bounds,'tight') && ~alreadyApplied
      ok = true(1,length(allAxes));
      for k=1:length(allAxes)
        if isappdata(allAxes(k),'NonDataObject')
          ok(k) = false;
        end
      end
      allDataAxes = allAxes(ok);
      warpModes = LocalGetAsCell(allDataAxes,'WarpToFillMode');
      old = LocalPushOldData(old, allDataAxes, {'WarpToFillMode'}, warpModes);
      warpModes = LocalGetAsCell(allDataAxes,'WarpToFill');
      old = LocalPushOldData(old, allDataAxes, {'WarpToFill'}, warpModes);
      set(allDataAxes,'WarpToFill','on')

      posModes = LocalGetAsCell(allDataAxes,'ActivePositionProperty');
      ax = allDataAxes(strcmp(posModes,'outerposition'));
      inset = LocalGetAsCell(ax,'LooseInset');
      outpos = LocalGetAsCell(ax,'OuterPosition');
      old = LocalPushOldData(old, ax, {'OuterPosition'}, outpos);
      old = LocalPushOldData(old, ax, {'LooseInset'}, inset);
      old = LocalPushOldData(old, ax, {'Units'}, LocalGetAsCell(ax,'Units'));
      set(ax,'Units','normalized');
      if length(ax) == 1,
        set(ax,'OuterPosition',[0 0 1 1],'LooseInset',[0 0 0 0]);
      elseif length(ax)  > 1,
	slop = [inf inf inf inf];
        voutpos = vertcat(outpos{:});
        edge = [min(voutpos(:,1:2)) max(voutpos(:,1:2)+voutpos(:,3:4))];
	for k=1:length(ax)
	  op = outpos{k};
	  loose = inset{k};
	  tight = get(ax(k),'TightInset');
          % compute the minimum "slop" around each edge
	  if abs(edge(1)-op(1)) < 100*eps
	    slop(1) = max(0,min(slop(1),(loose(1)*op(3)) - tight(1)));
	  end
	  if abs(edge(2)-op(2)) < 100*eps
	    slop(2) = max(0,min(slop(2),(loose(2)*op(4)) - tight(2)));
	  end
	  if abs(edge(3)-op(1)-op(3)) < 100*eps
	    slop(3) = max(0,min(slop(3),(loose(3)*op(3)) - tight(3)));
	  end
	  if abs(edge(4)-op(2)-op(4)) < 100*eps
	    slop(4) = max(0,min(slop(4),(loose(4)*op(4)) - tight(4)));
	  end
	end
	if all(isfinite(slop))
	  h = 1+slop(1)+slop(3);
	  v = 1+slop(2)+slop(4);
	  for k=1:length(ax)
	    op = outpos{k};

            % apply affine map to expand outer positions
	    op(1:2) = op(1:2) - slop(1:2);
	    op = op.*[h v h v];

            % transform loose inset to be relative to figure
            % position so that arithmetic below is simpler
            loose = inset{k}.*[op(3:4) op(3:4)];
            % now clamp outside outer positions to fit in figure
	    if op(1) < 0
              % trim left loose inset and left outerposition
	      loose(1) = loose(1) + op(1);
              op(3) = op(3) + op(1);
	      op(1) = 0;
	    end
	    if op(2) < 0
              % trim right loose inset and right outerposition
	      loose(2) = loose(2) + op(2);
              op(4) = op(4) + op(2);
	      op(2) = 0;
	    end
	    if op(1) + op(3) > 1
              % trim right loose inset and right outerposition
	      loose(3) = loose(3) - (op(1)+op(3)-1);
	      op(3) = 1-op(1);
	    end
	    if op(2) + op(4) > 1
              % trim top loose inset and top outerposition
	      loose(4) = loose(4) - (op(2)+op(4)-1);
	      op(4) = 1-op(2);
	    end
            % transform loose inset back to be relative to outerposition
            inset{k} = loose./[op(3:4) op(3:4)];

	    outpos{k} = op;
	  end      
	  set(ax,{'OuterPosition'},outpos);
	  set(ax,{'LooseInset'},inset);
	end
      end
    end
  end

  % Process text in a separate file if needed
  if ~isequal(opts.ApplyStyle,1)
    if strcmp(opts.SeparateText,'on') && ~isClipboard
      % First hide all text and export
      oldtvis = LocalGetAsCell(allText,'visible');
      set(allText,'visible','off');
      oldax = LocalGetAsCell(allAxes,'XTickLabel',1);
      olday = LocalGetAsCell(allAxes,'YTickLabel',1);
      oldaz = LocalGetAsCell(allAxes,'ZTickLabel',1);
      null = cell(length(oldax),1);
      [null{:}] = deal([]);
      set(allAxes,{'XTickLabel'},null);
      set(allAxes,{'YTickLabel'},null);
      set(allAxes,{'ZTickLabel'},null);
      print(H, filename, args{:});
      set(allText,{'Visible'},oldtvis);
      set(allAxes,{'XTickLabel'},oldax);
      set(allAxes,{'YTickLabel'},olday);
      set(allAxes,{'ZTickLabel'},oldaz);
      % Now hide all non-text and export as eps in painters
      [path, name, ext] = fileparts(filename);
      tfile = fullfile(path,[name '_t.eps']);
      tfile2 = fullfile(path,[name '_t2.eps']);
      foundRenderer = 0;
      for k=1:length(args)
        if strncmp('-d',args{k},2)
          args{k} = '-deps';
        elseif strncmp('-zbuffer',args{k},8) || ...
              strncmp('-opengl', args{k},6)
          args{k} = '-painters';
          foundRenderer = 1;
        end
      end
      if ~foundRenderer
        args = {args{:}, '-painters'};
      end
      allNonText = [allLines; allLights; allPatch; ...
                    allImages; allSurf; allRect];
      oldvis = LocalGetAsCell(allNonText,'Visible');
      oldc = LocalGetAsCell(allAxes,'Color');
      oldaxg = LocalGetAsCell(allAxes,'XGrid');
      oldayg = LocalGetAsCell(allAxes,'YGrid');
      oldazg = LocalGetAsCell(allAxes,'ZGrid');
      [null{:}] = deal('off');
      set(allAxes,{'XGrid'},null);
      set(allAxes,{'YGrid'},null);
      set(allAxes,{'ZGrid'},null);
      set(allNonText,'Visible','off');
      set(allAxes,'Color','none');
      print(H, tfile2, args{:});
      set(allNonText,{'Visible'},oldvis);
      set(allAxes,{'Color'},oldc);
      set(allAxes,{'XGrid'},oldaxg);
      set(allAxes,{'YGrid'},oldayg);
      set(allAxes,{'ZGrid'},oldazg);
      %hack up the postscript file
      fid1 = fopen(tfile,'w');
      fid2 = fopen(tfile2,'r');
      line = fgetl(fid2);
      while ischar(line)
        if strncmp(line,'%%Title',7)
          fprintf(fid1,'%s\n',['%%Title: ', tfile]);
        elseif (length(line) < 3) 
          fprintf(fid1,'%s\n',line);
        elseif ~strcmp(line(end-2:end),' PR') && ...
              ~strcmp(line(end-1:end),' L')
          fprintf(fid1,'%s\n',line);
        end
        line = fgetl(fid2);
      end
      fclose(fid1);
      fclose(fid2);
      delete(tfile2);
    elseif ~isClipboard
      print(H, filename, args{:});
    else
      driver = find(strncmp(args,'-d',2));
      if strcmp(get(H,'renderer'),'painters')
        args{driver} = '-dmeta';
      else
        args{driver} = '-dbitmap';
      end
      print(H, args{:});
    end
  end
  warning(oldwarn);
  
catch
  warning(oldwarn);
  hadError = 1;
end

% Restore figure settings
if isequal(opts.ApplyStyle,1)
  varargout{1} = old;
else
  for n=1:length(old.objs)
    if ~iscell(old.values{n}) && iscell(old.prop{n})
      old.values{n} = {old.values{n}};
    end
    set(old.objs{n}, old.prop{n}, old.values{n});
  end
end

if hadError
  error(deblank(lasterr));
end

%
%  Local Functions
%

function outData = LocalPushOldData(inData, objs, prop, values)
outData.objs = {objs, inData.objs{:}};
outData.prop = {prop, inData.prop{:}};
outData.values = {values, inData.values{:}};

function cellArray = LocalGetAsCell(fig,prop,allowemptycell);
cellArray = get(fig,prop);
if nargin < 3
  allowemptycell = 0;
end
if ~iscell(cellArray) && (allowemptycell || ~isempty(cellArray))
  cellArray = {cellArray};
end

function newArray = LocalScale(inArray, scale, minv)
n = length(inArray);
newArray = cell(n,1);
for k=1:n
  newArray{k} = max(minv,scale*inArray{k}(1));
end

function gray = LocalMapToGray1(color)
gray = color;
if ischar(color)
  switch color(1)
   case 'y'
    color = [1 1 0];
   case 'm'
    color = [1 0 1];
   case 'c'
    color = [0 1 1];
   case 'r'
    color = [1 0 0];
   case 'g'
    color = [0 1 0];
   case 'b'
    color = [0 0 1];
   case 'w'
    color = [1 1 1];
   case 'k'
    color = [0 0 0];
  end
end
if ~ischar(color)
  gray = 0.30*color(1) + 0.59*color(2) + 0.11*color(3);
end

function newArray = LocalMapToGray(inArray);
n = length(inArray);
newArray = cell(n,1);
for k=1:n
  color = inArray{k};
  if ~isempty(color)
    color = LocalMapToGray1(color);
  end
  if isempty(color) || ischar(color)
    newArray{k} = color;
  else
    newArray{k} = [color color color];
  end
end

function newArray = LocalMapColorToStyle(inArray);
inArray = LocalGetAsCell(inArray,'Color');
n = length(inArray);
newArray = cell(n,1);
styles = {'-','--',':','-.'};
uniques = [];
nstyles = length(styles);
for k=1:n
  gray = LocalMapToGray1(inArray{k});
  if isempty(gray) || ischar(gray) || gray < .05
    newArray{k} = '-';
  else
    if ~isempty(uniques) && any(gray == uniques)
      ind = find(gray==uniques);
    else
      uniques = [uniques gray];
      ind = length(uniques);
    end
    newArray{k} = styles{mod(ind-1,nstyles)+1};
  end
end

function newArray = LocalMapCData(inArray);
n = length(inArray);
newArray = cell(n,1);
for k=1:n
  color = inArray{k};
  if (ndims(color) == 3) && isa(color,'double')
    gray = 0.30*color(:,:,1) + 0.59*color(:,:,2) + 0.11*color(:,:,3);
    color(:,:,1) = gray;
    color(:,:,2) = gray;
    color(:,:,3) = gray;
  end
  newArray{k} = color;
end

function outData = LocalUpdateColors(inArray, prop, inData)
value = LocalGetAsCell(inArray,prop);
outData.objs = {inData.objs{:}, inArray};
outData.prop = {inData.prop{:}, {prop}};
outData.values = {inData.values{:}, value};
if (~isempty(value))
  if strcmp(prop,'CData') 
    value = LocalMapCData(value);
  else
    value = LocalMapToGray(value);
  end
  set(inArray,{prop},value);
end

function bool = LocalIsPositiveScalar(value)
bool = isnumeric(value) && ...
       prod(size(value)) == 1 && ...
       value > 0;

function value = LocalToNum(value,auto)
if ischar(value)
  if strcmp(value,'auto')
    value = auto;
  else
    value = str2num(value);
  end
end

function c = LocalIsHG(obj,hgtype)
c = 0;
if (length(obj) == 1) && ishandle(obj) 
  c = strcmp(get(obj,'type'),hgtype);
end

function c = LocalManualAxesMode(old, allAxes, base)
xs = ['X' base];
ys = ['Y' base];
zs = ['Z' base];
xlog = LocalGetAsCell(allAxes,'xscale');
ylog = LocalGetAsCell(allAxes,'yscale');
zlog = LocalGetAsCell(allAxes,'zscale');
nonlogxflag = logical([]);
nonlogyflag = logical([]);
nonlogzflag = logical([]);
for k = 1:length(xlog)
  nonlogxflag(k) =  logical(~strcmp(xlog{k},'log'));
  nonlogyflag(k) =  logical(~strcmp(ylog{k},'log'));
  nonlogzflag(k) =  logical(~strcmp(zlog{k},'log'));
end
allNonLogXAxes = allAxes(nonlogxflag);
allNonLogYAxes = allAxes(nonlogyflag);
allNonLogZAxes = allAxes(nonlogzflag);
oldXMode = LocalGetAsCell(allNonLogXAxes,xs);
oldYMode = LocalGetAsCell(allNonLogYAxes,ys);
oldZMode = LocalGetAsCell(allNonLogZAxes,zs);
old = LocalPushOldData(old, allNonLogXAxes, {xs}, oldXMode);
old = LocalPushOldData(old, allNonLogYAxes, {ys}, oldYMode);
old = LocalPushOldData(old, allNonLogZAxes, {zs}, oldZMode);
set(allNonLogXAxes,xs,'manual');
set(allNonLogYAxes,ys,'manual');
set(allNonLogZAxes,zs,'manual');
c = old;

function val = LocalCheckAuto(val, auto)
if ischar(val) && strcmp(val,'auto')
  val = auto;
end

function auto = LocalFactoryStyle
auto.Version = 1;
auto.Format = 'eps';
auto.Preview = 'none';
auto.Width = 'auto';
auto.Height = 'auto';
auto.Units = get(0,'DefaultFigurePaperUnits');
auto.Color = 'rgb';
auto.Background = 'w';
auto.FixedFontSize=10;
auto.ScaledFontSize='auto';
auto.FontMode='scaled';
auto.FontSizeMin = 8;
auto.FixedLineWidth = 1.0;
auto.ScaledLineWidth = 'auto';
auto.LineMode='none';
auto.LineWidthMin = 0.5;
auto.FontName = 'auto';
auto.FontWeight = 'auto';
auto.FontAngle = 'auto';
auto.FontEncoding = 'latin1';
auto.PSLevel = 2;
auto.Renderer = 'auto';
auto.Resolution = 'auto';
auto.LineStyleMap = 'none';
auto.ApplyStyle = 0;
auto.Bounds = 'loose';
auto.LockAxes = 'on';
auto.ShowUI = 'on';
auto.SeparateText = 'off';

%convert a struct to {field1,val1,field2,val2,...}
function c = LocalToCell(s,auto)
f = fieldnames(s);
v = struct2cell(s);
dup = false(length(f),1);
for k=1:length(f)
  try
    if isequal(auto.(f{k}),s.(f{k}))
      dup(k) = true;
    end
  end
end
f(dup) = [];
v(dup) = [];
opts = cell(2,length(f));
opts(1,:) = f;
opts(2,:) = v;
c = {opts{:}};

function h = LocalReadStyle(stylename)
stylefile = fullfile(prefdir(0),'ExportSetup',[stylename '.txt']);
if ~exist(stylefile)
  error(['Style ''' stylename ''' does not exist.']);
end
[p,v] = textread(stylefile,'%s%s%*[^\n]');
h = hgexport('factorystyle');
for k=1:length(p)
  h.(p{k}) = v{k};
end

function LocalWriteStyle(h,stylename)
stylefile = fullfile(prefdir(0),'ExportSetup',[stylename '.txt']);
fid = fopen(stylefile,'wt');
props = fieldnames(h);
for k=1:length(props)
  prop = props{k};
  val = h.(props{k});
  if isempty(val)
    if ischar(val)
      fprintf(fid,'%s \n',prop);
    else
      fprintf(fid,'%s []\n',prop);
    end
  elseif ischar(val)
    fprintf(fid,'%s %s\n',prop,val);
  else
    fprintf(fid,'%s %g\n',prop,val);
  end
end
fclose(fid);
