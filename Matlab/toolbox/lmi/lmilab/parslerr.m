% called by LMIEDIT

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function parslerr(hdl,messg1,messg2)


if nargin==2,
   set(hdl(22),'str',messg1,'hor','center');
else
   set(hdl(22),'str',messg1,'hor','left');
   set(hdl(23),'str',messg2,'hor','left');
end

set(hdl(21:24),'vis','on');
set(hdl(14:15),'enable','off')
