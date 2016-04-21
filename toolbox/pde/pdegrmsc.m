function  [y,h]=pdegrmsc(r,v)
%PDEGRMSC Gram Schmidt phase of Arnoldi algorithm.

%       A Ruhe 8-08-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:16 $

maxort=4;
qmax=0.7;
[n j]=size(v);
rnn=norm(r);
hc=zeros(j,1);
if j>0,
  for iort=1:maxort,
    hv=v'*r;
    hc=hc+hv;
    r=r-v*hv;
    rnorm=rnn;
    rnn=norm(r);
    if rnn > qmax*rnorm, break, end;
  end;
end;
h=[hc;rnn];
y=r/rnn;

