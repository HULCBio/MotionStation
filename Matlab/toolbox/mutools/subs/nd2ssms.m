% function [a,b,c,d] = nd2ssms(num,den)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [a,b,c,d] = nd2ssms(num,den)

  [nrn,ncn] = size(num);
  nlen = ncn;
  if nrn > 1
    if ncn > 1
      disp('NUM should be a vector');
      return
    else
      num = num.';
      nlen = nrn;
    end
  end
  [nrd,ncd] = size(den);
  dlen = ncd;
  if nrd > 1
    if ncd > 1
      disp('DEN should be a vector');
      return
    else
      den = den.';
      dlen = nrd;
    end
  end

  dstart = min(find(abs(den)>0));
  den = den(dstart:dlen);
  dlen = length(den);
  nstart = min(find(abs(num)>0));
  num = num(nstart:nlen);
  nlen = length(num);

  if nlen > dlen
    disp('NUM order should be <= DEN order')
    return
  elseif dlen == 1
    a = [];
    b = [];
    c = [];
    d = num/den;
  else
    num = num/den(1);
    den = den/den(1);
    if nlen == dlen
      d = num(1)/den(1);
      c = num - d*den;
      c = fliplr(c(2:dlen));
    else
      d = 0;
      c = fliplr([zeros(1,dlen-1-nlen) num]);
    end
    a = [zeros(dlen-2,1) eye(dlen-2);-fliplr(den(2:dlen))];
    b = [zeros(dlen-2,1);1];
  end