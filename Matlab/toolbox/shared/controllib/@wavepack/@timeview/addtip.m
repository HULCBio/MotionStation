function addtip(this,tipfcn,info)
%ADDTIP  Adds line tip to each curve in each view object

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:25:52 $
for ct1 = 1:size(this.Curves,1)
   for ct2 = 1:size(this.Curves,2)
      info.Row = ct1; info.Col = ct2;
      this.installtip(this.Curves(ct1,ct2),tipfcn,info)
   end
end