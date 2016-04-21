function sys = padeappx(sys,id,od,iod,Ni,No,Nio)
%PADEAPPX  Pade approximation algorithm.
%
%   SYSX = PADEAPPX(SYS,ID,OD,IOD,NI,NO,NIO).
%
%   LOW-LEVEL UTILITY.  See PADE.

%   Author: P. Gahinet 5-98
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 06:07:23 $

sizes = size(sys.num);
ny = sizes(1);
nu = sizes(2);

% Main loop over each model
for m=1:prod(sizes(3:end)),
   for j=1:nu,
      for i=1:ny,
         [npi,dpi] = pade(id(j,1,min(m,end)),Ni(j,1,min(m,end)));
         [npo,dpo] = pade(od(i,1,min(m,end)),No(i,1,min(m,end)));
         [npio,dpio] = pade(iod(i,j,min(m,end)),Nio(i,j,min(m,end)));
         sys.num{i,j,m} = fastconv(sys.num{i,j,m},npi,npo,npio);
         sys.den{i,j,m} = fastconv(sys.den{i,j,m},dpi,dpo,dpio);
      end
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function p = fastconv(p,p1,p2,p3)
%FASTCONV  Fast polynomial product

if ~isequal(p1,1),
   p = conv(p,p1);
end

if ~isequal(p2,1),
   p = conv(p,p2);
end

if ~isequal(p3,1),
   p = conv(p,p3);
end

