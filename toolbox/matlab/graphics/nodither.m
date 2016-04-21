function nodither( state, fig )
%NODITHER Modify figure to avoid dithered lines.
%   NODITHER(STATE,FIG) modifies the color of graphics objects to
%   black or white, whichever best contrasts the figure and axis
%   colors.  STATE is either 'save' to set up colors for black
%   background or 'restore'.
%
%   NODITHER(STATE) operates on the current figure.
%
%   See also SAVTONER, BWCONTR, PRINT

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.35.4.3 $  $Date: 2004/04/10 23:28:56 $

if nargin == 0 ...
	   | ~isstr( state ) ...
	   | ~(strcmp(state, 'save') | strcmp(state, 'restore'))
  error('NODITHER needs to know if it should ''save'' or ''restore''')
elseif nargin ==1
  fig = gcf;
end

persistent NoDitherOriginalColors;

if strcmp(get(fig,'color'),'none')
  return % Don't do anything -- Assume all users of 'none' have already
	 % mapped their colors if so desired.
end

NONE = [NaN NaN NaN];
AUTO = [Inf Inf Inf];
FLAT = [-1 -1 -1];
INTERP = [-Inf -Inf -Inf];
TEXTUREMAP = [-Inf -1 -Inf];
BLACK = [0 0 0];
WHITE = [1 1 1];

if strcmp( state, 'save' )
  
  di.axes = [];
  di.line = [];
  di.patch = [];
  di.surface = [];
  di.text = [];
  di.rect = [];
  
  figColor = get(fig,'color');
  figContrast = bwcontr(figColor);
  
  allAxes = findall( fig, 'type', 'axes' );
  naxes = length(allAxes);
  di.axes = zeros(naxes,10);
  for k = 1:naxes
    a = allAxes(k);

    axColor = get(a,'color');
    if (isequal(axColor,'none'))
      axContrast = figContrast;
    else
      axContrast = bwcontr(axColor);
    end
    
    % Make sure that X-, Y-, and ZColors are one of:
    %   - white
    %   - black
    %   - figColor
    %   - figContrast
    
    axc = get(a,'xcolor');
    ayc = get(a,'ycolor');
    azc = get(a,'zcolor');
    di.axes(k,:) = [a axc ayc azc];

    % filter out legends because they are automatically updated
    if strcmp(get(a,'tag'), 'legend')
      continue;
    end

    if (~isequal(axc,BLACK) & ~isequal(axc,WHITE) & ~isequal(axc,figColor))
      set(a,'xcolor',figContrast)
    end
    if (~isequal(ayc,BLACK) & ~isequal(ayc,WHITE) & ~isequal(ayc,figColor))
      set(a,'ycolor',figContrast)
    end
    if (~isequal(azc,BLACK) & ~isequal(azc,WHITE) & ~isequal(azc,figColor))
      set(a,'zcolor',figContrast)
    end
    
    lobjs = findall(a,'type','line','Visible','on');
    pobjs = findall(a,'type','patch','Visible','on');
    sobjs = findall(a,'type','surface','Visible','on');
    tobjs = findall(a,'type','text','Visible','on');
    robjs = findall(a,'type','rectangle','Visible','on');
    nlobjs = length(lobjs);
    npobjs = length(pobjs);
    nsobjs = length(sobjs);
    ntobjs = length(tobjs);
    nrobjs = length(robjs);
    already.line    = size(di.line,1);
    already.patch   = size(di.patch,1);
    already.surface = size(di.surface,1);
    already.text    = size(di.text,1);
    already.rect    = size(di.rect,1);
    di.line    = [di.line;    zeros(nlobjs,10)];% handle, color, marker edge/face
    di.patch   = [di.patch;   zeros(npobjs,13)]; % handle, facecolor, edgecolor, markeredge/face
    di.surface = [di.surface; zeros(nsobjs,13)]; % handle, facecolor, edgecolor, markeredge/face
    di.tobjs   = [di.text;    zeros(ntobjs,4)]; % handle, color
    di.rect    = [di.rect;    zeros(nrobjs,4)]; % handle, edgecolor
    
    for k = 1:nlobjs
      l = lobjs(k);
      lcolor = get(l,'color');
      lmecolor = get(l,'markeredgecolor');
      lmfcolor = get(l,'markerfacecolor');
      
      if (strcmp(lmecolor,'none'))
	di.line(already.line+k,1:7) = [l lcolor NONE];
      elseif (strcmp(lmecolor,'auto'))
	di.line(already.line+k,1:7) = [l lcolor AUTO];
      else
	di.line(already.line+k,1:7) = [l lcolor lmecolor];
      end
      if (strcmp(lmfcolor,'none'))
	di.line(already.line+k,8:10) = NONE;
      elseif (strcmp(lmfcolor,'auto'))
	di.line(already.line+k,8:10) = AUTO;
      else
	di.line(already.line+k,8:10) = lmfcolor;
      end

      if (~isequal(lcolor,BLACK) & ~isequal(lcolor,WHITE) & ...
	  ~isequal(lcolor,axColor))
	set(l,'color',axContrast)
      end
      
      if ~isstr(lmfcolor) & ~isequal(lmfcolor,BLACK) & ...
	    ~isequal(lmfcolor,WHITE) & ~isequal(lmfcolor,axColor)
	if (isequal(lmfcolor,axContrast))
	  set(l,'markerfacecolor',1-axContrast)
	else
	  set(l,'markerfacecolor',axContrast)
	end
      end
      
      %Don't change EdgeColor if it's one of the strings
      %  or the same color as the face itself.
      if ~isstr(lmecolor) & ~isequal(lmecolor,BLACK) & ...
	    ~isequal(lmecolor,WHITE) & ~isequal(lmecolor,axColor)
	if ~isequal( lmecolor, get(l,'markerfacecolor') )
	  if (isequal(lmfcolor,axContrast))
	    set(l,'markeredgecolor',1-axContrast)
	  else
	    set(l,'markeredgecolor',axContrast)
	  end
	end
      end
    end
    
    for k = 1:npobjs
      p = pobjs(k);
      pecolor = get(p,'edgecolor');
      pfcolor = get(p,'facecolor');
      pmecolor = get(p,'markeredgecolor');
      pmfcolor = get(p,'markerfacecolor');
      
      if (strcmp(pfcolor,'none'))
	pf1x3 = NONE;
      elseif (strcmp(pfcolor,'flat'))
	pf1x3 = FLAT;
      elseif (strcmp(pfcolor,'interp'))
	pf1x3 = INTERP;
      else
	pf1x3 = pfcolor;
      end
      
      if (strcmp(pecolor,'none'))
	pe1x3 = NONE;
      elseif (strcmp(pecolor,'flat'))
	pe1x3 = FLAT;
      elseif (strcmp(pecolor,'interp'))
	pe1x3 = INTERP;
      else
	pe1x3 = pecolor;
      end
      
      if (strcmp(pmecolor,'none'))
	pme1x3 = NONE;
      elseif (strcmp(pmecolor,'auto'))
	pme1x3 = AUTO;
      elseif (strcmp(pmecolor,'flat'))
	pme1x3 = FLAT;
      else
	pme1x3 = pmecolor;
      end
      
      if (strcmp(pmfcolor,'none'))
	pmf1x3 = NONE;
      elseif (strcmp(pmfcolor,'auto'))
	pmf1x3 = AUTO;
      elseif (strcmp(pmfcolor,'flat'))
	pmf1x3 = FLAT;
      else
	pmf1x3 = pmfcolor;
      end
      
      di.patch(already.patch+k,:) = [p pf1x3 pe1x3 pme1x3 pmf1x3];
      
      edgesUseCdata = strcmp(pecolor,'flat') | strcmp(pecolor,'interp');
      markerEdgesUseCdata = strcmp(pmecolor,'flat') | ...
	  (strcmp(pmecolor,'auto') & edgesUseCdata);
      XdataNanPos = isnan(get(p, 'xdata'));
      CdataNanPos = isnan(get(p, 'cdata'));
      nanInCdata = any(CdataNanPos);
      
      %Don't change EdgeColor if it is:
      % a) it is the same as the FaceColor
      % b) is None
      % c) is same as the Axes background
      % d) it is Black or White
      % e) the edges use cdata and there is a nan in the
      %    cdata and the position of the nans in the cdata
      %    and xdata differ (Contour plots have nans in cdata
      %    and vertices in the same positions -> we do want
      %    to change the edgecolors to black. But we do not
      %    want edges with nans in cdata without a corresponding
      %    nan in the vertices to suddenly appear when printing.)
      if ~( isequal(pecolor, pfcolor) | strcmp(pecolor,'none') | ...
	    isequal(pecolor,axColor) ...
	    | isequal(pecolor,BLACK) | isequal(pecolor,WHITE) ...
	    | (edgesUseCdata & nanInCdata & ~isequal(XdataNanPos, CdataNanPos)))
	if (isequal(pfcolor,axContrast))
	  set(p,'edgecolor',1-axContrast)
	else
	  set(p,'edgecolor',axContrast)
	end
	edgecolormapped = 1;
      else
	edgecolormapped = 0;
      end
      
      %Look for patches that want to be treated like lines
      %(e.g. arrow heads).  All patches where the AppData property
      %'NoDither' exists and is set to 'on' are treated like lines.
      if isappdata(p,'NoDither') & strcmp(getappdata(p,'NoDither'),'on')
	if (~isequal(pfcolor,BLACK) & ~isequal(pfcolor,WHITE) & ...
	    ~isequal(pfcolor,axColor))
	  set(p,'facecolor',axContrast)
	end
	if (~isequal(pecolor,BLACK) & ~isequal(pecolor,WHITE) & ...
	    ~isequal(pecolor,axColor))
	  set(p,'edgecolor',axContrast)
	end
      end
      
      %Don't change EdgeColor if it is
      % a) it is the same as the FaceColor
      % b) is None
      % c) is same as the Axes background
      % d) it is Black or White
      % e) the markeredges are flat and the edges weren't mapped
      % f) the marker edges are auto and the edges weren't mapped
      if ~strcmp(pmecolor,'none') & ...
	    ~isequal(pmecolor,pfcolor) & ~isequal(pmecolor,BLACK) & ...
	    ~isequal(pmecolor,WHITE) & ~isequal(pmecolor,axColor) & ...
	    ~(strcmp(pmecolor,'auto') & ~edgecolormapped) & ...
	    ~(strcmp(pmecolor,'flat') & ~edgecolormapped)
	if (isequal(pmfcolor,axContrast))
	  set(p,'markeredgecolor',1-axContrast)
	else
	  set(p,'markeredgecolor',axContrast)
	end
      end
      
      %Don't change MarkerFaceColor if it is
      % a) same as the FaceColor
      % b) None
      % c) same as the Axes Background
      % d) Black or White
      % e) the marker faces are auto and the edges weren't mapped
      if ~strcmp(pmfcolor,'none') & ...
	    ~isequal(pmfcolor,pfcolor) & ~isequal(pmfcolor,BLACK) & ...
	    ~isequal(pmfcolor,WHITE) & ~isequal(pmfcolor,axColor) & ...
	    ~(strcmp(pmfcolor,'auto') & ~edgecolormapped) & ...
	    ~(strcmp(pmfcolor,'flat') & ~edgecolormapped)
	if (isequal(pmfcolor,axContrast))
	  set(p,'markerfacecolor',1-axContrast)
	else
	  set(p,'markerfacecolor',axContrast)
	end
      end
      
    end
    
    for k = 1:nsobjs
      s = sobjs(k);
      secolor = get(s,'edgecolor');
      sfcolor = get(s,'facecolor');
      smecolor = get(s,'markeredgecolor');
      smfcolor = get(s,'markerfacecolor');
      
      if (strcmp(sfcolor,'none'))
	sf1x3 = NONE;
      elseif (strcmp(sfcolor,'flat'))
	sf1x3 = FLAT;
      elseif (strcmp(sfcolor,'interp'))
	sf1x3 = INTERP;
      elseif (strcmp(sfcolor,'texturemap'))
	sf1x3 = TEXTUREMAP;
      else
	sf1x3 = sfcolor;
      end
      
      if (strcmp(secolor,'none'))
	se1x3 = NONE;
      elseif (strcmp(secolor,'flat'))
	se1x3 = FLAT;
      elseif (strcmp(secolor,'interp'))
	se1x3 = INTERP;
      else
	se1x3 = secolor;
      end
      
      if (strcmp(smecolor,'none'))
	sme1x3 = NONE;
      elseif (strcmp(smecolor,'auto'))
	sme1x3 = AUTO;
      elseif (strcmp(smecolor,'flat'))
	sme1x3 = FLAT;
      else
	sme1x3 = smecolor;
      end
      
      if (strcmp(smfcolor,'none'))
	smf1x3 = NONE;
      elseif (strcmp(smfcolor,'auto'))
	smf1x3 = AUTO;
      elseif (strcmp(smfcolor,'flat'))
	smf1x3 = FLAT;
      else
	smf1x3 = smfcolor;
      end
      
      di.surface(already.surface+k,:) = [s sf1x3 se1x3 sme1x3 smf1x3];
      
      edgesUseCdata = strcmp(secolor,'flat') | strcmp(secolor,'interp');
      markerEdgesUseCdata = strcmp(smecolor,'flat') | ...
	  (strcmp(smecolor,'auto') & edgesUseCdata);
      nanInCdata = any(find(isnan(get(s, 'cdata'))));
      
      %Don't change EdgeColor if it is
      % a) it is the same as the FaceColor
      % b) is None
      % c) is same as the Axes background
      % d) it is Black or White
      % e) the edges use cdata and there is a nan in the cdata
      if ~( isequal(secolor, sfcolor) | strcmp(secolor,'none') | isequal(secolor,axColor) ...
	    | isequal(secolor,BLACK) | isequal(secolor,WHITE) ...
	    | (edgesUseCdata & nanInCdata))
	if (isequal(sfcolor,axContrast))
	  set(s,'edgecolor',1-axContrast)
	else
	  set(s,'edgecolor',axContrast)
	end
	edgecolormapped = 1;
      else
	edgecolormapped = 0;
      end
      
      %Look for surfaces that want to be treated like lines. All
      %surfaces where the AppData property 'NoDither' exists and is
      %set to 'on' are treated like lines.
      if isappdata(s,'NoDither') & strcmp(getappdata(s,'NoDither'),'on')
	if (~isequal(sfcolor,BLACK) & ~isequal(sfcolor,WHITE) & ...
	    ~isequal(sfcolor,axColor))
	  set(s,'facecolor',axContrast)
	end
	if (~isequal(secolor,BLACK) & ~isequal(secolor,WHITE) & ...
	    ~isequal(secolor,axColor))
	  set(s,'edgecolor',axContrast)
	end
      end
      
      %Don't change EdgeColor if it is
      % a) it is the same as the FaceColor
      % b) is None
      % c) is same as the Axes background
      % d) it is Black or White
      % e) the markeredges are flat and the edges weren't mapped
      % f) the markeredges are auto and the edges weren't mapped
      if ~strcmp(smecolor,'none') & ...
	    ~isequal(smecolor,sfcolor) & ~isequal(smecolor,BLACK) & ...
	    ~isequal(smecolor,WHITE) & ~isequal(smecolor,axColor) & ...
	    ~(strcmp(smecolor,'auto') & ~edgecolormapped) & ...
	    ~(strcmp(smecolor,'flat') & ~edgecolormapped)
	if (isequal(smfcolor,axContrast))
	  set(s,'markeredgecolor',1-axContrast)
	else
	  set(s,'markeredgecolor',axContrast)
	end
      end
      
      %Don't change MarkerFaceColor if it is
      % a) same as the FaceColor
      % b) None
      % c) same as the Axes Background
      % d) Black or White
      % e) the marker faces are auto and the edges weren't mapped
      if ~strcmp(smfcolor,'none') & ...
	    ~isequal(smfcolor,sfcolor) & ~isequal(smfcolor,BLACK) & ...
	    ~isequal(smfcolor,WHITE) & ~isequal(smfcolor,axColor) & ...
	    ~(strcmp(smfcolor,'auto') & ~edgecolormapped) & ...
	    ~(strcmp(smfcolor,'flat') & ~edgecolormapped)
	if (isequal(smfcolor,axContrast))
	  set(s,'markerfacecolor',1-axContrast)
	else
	  set(s,'markerfacecolor',axContrast)
	end
      end
      
    end        
    
    
    aLabels = get(a, {'xlabel';'ylabel';'zlabel';'title'});
    aLabels = cat(1, aLabels{:})'; % turn cell array into row vector
    for k = 1:ntobjs
      t = tobjs(k);
      tcolor = get(t,'color');
      
      di.text(already.text+k,:) = [t tcolor];
      
      if (~isequal(tcolor,BLACK) & ~isequal(tcolor,WHITE) )
	if find(t==aLabels)
	  %This will fail if user positions labels within Axis
	  %so that is must contrast a different color then figColor.
	  if ~isequal(tcolor,figColor)
	    set(t,'color',figContrast)
	  end
	else
	  if ~isequal(tcolor,axColor)
	    set(t,'color',axContrast)
	  end
	end
      end
    end
    
    for k = 1:nrobjs
      r = robjs(k);
      recolor = get(r,'edgecolor');
      rfcolor = get(r,'facecolor');
      
      if (strcmp(recolor,'none'))
	di.rect(already.rect+k,:) = [r NONE];
      else
	di.rect(already.rect+k,:) = [r recolor];
      end
      
      %Don't change EdgeColor if it is:
      % a) it is the same as the FaceColor
      % b) is None
      % c) is same as the Axes background
      % b) it is Black or White
      if ~( isequal(recolor, rfcolor) | strcmp(recolor,'none') | isequal(recolor,axColor) ...
	    | isequal(recolor,BLACK) | isequal(recolor,WHITE) )
	if (isequal(rfcolor,axContrast))
	  set(r,'edgecolor',1-axContrast)
	else
	  set(r,'edgecolor',axContrast)
	end
      end
    end
  end
  
  %Save for restoration later
  NoDitherOriginalColors = di;
  
else
  
  orig = NoDitherOriginalColors;
  
  for k = 1:size(orig.line,1)
    l = orig.line(k,1);
    lcolor = orig.line(k,2:4);
    lme1x3 = orig.line(k,5:7);
    if (isnan(lme1x3(1)))
      lmecolor = 'none';
    elseif (isequal(lme1x3,AUTO))
      lmecolor = 'auto';
    else
      lmecolor = lme1x3;
    end
    lme1x3 = orig.line(k,8:10);
    if (isnan(lme1x3(1)))
      lmfcolor = 'none';
    elseif (isequal(lme1x3,AUTO))
      lmfcolor = 'auto';
    else
      lmfcolor = lme1x3;
    end
    set(l,'color',lcolor )
    set(l,'markeredgecolor',lmecolor )
    set(l,'markerfacecolor',lmfcolor)
  end
  
  for k = 1:size(orig.patch,1)
    p = orig.patch(k,1);
    pf1x3 = orig.patch(k,2:4);
    pe1x3 = orig.patch(k,5:7);
    pme1x3 = orig.patch(k,8:10);
    pmf1x3 = orig.patch(k,11:13);
    
    if (isnan(pf1x3(1)))
      pfcolor = 'none';
    elseif (isequal(pf1x3,FLAT))
      pfcolor = 'flat';
    elseif (isequal(pf1x3,INTERP))
      pfcolor = 'interp';
    else
      pfcolor = pf1x3;
    end
    
    if (isnan(pe1x3(1)))
      pecolor = 'none';
    elseif (isequal(pe1x3,FLAT))
      pecolor = 'flat';
    elseif (isequal(pe1x3,INTERP))
      pecolor = 'interp';
    else
      pecolor = pe1x3;
    end
    
    if (isnan(pme1x3(1)))
      pmecolor = 'none';
    elseif (isequal(pme1x3,AUTO))
      pmecolor = 'auto';
    elseif (isequal(pme1x3,FLAT))
      pmecolor = 'flat';
    else
      pmecolor = pme1x3;
    end
    
    if (isnan(pmf1x3(1)))
      pmfcolor = 'none';
    elseif (isequal(pmf1x3,AUTO))
      pmfcolor = 'auto';
    elseif (isequal(pmf1x3,FLAT))
      pmfcolor = 'flat';
    else
      pmfcolor = pmf1x3;
    end
    
    set(p,'facecolor',pfcolor)
    set(p,'edgecolor',pecolor)
    set(p,'markeredgecolor',pmecolor)  
    set(p,'markerfacecolor',pmfcolor)
  end
  
  for k = 1:size(orig.surface,1)
    s = orig.surface(k,1);
    sf1x3 = orig.surface(k,2:4);
    se1x3 = orig.surface(k,5:7);
    sme1x3 = orig.surface(k,8:10);
    smf1x3 = orig.surface(k,11:13);
    
    if (isnan(sf1x3(1)))
      sfcolor = 'none';
    elseif (isequal(sf1x3,FLAT))
      sfcolor = 'flat';
    elseif (isequal(sf1x3,INTERP))
      sfcolor = 'interp';
    elseif (isequal(sf1x3,TEXTUREMAP))
      sfcolor = 'texturemap';
    else
      sfcolor = sf1x3;
    end
    
    if (isnan(se1x3(1)))
      secolor = 'none';
    elseif (isequal(se1x3,FLAT))
      secolor = 'flat';
    elseif (isequal(se1x3,INTERP))
      secolor = 'interp';
    else
      secolor = se1x3;
    end
    
    if (isnan(sme1x3(1)))
      smecolor = 'none';
    elseif (isequal(sme1x3,AUTO))
      smecolor = 'auto';
    elseif (isequal(sme1x3,FLAT))
      smecolor = 'flat';
    else
      smecolor = sme1x3;
    end
    
    if (isnan(smf1x3(1)))
      smfcolor = 'none';
    elseif (isequal(smf1x3,AUTO))
      smfcolor = 'auto';
    elseif (isequal(smf1x3,FLAT))
      smfcolor = 'flat';
    else
      smfcolor = smf1x3;
    end
    
    set(s,'facecolor',sfcolor)
    set(s,'edgecolor',secolor)
    set(s,'markeredgecolor',smecolor)
    set(s,'markerfacecolor',smfcolor)
  end
  
  for k = 1:size(orig.text,1)
    t = orig.text(k,1);
    tcolor = orig.text(k,2:4);
    set(t,'color',tcolor)
  end

  for k = 1:size(orig.axes,1)
    a = orig.axes(k,1);
    if ~strcmp(get(a,'tag'), 'legend')
      axc = orig.axes(k,2:4);
      ayc = orig.axes(k,5:7);
      azc = orig.axes(k,8:10);
      set(a,'xcolor',axc)
      set(a,'ycolor',ayc)
      set(a,'zcolor',azc)
    end
  end
  
  for k = 1:size(orig.rect,1)
    r = orig.rect(k,1);
    rcolor = orig.rect(k,2:4);
    if (isnan(rcolor(1)))
      rcolor = 'none';
    end
    set(r,'edgecolor',rcolor)
  end
end

