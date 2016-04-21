% function out = mdipii(in,data,depth,row,col)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = mdipii(in,data,depth,row,col)

 page  = xpii(in,depth);
 prow  = xpii(page,row);
 nrow  = ipii(prow,data,col);
 npage = ipii(page,nrow,row);
 out   = ipii(in,npage,depth);