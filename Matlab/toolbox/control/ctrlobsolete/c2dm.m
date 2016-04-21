function [adout,bd,cd,dd] = c2dm(a,b,c,d,Ts,method,varargin)
%C2DM   Conversion of continuous LTI systems to discrete-time.
%
%   [Ad,Bd,Cd,Dd] = C2DM(A,B,C,D,Ts,'method') converts the continuous-
%   time state-space system (A,B,C,D) to discrete time using 'method':
%     'zoh'         Convert to discrete time assuming a zero order
%           hold on the inputs.
%     'foh'         Convert to discrete time assuming a first order 
%           hold on the inputs.
%     'tustin'      Convert to discrete time using the bilinear 
%           (Tustin) approximation to the derivative.
%     'prewarp'     Convert to discrete time using the bilinear 
%           (Tustin) approximation with frequency prewarping.
%           Specify the critical frequency with an additional
%           argument, i.e. C2DM(A,B,C,D,Ts,'prewarp',Wc)
%     'matched'     Convert the SISO system to discrete time using the
%           matched pole-zero method.
%
%   [NUMd,DENd] = C2DM(NUM,DEN,Ts,'method') converts the continuous-
%   time polynomial transfer function G(s) = NUM(s)/DEN(s) to discrete
%   time, G(z) = NUMd(z)/DENd(z), using 'method'.
%
%   See also: C2D, and D2CM.

%   Clay M. Thompson  7-19-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 06:35:04 $

error(nargchk(3,7,nargin));
ni = nargin;
cd = [];  dd = [];

% Check inputs
if ni==3 | ni==4 | (ni==5 & isstr(d)),
  % TF input
  tfin = 1;
  [num,den] = tfchk(a,b);
  if size(num,1)>1,
    % SIMO syntax
    num = num2cell(num,2);
    den0 = den;
    den = cell(size(num,1),1);
    den(:) = {den0};
  end
  sys = tf(num,den);
else
  tfin = 0;
  [msg,a,b,c,d] = abcdchk(a,b,c,d); error(msg);
  sys = ss(a,b,c,d);
end


% --- Determine which syntax is being used ---
switch ni
case 3        % Transfer function without method, assume 'zoh'
  sysd = c2d(sys,c);
  [ad,bd] = tfdata(sysd);
  ad = cat(1,ad{:});
  bd = bd{1};

case 4        % Transfer function with method.
  sysd = c2d(sys,c,d);
  [ad,bd] = tfdata(sysd);
  ad = cat(1,ad{:});
  bd = bd{1};

case 5
  if isstr(d),      % Transfer function with method and prewarp const.
     sysd = c2d(sys,c,d,Ts);
     [ad,bd] = tfdata(sysd);
     ad = cat(1,ad{:});
     bd = bd{1};
  else              % State space system without method, assume 'zoh'
     sysd = c2d(sys,Ts);
     [ad,bd,cd,dd] = ssdata(sysd);
  end

otherwise     % State space system with method.
  sysd = c2d(sys,Ts,method,varargin{:});
  [ad,bd,cd,dd] = ssdata(sysd);

end


if nargout==0 & ~isstudent, % Compare Bode or Singular value plots
  if tfin,
     nu = 1;  ny = size(a,1);
  else
     [ny,nu] = size(d);
  end
  if (ny==1)&(nu==1),   % Plot Bode plots
    [magc,phasec,wc] = bode(sys);
    [magd,phased,wd] = bode(sysd);
    magc = permute(magc,[3 1 2]);
    magd = permute(magd,[3 1 2]);
    semilogx(wc,20*log10(magc),'-',wd,20*log10(magd),'--')
    title('C2DM comparison plot')
    xlabel('Frequency (rad/s)'), ylabel('Gain dB')
  else
    [svc,wc] = sigma(sys);  
    [svd,wd] = sigma(sysd); 
    semilogx(wc,20*log10(svc'),'-',wd,20*log10(svd'),'--');
    title('C2DM comparison plot')
    xlabel('Frequency (rad/s)'), ylabel('Singular Values dB')
  end

else
  adout = ad;

end




% end c2dm
