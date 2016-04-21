function [out1,out2,out3] = key2info(lin_norm,lin_zero,key,typ)
%KEY2INFO Key driven retrieve from tables.
%   [OUT1,OUT2,OUT3] = KEY2INFO(HDL_NORM,HDL_ZERO,KEY,TYP)
%   returns elements TAB1(index),TAB2(index)  and TAB3(index)
%   where index is the approximate solution for TABX(index) = KEY,
%   where TABX is constructed from the lines of the performance axes
%   depending on the type of the typ input:
%   typ = N means that the key is a l2-norm recovery value
%   typ = Z means that the key is a number of zeros value
%   typ = T means that the key is a threshold value.
%   TAB1,TAB2 and TAB3 are constructed from the Xdata or Ydata of
%   the lines which handles are lin_norm and lin_zero, depending
%   on the value of key.
%   TAB1,TAB2 and TAB3 are supposed to be of the same length.
%
%   See also WCMPSCR, WPCMPSCR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.12.4.2 $

%   Only minimal argument checking for this program.

switch upper(typ)
  case 'N'
    tab   = get(lin_norm,'Ydata');
    index = getIndex('dec',key,tab);
    out1  = tab(index);
    tab   = get(lin_zero,'Ydata');
    out2  = tab(index);
    tab   = get(lin_norm,'Xdata');
    out3  = tab(index);

  case 'Z'
    tab   = get(lin_zero,'Ydata');
    index = getIndex('inc',key,tab);
    out2  = tab(index);
    tab   = get(lin_norm,'Ydata');
    out1  = tab(index);
    tab   = get(lin_norm,'Xdata');
    out3  = tab(index);

  case 'T'
    tab   = get(lin_norm,'Xdata');
    index = getIndex('inc',key,tab);
    out3  = tab(index);
    tab   = get(lin_norm,'Ydata');
    out1  = tab(index);
    tab   = get(lin_zero,'Ydata');
    out2  = tab(index);
end


function index = getIndex(opt,key,tab)

n     = length(tab);
index = [];
switch opt
  case 'dec'
    if     key<=tab(n) , index = n;
    elseif key>=tab(1) , index = 1;
    end
  case 'inc'
    if     key<=tab(1) , index = 1;
    elseif key>=tab(n) , index = n;
    end  
end
if isempty(index)
    d = abs(key-tab);
    m = min(d);
    index = max(find(d==m));
end
