function [mainmod,noisemod] = th2mod(th1,th2,th3,th4,th5,th6,th7,th8)
%TH2MOD Converts from the ID "theta" format to the MPC mod format.
%
% 	      umod  = th2mod(th)
%	[umod,emod] = th2mod(th1,th2,th3,th4,th5,th6,th7,th8)
%
% Inputs:
%  th   model in the theta format.  Each additional input
%       is assumed to model a new output which is placed in
%       parallel with the preceding outputs.  These are the
%       inputs to "umod", whose dynamics depend on the A, B
%       and F polynomials of the theta model(s).  An optional
%       noise model ("emod") is created in which each output
%       is affected by an independent noise input, and whose
%       dynamics depends on the A, C and D polynomials of the
%       theta model(s).
%
% Outputs:
%  umod : Model of effect of measured inputs on outputs, in MPC
%         MOD format.
%  emod : Model of effect of noise on outputs, in MPC
%         MOD format.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $


nm=nargin;
if nm < 1 | nm > 8
   disp('USAGE:  [umod,emod] = th2mod(th1,th2,th3,th4,th5,th6,th7,th8)')
   return
end

T=th1.Ts;
m=size(th1,2);


for im=1:nm

   th = eval(['th',int2str(im)]);

   if th.Ts ~= T
      fprintf('Problem with model:  th%.0f \n',im)
      error('Sampling period different from previous model.')
   end
   if size(th,2) ~= m
      fprintf('Problem with model:  th%.0f \n',im)
      error('Different # of manipulated variables')
   end

   [at,bt,ct,dt,ft]=polyform(th);
   na=length(at)-1;
   [nrows,nb]=size(bt);
   nc=length(ct)-1;
   nd=length(dt)-1;
   [nrows,nf]=size(ft);
   nf=nf-1;
   ngex=na+nf-nb+1;
   if ngex > 0
      bt=[bt zeros(m,ngex)];
   elseif ngex < 0
      ft=[ft zeros(m,-ngex)];
   end
   nhex=na+nd-nc;
   if nhex > 0
      ct=[ct zeros(1,nhex)];
   elseif nhex < 0
      dt=[dt zeros(1,-nhex)];
   end

% Now process the polynomials.

   if m > 0
      phi2=[];gam2=[];c2=[];d2=[];
      for iu=1:m
         [phi1,gam1,c1,d1]=tf2ssm(bt(iu,:),conv(at,ft(iu,:)));
         [phi2,gam2,c2,d2]=mpcparal(phi2,gam2,c2,d2,phi1,gam1,c1,d1);
      end

      if im == 1
         phi3=phi2;
         gam3=gam2;
         c3=c2;
         d3=d2;
      else
         [phi3,gam3,c3,d3]=mod2ss(appmod(ss2mod(phi3,gam3,c3,d3),...
                                  ss2mod(phi2,gam2,c2,d2)));

         gam3=gam3(:,1:m)+gam3(:,m+1:m+m);
         d3=d3(:,1:m)+d3(:,m+1:m+m);
      end
   end
   [phi1,gam1,c1,d1]=tf2ssm(ct,conv(at,dt));
   if im==1
      phin=phi1;
      gamn=gam1;
      cn=c1;
      dn=d1;
    else
        [phin,gamn,cn,dn]=mod2ss(appmod(ss2mod(phin,gamn,cn,dn),...
                          ss2mod(phi1,gam1,c1,d1)));
    end
end

if m > 0
   mainmod=ss2mod(phi3,gam3,c3,d3,T);
else
   mainmod=[];
end
if nargout > 1
   noisemod=ss2mod(phin,gamn,cn,dn,T);
end

% end of function TH2MOD