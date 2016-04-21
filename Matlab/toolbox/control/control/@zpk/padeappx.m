function sys = padeappx(sys,id,od,iod,Ni,No,Nio)
%PADEAPPX  Pade approximation algorithm.
%
%   SYSX = PADEAPPX(SYS,ID,OD,IOD,NI,NO,NIO).
%
%   LOW-LEVEL UTILITY.  See PADE.

%   Author: P. Gahinet 5-98
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 06:12:19 $

sizes = size(sys.k);
ny = sizes(1);
nu = sizes(2);

% Main loop over each model
for m=1:prod(sizes(3:end)),
   for j=1:nu,
      for i=1:ny,
         [zi,pi,ki] = pade(id(j,1,min(m,end)),Ni(j,1,min(m,end)));
         [zo,po,ko] = pade(od(i,1,min(m,end)),No(i,1,min(m,end)));
         [zio,pio,kio] = pade(iod(i,j,min(m,end)),Nio(i,j,min(m,end)));
         sys.z{i,j,m} = [sys.z{i,j,m} ; zi ; zo ; zio];
         sys.p{i,j,m} = [sys.p{i,j,m} ; pi ; po ; pio];
         sys.k(i,j,m) = sys.k(i,j,m) * ki * ko * kio;
      end
   end
end

