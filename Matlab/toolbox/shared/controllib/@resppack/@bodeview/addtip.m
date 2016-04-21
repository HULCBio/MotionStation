function addtip(this,tipfcn,info)
%ADDTIP  Adds line tip to each curve in each view object

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:20:31 $

for ct1 = 1:size(this.MagCurves,1)
   for ct2 = 1:size(this.MagCurves,2)
      info.Row = ct1; 
      info.Col = ct2;
      info.SubPlot = 1;
      this.installtip(this.MagCurves(ct1,ct2),tipfcn,info)
      info.SubPlot = 2;
      this.installtip(this.PhaseCurves(ct1,ct2),tipfcn,info)
   end
end

