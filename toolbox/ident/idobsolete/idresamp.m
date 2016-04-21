function [zd,decr] = idresamp(data,r,nfilt,tol)
%IDRESAMP Resamples data by decimation and interpolation.
%   IDRESAMP is OBSOLETE. Use IDDATA/RESAMPLE instead.
%   ZD = IDRESAMP(Z,R)
%
%   Z  : The output-input data as a matrix or as an IDDATA object. 
%   ZD : The resampled data.  If Z is IDDATA, so is ZD. Otherwise the
%        columns of ZD correspond to those of Z.
%   R  : The resampling factor. The new data record ZD will correspond
%        to a sampling interval of R times that of the original data.
%        R > 1 thus means decimation and R < 1 means interpolation.
%        Any positive number for R is allowed, but it will be replaced
%        by a rational approximation.
%
%   [ZD, ACT_R] = IDRESAMP(Z,R,ORDER,TOL) gives access to the following
%   options: ORDER determines the filter orders used at decimation
%   and interpolation (Default 8). TOL gives the tolerance of the
%   rational approximation (Default 0.1). ACT_R is the actually used
%   resampling factor.
%   See also IDFILT.

%   L. Ljung 3-3-95.
%   The code is adopted from the routines DECIMATE and INTERP
%   in the Signal Processing Toolbox, written by L. Shure.
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.2 $ $Date: 2001/04/06 14:21:44 $

if nargin < 2
   disp('Usage: ZD = IDRESAMP(Z,R).')
   disp('       [ZD,ACT_R] = IDRESAMP(Z,R,FILTER_ORDER,TOLERANCE)')
   return
end

if nargin<4
   tol=[];
end
if nargin<3
   nfilt=[];
end

%if isempty(tol),tol=0.1;end
if isempty(nfilt),nfilt=8;end
if r<=0, error('The resampling factor R must be positive.'),end
if isa(data,'iddata')
   iddataflag = 1;
   
   y = pvget(data,'OutputData');y = y{1};
   u = pvget(data,'InputData'); u = u{1};
   ny = size(y,2); nu = size(u,2);
   zdat = [y, u];
   Ts = pvget(data,'Ts');Ts = Ts{1};
else
   iddataflag = 0;
   zdat = data;
end

[ndat,nyu]=size(zdat);

if ndat<nyu
   error('Data should be organized columnwise.')
end
if ndat<10
 error('The data record length must be at least 10.')
end
if isempty(tol)
   [numr,denr] = rat(r);
else
   [numr,denr] = rat(r,tol);
end
if numr==0
   [numr,denr] = rat(r,tol/2);
end

decr = numr/denr;
if numr == 1 & denr == 1
        zd = data;
        return
end
if denr>1

   l = nfilt/2;
   alpha = .5;
   % calculate AP and AM matrices for inversion
   s1 = toeplitz(0:l-1) + eps;
   s2 = hankel(2*l-1:-1:l);
   s2p = hankel([1:l-1 0]);
   s2 = s2 + eps + s2p(l:-1:1,l:-1:1);
   s1 = sin(alpha*pi*s1)./(alpha*pi*s1);
   s2 = sin(alpha*pi*s2)./(alpha*pi*s2);
   ap = s1 + s2;
   am = s1 - s2;
   ap = inv(ap);
   am = inv(am);

   % now calculate D based on INV(AM) and INV(AP)
   d = zeros(2*l,l);
   d(1:2:2*l-1,:) = ap + am;
   d(2:2:2*l,:) = ap - am;
   % set up arrays to calculate interpolating filter B
   x = (0:denr-1)/denr;
   y = zeros(2*l,1);
   y(1:2:2*l-1) = (l:-1:1);
   y(2:2:2*l) = (l-1:-1:0);
   X = ones(2*l,1);
   X(1:2:2*l-1) = -ones(l,1);
   XX = eps + y*ones(1,denr) + X*x;
   y = X + y + eps;
   h = .5*d'*(sin(pi*alpha*XX)./(alpha*pi*XX));
   b = zeros(2*l*denr+1,1);
   b(1:l*denr) = h';
   b(l*denr+1) = .5*d(:,l)'*(sin(pi*alpha*y)./(pi*alpha*y));
   b(l*denr+2:2*l*denr+1) = b(l*denr:-1:1);
   for kc = 1:nyu
       idata = zdat(:,kc);
       % use the filter B to perform the interpolation
       odata = zeros(denr*ndat,1);
       odata(1:denr:ndat*denr) = idata;
       % Filter a fabricated section of data first
       od = zeros(2*l*denr,1);
       od(1:denr:(2*l*denr)) = 2*idata(1)-idata((2*l+1):-1:2);
       [od,zi] = filter(b,1,od);
       [odata,zf] = filter(b,1,odata,zi);
       odata(1:(ndat-l)*denr) = odata(l*denr+1:ndat*denr);

       od = zeros(2*l*denr,1);
       od(1:denr:(2*l)*denr) = ...
                        [2*idata(ndat)-(idata((ndat-1):-1:(ndat-2*l)))];
       od = filter(b,1,od,zf);
       odata(ndat*denr-l*denr+1:ndat*denr) = od(1:l*denr);
       zd(:,kc) = odata;
    end
    zdat = zd;
    [ndat,dum]=size(zdat);
end
if numr>1
   nout = ceil(ndat/numr);
   odata = idfilt(zdat,nfilt,0.8/numr);
   nbeg = numr - (numr*nout - ndat);
   zd = odata(nbeg:numr:ndat,:);
end
if iddataflag
   zd = pvset(data,'OutputData',zd(:,1:ny),'InputData',zd(:,ny+1:end),...
      'Ts',Ts*decr);
end
