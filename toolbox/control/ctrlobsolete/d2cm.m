function [acout,bc,cc,dc] = d2cm(a,b,c,d,Ts,method,varargin)
%D2CM   Conversion of discrete LTI systems to continuous-time.
%   [Ac,Bc,Cc,Dc] = D2CM(A,B,C,D,Ts,'method') converts the discrete-
%   time state-space system to continuous-time using 'method':
%     'zoh'         Convert to continuous time assuming a zero order
%                   hold on the inputs.
%     'tustin'      Convert to continuous time using the bilinear 
%                   (Tustin) approximation to the derivative.
%     'prewarp'     Convert to continuous time using the bilinear 
%                   (Tustin) approximation with frequency prewarping.
%                   Specify the critical frequency with an additional
%                   argument, i.e. D2CM(A,B,C,D,Ts,'prewarp',Wc)
%     'matched'     Convert the SISO system to continuous time using
%                   the matched pole-zero method.
%
%   [NUMc,DENc] = D2CM(NUM,DEN,Ts,'method') converts the discrete-time
%   polynomial transfer function G(z) = NUM(z)/DEN(z) to continuous
%   time, G(s) = NUMc(s)/DENc(s), using 'method'.
%
%   Note:  'foh' is no longer available.
%
%   See also: D2C, and C2DM.

%   Clay M. Thompson  7-19-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 06:34:52 $

error(nargchk(3,7,nargin));
ni = nargin;
cc = [];  dc = [];

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
  sys = tf(num,den,c);
else
  tfin = 0;
  [msg,a,b,c,d] = abcdchk(a,b,c,d); error(msg);
  sys = ss(a,b,c,d,Ts);
end


% --- Determine which syntax is being used ---
switch ni
case 3        % Transfer function without method, assume 'zoh'
  sysc = d2c(sys);
  [ac,bc] = tfdata(sysc);
  ac = cat(1,ac{:});
  bc = bc{1};

case 4        % Transfer function with method.
  sysc = d2c(sys,d);
  [ac,bc] = tfdata(sysc);
  ac = cat(1,ac{:});
  bc = bc{1};

case 5
  if isstr(d),      % Transfer function with method and prewarp const.
     sysc = d2c(sys,d,Ts)
     [ac,bc] = tfdata(sysc);
     ac = cat(1,ac{:});
     bc = bc{1};
  else              % State space system without method, assume 'zoh'
     sysc = d2c(sys);
     [ac,bc,cc,dc] = ssdata(sysc);
  end

otherwise     % State space system with method.
  sysc = d2c(sys,method,varargin{:});
  [ac,bc,cc,dc] = ssdata(sysc);

end


if nargout==0 & ~isstudent,      % Compare Bode or Singular value plots
  if tfin,
     nu = 1;  ny = size(a,1);
  else
     [ny,nu] = size(d);
  end
  if (ny==1)&(nu==1),   % Plot Bode plots
    [magd,phased,wd] = bode(sys);
    [magc,phasec,wc] = bode(sysc);
    magc = permute(magc,[3 1 2]);
    magd = permute(magd,[3 1 2]);
    semilogx(wd,20*log10(magd),'-',wc,20*log10(magc),'--')
    xlabel('Frequency (rad/sec)'), ylabel('Gain dB')
    title('D2CM comparison plot')
  else
    [svd,wd] = sigma(sys);
    [svc,wc] = sigma(sysc);
    semilogx(wd,20*log10(svd'),'-',wc,20*log10(svc'),'--')
    xlabel('Frequency (rad/sec)'), ylabel('Singular Values dB')
    title('D2CM comparison plot')
  end

else
  acout = ac;
end

% end d2cm
