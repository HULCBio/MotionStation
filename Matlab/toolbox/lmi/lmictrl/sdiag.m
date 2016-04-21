% sys = sdiag(sys1,sys2,...)
%
% Appends the systems  SYS1, SYS2 ,... into a single system SYS
%
%           _______________________
%           |       ________      |
%           |       |      |      |
%       ----------->| sys1 |----------->
%           |       |______|      |
%           |          :          |
%           |          :          |
%           |       ________      |
%           |       |      |      |
%       ----------->| sysk |----------->
%           |       |______|      |
%           |_____________________|
%
%                     SYS
%
% One (and at most one) of these systems can be polytopic or
% parameter-dependent.  SDIAG takes up to 10 input arguments.
%
%
% See also  LTISYS, SADD, SMULT, SDIAG, PSYS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function sys=sdiag(s1,s2,s3,s4,s5,s6,s7,s8,s9,s10)


if nargin==2,

  if isempty(s1),
    sys=s2;

  elseif isempty(s2),
    sys=s1;

  elseif ispsys(s1) & ispsys(s2),
    error('Cannot append two polytopic or parameter-dependent systems');

  elseif ispsys(s1) & ~ispsys(s2),
    [pdtype,nv,ns,ni,no]=psinfo(s1);

    if strcmp(pdtype,'pol'),
      sys=[];
      for j=1:nv, sys=[sys sdiag(psinfo(s1,'sys',j),s2)]; end
    else
      [ns,ni,no]=sinfo(s2);
      s2z=ltisys(zeros(ns),zeros(ns,ni),zeros(no,ns),zeros(no,ni),0);
      sys=sdiag(psinfo(s1,'sys',1),s2);
      for j=2:nv, sys=[sys sdiag(psinfo(s1,'sys',j),s2z)]; end
    end

    pdtype=1+strcmp(pdtype,'aff');
    sys=psys(psinfo(s1,'par'),sys,pdtype);

  elseif ~ispsys(s1) & ispsys(s2),
    [pdtype,nv,ns,ni,no]=psinfo(s2);

    if strcmp(pdtype,'pol'),
      sys=[];
      for j=1:nv, sys=[sys sdiag(s1,psinfo(s2,'sys',j))]; end
    else
      [ns,ni,no]=sinfo(s1);
      s1z=ltisys(zeros(ns),zeros(ns,ni),zeros(no,ns),zeros(no,ni),0);
      sys=sdiag(s1,psinfo(s2,'sys',1));
      for j=2:nv, sys=[sys sdiag(s1z,psinfo(s2,'sys',j))]; end
    end

    pdtype=1+strcmp(pdtype,'aff');
    sys=psys(psinfo(s2,'par'),sys,pdtype);

  else
    [a,b,c,d,e]=sxtrct(s1);
    [a2,b2,c2,d2,e2]=sxtrct(s2);
    n=size(a,1); n2=size(a2,1);
    [m,p]=size(d); [m2,p2]=size(d2);
    a=mdiag(a,a2); e=mdiag(e,e2);

%%% v5 code.  this is needed to ensure empty matrices
%%% are their correct sizes.
    if isempty(b), b = zeros(n,p); end
    if isempty(c), c = zeros(m,n); end
    if isempty(d), d = zeros(m,p); end
    if isempty(b2), b2 = zeros(n2,p2); end
    if isempty(c2), c2 = zeros(m2,n2); end
    if isempty(d2), d2 = zeros(m2,p2); end

    b=[b,zeros(n,p2);zeros(n2,p),b2];
    c=[c,zeros(m,n2);zeros(m2,n),c2];
    d=[d,zeros(m,p2);zeros(m2,p),d2];
    sys=ltisys(a,b,c,d,e);

  end


else

  sys=s1;

  for k=2:nargin,
     eval(['sys=sdiag(sys,s' int2str(k),');']);
  end

end
