function eqntxtH = bfitcreateeqntxt(digits,axesh,dataH,fitsshowing)
% BFITCREATEEQNTXT Create text equations for Basic Fitting GUI.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/15 04:06:25 $

eqntxtH = [];
figH = get(axesh,'parent');
coeffcell = getappdata(dataH,'Basic_Fit_Coeff');

n = length(fitsshowing);
eqns = cell(n+1,1);
eqns{1,:} = ' ';
for i = 1:n
    % get fit type
    currentInd = fitsshowing(i);
    fittype = currentInd - 1;
    % add string to matrix
    eqns{i+1,:} = eqntxtstring(fittype,coeffcell{currentInd},digits,axesh);
end
if ~isempty(eqns) & n > 0 
    figure(figH)
    xl = get(axesh,'xlim');
    yl = get(axesh,'ylim');
    eqntxtH = text(xl*[.95;.05],yl*[.05;.95],eqns,'parent',axesh, ...
        'tag', 'equations', ...
        'verticalalignment','top');
end
%-------------------------------------------------------

function s = eqntxtstring(fitnum,pp,digits,axesh)

op = '+-'; flag = 0;
format1 = ['%s %0.',num2str(digits),'g*x^{%s} %s'];
format2 = ['%s %0.',num2str(digits),'g'];

xl = get(axesh,'xlim');
if isequal(fitnum,0)
  s = 'Cubic spline interpolant';
elseif isequal(fitnum,1)
  s = 'Shape-preserving interpolant';
else
  fit = fitnum - 1;
  s = sprintf('y =');
  th = text(xl*[.95;.05],1,s,'parent',axesh, 'vis','off');
  if abs(pp(1) < 0), s = [s ' -']; end
  for i = 1:fit
    sl = length(s);
    if ~isequal(pp(i),0) % if exactly zero, skip it
      s = sprintf(format1,s,abs(pp(i)),num2str(fit+1-i), op((pp(i+1)<0)+1));
    end    
    if (i==fit) & ~isequal(pp(i),0), s(end-5:end-2) = []; end % change x^1 to x.
    set(th,'string',s);
    et = get(th,'extent');
    if et(1)+et(3) > xl(2)
      s = [s(1:sl) sprintf('\n     ') s(sl+1:end)];
    end
  end
  if ~isequal(pp(fit+1),0) & ~flag
    sl = length(s);
    s = sprintf(format2,s,abs(pp(fit+1)));
    set(th,'string',s);
    et = get(th,'extent');
    if et(1)+et(3) > xl(2),
      s = [s(1:sl) sprintf('\n     ') s(sl+1:end)];
    end
  end
  delete(th);
end

% delete last '+' if one is left hanging on the end
if isequal(s(end),'+')
    s(end-1:end) = []; % there is always a space before the +.
end

if length(s) == 3
    s = sprintf(format2,s,0);
end

