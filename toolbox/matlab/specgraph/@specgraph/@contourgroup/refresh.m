function refresh(this)
%REFRESH Refresh contour plot
  
%   Copyright 1984-2003 The MathWorks, Inc. 

if ~strcmp(this.dirty,'clean')
  z = real(this.zdata);
  k = find(isfinite(z));
  zmax = max(z(k));
  zmin = min(z(k));
  msg='';
  if isempty(z) || (zmax == zmin) || ~any(k)
    msg = 'Contour ZData must be finite and non-constant.';
  elseif isempty(this.contourmatrix) || strcmp(this.fill,'on')
    listeners = getappdata(0,'SpecgraphContourListeners');
    set(listeners(end),'enable','off'); % disable mode listener
    
    if strcmp(this.xdatamode,'auto')
      this.xdata = 1:size(z,2);
    end
    if strcmp(this.ydatamode,'auto')
      this.ydata = 1:size(z,1);
    end

    range = zmax-zmin;
    range10 = 10^(floor(log10(range)));
    if strcmp(this.levelstepmode,'auto')
      nsteps = range/range10;
      if nsteps < 1.2
	range10 = range10/10;
      elseif nsteps < 2.4
	range10 = range10/5;
      elseif nsteps < 6
	range10 = range10/2;
      end
      this.levelstep = range10;
    end

    if strcmp(this.textstepmode,'auto')
      this.textstep = this.levelstep;
    end
    
    if strcmp(this.levellistmode,'auto')
      if zmin < 0 && zmax > 0
	step = this.levelstep;
	neg = -step:-step:zmin;
	pos = 0:step:zmax;
	this.levellist = [fliplr(neg) pos];
      elseif zmin < 0
	step = this.levelstep;
	start = zmin - (step - mod(-zmin,step));
	this.levellist = start:-step:zmax;
      else
	step = this.levelstep;
	start = zmin + (step - mod(zmin,step));
	this.levellist = start:step:zmax;
      end
      if strcmp(this.fill,'on') && (this.levellist(1) ~= zmin)
	this.levellist = [zmin this.levellist];
      end
    end

    if strcmp(this.textlistmode,'auto') 
      if strcmp(this.levellistmode,'auto')
        if zmin < 0 && zmax > 0
          step = this.textstep;
          neg = -step:-step:zmin;
          pos = 0:step:zmax;
          this.textlist = [fliplr(neg) pos];
        elseif zmin < 0
          step = this.textstep;
          start = zmin - (step - mod(-zmin,step));
          this.textlist = start:-step:zmax;
        else
          step = this.levelstep;
          start = zmin + (step - mod(zmin,step));
          this.textlist = start:step:zmax;
        end
      else
        this.textlist = this.levellist;
      end
    end

    set(listeners(end),'enable','on'); % enable mode listener

    levels = sort(this.levellist);
    x = this.xdata;
    y = this.ydata;
    
    if strcmp(this.fill,'on')
      [mz,nz] = size(z);
      if (size(y,1)==1), y=y'; end;
      if (size(x,2)==1), x=x'; end;
      
      % Get the unique levels
      levels = [zmin levels];
      zi = [1, find(diff(levels))+1];
      levels = levels(zi);

      % Surround the matrix by a very low region to get closed contours, and
      % replace any NaN with low numbers as well.
      z=[ repmat(NaN,1,nz+2) ; repmat(NaN,mz,1) z repmat(NaN,mz,1) ; repmat(NaN,1,nz+2)];
      kk=find(isnan(z(:)));
      z(kk)=zmin-1e4*(zmax-zmin)+zeros(size(kk));

      x = [2*x(:,1)-x(:,2), x, 2*x(:,nz)-x(:,nz-1)];
      y = [2*y(1,:)-y(2,:); y; 2*y(mz,:)-y(mz-1,:)];
      if min(size(y)) ~= 1
	x = x([1 1:mz mz],:);
	y = y(:,[1 1:nz nz]);
      end
    end

    if length(levels) == 1
      levels = [levels levels];
    end
    [this.contourmatrix,msg] = contours(x,y,z,levels);
  end
  if ~isempty(this.children)
    delete(this.children);
  end
  if ~isempty(msg)
    this.dirty = 'inconsistent';
  else
    if strcmp(this.fill,'on')
      LdrawFilled(this);
    else
      LdrawUnfilled(this);
    end

    if strcmp(this.showtext,'on')
      LdrawLabels(this);
    end

    % since tight limits aren't part of axes state we have to set
    % them explicitly even though limits might be in manual mode.
    % We don't set other properties that contour.m would set like
    % grid off and view(2) since those are not dependent on the
    % data of the contour plot and users would be surprised if 
    % changing the data of the plot would turn their grid off.
    cax = ancestor(this,'axes');
    if ~ishold(cax)
      % make a line across the diagonal to make sure the limit picker
      % includes the whole contour region and not just the lines
      xdata = this.xdata;
      ydata = this.ydata;
      bounds = line('parent',double(this),...
		    'xdata',[min(xdata(:)) max(xdata(:))],...
		    'ydata',[min(ydata(:)) max(ydata(:))],...
		    'handlevisibility','off','hittest','off',...
		    'linestyle','none');
      update(this);
      axis(cax,'tight');
      delete(bounds); % don't need the line anymore
    end
    
    this.dirty = 'clean';
    update(this); %workaround bug in hggroup to update limits
    setLegendInfo(this);
  end
end

function LdrawUnfilled(this)
c = this.contourmatrix;
limit = size(c,2);
color_h = [];
h = [];
i = 1;
while(i < limit)
  z_level = c(1,i);
  npoints = c(2,i);
  nexti = i+npoints+1;

  xdata = c(1,i+1:i+npoints);
  ydata = c(2,i+1:i+npoints);
  zdata = 0*xdata;  % Make zdata the same size as xdata
  cdata = z_level + 0*xdata;  % Make zdata the same size as xdata

  cu = handle(patch('XData',[xdata NaN],'YData',[ydata NaN], ...
                    'ZData',[zdata NaN],'CData',[cdata NaN], ... 
                    'facecolor','none','edgecolor',this.edgecolor,...
                    'xliminclude','off','yliminclude','off',...
                    'hittest','off',...
                    'linewidth',this.linewidth,'linestyle',this.linestyle,...
                    'userdata',z_level,'parent',double(this)));

  ncdata = size(get(cu,'FaceVertexCData'),1);
  if size(get(cu,'Vertices'),1) ~= ncdata
    verts = get(cu,'Vertices');
    set(cu,'Vertices',verts(1:ncdata,:));
  end
  set(cu,'zdata',[]);
  hasbehavior(cu,'legend',false);
  h = [h; cu(:)];
  color_h = [color_h ; z_level];
  i = nexti;
end
  
if strcmp(this.useaxescolororder,'on')
  cax = this.parent;
  colortab = get(cax,'colororder');
  [mc,nc] = size(colortab);
  % set linecolors - all LEVEL lines should be same color
  % first find number of unique contour levels
  [zlev, ind] = sort(color_h);
  h = h(ind);     % handles are now sorted by level
  ncon = length(find(diff(zlev))) + 1;    % number of unique levels
  if ncon > mc    % more contour levels than colors, so cycle colors
                  % build list of colors with cycling
    ncomp = round(ncon/mc); % number of complete cycles
    remains = ncon - ncomp*mc;
    one_cycle = (1:mc)';
    index = one_cycle(:,ones(1,ncomp));
    index = [index(:); (1:remains)'];
    colortab = colortab(index,:);
  end
  j = 1;
  zl = min(zlev);
  for i = 1:length(h)
    if zl < zlev(i)
      j = j + 1;
      zl = zlev(i);
    end
    set(h(i),'color',colortab(j,:));
  end
end

function LdrawFilled(this)

levels = this.levellist;
xdata = this.xdata;
ydata = this.ydata;
zdata = this.zdata;
minz = min(zdata(:));
maxz = max(zdata(:));

% Don't fill contours below the lowest level specified in nv.
% To fill all contours, specify a value of nv lower than the
% minimum of the surface. 
draw_min=0;
if any(levels <= minz),
  draw_min=1;
end

% Get the unique levels
levels = [minz levels];
zi = [1, find(diff(levels))+1];
nv = levels(zi);

CS = this.contourmatrix;  
% Find the indices of the curves in the c matrix, and get the
% area of closed curves in order to draw patches correctly. 
ii = 1;
ncurves = 0;
I = [];
Area=[];
while (ii < size(CS,2)),
  nl=CS(2,ii);
  ncurves = ncurves + 1;
  I(ncurves) = ii;
  xp=CS(1,ii+(1:nl));  % First patch
  yp=CS(2,ii+(1:nl));
  Area(ncurves)=sum( diff(xp).*(yp(1:nl-1)+yp(2:nl))/2 );
  ii = ii + nl + 1;
end

% Plot patches in order of decreasing size. This makes sure that
% all the levels get drawn, not matter if we are going up a hill or
% down into a hole. When going down we shift levels though, you can
% tell whether we are going up or down by checking the sign of the
% area (since curves are oriented so that the high side is always
% the same side). Lowest curve is largest and encloses higher data
% always.

[FA,IA]=sort(-abs(Area));

% Tolerance for edge comparison
lims = [min(xdata(:)),max(xdata(:)), ...
	min(ydata(:)),max(ydata(:))];
xtol = 0.1*(lims(2)-lims(1))/size(zdata,2);
ytol = 0.1*(lims(4)-lims(3))/size(zdata,1);
H=[];
cout = [];
bg = get(ancestor(this,'axes'),'Color');
for jj=IA,
  nl=CS(2,I(jj));
  lev=CS(1,I(jj));
  if (lev ~= minz | draw_min ),
    xp=CS(1,I(jj)+(1:nl));  
    yp=CS(2,I(jj)+(1:nl));
    clev = lev;           % color for filled region above this level
    if (sign(Area(jj)) ~=sign(Area(IA(1))) ),
      kk=find(nv==lev);
      kk0 = 1 + sum(nv<=minz) * (~draw_min);
      if (kk > kk0)
        clev=nv(kk-1);    % in valley, use color for lower level
      elseif (kk == kk0)
        clev=NaN;
      else 
        clev=NaN;         % missing data section
        lev=NaN;
      end

    end
    if strcmp(this.edgecolor,'flat')
      clev = clev  + 0*xp;
    end
    if (isfinite(clev)),
      cu=patch(xp,yp,clev,'facecolor','flat','edgecolor',this.edgecolor, ...
	       'linewidth',this.linewidth,'linestyle',this.linestyle,...
	       'hittest','off',...
	       'userdata',lev,'parent',double(this));
    else
      cu=patch(xp,yp,clev,'facecolor',bg,'edgecolor',this.edgecolor, ...
	       'linewidth',this.linewidth,'linestyle',this.linestyle,...
	       'hittest','off',...
	       'userdata',CS(1,I(jj)),'parent',double(this));
    end
    set(cu,'zdata',[]);
    hasbehavior(cu,'legend',false);
    H=[H;cu];
    
    % Ignore contours that lie along a boundary
    
    % Get +1 along lower boundary, -1 along upper, 0 in middle
    tx = (abs(xp - lims(1)) < xtol ) - (abs(xp - lims(2)) < xtol);
    ty = (abs(yp - lims(3)) < ytol ) - (abs(yp - lims(4)) < ytol);

    % Locate points with a boundary contour segment leading up to them
    bcf = find((tx & [0 ~diff(tx)]) | (ty & [0 ~diff(ty)]));

    if (~isempty(bcf))
      % Get a logical vector that has 0 inserted before each such location
      wuns = true(1,length(xp) + length(bcf));
      wuns(bcf + (0:(length(bcf)-1))) = 0;

      % Create new arrays so that NaN breaks each boundary contour segment
      xp1 = NaN * wuns;
      yp1 = xp1;
      xp1(wuns) = xp;
      yp1(wuns) = yp;

      % Remove unnecessary elements
      if (length(xp1) > 2)
	% Blank out segments consisting of a single point
	tx = ([1 isnan(xp1(1:end-1))] & [isnan(xp1(2:end)) 1]);
	xp1(tx) = NaN;
	
	% Remove consecutive NaNs or NaNs on either end
	tx = isnan(xp1) & [isnan(xp1(2:end)) 1];
	xp1(tx) = [];
	yp1(tx) = [];
	if (length(xp1)>2 & isnan(xp1(1)))
	  xp1 = xp1(2:end);
	  yp1 = yp1(2:end);
	end
	
	% No empty contours allowed
	if (length(xp1) == 0)
	  xp1 = NaN;
	  yp1 = NaN;
	end
      end

      % Update the contour segments and their length
      xp = xp1;
      yp = yp1;
      nl = length(xp);
    end

    cout = [cout,[lev xp;nl yp]];
  end
end
setContourMatrix(this,cout);

numPatches = length(H);
if numPatches>1
  for i=1:numPatches
    set(H(i), 'faceoffsetfactor', 0, 'faceoffsetbias', (1e-3)+(numPatches-i)/(numPatches-1)/30); 
  end
end

function LdrawLabels(this)
CS = this.contourmatrix;
cax = ancestor(this,'axes');
v = unique(this.textlist);
lab_int=this.labelspacing;  % label interval (points)
h = flipud(findobj(double(this),'Type','patch'));

if (strcmp(get(cax, 'XDir'), 'reverse')), XDir = -1; else XDir = 1; end
if (strcmp(get(cax, 'YDir'), 'reverse')), YDir = -1; else YDir = 1; end

% Compute scaling to make sure printed output looks OK. We have to go via
% the figure's 'paperposition', rather than the the absolute units of the
% axes 'position' since those would be absolute only if we kept the 'units'
% property in some absolute units (like 'points') rather than the default
% 'normalized'.

UN=get(cax,'units');
hfig = get(cax,'parent');
if (UN(1:3)=='nor'),
  UN=get(hfig,'paperunits');
  set(hfig,'paperunits','points');
  PA=get(hfig,'paperposition');
  set(hfig,'paperunits',UN);
  PA=PA.*[get(cax,'position')];
else
  PA = hgconvertunits(hfig,get(cax,'Position'),...
                      get(cax,'Units'),'points',get(cax,'Parent'));
end

% Find beginning of all lines

lCS=size(CS,2);

XL=get(cax,'xlim');
YL=get(cax,'ylim');

Aspx=PA(3)/diff(XL);  % To convert data coordinates to paper (we need
                      % to do this
Aspy=PA(4)/diff(YL);  % to get the gaps for text the correct size)

H=[];

% Set up a dummy text object from which you can get text extent info
H1=text(XL(1),YL(1),'dummyarg','parent',double(this),...
	'units','points','visible','off');

% Get labels all at once to get the length of the longest string.  
% This allows us to call extent only once, thus speeding up this routine
labels = getlabels(CS);
% Get the size of the label
set(H1,'string',repmat('9',1,size(labels,2)),'visible','on')
EX=get(H1,'extent'); set(H1,'visible','off')
len_lab=EX(3)/2;

ii=1; k = 0;
while (ii<lCS),
  k = k+1;

  l=CS(2,ii);
  x=CS(1,ii+(1:l));
  y=CS(2,ii+(1:l));

  lvl=CS(1,ii);

  %RP - get rid of all blanks in label
  lab=labels(k,labels(k,:)~=' ');
  %RP - scale label length by string size instead of a fixed length
  len_lab=EX(3)/2*length(lab)/size(labels,2);
  
  % RP28/10/97 - Contouring sometimes returns x vectors with 
  % NaN in them - we want to handle this case!
  sx=x*Aspx;
  sy=y*Aspy;
  d=[0 sqrt(diff(sx).^2 +diff(sy).^2)]; 
  % Determine the location of the NaN separated sections
  section = cumsum(isnan(d));
  d(isnan(d))=0;
  d=cumsum(d);
  
  len_contour = max(0,d(l)-3*len_lab);
  slop = (len_contour - floor(len_contour/lab_int)*lab_int);
  start = 1.5*len_lab + max(len_lab,slop)*rands(1); % Randomize start
  psn=[start:lab_int:d(l)-1.5*len_lab];
  lp=size(psn,2);
  
  if (lp>0) & isfinite(lvl)  & ...
     (isempty(v) | any(abs(lvl-v)/max(eps+abs(v)) < .00001)),
 
    Ic=sum( d(ones(1,lp),:)' < psn(ones(1,l),:),1 );
    Il=sum( d(ones(1,lp),:)' <= psn(ones(1,l),:)-len_lab,1 );
    Ir=sum( d(ones(1,lp),:)' < psn(ones(1,l),:)+len_lab,1 );
 
    % Check for and handle out of range values
    out = (Ir < 1 | Ir > length(d)-1) | ...
          (Il < 1 | Il > length(d)-1) | ...
          (Ic < 1 | Ic > length(d)-1);
    Ir = max(1,min(Ir,length(d)-1));
    Il = max(1,min(Il,length(d)-1));
    Ic = max(1,min(Ic,length(d)-1));

    % For out of range values, don't remove datapoints under label
    Il(out) = Ic(out);
    Ir(out) = Ic(out);
    
    % Remove label if it isn't in the same section
    bad = (section(Il) ~= section(Ir));
    Il(bad) = [];
    Ir(bad) = [];
    Ic(bad) = [];
    psn(:,bad) = [];
    out(bad) = [];
    lp = length(Il);
    in = ~out;
    
    if ~isempty(Il)
      
      % Endpoints of text in data coordinates
      wl=(d(Il+1)-psn+len_lab.*in)./(d(Il+1)-d(Il));
      wr=(psn-len_lab.*in-d(Il)  )./(d(Il+1)-d(Il));
      xl=x(Il).*wl+x(Il+1).*wr;
      yl=y(Il).*wl+y(Il+1).*wr;
   
      wl=(d(Ir+1)-psn-len_lab.*in)./(d(Ir+1)-d(Ir));
      wr=(psn+len_lab.*in-d(Ir)  )./(d(Ir+1)-d(Ir));
      xr=x(Ir).*wl+x(Ir+1).*wr;
      yr=y(Ir).*wl+y(Ir+1).*wr;
     
      trot=atan2( (yr-yl)*YDir*Aspy, (xr-xl)*XDir*Aspx )*180/pi; %% EF 4/97
      backang=abs(trot)>90;
      trot(backang)=trot(backang)+180;
      
      % Text location in data coordinates 
      wl=(d(Ic+1)-psn)./(d(Ic+1)-d(Ic));
      wr=(psn-d(Ic)  )./(d(Ic+1)-d(Ic));    
      xc=x(Ic).*wl+x(Ic+1).*wr;
      yc=y(Ic).*wl+y(Ic+1).*wr;
  
      % Shift label over a little if in a curvy area
      shiftfrac=.5;
      
      xc=xc*(1-shiftfrac)+(xr+xl)/2*shiftfrac;
      yc=yc*(1-shiftfrac)+(yr+yl)/2*shiftfrac;

      % Remove data points under the label...
      % First, find endpoint locations as distances along lines
    
      dr=d(Ir)+sqrt( ((xr-x(Ir))*Aspx).^2 + ((yr-y(Ir))*Aspy).^2 );
      dl=d(Il)+sqrt( ((xl-x(Il))*Aspx).^2 + ((yl-y(Il))*Aspy).^2 );
    
      % Now, remove the data points in those gaps using that
      % ole' MATLAB magic. We use the sparse array stuff instead of
      % something like:  
      %        f1=zeros(1,l); f1(Il)=ones(1,lp);
      % because the sparse functions will sum into repeated indices,
      % rather than just take the last accessed element - compare
      %   x=[0 0 0]; x([2 2])=[1 1]
      % with
      %   x=full(sparse([1 1],[2 2],[1 1],1,3))
      % (bug fix in original code 18/7/95 - RP)
  
      f1=full(sparse(ones(1,lp),Il,ones(1,lp),1,l));
      f2=full(sparse(ones(1,lp),Ir,ones(1,lp),1,l));
      irem=find(cumsum(f1)-cumsum(f2))+1;
      x(irem)=[];
      y(irem)=[];
      d(irem)=[];
      l=l-size(irem,2);
      
      % Put the points in the correct order...
      
      xf=[x(1:l),xl,repmat(NaN,size(xc)),xr];
      yf=[y(1:l),yl,yc,yr];
  
      [df,If]=sort([d(1:l),dl,psn,dr]);
    
      % ...and draw.
      %
      % Here's where we assume the order of the h(k).  
      %
  
      z = get(h(k),'zdata');
      if ~strcmp(this.fill,'on'), % Only modify lines or patches if unfilled
        % Handle contour3 case (z won't be empty).
        set(h(k),'zdata',[]) % Work around for bug in face generation
        if isempty(z), 
          set(h(k),'xdata',[xf(If) NaN],'ydata',[yf(If) NaN],...
                   'cdata',lvl+[0*xf(If) nan])
        else
          xd = [xf(If) NaN];
          set(h(k),...
              'xdata',xd,'ydata',[yf(If) NaN],...
              'zdata',z(1)+0*xd,...
              'cdata',lvl+[0*xf(If) nan])
        end
        ncdata = size(get(h(k),'FaceVertexCData'),1);
        if size(get(h(k),'Vertices'),1) ~= ncdata
          verts = get(h(k),'Vertices');
          set(h(k),'Vertices',verts(1:ncdata,:));
        end
      end

      H=[];
      for jj=1:lp,
	H = [H;text(xc(jj),yc(jj),lab,'parent',double(this),...
		    'rotation',trot(jj), ...
		    'verticalAlignment','middle',...
		    'horizontalAlignment','center',...
		    'clipping','on',...
		    'hittest','off',...
		    'userdata',lvl)];
      end
    end % ~isempty(Il)
  end;
  
  ii=ii+1+CS(2,ii);
end;
  
% delete dummy string
delete(H1);


function labels = getlabels(CS)
%GETLABELS Get contour labels
v = []; i =1;
while i < size(CS,2), 
  v = [v,CS(1,i)];
  i = i+CS(2,i)+1;
end
labels = num2str(v');

function r = rands(n)
%RANDS Stateless rand
%   R = RANDS(N) is the same as calling RAND(INP) except
%   that the state of the random number generator is unaffected.

Currstate=rand('state');
rand('state',sum(100*clock));
r = rand(n);
rand('state',Currstate); % resets to original state.
