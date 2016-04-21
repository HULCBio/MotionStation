function [de,estdat] = misdata(dn,m,tol)
%MISDATA: Estimating Missing Data
%
%   DATAE = MISDATA(DATAN,MODEL) or DATAE = MISDATA(DATAN,MAXITER,TOL)
%
%   DATAN: A Time Domain data set in the IDDATA format, where any missing input
%       or output data is denoted by NaN.
%   MODEL: The model, in any IDMODEL (IDPOLY, IDSS, IDARX or IDGREY) format.
%       This model will be used for the reconstruction of missing data.
%   MAXITER: In case no model is specified a default order N4SID model is
%       used, and up to MAXITER iterations are performed, alternating between
%       estimating MODEL and DATAE. The iterations are terminated when
%       the difference between two consecutive missing data estimates differ by
%       less than TOL %. (Default MAXITER = 10 and TOL = 1.)
%   DATAE: The new data set, in IDDATA format, with the missing data in DATAN
%       replaced by estimates.
%

%	L. Ljung 00-05-10
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.8.4.1 $  $Date: 2004/04/10 23:19:07 $

if nargin < 1
   disp('Usage: DataE = MISDATA(DataN)')
   disp('       DataE = MISDATA(DataN,Model)')
   disp('       DataE = MISDATA(DataN,Maxiter,Tolerance)')
   return
end
if ~isa(dn,'iddata')
   error('The data must be an IDDATA object. See Help IDDATA.')
end
if ~isnan(dn)
   de = dn;
   return
end
if strcmp(pvget(dn,'Domain'),'Frequency')
    error('MISDATA does not support Frequency Domain data.')
end
if nargin < 2
   iterflag = 1;
   maxiter = 10;
   tol = 1;
   m = [];
end
if nargin == 2
   iterflag = 0;
   if isempty(m)
      iterflag = 0;
   elseif isa(m,'double')
      if fix(m)~=m|m<0
         error('The second argument must be an IDMODEL or an INTEGER.')
      end
      maxiter = m; tol = 1; iterflag = 1;
      m = [];
   elseif ~isa(m,'idmodel')
      error('The second argument must be an IDMODEL or an INTEGER.')
   end
end
if nargin == 3
   if isa(m,'idmodel')
      error('With three arguments, the second one, MAXITER, must be an integer.')
   elseif isa(m,'double')
      if fix(m)~=m|m<0
         error('The second argument must be an INTEGER.')
      end
      maxiter = m;iterflag = 1;
      m = [];
   else
      error('The second argument must be an INTEGER.')
   end
   if ~isa(tol,'double')|tol<0
      error('Tolerance must be positive.')
   end
end


if iterflag         
   for ki = 1:maxiter
      [de,estdat] = misdata(dn,m);
      m = n4sid(de,'best','cov','none');
      if ki>1
         test = norm(estdatprev-estdat)/norm(estdat);
         if test < tol/100
            break
         end
      end
      estdatprev = estdat;
   end
end


y = pvget(dn,'OutputData');
u = pvget(dn,'InputData');
de = dn;
Nexp = length(y);
ny = size(y{1},2);
estdat = [];
for kexp = 1:Nexp
   zn = [y{kexp},u{kexp}];
   [N,nd] = size(zn);
   zv = zn(:);
   indmd = find(isnan(zv));
   ze = zv;
   ze(indmd) = zeros(size(indmd));
   ze = reshape(ze,N,nd);
   if ~isempty(m)
      for kk=1:length(indmd)
         zt = zeros(size(zv));
         zt(indmd(kk)) = 1;
         zt = reshape(zt,N,nd);
         ee =pe(zt,m);
         phi(:,kk) = ee(:);%pe(zt,m);
      end
      y = pe(ze,m);
      
      md = -phi\y(:);
      estdat = [estdat;md];
      ze = ze(:);
      ze(indmd) = md;
      ze = reshape(ze,N,nd);
   else
      estdat = [estdat;zeros(size(indmd))];
   end
   ye{kexp}=ze(:,1:ny);
   ue{kexp} = ze(:,ny+1:nd);
end
de = pvset(de,'InputData',ue,'OutputData',ye);

