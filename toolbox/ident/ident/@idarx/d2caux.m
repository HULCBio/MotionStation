function thd=d2caux(thc,method,varargin)
%IDARX/D2CAUX Help function to IDMODEL/D2C   

%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.4 $ $Date: 2002/01/21 09:33:07 $

if nargin < 1
   disp('Usage: SYSD = D2C(SYSC)')
   disp('       SYSD = D2C(SYSC,METHOD)')
   disp('       METHOD is one of ''Zoh'' or ''Foh''')
   return
end
if ~exist('ss/minreal')
   error(sprintf(['Transformation of multioutput arx-models will be supported ',...
         '\nonly if you have the CONTROL SYSTEMS TOOLBOX']))
end
errm = sprintf(['Arguments should be D2C(M,''Covariance'',''None'')',...
      '\n or D2C(M,''InputDelay'',0) (or both).']);
nv = length(varargin);
if fix(nv/2)~=nv/2
   error(errm);
end
delays = 1;
cov = 1;
for kk = 1:2:nv
   if ~ischar(varargin{kk})
      error(errm)
   elseif lower(varargin{kk}(1))=='c'
      if lower(varargin{kk+1}(1))=='n'
         cov = 0;
      end
   elseif lower(varargin{kk}(1))=='i'
      if varargin{kk+1}(1)==0
         delays = 0;
      end
   else
      error(errm)
   end
end
if ischar(pvget(thc,'CovarianceMatrix'))
   cov = 0;
end
if cov==0
   thc = pvset(thc,'CovarianceMatrix','None');
end
Told=pvget(thc.idmodel,'Ts'); 
if Told==0,
   error('This model is already  continuous-time!')
end

[ny,nu]=size(thc);
p = pvget(thc.idmodel,'ParameterVector');
nkflag = 0;
if delays
   nka = thc.nk;
   nk = min(nka);     
   if any(nk>1)
      nknew = nk>=1;
      adjnk = nk-nknew;
      thc = pvset(thc,'nk',nka-ones(ny,1)*adjnk);
      nkflag = 1;
   end
end

setcov(thc); % so that covinfo is not lost in the transformation. No loss of time
             % is CovarianceMatrix = 'None',
thc=minreal(idss(thc));
 thd=d2caux(thc,method,varargin{:});
if any(any(isinf(pvget(thd,'A'))'))
   error(sprintf(['Transformation to continuous time failed.',...
         '\nThe reason is probably pure time delays in the system.']))
   end
if nkflag
   thd = pvset(thd,'InputDelay',adjnk*Told);
end
