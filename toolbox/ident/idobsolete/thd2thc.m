function thc=thd2thc(th,delays,nop)
%THD2THC  converts a model to continuous-time form.
%   This function is OBSOLETE. Use D2C instead. See HELP IDMODEL/D2C.
%
%   THC = THD2THC(TH)
%
%   TH: A discrete time model defined in the theta format, see also THETA.
%
%   THC: The continuous-time counterpart, stored in THETA format
%
%   If the model TH has extra delays from some inputs (nk>1), these are
%   first removed. They should be appended to the continuous-time model
%   as a pure time-delay (deadtime) (this is done by TH2FF).
%   To have the delays approximated by THC, enter THC = THD2THC(TH,'del');
%
%   The covariance matrix P of TH is translated by the use of numerical
%   derivatives. The step sizes used for the differences are given by the
%   m-file nuderst. To inhibit the translation of P, which saves time,
%   enter THC = THD2THC(TH,c,'nop'), where c is 'del' or 'nodel'.
%
%   CAUTION: The transformation could be ill-conditioned. Negative
%   real poles, poles in the origin and in 1 may cause problems. See the
%   manual.
%   See also THC2THD, TH2FF.

%   L. Ljung 10-1-86,4-20-87,8-27-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2001/04/06 14:21:42 $

if nargin < 1
   disp('Usage: THC = THD2THC(TH)')
   disp('       THC = THD2THC(TH,Delay_Handling)')
   disp('       Delay_Handling is one of ''del'', ''nodel''.')
   return
end
if nargin>1&~isempty(delays)&delays(1)=='d'
   inp = 0;
else 
   inp =1;
end
if nargin>2&~isempty(nop)&nop(1)=='n'
   cov = 'None';
else
   cov = 'Estimate';
end

thc = d2c(th,'Cov',cov,'Inp',inp);
