function addtip(this,tipfcn,info)
%ADDTIP  Adds line tip to each curve in each view object

%   Author(s): John Glass
%   Revised  : Kamesh Subbarao 10-15-2001
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:22:14 $
info.TipOptions = {'Movable','off','Marker','none','InterpolationMethod','nearest'};
for ct1 = 1:size(this.PoleCurves,1)
   for ct2 = 1:size(this.PoleCurves,2)
      info.Row = ct1; 
      info.Col = ct2; 
      info.type = 'x'; 
      this.installtip(this.PoleCurves(ct1,ct2),tipfcn,info)
      info.type = 'o'; 
      this.installtip(this.ZeroCurves(ct1,ct2),tipfcn,info)
   end
end
