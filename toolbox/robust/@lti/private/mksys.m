function sys=mksys(varargin)
% LTI/PRIVATE/MKSYS creates an LTI object SYS from system data matrices.
% SYS=MKSYS(A,B,C,D) or
% SYS=MKSYS(V1,V2,...,VN, TY) packs matrices describing a system into 
% variable SYS depending on the STRING TY as follows:
% -----   -------------------------------          ---------------------------
% TY      V1,V2,...,VN                             Description
% -----   -------------------------------          ---------------------------
% 'ss'    'a,b,c,d[,Ts],ty'                        Standard Statespace (default)
% 'des'   'a,b,c,d,e[,Ts],ty'                      Descriptor System
% 'tss'   'a,b1,b2,c1,c2,d11,d12,d21,d22[,Ts],ty'  Two-port Statespace
% 'tdes'  'a,b1,b2,c1,c2,d11,d12,d21,d22,e[,Ts],ty'Two-port Descriptor
% 'gss'   'sm,dimx,dimu,dimy[,Ts],ty'              General statespace
% 'gdes'  'e,sm,dimx,dimu,dimy[,Ts],ty'            General descriptor
% 'gpsm'  'psm,deg,dimx,dimu,dimy[,Ts],ty'         General polynom. sys. matrix
% 'tf'    'num,den[,Ts],ty'                        Transfer function
% 'tfm'   'num,den,m,n[,Ts],ty'                    Transfer function matrix
% 'imp'   'y,ts,nu,ny[,Ts],ty'                     Impulse response
% ----------------------------------------------------------------------
% The optional input Ts (sampling time), if non-zero, tags the system as 
% discrete-time; a negative Ts=-1 indicates sampling time is unspecified.
% The BRANCH function recovers matrices packed into S, e.g., the 'c'
% and 'a' matrices from a standard statespace system S are returned by
% the command [C,A,Ts]=BRANCH(S,'c,a,Ts').  Alternatively, the command
% [AG,BG,CG,DG,TY]=BRANCH(S) returns the matrices (except for Ts) 
% in the order in which they were originally packed.
%
% LTI/PRIVATE/MKSYS uses same syntax as the function MKSYS, but differs
% in that it produces an LTI object output SYS in most cases.
%
% See also BRANCH, SSDATA, TFDATA, LTI, MKSYS

% R. Y. Chiang & M. G. Safonov (9/21/97)
% Revised 4/3/98 M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.7.4.4 $
% ---------------------------------------------------------------------------

nin=nargin;
Ts=0; % default sampling time

% Determine TY and set NIN equal to number of input arguments other than TY
if nin<1
   error('Too few input arguments')
else
   %% eval(['ty=v' num2str(nin) ';'])
   ty=varargin{nin};
   if isstr(ty),               % If TY is present
     nin=nin-1;
   else
     ty='ss';                   % Default TY='ss' if last argument is not a string
   end
end

% Verify validity of TY
[vars,nvars]=vrsys(ty);

% Get optional input Ts, if present
temp=varargin{nin};
if nvars<nin & isa(temp,'double') & length(temp)==1,
   Ts=temp;
   nin=nin-1;
end

if nvars>nin,
   error(['Too few input arguments for MKSYS type ' ty]),
elseif nvars<nin,
   error(['Too many input arguments for MKSYS type ' ty]),
end

% Convert TY to lowercase
ty=lower(ty);

switch ty
case {'ss'} 
   % 'ss'    'a,b,c,d,ty'                        Standard Statespace (default)
   sys=ss(varargin{1:nin});
case {'des','dss'}
   % 'des'   'a,b,c,d,e,ty'                      Descriptor System
   if rcond(varargin{5}) < eps,   % bypass singular E-matrix bug in lti/dss
      % warning('Singular E matrix: using mksys(A,B,C,D,E,''des'') instead of dss(A,B,C,D,E)')
      sys=mksys(varargin{1:nin},'des');
   else
      sys=dss(varargin{1:nin});
   end
case {'tss'}
   % 'tss'   'a,b1,b2,c1,c2,d11,d12,d21,d22,ty'  Two-port Statespace
   sys=tss(varargin{1:nin});
case {'tdes','tdss'}
   % 'tdes'  'a,b1,b2,c1,c2,d11,d12,d21,d22,e,ty'Two-port Descriptor
   if rcond(varargin{10}) < eps, % bypass singular E-matrix bug in lti/dss
      % warning('Singular E matrix: using mksys instead of LTI')
      sys=mksys(varargin{1:nin},'tdes');
   else
      sys=tss(varargin{1:nin-1});
      set(sys,'e',varargin{nin});
   end
case {'tf'}
   % 'tf'    'num,den,ty'  SIMO Transfer function
   num=varargin{1};
   den=varargin{2};
   [rnum]=size(num,1);
   if rnum >1 & size(den,1)==1,    % If den is scalar poly,
      den=ones(rnum,1)*den;        % then make it same size as num poly vector
   end
   num=num2cell(num,2);
   den=num2cell(den,2);
   sys=tf(num,den);
case {'tfm'}
   % 'tfm'    'num,den,n,m,ty'  MIMO nxm transfer function matrix
   nummat=varargin{1};
   denmat=varargin{2};
   rtfm=varargin{3};
   ctfm=varargin{4};
   [rnum]=size(nummat,1);
   if rnum >1 & size(denmat,1)==1,    % If den is scalar poly,
      denmat=ones(rnum,1)*denmat;        % then make it same size as num poly vector.
   end
   num=cell(rtfm,ctfm);           % Form empty cells arrays
   den=cell(rtfm,ctfm);
   num(:)=num2cell(nummat,2);         % then fill with data from rows of num 
   den(:)=num2cell(denmat,2);         % and rows of den.
   sys=tf(num,den);
case {'gss','gdes','gpsm','imp'}  % Types with no LTI equivalent
   %% ASSEMBLE SYS USING OLD PRE-LTI RCT TREE VECTOR METHOD:
   %% 
   % 'gss'   'sm,dimx,dimu,dimy,ty'              General statespace
   % 'gdes'  'e,sm,dimx,dimu,dimy,ty'            General descriptor
   % 'gpsm'  'psm,deg,dimx,dimu,dimy,ty'         General polynom. sys. matrix
   % 'imp'   'y,ts,nu,ny'                        Impulse response
   
   sysmagic=27591;  % number installed in any system TREE in position 4
                    % to distinguish SYS from ordinary tree vectors
   vars = [vars ',ty'];
   temp=[];
   sys=tree(vars,varargin{1:nin},ty);
   sys(4)=sysmagic;
otherwise
   error(['Unknown system type ''' ty '''']),
end

if isa(sys,'lti'),
   set(sys,'Ts',Ts); 
elseif Ts,
   sys=graft(sys,Ts,'Ts');
end

%  -------- End LTI/PRIVATE/MKSYS.M -----------RYC/MGS 1997 %

function sys=tss(a,b1,b2,c1,c2,d11,d12,d21,d22)
% SYS= TSS(A,B1,B2,C1,C2,D11,D12,D21,D22) transforms TITO system
%     (two-input-two-output) state-space matrices 
%          A,B1,B2,C1,C2,D11,D12,D21,D22
%      into the corresponding partitioned LTI object.  TSS
%      is the inverse of the function TSSDATA.
% 
% See also TSSDATA, MKTITO

% R. Y. Chiang & M. G. Safonov

b=[b1,b2];
c=[c1;c2];
d=[d11,d12; d21, d22];
[msg,a,b,c,d]=abcdchk(a,b,c,d);
sys=ss(a,b,c,d);
[nmeas,ncont]=size(d22);
sys=mktito(sys,nmeas,ncont);
% ----------- End of TSS.M --------RYC/MGS 1997

function sys=mktito(sys,nmeas,ncont)
% SYS=MKTITO(SYS,NMEAS,NCONT) adds TITO partitioning to 
%    a system by re-setting its InputGroup and
%    OutputGroup properties, labeling last NMEAS
%    output channels 'measurement' and the last NCONT input
%    channels 'command'.  Other output and input channels 
%    are labeled 'error'  and 'disturbance', respectively. 
%    Any pre-existing partition of SYS is overwritten.

% R. Y. Chiang & M. G. Safonov

% Based on Gahinet's 01/98 partitioning specification

[r,c]=size(sys);
if ~isa(sys,'lti'), error('SYS is not an LTI object'), end
if r<nmeas, error('NMEAS exceeds SYS output dimension'), end
if c<ncont, error('NCONT exceeds SYS input dimension'), end

set(sys,'InputGroup',{ 1:c-ncont 'U1'; c-ncont+1:c 'U2' });
set(sys,'OutputGroup',{ 1:r-nmeas 'Y1'; r-nmeas+1:r 'Y2'});

% ----------- End of MKTITO.M --------RYC/MGS 1997

