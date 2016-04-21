% sys = sadd(sys1,sys2,...)
%
% Forms the parallel interconnection of the systems  SYS1,
% SYS2, ...   In terms of transfer fucntions, the result is
%
%          SYS = SYS1 + SYS2 + ...
%
% One (and at most one) of these systems can be polytopic or
% parameter-dependent.  SADD takes up to 10 input arguments.
%
%
% See also  SMULT, SDIAG, LTISYS, PSYS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function sys=sadd(sys1,sys2,sys3,sys4,sys5,sys6,sys7,sys8,sys9,sys10)


if nargin<1,
   error('usage: sys = sadd(sys1,sys2,...)')
elseif nargin==2,

  if ispsys(sys1),

    if ispsys(sys2),
       error('Cannot add two polytopic or parameter-dependent systems');

    else
       [pdtype,nv]=psinfo(sys1);

       if strcmp(pdtype,'pol'),
         sys=[];
         for j=1:nv, sys=[sys sadd(psinfo(sys1,'sys',j),sys2)]; end
       else
         [ns,ni,no]=sinfo(sys2);
         s2z=ltisys(zeros(ns),zeros(ns,ni),zeros(no,ns),zeros(no,ni),0);
         sys=sadd(psinfo(sys1,'sys',1),sys2);
         for j=2:nv, sys=[sys sadd(psinfo(sys1,'sys',j),s2z)]; end
       end

       pdtype=1+strcmp(pdtype,'aff');
       sys=psys(psinfo(sys1,'par'),sys,pdtype);
    end

  else

    if ispsys(sys2),
       [pdtype,nv]=psinfo(sys2);

       if strcmp(pdtype,'pol'),
         sys=[];
         for j=1:nv, sys=[sys sadd(sys1,psinfo(sys2,'sys',j))]; end
       else
         [ns,ni,no]=sinfo(sys1);
         s1z=ltisys(zeros(ns),zeros(ns,ni),zeros(no,ns),zeros(no,ni),0);
         sys=sadd(sys1,psinfo(sys2,'sys',1));
         for j=2:nv, sys=[sys sadd(s1z,psinfo(sys2,'sys',j))]; end
       end

       pdtype=1+strcmp(pdtype,'aff');
       sys=psys(psinfo(sys2,'par'),sys,pdtype);

    else
       [a,b,c,d,e]=sxtrct(sys1);
       [a2,b2,c2,d2,e2]=sxtrct(sys2);
       a=mdiag(a,a2);e=mdiag(e,e2);

%%% v5 code
       if isempty(b), b = zeros(0,size(b2,2)); end
       if isempty(b2), b2 = zeros(0,size(b,2)); end
       if isempty(c), c = zeros(size(c2,1),0); end
       if isempty(c2), c2 = zeros(size(c,1),0); end

       b=[b;b2];
       c=[c,c2];
       d=d+d2;
       sys=ltisys(a,b,c,d,e);
    end
  end


else

  sys=sys1;

  for k=2:nargin,
     eval(['sys=sadd(sys,sys' int2str(k),');']);
  end

end
