function [num,den]=th2tf(m,iu)
%TH2TF  Transforms from the THETA-format to transfer functions.
%   This function is obsolete. Use TFDATA instead.
%
%   [NUM,DEN] = TH2TF(TH,IU)
%
%   TH: The model, defined in the THETA-format (See also THETA).
%
%   IU: The input number (default 1) to be considered. Noise source
%       number ni is counted as input number -ni.
%   NUM: The numerator(s) of the transfer function. For a multivariable
%        model row k of NUM gives the transfer function from input # IU
%        to output # k.
%   DEN: The denominator of the transfer function. (Common to all outputs)
%
%   NUM and DEN are given in the standard formats of the Control Systems
%   Toolbox (both for continuous and discrete time models)
%   See also TH2FF, TH2POLY, TH2SS and TH2ZP.

%   L. Ljung 10-2-90
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/10 23:20:11 $

if nargin < 1
   disp('Usage: [NUMERATOR(S), DENOMINATOR] = TH2TF(TH)')
   disp('       [NUMERATOR(S), DENOMINATOR] = TH2TF(TH,INPUT_NUMBER)')
   return
end
 
if nargin<2
   iu=1;
end
if ~isa(m,'idmodel')
   m = th2ido(m);
end

[ny,nu] = size(m);
if nu==0
    iu = 0;
end
if iu<0
   [num1,den1]=tfdata(m('n'));
   num = [];
   den = [];
   for kk = 1:ny
      num = [num;num1{kk,-iu}];
      den = [den;den1{kk,-iu}];
   end
   return
end

[num1,den1]=tfdata(m(:,iu));
num =[];
den=[];
for kk = 1:ny
   num=[num;num1{kk,1}];
   den = [den;den1{kk,1}];
end
 
