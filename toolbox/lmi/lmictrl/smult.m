% sys = smult(sys1,sys2,...)
%
% Forms the series interconnection
%
%        ________    ________
%        |      |    |      |
%    --->| sys1 |--->| sys2 |---> ...
%        |______|    |______|
%
%
% of the systems  SYS1, SYS2, etc.   In terms of transfer
% functions, the result is
%            SYSn * ... * SYS2 * SYS1
% One and at most one of the systems can be polytopic or
% parameter-dependent.  SMULT takes up to 10 input arguments.
%
%
% See also  SADD, SDIAG, LTISYS, PSYS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function sys=smult(s1,s2,s3,s4,s5,s6,s7,s8,s9,s10)


if nargin==2,

  if ispsys(s1),

    if ispsys(s2),
       error('Cannot multiply two polytopic or parameter-dependent systems');

    else
       [pdtype,nv]=psinfo(s1);

       if strcmp(pdtype,'pol'),
         sys=[];
         for j=1:nv, sys=[sys smult(psinfo(s1,'sys',j),s2)]; end
       else
         [a,b,c,d,e]=sxtrct(s2);
         s2m=ltisys(zeros(size(a)),b,zeros(size(c)),d,0);
         sys=smult(psinfo(s1,'sys',1),s2);
         for j=2:nv, sys=[sys smult(psinfo(s1,'sys',j),s2m)]; end
       end

       pdtype=1+strcmp(pdtype,'aff');
       sys=psys(psinfo(s1,'par'),sys,pdtype);
    end

  else

    if ispsys(s2),
       [pdtype,nv]=psinfo(s2);

       if strcmp(pdtype,'pol'),
         sys=[];
         for j=1:nv, sys=[sys smult(s1,psinfo(s2,'sys',j))]; end
       else
         [a,b,c,d,e]=sxtrct(s1);
         s1m=ltisys(zeros(size(a)),zeros(size(b)),c,d,0);
         sys=smult(s1,psinfo(s2,'sys',1));
         for j=2:nv, sys=[sys smult(s1m,psinfo(s2,'sys',j))]; end
       end

       pdtype=1+strcmp(pdtype,'aff');
       sys=psys(psinfo(s2,'par'),sys,pdtype);

    else
       [a,b,c,d,e]=sxtrct(s1);
       [a2,b2,c2,d2,e2]=sxtrct(s2);
       if size(d2,2)~=size(d,1) & ...
          ~(isempty(a) & all(size(d)==[1 1])) & ...
          ~(isempty(a2) & all(size(d2)==[1 1]))
          error('Incomptatible dimensions!');
       end
       n1=size(a,1);
       n2=size(a2,1);

%%% v5 code
       if isempty(b), b = zeros(0,size(b2,2)); end
       if isempty(c), c = zeros(size(b2,2),0); end
       if isempty(b2), b2 = zeros(0,size(c,1)); end
       if isempty(c2), c2 = zeros(size(c,1),0); end

       a=[a2 b2*c;zeros(n1,n2) a];

       e=mdiag(e2,e);
       b=[b2*d;b];
       c=[c2,d2*c];
       d=d2*d;

       sys=ltisys(a,b,c,d,e);

    end
  end


else

  sys=s1;

  for k=2:nargin,
     eval(['sys=smult(sys,s' int2str(k),');']);
  end

end
