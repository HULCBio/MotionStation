function [aw,bw,cw,dw,magfit] = fitd(threl, freq, n, blksz,flag)
%FITD State space realization of a given magnitude Bode plot.
%
% [SS_D,LOGDFIT] = FITD(LOGD,W,N,BLKSZ,FLAG)
% [AD,BD,CD,DD,LOGDFIT] = FITD(LOGD,W,N,BLKSZ,FLAG) produces a stable,
%   minimum-phase state-space realization SS_D of a diagonal transfer
%   function matrix such that the diagonal elements' magnitude bode plots
%   approximately fit Bode magnitude plot data given in the rows of the
%   matrix LOGD.  Uses the numerically stable routine "YLWK.M".
%
%   Input:     LOGD  matrix whose rows are logs of magnitude bode plots;
%              W frequency vector.
%   Optional:  N vector of desired orders of the approximants (default=0);
%              BLKSZ vector of sizes diagonal blocks in SS_D (default = 1);
%              FLAG (default: display Bode plot; 0: no Bode plot);
%              Bode plot of the fit will be displayed 4 at a time
%              with a "pause" in between every full screen display.
%   Output:    SS_D is a state-space realization of the diagonal transfer
%              function matrix  D(s) =diag(d1(s)I1,...,dn(s)In) where
%              di(s) is the fit to the i-th row of LOGD and I1,...,In are
%              identity matrices of dimensions given in the n-vector BLKSZ.
%              LOGDFIT contains the fit to LOGD, i.e., SS_D's bode plot.

% by Weizheng Wang (University of Southern California)
% with enhancements by
% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.11.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------------

% -------------- Initialize variables:
aw = []; bw = []; cw = []; dw = [];

nag1 = nargin;

[mmm,nnn] = size(threl);
if mmm > nnn
   threl = threl';
   [mmm,nnn] = size(threl);
end
thre=exp(threl);
threl=threl/log(10);     % from log to log10
freql = log10(freq);

bodeflag=0;
magfit=[];
if nargout==2 | nargout==5, bodeflag == 1; end

nfreq=length(freq);
if nnn ~= nfreq,
   error('MAG and W must have the same number of points')
end

if nag1<3, n=zeros(1,mmm); end
if length(n)==1, n=n*ones(1,mmm); end

if nag1 <5
   bodeflag=1;% compute bode plot of fit
   flag = 1;  % display bode plot of fit
   if nag1<4,blksz=ones(1,mmm);end
end
if length(n)==0, n=zeros(1,mmm); end
if length(blksz)==0, blksz=ones(1,mmm); end
if length(flag)==0,
   bodeflag=1;% compute bode plot of fit
   flag = 1;  % display bode plot of fit
end


% if scalar blksz, make it a vector
if length(blksz)==1, blksz=blksz*ones(1,mmm);end

% Find the best sampling time "ff so that the frequency mapping from "s"
% to "z" is approximately linear between 0 and Pi:
%
mx=max(freql);  mn=min(freql);
ff=10^(mn+2);
ff=ff/3^(4-mx+mn); % ff is approx. sqrt(max(freq)/min(freq));

%
% Bilinear mapping of the frequency axis from "z" to "s":
%
z=[0:126]/126*pi;
j=sqrt(-1);
w=imag(ff*(exp(j*z(1:126))-1)./(exp(j*z(1:126))+1));
wl(1)=log10(freq(1));
[x,y]=size(freq);
x=max(x,y);
wl(127)=log10(freq(x));
wl(2:126)=log10(w(2:126));
for i=2:126, if wl(i)>wl(127), wl(i)=wl(127); end; end;
for i=2:126, if wl(i)<wl(1),  wl(i)=wl(1); end; end;
z=z/pi;
%

% Curve fit the continuous THREL magnitude data, one row at a time:
%
% Now prepare to curve fit THREL magnitude data, one row at a time:

loop = mmm;

if loop ~= length(n),
   error('Number of rows of MAG must equal the dimension of the vector N')
end
count = 0;

for i = 1:loop
  mag =thre(i,:);
  magl = threl(i,:);
  nl = n(1,i);
  count = count + 1;
%

  if nl==0
    ad=1;
    bd = exp(log(10)*polyfit(freql, magl, 0));
  else

  % First do a high order least squares polynomial curve fit to the
  % loglog bode magnitude plot data in ith row of THREL:
    y = nl*2;
    if y < 8, y = 8; end
    if y>nfreq/2, y=round(nfreq/2); end
    if y<1, y=1; end; if nfreq>100, y=10; end;
    p = polyfit(freql, magl, y);

  %
  % Now obtain a lower order approximation in z-plane via YULEWALK.M:
  %
    dth = polyval(p, wl);
    dth = exp(log(10)*dth);
    dth(1)=mag(1);
    dth(127)=mag(x);
    if exist('yulewalk')
     eval('[bd,ad]=yulewalk(nl,z,dth);');
    else
     [bd, ad] = ylwk(nl,z,dth);
    end;
    % make sure the fitting is minimum phase
    %    bd = polystab(bd); to avoid call signal processing toolbox
    % the following line are added.
    if length(bd) > 1,
	vv=roots(bd);
	ii = find(vv~=0);
	vs = 0.5*(sign(abs(vv(ii))-1)+1);
	vv(ii) = (1-vs).*vv(ii) + vs./conj(vv(ii));
	vv = bd(1) * poly(vv);
	if ~any(imag(bd))
           vv = real(vv);
	end;
     else
       vv=bd;
     end;
     bd=vv;
  end

% Discrete time state-space (az,bz,cz,dz):
%
  [az,bz,cz,dz]=tf2ss(bd,ad);
%% WAS Added line to fix non-square empty bz,cz matrices
  [msg,az,bz,cz,dz]=abcdchk(az,bz,cz,dz);
%
% Convert the discrete state-space to W-plane:
%
  if nl>0,
    [aw0,bw0,cw0,dw0]=bilin(az,bz,cz,dz,-1,'Tustin',2/ff);
  else
%% WAS     aw0=[];bw0=[];cw0=[];dw0=dz;
     aw0=az;bw0=bz;cw0=cz;dw0=dz;
  end
  for j=1:blksz(i);
     if i == 1 & j==1
        aw = aw0; bw = bw0; cw = cw0; dw = dw0;
     else
        [aw,bw,cw,dw] = append(aw,bw,cw,dw,aw0,bw0,cw0,dw0);
     end
  end

%
% Compute and display (if flag==1) the frequency response and fit
%
  if bodeflag==1,
     if nl==0,
         aw0=-1;bw0=0; cw0=0;
     end
     [ga_w0,ph0] = bode(aw0,bw0,cw0,dw0,1,freq);
     magfit=[magfit; log(ga_w0')];
     if flag==1,
        if loop > 1
           if count==1, clf; subplot(2,2,1); end;
	   if count==2, subplot(2,2,2); end;
           if count==3, subplot(2,2,3); end;
           if count==4, subplot(2,2,4); end;
        end;
        loglog(freq,mag,'x',freq,ga_w0);
        title([ 'YULE-WALKER ORDER ' num2str(n(i)) ' FIT']);
        xlabel('R/S (x: data; solid: fit)')
        ylabel(['Mag D' num2str(i)]);
     end
  end
  if count == 4     % reset the counter after four loops
     count = 0;
     disp('  <hit a key to continue ...>')
     pause          % pause the 4-window plot on the screen
     clf
  end
%
end  % of the loop
%
if nargout <3,
    ss_w = mksys(aw,bw,cw,dw);
    aw = ss_w;
    bw=magfit;
end
%
% -------- End of FITD.M % WW/RYC/MGS %
