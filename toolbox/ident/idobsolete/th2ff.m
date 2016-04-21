function [G,PV]=th2ff(th,nnu,w,nny)
%TH2FF  Computes a model's frequency function,along with its standard deviation
%   This function is obsolete. Use IDFRF instead.
%
%   G = TH2FF(TH)  or  [G,NSP] = TH2FF(TH)
%
%   TH: An object defining a model as an IDPOLY, IDSS, IDARX or IDGREY object.
%
%   G is returned as the transfer function estimate, and NSP (if specified)
%   as the noise spectrum, corresponding to the model TH. These matrices
%   contain also estimated standard deviations, calculated from the
%   covariance matrix in TH, and are IDFRD frequency function objects.  
%   (see also IDFRD).
%
%   If TH describes a time series, G is returned as its spectrum.
%   Both discrete and continuous time models are handled.
%
%   If the model TH has several inputs, G will be returned as the transfer
%   functions of selected inputs # j1 j2 .. jk by
%   G = TH2FF(TH,[j1 j2 ... jk])  [default is all inputs]. A negative input
%   number jj is interpreted as noise input number -jj. The functions
%   are computed at 128 equally spaced frequency-values between 0(excluded)
%   and pi/T, where T is the sampling interval specified by TH. The func-
%   tions can be computed at arbitrary frequencies w (a row vector, gene-
%   rated e.g. by LOGSPACE) by G = TH2FF(TH,ku,w). The transfer function
%   can be plotted by BODEPLOT.
%   If the model TH has several outputs, G will be returned
%   as the frequency function at selected outputs ky (a row vector) by
%   G=TH2FF(TH,ku,w,ky); (Default is all outputs).
%   See also BODEPLOT, FFPLOT, NYQPLOT, and IDFRD.

%   L. Ljung 7-7-87,1-25-92
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2001/08/03 14:23:39 $

if nargin<1
   disp('Usage: G = TH2FF(TH)')
   disp('       [G,NSP] = TH2FF(TH,INPUTS,FREQUENCIES,OUTPUTS)')
   return
end
if nargin < 3
   w =[];
end
if nargin < 2
   nnu =[];
end
if isempty(nnu)
   nnu = ':';
end

if nargin < 4
   nny = [];
end
if isempty(nny)
   nny = ':';
end

noiseflag= 0;
if any(nnu<0) % this is subreferencing noise
   noiseflag = 1;
end
if ~noiseflag
   try
      th = th(nny,nnu);
   catch
      error(lasterr)
   end
   
 G = idfrd(th);
if nargout == 2
   PV = idfrd(th(:,'noise'));
end
else
   nnu1 = nnu(find(nnu>0));
   nnun = -nnu(find(nnu<0))+size(th,'nu');
   thn = th(:,'allx9'); %% This also normalizes the noise input %%LL%%
   G = idfrd(thn(nny,[nnu1,nnun]));  
end

 
