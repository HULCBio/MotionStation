% dsys = sderiv(sys,chan,pd)
%
% Multiplication of some input or output channel of
% the LTI system  SYS  by a proportional-derivator
% component  N*s+D :
%
%           +-------+     +-----------+
%     ------|       |-----|  s*N + D  |---->
%           |  SYS  |     +-----------+
%     ------|       |---------------------->
%           +-------+
%
% Set  CHAN = j  to select the j-th output channel, and
% CHAN = -j  to select the j-th input channel.
% To multiply several channels by  N*s+D, set CHAN to
% the corresponding list of channels.
%
% The real coefficients  N,D  are specified by setting
% PD = [N , D].  SDERIV returns the SYSTEM matrix of the
% resulting interconnection.  This function is useful to
% append non proper shaping filters to a given plant. It
% is applicable to polytopic systems.
%
%
% See also  SMULT, SCONNECT, LTISYS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function dsys = sderiv(sys,chan,pd)


if nargin~=3,
   error('usage:  dsys = sderiv(sys,chan,pd)');
elseif ~islsys(sys) & ~ispsys(sys),
   error('SYS must be a SYSTEM matrix or polytopic system');
end


if ispsys(sys),

  [typ,nv]=psinfo(sys);
  if ~strcmp(typ,'pol'),
    error('Affine parameter-dependent systems not allowed');
  end

  dsys=[];
  for j=1:nv,
   dsys=[dsys sderiv(psinfo(sys,'sys',j),chan,pd)];
  end
  dsys=psys(psinfo(sys,'par'),dsys,1);

else

[as,bs,cs,ds]=ltiss(sys);
[outdim,indim]=size(ds);

if min(chan)<-indim | max(chan)>outdim,
  error(sprintf('The entries of CHAN should be between %d and %d',...
            -indim,outdim));
end



% treat inputs
jneg=abs(chan(find(chan<0)));
lneg=length(jneg);

if lneg>0,

   N=zeros(1,indim);
   D=ones(1,indim);
   N(jneg)=pd(1)*ones(1,lneg);
   D(jneg)=pd(2)*ones(1,lneg);
   nN=max(abs(N));  nD=max(abs(D));
   N=diag(N);  D=diag(D);

   % test properness
   if norm(ds*N) > 0,
     error('The resulting system is non proper');
   end

   cbs=cs*bs;    nds=max(norm(cbs,1)*nN,norm(ds,1)*nD);
   bs=bs*D+as*bs*N;  ds=cbs*N+ds*D;

end



% treat outputs
jpos=abs(chan(find(chan>0)));
lpos=length(jpos);

if lpos>0,

   N=zeros(1,outdim);
   D=ones(1,outdim);
   N(jpos)=pd(1)*ones(1,lpos);
   D(jpos)=pd(2)*ones(1,lpos);
   nN=max(abs(N));  nD=max(abs(D));
   N=diag(N);  D=diag(D);

   % test properness
   if norm(N*ds) > 0,
     error('The resulting system is non proper');
   end

   cbs=cs*bs;    nds=max(norm(cbs,1)*nN,norm(ds,1)*nD);
   cs=D*cs+N*cs*as;  ds=N*cbs+D*ds;

end



if norm(ds,1) < 1000*mach_eps*nds,
  ds=zeros(size(ds));
end


dsys=ltisys(as,bs,cs,ds);

end


% balancing in SYSTEM case

if islsys(dsys), dsys=sbalanc(dsys); end
