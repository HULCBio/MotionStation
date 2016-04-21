function varargout = zplane(Hq,varargin)
%ZPLANE Quantized filter Z-plane pole-zero plot.
%   [Zq,Pq,Kq]=ZPLANE(Hq) returns the zeros Zq, poles Pq, and gains Kq
%   for the quantized coefficients of quantized filter Hq.
%
%   [Zq,Pq,Kq,Zr,Pr,Kr]=ZPLANE(Hq) returns the zeros Zq, poles Pq, and
%   gains Kq for the quantized coefficients of quantized filter Hq, as
%   well as the zeros Zr, poles Pr, and gains Kr for the reference
%   coefficients.
%
%   If Hq consists of cascaded sections, then Zq, Pq, Kq, Zr, Pr, and Kr
%   are returned as a 1xN cell array where N is equal to Hq's
%   NumberOfSections property value.
%
%   The zeros and poles of the quantized filter are computed by
%   implicitly assuming linearity.
%
%   ZPLANE(Hq) plots the quantized and reference zeros and poles of the
%   quantized filter object Hq on the unit circle.
%
%   ZPLANE(Hq,REFERENCE) or
%   ZPLANE(Hq,REFERENCE,PLOTTYPE) plots the zeros and poles of the quantized
%   filter object Hq according to the plotting options specified by the string
%   arguments REFERENCE and PLOTTYPE.
%   REFERENCE can be turned:
%     'on'           Plot reference zeros and poles with their corresponding
%                    quantized values. 
%     'off'          Hide the reference zeros and poles.  Only plot the
%                    quantized zeros and poles.
%
%   PLOTTYPE can be:
%     'individual'   Produce an individual figure window for each filter section's
%                    poles and zeros.
%     'overlay'      Overlay poles and zeros on the same axis. 
%     'tile'         Plot the zeros and poles for each filter section using subplots. 
%
%   Example:
%     Fs = 100;
%     [b,a] = ellip(4,0.1,40,[10 20]*2/Fs);
%     sos = tf2sos(b,a);
%     Hq = qfilt('df2', sos2cell(sos));
%     zplane(Hq,'on','tile')
%
%   Multiple quantized zeros and poles are indicated by the multiplicity
%   number shown in black to the upper right of the zero or pole.
%   Multiple reference zeros and poles are indicated by the multiplicity
%   number shown in red to the bottom left of the zero or pole.
%
%   See also QFILT, QFILT/FREQZ, QFILT/IMPZ.

%   Author(s): Chris Portal
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.23 $  $Date: 2002/04/14 15:29:31 $

error(nargchk(1,3,nargin));

% Obtain neccesary property values:
fstruc = get(Hq,'FilterStructure');
qcoeff = get(Hq,'QuantizedCoefficients');
rcoeff = get(Hq,'ReferenceCoefficients');
Nsec   = get(Hq,'NumberOfSections');

% Convert structures to their transfer function representation:
try
  lasterr('')
  [Cq,Cr] = qfilt2tf(Hq,'sections');
catch
  error(qerror(lasterr))
end

% If only one section is present, embed the single cell so we can index
% into embedded cells in the subsequent loop.
if isnumeric(Cr{1})
    Cq = {Cq};
    Cr = {Cr};
end

% Index out the numerator and denominator for each section and convert get 
% it's ZPKs.
for k=1:Nsec,
    % Divide by zero not allowed
    if (max(abs(Cr{k}{2})) == 0) | (max(abs(Cq{k}{2})) == 0),
        error('Denominator cannot be zero.');
    end
    [Zr{k},Pr{k},Kr{k}] = lcltf2zp(Cr{k}{1},Cr{k}{2});
    [Zq{k},Pq{k},Kq{k}] = lcltf2zp(Cq{k}{1},Cq{k}{2});
end

% Determine if we should plot or return zpk:
switch nargout
case 0
    % Parse out plot options
    [refPlotOp,casPlotOp,msg] = lclPlotOps(varargin{:});
    error(msg)

    % Initialize storage variables for poles and zeros:
    Zrtemp = [];
    Prtemp = [];      
    Zqtemp = [];
    Pqtemp = [];
    
    % Find all open figures so we can reuse them:
    openfigs = findobj('type','figure');

    % Plot on a per section basis.
    for SecNum=1:Nsec,
        lclsecplot(Nsec,SecNum,casPlotOp,refPlotOp,openfigs,...
            Zr{SecNum},Pr{SecNum},Zq{SecNum},Pq{SecNum});

        if strcmp(casPlotOp,'overlay'),
            % Store all the poles and zeros in a single array so we can
            % plot total multiplicities for all sections in the next loop.
            Zrtemp = [Zrtemp;Zr{SecNum}];
            Prtemp = [Prtemp;Pr{SecNum}];      
            Zqtemp = [Zqtemp;Zq{SecNum}];
            Pqtemp = [Pqtemp;Pq{SecNum}];
        else
            % Plot the multiplicities section by section if we're
            % not in overlay mode.
            lclmultiZP([Zr{SecNum}],'red','top','right');
            lclmultiZP([Pr{SecNum}],'red','top','right');
            lclmultiZP([Zq{SecNum}],'black','bottom','left');
            lclmultiZP([Pq{SecNum}],'black','bottom','left');
            
            % Set the current figure to replace the plot and settings.
            % We don't do it for overlay yet because we still have to modify
            % the axis limits and plot the Re and Im lines with the right limits:
            set(gcf,'NextPlot','replace')         
        end
    end
   
   % Modify axis limits and Re and Im lines for overlay mode.
   % This way we can take into account all the poles and zeros when
   % determining the axis limits.
   % Also plot the multiplicities by taking the total number of
   % multiplicities for all sections using the temp variables we created:
   if strcmp(casPlotOp,'overlay'),
      % Zoom out ever so slightly.
      temp = [Zqtemp(:);Pqtemp(:);Zrtemp(:);Prtemp(:);1];
      maxlim = max(abs([real(temp); imag(temp)]));
      maxlim = maxlim + maxlim*0.1;
      axis([-maxlim, maxlim, -maxlim, maxlim])
      
      % Plot the multiplicities in overlay mode only:
      lclmultiZP([Zrtemp(:)],'red','top','right');
      lclmultiZP([Prtemp(:)],'red','top','right');
      lclmultiZP([Zqtemp(:)],'black','bottom','left');
      lclmultiZP([Pqtemp(:)],'black','bottom','left');
      
      % Format the axes limits and plot the real and imaginary axes.
      axis('equal')
      V = axis;
      plot([0 0],V(3:4),':b',V(1:2),[0 0],':b')
      
      % Set the current figure to replace the plot and settings:
      set(gcf,'NextPlot','replace')
   end
   
otherwise
   % Return the zpk as an array if there's only one section for 'nthos'.
   if Nsec==1,
      Zq = Zq{1};
      Zr = Zr{1};
      Pq = Pq{1};
      Pr = Pr{1};
      Kq = Kq{1};
      Kr = Kr{1};
   end
   
   % Assign the output arguments:
   argout = {Zq, Pq, Kq, Zr, Pr, Kr};
   varargout = argout;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [z,p,k]=lcltf2zp(num,den)

% Catch cases when the num are zero and there are no poles.
if max(abs(num)) == 0,
   den = 1;
end

% Pad NUM or DEN with trailing zeros if B and A are of different length
num = [num(:).' zeros(1,max(0,length(den)-length(num)))];
den = [den(:).' zeros(1,max(0,length(num)-length(den)))];

% Find Poles and Zeros
z = roots(num);
p = roots(den);

% Find gains:
denNonZero = find(den~=0);
numNonZero = find(num~=0);
n=1;
d=1;
if ~isempty(numNonZero)
  n = numNonZero(1);
end
if ~isempty(denNonZero)
  d = denNonZero(1);
end
w = warning;
warning off;
k = num(n)/den(d);
warning(w)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = lclsecplot(Nsec,SecNum,casPlotOp,refPlotOp,openfigs,Zr,Pr,Zq,Pq)
%LCLSECPLOT Plots the current section's zeros and poles.
%
%        NSec - Total number of sections.
%      SecNum - Current section number that we are plotting
%	casPlotOp - plotting option for cascades
%   refPlotOp - plotting option for the reference
%    openfigs - array of handles to figures already opened
%          Zr - reference zeros
%          Pr - reference poles
%          Zq - quantized zeros
%          Pq - quantized poles
%
%           h - array of handles to the plotted zeros and poles
%               later used for creating the legends

% Set up figure axes and figures based on plotting options.
% M, N and P are used to create an M by N matrix of axes within
% one figure window with the Pth one being active.
[m,n,p] = lclplotsetup(Nsec,SecNum,casPlotOp,openfigs);

% Use the current figure:
Figh = gcf;

% Pop up the figure we're using:
figure(Figh)

% Use subplot in case we are tiling
subplot(m,n,p);

% Clear the axes or figure as necessary in case it was
% used for a previous plot.
switch casPlotOp,
case 'individual'
   clf
case 'tile',
   cla
case 'overlay',
   if SecNum==1,
      clf
   end
end   

% Use subplot in case we are tiling
ax = gca;

% Set the axis and figure to add plots instead of replace.
set(ax,'NextPlot','add','box','on')
set(Figh,'NextPlot','add')

% Plot the poles and zeros.  Store the handles to these lines for
% creating the legends later.
switch refPlotOp
case 'on',
   Uh = plot(real(Zr),imag(Zr),'or', ...
      real(Pr),imag(Pr),'xr');
%      'markersize', 5);
   Qh = plot(real(Zq),imag(Zq),'sk', ...
      real(Pq),imag(Pq),'+k');
%      'markersize', 8);
   h = [Qh Uh];
otherwise
   h = plot(real(Zq),imag(Zq),'sk', ...
      real(Pq),imag(Pq),'+k');
%      'markersize', 8);
end

% Calculate points for dashed circle and plot unit circle:
t = linspace(0,2*pi,200);
x = cos(t); 
y = sin(t);
plot(x,y,':b')

% Modify axis limits and Re and Im lines later for overlay.
% This way we can take into account all the poles and zeros when
% determining the axis limits.
if ~strcmp(casPlotOp,'overlay'),
   % Zoom out ever so slightly.
   temp = [Zq(:);Pq(:);Zr(:);Pr(:);1];
   maxlim = max(abs([real(temp); imag(temp)]));
   maxlim = maxlim + maxlim*0.1;
   axis([-maxlim, maxlim, -maxlim, maxlim])
   
   % Format the axes limits and plot the real and imaginary axes.
   axis('equal')
   V = axis;
   plot([0 0],V(3:4),':b',V(1:2),[0 0],':b')
end

% Add labels to plot.
xlabel('Real part')
ylabel('Imaginary part')

% Place a title for the plot:
switch casPlotOp,
case {'individual','tile'},
   title(['Section ',num2str(SecNum)])
 case 'overlay',
   if Nsec>1
     title(['Sections 1 - ',num2str(Nsec)])
   end
end

% Create and turn 1 legend on.  If we're tiling plots, then we want to create
% but turn all the legends off except the legend for the first section:
switch casPlotOp
case {'individual','overlay'}   
   if ~isempty(h)
      lcllegend(h(1:2,:),refPlotOp);
   end   
case 'tile',
   % Create the legend but turn it off only so we can turn it on from the figure
   % and have the right one appear.
   if ~isempty(h)
      % We need to keep the current axis current after we create the legends.
      % Store it temporarily.
      ax = gca;
      
      [Lh,objH] = lcllegend(h(1:2,:),refPlotOp);
      if Nsec ~=1,
         set([Lh;objH],'Visible','off')
      end
      
      % Reset the axis to what was current before the legend creation.
      set(gcf,'CurrentAxes',ax)
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [m,n,p] = lclplotsetup(Nsec,SecNum,casPlotOp,openfigs)
%LCLPLOTSETUP Parse plotting options to set up figures and axes.
%
%        NSec - Total number of sections.
%      SecNum - Current section number that we are plotting
%	casPlotOp - plotting option for cascades
%    openfigs - array of handles to figures already opened
%
%       m,n,p - Defines an M by N matrix of axes within one figure
%               window.  Pth axis is the current active one.
%           

% Indexes used for subplots.  These are overridden only if we Tile.
% Otherwise we use a M by N figure with the Pth subplot active.
m = 1;
n = 1;
p = 1;

switch casPlotOp,
case 'individual',
    if SecNum > length(openfigs),
        % No more open figures available, so we need to open new ones now.
        Figh = figure;
        
        % Reposition if we're plotting into new figure windows so
        % they don't all overlap on top of eachother:
        pos = get(Figh,'Position');
        shift = SecNum/Nsec;
        set(Figh,'Position',[shift*pos(1) shift*pos(2) pos(3) pos(4)])
    else
        % Use one of the figure windows already open:       
        figure(openfigs(SecNum))
    end
case 'tile'
    % Create a matrix of axes with the right dimensions.
    m = ceil(sqrt(Nsec));
    n = ceil(Nsec/m);
    p = SecNum;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Lh,objH] = lcllegend(h,refPlotOp)
%LCLLEGEND  Turn legend on after we plot.
%
%     Lh - handle to the legend axes
%   objH - handle to the text, line and patch handles

if strcmp(refPlotOp,'on')
   [Lh,objH] = legend(h,'Quantized zeros','Quantized poles',...
       'Reference zeros', 'Reference poles');
else
   [Lh,objH] = legend(h,'Quantized zeros','Quantized poles');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lclmultiZP(ZP,color,vertalign,horizalign)
% Plot text labels for multiple poles and zeros.

% Determine the multiple poles/zeros and their indexes:
[mults,ind]=mpoles(ZP);

% For each multiple pole/zero, add a label.
for i=2:max(mults),
   % Store the indices for the multiplicities.
   j=find(mults==i);
   
   for k=1:length(j),
      % Get the location of the pole/zero.
      x = real(ZP(ind(j(k))));% + 0.01;
      y = imag(ZP(ind(j(k))));% + 0.001;
      
      if (j(k)~=length(ZP)),
         % If we are not attempting to label the final multiplicity,
         % check if the next element is a multiplicity or another pole/zero.
         if (mults(j(k)+1)<mults(j(k))),
            % The next element is another pole/zero, not another multiplicity,
            % so we are labeling the final multiplicity.
            text(x,y,num2str(i),'Color',color,...
                'VerticalAlignment',vertalign,'HorizontalAlignment',horizalign); 
         end
      else
         % Label the last multiplicity:
         text(x,y,num2str(i),'Color',color,...
             'VerticalAlignment',vertalign,'HorizontalAlignment',horizalign);
      end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [refPlotOp,casPlotOp,msg] = lclPlotOps(varargin)
%LCLPLOTOPS  Parse plot options from input list


% Defaults
refPlotOp = 'on';
casPlotOp = 'overlay'; 
msg = '';

for k=1:nargin
  if ~isempty(varargin{k})
    [op,msg] = qpropertymatch(varargin{k}, ...
        {'on','off','overlay','individual','tile'}); 
    if ~isempty(msg)
      msg = 'Ambiguous or invalid plotting option specified.';
      return
    end

    switch op
      case {'on','off'}
        refPlotOp = op;
      case {'overlay','individual','tile'}
        casPlotOp = op;
      otherwise
        msg = 'Ambiguous or invalid plotting option specified.';
        return
    end
  end
end
