function sysc = d2c(sys,method,varargin)
%D2C  Conversion of discrete LTI models to continuous time.
%
%   SYSC = D2C(SYSD,METHOD) produces a continuous-time model SYSC
%   that is equivalent to the discrete-time LTI model SYSD.  
%   The string METHOD selects the conversion method among the 
%   following:
%      'zoh'       Assumes zero-order hold on the inputs.
%      'tustin'    Bilinear (Tustin) approximation.
%      'prewarp'   Tustin approximation with frequency prewarping.  
%                  The critical frequency Wc is specified last as in
%                  D2C(SysD,'prewarp',Wc)
%      'matched'   Matched pole-zero method (for SISO systems only).
%   The default is 'zoh' when METHOD is omitted.
%
%   See also C2D, D2D, LTIMODELS.

%   Clay M. Thompson  7-19-90
%   Revised: P. Gahinet  8-27-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/10 06:08:14 $

ni = nargin;
no = nargout;
error(nargchk(1,3,ni))
if ni==1,  
   method = 'zoh';  
elseif ~isstr(method) | ~any(method(1)=='zfmpt'),
   error('Unknown METHOD.')
end

% Call @zpk/d2c or @ss/d2c 
try
   if any(method(1)=='mpt'),
      sysc = tf(d2c(zpk(sys),method,varargin{:}));
   else
      % ZOH: proceed entry by entry
      [num,den,Ts] = tfdata(sys);
      sizes = size(num);
      
      sysc = sys;
      tmpsys = tf(0,'ts',Ts);
      for k=1:prod(sizes),
         tmpsys.num = num(k);
         tmpsys.den = den(k); 
         [sysc.num(k),sysc.den(k)] = ...
            tfdata(d2c(ss(tmpsys),method,varargin{:}));
      end
       
      % Set variable to s
      sysc.Variable = 's';

      % Update LTI properties
      sysc.lti = d2c(sys.lti);
   end
catch 
   rethrow(lasterror)
end



