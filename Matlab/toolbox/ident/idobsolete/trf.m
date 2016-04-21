function [G,PV]=trf(th,nnu,w,nny)
%TRF  Computes a model's frequency function, without covariance data. 
%   This function is OBSOLETE. Use IDFRD instead. To suppress covariance
%   information use: M.cov = 'None'; G = IDFRD(M);
%
%   G = TRF(M)  or  [G,NSP] = TRF(M)
%   
%   Same function as TH2FF, except that covariance information is not
%   calculated.
%
%   M: A matrix defining a model as IDSS, IDPOLY, IDARX or IDGREY object.
%
%   G is returned as the transfer function estimate, and NSP (if specified)
%   as the noise spectrum, corresponding to the model M.  
%   If M describes a time series, G is returned as its spectrum.
%   Both discrete and continuous time models are handled.
%
%   If the model M has several inputs, G will be returned as the transfer
%   functions of selected inputs # j1 j2 .. jk by
%   G = TRF(M,[j1 j2 ... jk])  [default is all inputs]. A negative input
%   number jj is interpreted as noise input number -jj. The functions
%   are computed at 128 equally spaced frequency-values between 0(excluded)
%   and pi/T, where T is the sampling interval specified by M. The func-
%   tions can be computed at arbitrary frequencies w (a row vector, gene-
%   rated e.g. by LOGSPACE) by G = TRF(M,ku,w). The transfer function
%   can be plotted by BODEPLOT.
%   If the model M has several outputs, G will be returned
%   as the frequency function at selected outputs ky (a row vector) by
%   G=TFR(M,ku,w,ky); (Default is all outputs).
%   See also BODEPLOT, FFPLOT, FREQFUNC, NYPLOT and TH2FF.

%   L. Ljung 7-7-87,1-25-92
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.11 $ $Date: 2001/08/03 14:23:37 $

if nargin<1
   disp('Usage: G = TRF(TH)')
   disp('       [G,NSP] = TRF(TH,INPUTS,FREQUENCIES,OUTPUTS)')
   return
end
if ~isa(th,'idmodel')
   th = th2ido(th);
end

th = pvset(th,'CovarianceMatrix',[]);
ut = pvget(th,'Utility');
try
   ut.Pmodel = [];
   th = pvset(th,'Utility',ut);
catch
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
   thn = th(:,'allx9'); % Includes scaling as for normalizing the noise input %%LL%%
   G = idfrd(thn(nny,[nnu1,nnun]));  
end

 
