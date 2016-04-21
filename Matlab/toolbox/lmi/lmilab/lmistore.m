% utility function

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.7.2.3 $

function lmistore(data,opt,j)

ld=length(data);
[c,ceilg]=computer;

if opt==1,
  global GLZ_LMIS
  dim=size(GLZ_LMIS,1);
  if j >= dim,        % reallocate
    news=dim+10+min([0.9*abs(ceilg-dim),1e5,9*dim]);
    GLZ_LMIS(news,max(size(GLZ_LMIS,2),ld))=0;
  end
  GLZ_LMIS(j,1:ld)=data;

elseif opt==2,
  global GLZ_LMIT
  dim=size(GLZ_LMIT,2);
  if j >= dim,        % reallocate
    news=dim+10+min([0.9*abs(ceilg-dim),1e6,9*dim]);
    GLZ_LMIT(6,news)=0;
  end
  GLZ_LMIT(1:6,j)=data;

elseif opt==3,
  global GLZ_DATA
  dim=length(GLZ_DATA);
  if j+ld >= dim,
    news=dim+100+min([0.9*abs(ceilg-dim),1e6,9*dim]);
    GLZ_DATA(news,1)=0;
  end
  GLZ_DATA(j+1:j+ld)=data;

end
