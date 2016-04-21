% Retrieves information about some block-diagonal uncertainty
% structure  DELTA  created with UBLOCK/UDIAG
%
% UINFO(DELTA)    displays the characteristics of each
%                 uncertainty block in DELTA
%
% N = UINFO(DELTA)    returns the number N of uncertainty
%                     blocks
%
% [DIMS,TYP,BND] = UINFO(DELTA,K)
%       returns the dimensions, type, and bounds for the
%       K-th uncertainty block in DELTA
%
%
% See also  UBLOCK, UDIAG.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function [dims,type,bnd]=uinfo(delta,k);


if ~any(nargin==[1 2]),
  error('for correct calling syntax, type:  help uinfo');
end


if nargout,
  nblck=size(delta,2);
  if nargin==1,
    dims=nblck; typ=[]; bnd=[];
  else
    if k < 0 | k > nblck,
      error(sprintf('K should be an integer between 1 and %d',nblck));
    end
    b=delta(:,k);
    dims=b(1:2)';

    lin=b(3); time=b(4);
    comp=b(5); scal=b(6);
    m=b(7); n=b(8);
    bnd=reshape(b(9:8+m*n),m,n);

%    if lin, type='l'; else type='nl'; end
%    if time, type=[type 'tv']; else type=[type 'ti']; end
    if lin,
      if time, type='ltv'; else type='lti'; end
    else
      if time, type='nl'; else type='nlm'; end
    end
    if comp==0, type=[type 'r']; else type=[type 'c']; end
    if scal==1, type=[type 's']; else type=[type 'f']; end
  end

else


  dispstr=str2mat(...
  ' block   dims   type   real/cplx   full/scal      bounds',[]);

  bn=1;

  for b=delta,
    lin=b(3); time=b(4);
    comp=b(5); scal=b(6);
    m=b(7); n=b(8);  bnd=reshape(b(9:8+m*n),m,n);

%    if lin, type=' L'; else type='NL'; end
%    if time, type=[type 'TV']; else type=[type 'TI']; end

    if lin,
      if time, type='LTV'; else type='LTI'; end
    else
      if time, type=' NL'; else type='NLM'; end
    end
    if comp==0, rc='r'; elseif comp==1, rc='c'; else rc='?'; end
    if scal==1, fs='s'; elseif scal==0, fs='f'; else fs='?'; end

    if m==1 & n==1,
      bnd=['norm <= ' num2str(bnd)];
    elseif m>1 & n>1,
      bnd='freq. dependent';
    else
      bnd=['sector {' num2str(bnd(1)) ',' num2str(bnd(2)) '}'];
    end

    str=['   ' num2str(bn) '      ' num2str(b(1)) 'x' num2str(b(2)) ];
    str=[str '    ' type '       ' rc '           ' fs '         ' bnd ];

    dispstr=str2mat(dispstr,str);

    bn=bn+1;
  end

  disp(' ');
  disp(dispstr);
  disp(' ');


end
