function setDataTipInfo(this,val)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:12:41 $

if ischar(val)
  this.DataTipInfo = val;
else
  this.DataTipInfo = num2str(val);
end