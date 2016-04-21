function addtip(this,tipfcn,info)
%ADDTIP  Adds line tip to each curve in each view object

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:23:00 $
this.installtip(this.Locus(1),tipfcn,info)