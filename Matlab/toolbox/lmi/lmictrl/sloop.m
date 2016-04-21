% clsys = sloop(g1,g2,sgn)
%
% Forms the feedback interconnection
%                    ______
%        +          |      |
%   r --->O-------->|  G1  |-------+----> y
%         |         |______|       |
%     +/- |                        |
%         |          ______        |
%         |         |      |       |
%         |_________|  G2  |<------+
%                   |______|
%
% The output CLSYS is a realization of the closed-loop
% transfer function from r to y.
% SGN = -1 specifies negative feedback (default) and
% SGN = +1 specifies positive feedback.
%
% Either G1 or G2 can be polytopic or parameter-dependent.
%
%
% See also  SLFT, SCONNECT, LTISYS, PSYS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function sys=sloop(sys1,sys2,sgn)

if nargin==2, sgn=-1; end


if ispsys(sys1),

   if ispsys(sys2),
     error('G1 and G2 cannot be both polytopic or parameter-dependent');
   else
     [pdtype,nv,ns,ni,no]=psinfo(sys1);
     if strcmp(pdtype,'aff'),
        error('Not implemented for affine PD system');
     end

     sys=[];
     for j=1:nv, sys=[sys sloop(psinfo(sys1,'sys',j),sys2,sgn)]; end

     sys=psys(psinfo(sys1,'par'),sys,1);
   end

else

   if ispsys(sys2),
     [pdtype,nv,ns,ni,no]=psinfo(sys2);
     if strcmp(pdtype,'aff'), error('Not implemented for affine PDS'); end

     sys=[];
     for j=1:nv, sys=[sys sloop(sys1,psinfo(sys2,'sys',j),sgn)]; end

     sys=psys(psinfo(sys2,'par'),sys,1);
   else

     [a1,b1,c1,d1,e1]=sxtrct(sys1);
     [a2,b2,c2,d2,e2]=sxtrct(sys2);

     if any(size(d1)~=size(d2')),
       if isempty(a1) & isequal(size(d1),[1 1]) & size(d2,1)==size(d2,2),
         sd2 = size(d2,1);
         b1 = zeros(0,sd2);  c1 = b1';   d1=d1*eye(sd2);
       elseif isempty(a2) & isequal(size(d2),[1 1]) & size(d1,1)==size(d1,2),
         sd1 = size(d1,1);
         b2 = zeros(0,sd1);  c2 = b2';   d2=d2*eye(sd1);
       else
         error('Incompatible system dimensions');
       end
     end

     d0=d1*d2;  Phi=eye(size(d0))-sgn*d0;
     d0=d2*d1;  Psi=eye(size(d0))-sgn*d0;

     % test for algebraic loop
     if rcond(Phi) < 100*mach_eps,
        error('Algebraic loop!')
     end

     % connect
     b1psi=b1/Psi;
     phic1=Phi\c1;
     phid1=Phi\d1;

     a1=[a1+sgn*b1psi*d2*c1 sgn*b1psi*c2; b2*phic1 a2+sgn*b2*phid1*c2];
     b1=[b1psi;b2*phid1];
     c1=[phic1 sgn*phid1*c2];
     d1=phid1;


     sys=ltisys(a1,b1,c1,d1,mdiag(e1,e2));

   end

end


% balancing in SYSTEM case
if islsys(sys), sys=sbalanc(sys); end
