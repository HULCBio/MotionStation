% function matout = swapiv(matin,alpha)
%
%  Exchanges the order of nested levels of INDEPENDENT
%  VARIABLEs for generalized VARYING matrices.
%
%  See also: VEVAL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 function matout = swapiv(matin,alpha)
  if nargin<2
    disp('usage: matout = swapiv(matin,alpha)');
    return;
  end
  [nra,nca] = size(alpha);
  niv = nca;
  if nra ~= 1
    if nca ~= 1
      error('ALPHA should be a row vector')
      return
    else
      alpha = alpha.';
      niv = nra;
    end
  end
  if sort(alpha) ~= 1:niv
    error('ALPHA should contain all integers from 1 to LENGTH(ALPHA)');
    return
  end
  tmat = matin;
  betaorig = [];
  for i=1:niv
    [type,rows,cols,num] = minfo(tmat);
    if strcmp(type,'vary')
      betaorig = [betaorig num];     %  [slowest ... fastest]
      tmat = tmat(1:rows,1:cols);    %  XTRACTI(TMAT,1)
    else
      error('insufficient levels of VARYING data were found')
      return
    end
  end
  liv = betaorig(alpha);	% reqrranged IV lengths
  cliv = betaorig;		% original iv lengths [slow ... fast]
  basicrow = rows;
  basiccol = cols;

  nummat = liv(niv);
  nblanks = 1;
  prd = 1;         			% no blank lines for the fastest
  facbac = zeros(niv,1);		% factorial bacwards
  gammai = zeros(niv,1);		% index for matin
  gammam = zeros(niv,1);		% index for matin
  facbac(1) = 1;
  gammai(niv) = basicrow;
  gammam(niv) = basicrow;
  for i=1:niv-1
    facbac(i+1) = facbac(i)*liv(i);	%facbac(k)=liv(k-1)*...*liv(1)
    nummat = nummat*liv(i);
    prd = prd*liv(i);
    nblanks = nblanks + prd;
    gammai(niv-i) = gammai(niv-i+1)*cliv(niv-i+1) + 1;
    gammam(niv-i) = gammam(niv-i+1)*liv(niv-i+1) + 1;
  end

  cdim = basiccol + niv;
  rdim = basicrow*nummat + nblanks;
  matout = zeros(rdim,cdim);

  index = [1:basicrow]';
  mask = [1:basicrow]';
  for i=1:niv
    index = ksum([0:cliv(alpha(niv-i+1))-1]'*gammai(alpha(niv-i+1)),index);
    mask = ksum([0:liv(niv-i+1)-1]'*gammam(niv-i+1),mask);
  end
  matout(mask,1:cols) = matin(index,1:cols);

  loc = 0;
  insert = ksum(loc,[1:liv(1)]');
  matout(insert,cdim) = matin(1:liv(1),basiccol+niv-alpha(1)+1);
  matout(rdim,cdim-1:cdim) = [liv(1) inf];
  for i=2:niv
    loc = ksum([0:liv(i-1)-1]'*gammam(i-1),loc);
    insert = ksum(loc,[1:liv(i)]');
    matout(insert,cdim-i+1)=kron(ones(facbac(i),1),matin(1:liv(i),basiccol+niv-alpha(i)+1));
    locc = loc + gammam(i-1);
    matout(locc,cdim-i:cdim-i+1) = ones(facbac(i),1)*[liv(i) inf];
  end
%
%