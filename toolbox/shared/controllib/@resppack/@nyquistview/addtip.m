function addtip(this,tipfcn,info)
%ADDTIP  Adds line tip to each curve in each view object

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:21:50 $
for ct1 = 1:size(this.PosCurves,1)
   for ct2 = 1:size(this.PosCurves,2)
      info.Row = ct1; 
      info.Col = ct2;
      info.Sign = 1;
      this.installtip(this.PosCurves(ct1,ct2),tipfcn,info)
      info.Sign = -1;
      this.installtip(this.NegCurves(ct1,ct2),tipfcn,info)
   end
end
