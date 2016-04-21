% lmisys=lmipck(lmis,lmiv,lmit,data)
%
% Packs the four arrays  LMISET,VAR,TERM and DATA into a
% single vector

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function lmisys=lmipck(lmis,lmiv,lmit,data)

[rs,nlmi]=size(lmis);
[rv,nvar]=size(lmiv);
nterm=size(lmit,2);          % col size = 6
ls=nlmi*rs;                  % length of LMISET
lv=nvar*rv;                  % length of LMIVAR
lt=6*nterm;                  % length of LMITERM
ldt=length(data);
bdt=10+ls+lv+lt;             % base of DATA

% number of dec. vars
if isempty(lmiv), ndec=0; else ndec=max(lmiv(4,:)); end



% allocate
lmisys=zeros(bdt+ldt,1);

% header
lmisys(1:8)=[nlmi;nvar;nterm;rs;rv;bdt;ldt;ndec];

% store info/data
sh=10;       lmisys(sh+1:sh+ls)=lmis(:);
sh=sh+ls;    lmisys(sh+1:sh+lv)=lmiv(:);
sh=sh+lv;    lmisys(sh+1:sh+lt)=lmit(:);
sh=sh+lt;    lmisys(sh+1:sh+ldt)=data;

