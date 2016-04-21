function sys = idpoly(varargin)
%IDPOLY  Create IDPOLY model structure
%       
%  M = IDPOLY(A,B,C,D,F,NoiseVariance,Ts)
%  M = IDPOLY(A,B,C,D,F,NoiseVariance,Ts,'Property',Value,..)
%
%  M: returned as a  model structure object describing the model
%
%     A(q) y(t) = [B(q)/F(q)] u(t-nk) + [C(q)/D(q)] e(t)
%
%  The variance of the white noise source e is NoiseVariance. Ts is
%  the sample interval. Ts = 0 means a continuous time model.
%  A,B,C,D and F are entered as the polynomials.
%
%  For a discrete time model, A, C, D and F start with 1, while B 
%  contains leading zeros to indicate the delay(s).
%  For multi-input systems B and F ar  matrices with the number of 
%  rows equal to the number of inputs.
%  For a time series, B and F are entered as [].
%
%  Example: A = [1 -1.5 0.7], B = [0 0.5 0 0.3; 0 0 1 0], Ts =1 gives the
%  model y(t) - 1.5y(t-1) + 0.7y(t-2) = 0.5u1(t-1) + 0.3u1(t-3) + u2(t-2).
%
%  For a continuous time model, the polynomials are entered in descending 
%  powers of s.  Example: A = 1; B = [1 2;0 3]; C = 1; D = 1; F = [1 0;0 1]; 
%  Ts = 0 corresponds to the time-continuous system  Y = (s+2)/s U1 + 3 U2.
%
%  Trailing C, D, F, NoiseVariance, and Ts can be omitted, in which case they are
%  taken as 1's (if B=[], then F=[]).
%
%  M = IDPOLY creates an empty object.
%
%  M = IDPOLY(SYS) creates an IDPOLY model for any single output IDMODEL or
%      LTI object SYS. If an LTI model contains an InputGroup 'Noise', these
%      will be treated as white noise, when computing the noise model of M.
%
%  For more info on IDPOLY properties, type SET(IDPOLY). See also POLYDATA.
%

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.22.4.1 $ $Date: 2004/04/10 23:16:32 $

ni = nargin;
ABCDFT(1:7) = {[],[],[],[],[],1,1};
PVstart=[];
superiorto('iddata') 
try
   superiorto('lti','zpk','ss','tf','frd')
end

if ni>0
   % Quick exit for idpoly objects
   if ni & isa(varargin{1},'idpoly'),
      if ni~=1
         error('Use SET to modify the properties of IDPOLY objects.');
      end
      sys = varargin{1};
      return
   end
   if ni & isa(varargin{1},'lti'),
      if isa(varargin{1},'frd')
         error('FRD objects cannot be transformed to IDPOLY objects.')
      end
      sys = idss(varargin{:});
      sys = idpoly(sys);
      return
   end
   if ni & isa(varargin{1},'idarx')
      sys1 = varargin{1};
      [A,B] = arxdata(sys1);
      [ny,nu,nb] = size(B);
      if ny>1
         error(sprintf(['Only single-output IDARX models can be converted to IDPOLY.',...
               '\n To convert to IDPOLY, apply to one output at a time:',...
               '   Mp = IDPOLY(M(ky,:)).']))
      end
      
      a = A(:).';
      b = squeeze(B); 
      if nu == 1, b = b(:).';end
      sys = idpoly(a,b,'Ts',pvget(sys1,'Ts'));
      sys = inherit(sys,sys1);
      cov1 = pvget(sys1,'CovarianceMatrix');
      if ~isempty(cov1)
         par1 = pvget(sys1,'ParameterVector');
         sys1 = parset(sys1,[1:length(par1)]');
         sys1 = pvset(sys1,'CovarianceMatrix',[]);
         sys2 = idpoly(sys1);
         par2 = pvget(sys2,'ParameterVector');
         par3 = find(par2<0);
         par4 = find(par2>0);
         cov = cov1(abs(par2),abs(par2));
         cov(par3,par4) = - cov(par3,par4);
         cov(par4,par3) = - cov(par4,par3);
         sys = pvset(sys,'CovarianceMatrix',cov);
      end
      return
   end
   if ni&(isa(varargin{1},'idss')|isa(varargin{1},'idgrey'))
      sysold = varargin{1};
      ny = size(sysold,'ny');
      if ny>1
         error(sprintf(['IDPOLY can only represent single output models.',...
               '\nDo the conversion one output at a time: mp = IDPOLY(mod(ky,:)).']))
      end
      [sys,sysold,flag] = idpolget(sysold,'d');
      if ~isempty(sys)
         sys = sys{1};
         sys = pvset(sys,'NoiseVariance',pvget(sysold,'NoiseVariance'));%%%%%%%%%%%%%%%%%%
      end
      
      if isempty(sys) % Then we could not compute cov-info
         % but should still provide an IDPOLY version
         [a,b,c,d,f] = polydata(sysold);
         sys = idpoly(a,b,c,d,f,'Ts',pvget(sysold,'Ts'),'NoiseVariance',pvget(sysold,'NoiseVariance'));
        % sys = pvset(sys,'NoiseVariance',pvget(sysold,'NoiseVariance'));
         sys = inherit(sys,sysold);
      end
      
      if length(varargin)>1
         for ky = 1:ny
            try
               set(sys,varargin{2:end})
            catch
               error(lasterr)
            end
         end
      end
      return
   end
   try
      superiorto('tf','zpk','ss','lti') 
   catch
   end
   
   % Dissect input list
   PVstart = min(find(cellfun('isclass',varargin,'char')));
   if isempty(PVstart)
      DoubleInputs = ni;
   else
      DoubleInputs = PVstart - 1;
      if PVstart==1,
         error('Conversion from string to idpoly is not possible.')
      end
   end
   
   % Actually zero arguments is OK, creates an empty object
   if DoubleInputs == 1,
      error('IDPOLY requires at least two input arguments.');
   end
   
   % Omitted arguments default to empty.. set them up now
   % Then add any user-specified arguments
   ABCDFT(1:DoubleInputs) = varargin(1:DoubleInputs);
   
   lasterr('');
   % Must find Ts first, since the creator treats poly's differently
   if ~isempty(PVstart)
      for kk = PVstart:2:length(varargin)
         if strcmp(lower(varargin{kk}),'ts')
            ABCDFT{7} = varargin{kk+1};
         end
      end
   end
   
   try 
      [na,nb,nc,nd,nf,nk,par,nu] = polychk(ABCDFT{:});
   catch
      error(lasterr)
   end 
else % if ni==0
   nu = 0;
   na=0;nb=zeros(1,0);nc=0;nd=0;nf=zeros(1,0);nk=zeros(1,0);
   par =[];
   ABCDFT{6}=0;
end

sys = struct('na',na,'nb',nb,'nc',nc,'nd',nd,'nf',nf,'nk',nk,...
   'InitialState','Auto');

% The parent for IDPOLY models is always single-output
idparent = idmodel(1, nu,1, par, []);
try
   idparent = pvset(idparent,'Ts',ABCDFT{7});
catch
   error(lasterr)
end

idparent = timemark(idparent,'c');
sys = class(sys,'idpoly', idparent);
sys = pvset(sys,'NoiseVariance',ABCDFT{6});
%sys = timemark(sys,'c');
% Finally, set any PV pairs, some of which may be in the parent.
if ~isempty(PVstart)
   try
      set(sys, varargin{PVstart:end})
   catch
      error(lasterr)
   end
end