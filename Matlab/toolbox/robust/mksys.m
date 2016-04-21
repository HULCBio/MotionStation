function s=mksys(varargin)
% MKSYS Pack system matrices into "TREE" variable.  
% S=MKSYS(A,B,C,D) or
% S=MKSYS(V1,V2,...,VN, TY) packs matrices describing a system into TREE
% vector S under variable names depending on the STRING TY as follows:
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
% See also TREE, BRANCH, GRAFT.

% R. Y. Chiang & M. G. Safonov 10/25/90 (rev 4/21/98)
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------------------

nin=nargin;
sysmagic=27591;  % number installed in any system TREE in position 4
                 % to distinguish it from ordinary tree vectors
Ts=0;            % default value of sample time

% Determine TY and set NIN equal to number of input arguments other than TY
if nin<1
  error('Too few input arguments')
else
  ty=varargin{nin};
  if isstr(ty),               % If TY is present
     nin=nin-1;
  else
     ty='ss';                 % Default TY
  end
end

% Convert TY to lowercase
ty=lower(ty);

[vars,nvars]=vrsys(ty);
%% WAS nvars=max(size(find(vars==',')))+1;

% Get optional input Ts, if present
temp=varargin{nin};
if nvars<nin & isa(temp,'double') & length(temp)==1,
   Ts=temp;
   nin=nin-1;
end

if nvars>nin,
   error(['Too few input arguments for system type ' ty]),
elseif nvars<nin,
   error(['Too many input arguments for system type ' ty]),
end
vars = [vars ',ty'];
s=tree(vars,varargin{1:nin},ty);
s(4)=sysmagic;

% If Ts is non-zero, graft 'Ts' branch onto s
if Ts, s=graft(s,Ts,'Ts'); end
   
%  -------- End MKSYS.M -----------RYC/MGS 10/25/90 %