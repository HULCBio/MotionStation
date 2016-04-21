% function [soln]= sdn_step(a,b1,b2,c1,c2,invT,T,S,s,h,delay,k);
%
% SOLN contains 0 if gamma is too small
%               1 if norm less than gamma
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [soln]= ...
sdn_step(a,b1,b2,c1,c2,invT,T,S,s,h,delay,k);

%start optimistically
soln=1;

%
tn=max(size(S));
n=tn/2;

% construct equivalent discrete system

dsdsys=sdequiv(a,b1,b2,c1,c2,invT,T,S,s,h,delay);
if isempty(dsdsys),
    soln=0;
    return
  end

row2=length(c2(:,1)); col2=length(b2(1,:));
clsys=starp(dsdsys,k,row2,col2);
clpoles=spoles(clsys);

%convert to continuous-time

if max(abs(clpoles))>=1,
        soln=0;
        return;
	end

csys=bilinz2s(clsys,h);
[A,B,C,D]=unpck(csys);

%call hinfchk to check the gamma value

if (max(real(eig(A)))>=0.0) | (norm(D)>=1),
      soln=0;
  else
      out = hinfchk(csys);
      if ~isempty(out),
	soln=0;
	end
  end; %if (max(real