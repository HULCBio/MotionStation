% function dida = dkdispla(dat)
%
%  Displays D-K iteration data.  Called from DKIT.
%  Easily customized for user preference

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function dida = dkdispla(dat)

% set up display width's
 itemwidth = 19;
 fldw = 10;
% set up item names and type
 numitem = 5;
 item1header = 'Iteration #';         item1t = 'int';
 item2header = 'Controller Order';    item2t = 'int';
 item3header = 'Total D-Scale Order'; item3t = 'int';
 item4header = 'Gamma Acheived';      item4t = 'float';
 item5header = 'Peak mu-Value';       item5t = 'float';

 [numitem,itcnt] = size(dat);
 dida = [];
 for i = 1:numitem
   lin1 = eval(['item' int2str(i) 'header']);
   lin2 = eval(['blanks(itemwidth-length(item' int2str(i) 'header));']);
   lin = [lin1 lin2];
   ty = eval(['item' int2str(i) 't;']);
   if strcmp(ty,'int')
     for j = 1:itcnt
      lin = [lin blanks(fldw-length(int2str(dat(i,j)))) int2str(dat(i,j))];
     end
   elseif strcmp(ty,'float')
     for j = 1:itcnt
        if abs(dat(i,j)) >= 1000
          textv = sprintf('%7.2f',dat(i,j));
        else
          textv = sprintf('%6.3f',dat(i,j));
        end
        lin = [lin blanks(fldw-length(textv)) textv];
     end
   elseif strcmp(ty,'exp')
     for j = 1:itcnt
        textv = sprintf('%8.2e',dat(i,j));
        lin = [lin blanks(fldw-length(textv)) textv];
     end
   else
   end
   dida = [dida;lin];
 end
 thetitle = 'Iteration Summary';
 topline = [thetitle blanks(length(lin)-length(thetitle))];
 dida = [topline ; setstr(ones(1,length(lin))*'-') ; dida];