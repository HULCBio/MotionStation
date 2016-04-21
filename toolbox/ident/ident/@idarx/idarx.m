function sys = idarx(varargin)
%IDARX  Create IDARX model structure
%       
%   M = IDARX(A,B,Ts)
%   M = IDARX(A,B,Ts,'Property',Value,..)
%
%   Describes the multivariable ARX model
%
%   A0*y(t)+A1*y(t-T)+ ... + An*y(t-nT) =
%	      '                 B0*u(t)+B1*u(t-T)+Bm*u(t-mT) + e(t) 
%	      
%   with ny outputs and nu inputs.
%   A is a ny-by-ny-by-n array, such that A(:,:,k+1) = Ak.
%   The normalization must be such that A0 = eye(ny).
%   B is similarly an ny-by-nu-by-m array.
%   
%   Ts is the sampling interval.
%
%   For more info on IDARX properties, type SET(IDARX) or IDPROPS IDARX
%

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.15.4.1 $  $Date: 2004/04/10 23:15:06 $

ni = nargin;
PVstart=[];
superiorto('iddata')
try
    superiorto('lti','zpk','ss','tf','frd')
end

if ni
   % allow conversion from idpoly/arx
   if isa(varargin{1},'idpoly')
      sys1 = varargin{1};
      nc = pvget(sys1,'nc');nd=pvget(sys1,'nd');nf=pvget(sys1,'nf');
      noi = pvget(sys1,'NoiseVariance');
      if sum([nc nd nf])==0
         [a,b] = polydata(sys1);
         while a(end)==0
             a=a(1:end-1);
         end
         A = zeros(1,1,length(a));
         A(1,1,:) = a;
         [nu,nb]=size(b);
         B = zeros(1,nu,nb);
         for ku = 1:nu
            B(1,ku,:)=b(ku,:);
         end
         sys = idarx(A,B,pvget(sys1,'Ts'),'NoiseVariance',noi);
         sys = inherit(sys,sys1);
         cov1 = pvget(sys1,'CovarianceMatrix');
         if ~isempty(cov1)
            par1 = pvget(sys1,'ParameterVector');
            sys1 = parset(sys1,[1:length(par1)]');
            sys1 = pvset(sys1,'CovarianceMatrix',[]);
            sys2 = idarx(sys1);
            par2 = pvget(sys2,'ParameterVector');
            par3 = find(par2<0);
            par4 = find(par2>0);
            cov = cov1(abs(par2),abs(par2));
            cov(par3,par4) = - cov(par3,par4);
            cov(par4,par3) = - cov(par4,par3);
            sys = pvset(sys,'CovarianceMatrix',cov);
         end
         return
      else
         error('IDPOLY can be converted to IDARX only if nc=nd=nf=0.')
      end
      
   end
   if (isa(varargin{1},'ss')|isa(varargin{1},'zpk')|isa(varargin{1},'tf')|...
         (isa(varargin{1},'idmodel')&~isa(varargin{1},'idarx')))
      error('Conversion of general models to idarx not possible.')
   end
   
   % Quick exit for idarx objects
   if isa(varargin{1},'idarx'),
      if ni~=1
         error('Use SET to modify the properties of IDARX objects.');
      end
      sys = varargin{1};
      return
   end
   % Dissect input list
   PVstart = min(find(cellfun('isclass',varargin,'char')));
   if isempty(PVstart)
      DoubleInputs = ni;
   else
      DoubleInputs = PVstart - 1;
      if PVstart==1,
         error('Conversion from string to idarx is not possible.')
      end
   end
   A = varargin{1};
   
   if nargin>1
      B=varargin{2};
   else 
      B =[];
   end
   if nargin>2
      Ts = varargin{3};
   else
      Ts = 1;
   end
   if Ts==0
      error('Continuous time IDARX models currently not supported.')
   end
   [par,na,nb,nk,ny,nu,status] = getnnpar(A,B);
   if ~all(all(A(:,:,1)==eye(ny)))
      error('The leading A(:,:,1) must be the unit matrix')
   end
else
   na=0;par=[];nb=[];nk=[];nu=[];Ts=1;ny=0;
end

sys.na = na; sys.nb=nb; sys.nk=nk;
idparent = idmodel(ny, nu, Ts, par, []);

sys = class(sys, 'idarx', idparent);
sys=timemark(sys,'c');
% Finally, set any PV pairs, some of which may be in the parent.
if ~isempty(PVstart)
   try
      set(sys, varargin{PVstart:end})
   catch
      error(lasterr)
   end
end
