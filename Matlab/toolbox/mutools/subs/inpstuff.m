% function [numxinp,names,namelen,maxlen] = inpstuff(inputvar);

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [numxinp,ndf,inppoint,names,namelen,maxlen,err] = inpstuff(inputvar);
  err = 0;
  startp = 0;
  inppoint = [];
  maxlen = 0;
  names = [];
  tmpln = length(inputvar);
  iloc = find(inputvar ~= ']' & inputvar ~= '[');
  tmp = inputvar(iloc);
  tmp = tmp(find(tmp ~= ' '));
  semic = [0 find(tmp == ';') length(tmp)+1];
  numdiffinp = length(semic) - 1;
  namelen = zeros(numdiffinp,1);
  numxinp = 0;
  for i=1:numdiffinp
    var = tmp(semic(i)+1:semic(i+1)-1);
    %  lparen = find(var == '(');
    %  rparen = find(var == ')');
    %  backwards compatible, but supports braces now
    lparen = find(var == '(' | var == '{');
    rparen = find(var == ')' | var == '}');
    if length(lparen) > 1 | length(rparen) > 1
      err = 1;
      return
    elseif length(lparen) ~= length(rparen)
      err = 1;
      return
    elseif length(lparen) == 1
      if lparen >= rparen
        err = 1;
        return
      elseif rparen ~= length(var)
        err = 1;
        return
      elseif lparen == rparen - 1
        err = 1;
        return
      else
        numass = eval(var(lparen+1:rparen-1));
        nn = var(1:lparen-1);
        if lparen-1 > maxlen
          maxlen = lparen - 1;
        end
        namelen(i) = length(nn);
        names = [names ; [nn mtblanks(tmpln-length(nn))]];
        inppoint = [inppoint ; [startp numass]];
        startp = startp + numass;
        numxinp = numxinp + numass;
      end
    else
      nn = var;
      if length(nn) > maxlen
        maxlen = length(nn);
      end
      namelen(i) = length(nn);
      names = [names ; [nn mtblanks(tmpln-length(nn))]];
      inppoint = [inppoint ; [startp 1]];
      startp = startp + 1;
      numxinp = numxinp + 1;
    end
  end
  names = names(:,1:maxlen);
  ndf = numdiffinp;
%
%