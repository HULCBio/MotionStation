function [gm,pm,Wcg,Wcp] = imargin(mag,phase,w,AllMarginFlag)
%IMARGIN  Gain and phase margins using interpolation.
%
%   [Gm,Pm,Wcg,Wcp] = IMARGIN(MAG,PHASE,W) returns gain margin Gm,
%   phase margin Pm, and associated frequencies Wcg and Wcp, given
%   the Bode magnitude, phase, and frequency vectors MAG, PHASE,
%   and W from a linear system.  IMARGIN expects magnitude values 
%   in linear scale and phase values in degrees.
%
%   When invoked without left-hand arguments IMARGIN(MAG,PHASE,W) 
%   plots the Bode response with the gain and phase margins marked  
%   with a vertical line.
%
%   IMARGIN works with the frequency response of both continuous and
%   discrete systems. It uses interpolation between frequency points 
%   to approximate the true gain and phase margins.  Use MARGIN for 
%   more accurate results when an LTI model of the system is available.
%
%   Example of IMARGIN:
%     [mag,phase,w] = bode(a,b,c,d);
%     [Gm,Pm,Wcg,Wcp] = imargin(mag,phase,w)
%
%   See also BODE, MARGIN, ALLMARGIN.

%   Clay M. Thompson  7-25-90
%   Revised A.C.W.Grace 3-2-91, 6-21-92
%   Revised A.Potvin 10-1-94
%   Revised P. Gahinet 10-99
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.19.4.2 $  $Date: 2004/04/10 23:13:37 $

ni = nargin;
no = nargout;
error(nargchk(3,4,ni));
if isequal(size(mag),size(phase),[1 1 length(w)])
   % Support 3D input from Bode
   mag = mag(:);
   phase = phase(:);
elseif ndims(mag)>2 | ndims(phase)>2,
   error('Inputs MAG and PHASE must be 2D arrays.')
end

w = w(:);                   % Make sure freq. is a column
[m, n] = size(phase);       % Assume column orientation.

% Compute interpolated margins for each column of phase
if ni==4
   % Return all margins
   [Gm,Pm,Wcg,Wcp] = LocalAllMargins(mag(:),phase(:),w);
   
elseif n==1
   % Minimum margins of single response
   [Gm,Pm,Wcg,Wcp] = LocalAllMargins(mag(:),phase(:),w);
   
   % Compute min gain margins
   [junk,idx] = min(abs(log2(Gm)));
   Gm = Gm(idx);
   Wcg = Wcg(idx);
   
   % Compute min phase margins
   [junk,idx] = min(abs(Pm));
   Pm = Pm(idx);
   Wcp = Wcp(idx);
   
else
   % Minimum margins of multiple response
   Gm = zeros(1,n);
   Pm = zeros(1,n); 
   Wcg = zeros(1,n); 
   Wcp = zeros(1,n);
   for j=1:n,
      [Gm(j),Pm(j),Wcg(j),Wcp(j)] = imargin(mag(:,j),phase(:,j),w);
   end
end

% If no left hand arguments then plot graph and show location of margins.
if no==0,
   % Call with graphical output: plot using LTIPLOT
   if n>1
      error('Can only plot margins for a single SISO system.')
   end
   
   % Create plot (visibility ='off')
   h = ltiplot(gca,'bode',{''},{''},cstprefs.tbxprefs);
   
   % Create Bode response
   r = h.addresponse(1,1,1);
   r.Data.Frequency = w;
   r.Data.Focus = [w(1) w(end)];
   r.Data.Magnitude = mag(:);
   r.Data.Phase = phase(:);
   r.Data.PhaseUnits = 'deg';
   initsysresp(r,'bode',h.Preferences,[])
   
   % Add margin display
   c = r.addchar('Stability Margins','resppack.MinStabilityMarginData', ...
      'resppack.MarginPlotCharView');
   
   % Draw now
   if strcmp(h.AxesGrid.NextPlot,'replace')
      h.Visible = 'on';  % new plot crated with Visible='off'
   else
      draw(h);  % hold mode
   end
   
   % Right-click menus
   m = ltiplotmenu(h,'margin');
else
   gm = Gm;
   pm = Pm;
end

%------------------- Local functions ------------------

function [Gm,Pm,Wcg,Wcp] = LocalAllMargins(mag,phase,w)
%LocalAllMargins   Interpolated margins for single SISO response

nf = length(w);
logmag = log10(mag);                     % log magnitude
phase = (180/pi)*unwrap((pi/180)*phase); % unwrap phase values in rad
logw  = log10(w);                        % log frequency

%------------------------------------
% Gain margins (-180 phase crossings)
%------------------------------------

% Find points where phase crosses -180 degrees modulo 360
k = floor((phase+180)/360);       % -180+k*360 <= p < 180+k*360
lowcross = 360*k(1:nf-1,:)-180;   % nearest -180 crossing below p
ic = find(phase(2:nf,:)<lowcross | ...
   phase(2:nf,:)>=lowcross+360);  % phase crossing locations
Pc = lowcross(ic,:) + 360*(phase(ic+1,:)>phase(ic,:)); % phase at crossings
% Pc = (1-t) P(ic) + t P(ic+1)
t = (Pc - phase(ic,:)) ./ (phase(ic+1,:) - phase(ic,:));

% Get gain margin values for -180 phase crossings
Wcg = logw(ic,:) + t .* (logw(ic+1,:)-logw(ic,:));
Gm = logmag(ic,:) + t .* (logmag(ic+1,:)-logmag(ic,:));  % -G.M. in dB

% Look for asymptotic behavior near -180 degrees.  (30 degree tolerance).
% Linearly extrapolate gain and frequency based on first 2 or last 2 points.
tol = 30;
if nf>=2,
   % Extrapolation toward w=0
   pcs = 360*round((phase(1)+180)/360)-180;  % -180 crossing nearest to P(1)
   if abs(phase(1)-pcs)<tol & abs(phase(2)-phase(1))~=0,       % Starts near -180 degrees (mod 360)
      t = (pcs-phase(1)) / (phase(2)-phase(1));
      if t<0,  % Extrapolation toward 0
         Wcg = [Wcg ; logw(1) + t * (logw(2)-logw(1))];
         Gm = [Gm ; logmag(1) + t * (logmag(2)-logmag(1))];
      end
   end
   % Extrapolation toward w=Inf
   pce = 360*round((phase(nf)+180)/360)-180;  % -180 crossing nearest to P(end)
   if abs(phase(nf)-pce)<tol & abs(phase(nf)-phase(nf-1))~=0,  % Ends near -180 degrees.
      t = (pcs-phase(nf-1)) / (phase(nf)-phase(nf-1));
      if t>0,  % Extrapolation toward +Inf
         Wcg = [Wcg ; logw(nf-1) + t * (logw(nf)-logw(nf-1))];
         Gm = [Gm ; logmag(nf-1) + t * (logmag(nf)-logmag(nf-1))];
      end
   end
end

% Return sorted list of crossings and associated margins
if isempty(Gm)
   Gm = Inf;   Wcg = NaN;
else
   [Wcg,is] = sort(Wcg);
   Gm = 10.^(-Gm(is).');
   Wcg = 10.^Wcg.';
end

%------------------------------------
% Phase margins (0dB gain crossings)
%------------------------------------

% Find points where magnitude crosses 0 db
ic = find(logmag(1:end-1,:) .* logmag(2:end,:) <= 0 & logmag(1:end-1,:)~=logmag(2:end,:));
t = -logmag(ic,:) ./ (logmag(ic+1,:) - logmag(ic,:));

% Get interpolated frequency and phase margin values for 0 dB crossings
Wcp = logw(ic,:) + t .* (logw(ic+1,:)-logw(ic,:));
Pm = phase(ic,:) + t .* (phase(ic+1,:)-phase(ic,:)); 

% Compute min phase margins
if isempty(Pm)
   Pm = Inf;   Wcp = NaN;
else
   [Wcp,is] = sort(Wcp);
   Pm = mod(Pm(is).',360)-180;
   Wcp = 10.^Wcp.';
end


