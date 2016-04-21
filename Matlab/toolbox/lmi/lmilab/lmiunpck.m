%  [lmis,lmiv,lmit,data]=lmiunpck(lmisys)
%
%  Extracts the four arrays  LMI-SET,VAR,TERM and DATA
%  from LMISYS


% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [lmis,lmiv,lmit,data]=lmiunpck(lmisys)

% NB: lmisys is a vector...



if isempty(lmisys),
  lmis=[]; lmiv=[]; lmit=[]; data=[];

else

  nlmi=lmisys(1); nvar=lmisys(2); nterm=lmisys(3);
  rs=lmisys(4); rv=lmisys(5);  % row sizes of LMISET,LMIVAR
  ls=nlmi*rs;                  % length of LMISET
  lv=nvar*rv;                  % length of LMIVAR
  lt=6*nterm;                  % length of LMITERM
  ldt=lmisys(7);               % length of DATA

  shift=10; % reserved header
  lmis=reshape(lmisys(shift+1:shift+ls),rs,nlmi);
  shift=shift+ls;
  lmiv=reshape(lmisys(shift+1:shift+lv),rv,nvar);

  if nargout > 2,
    shift=shift+lv;
    lmit=reshape(lmisys(shift+1:shift+lt),6,nterm);
  end

  if nargout > 3,
    shift=shift+lt;
    data=lmisys(shift+1:shift+ldt);
  end

end
