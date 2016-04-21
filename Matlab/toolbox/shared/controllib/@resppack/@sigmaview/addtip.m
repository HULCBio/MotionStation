function addtip(this,tipfcn,info)
%ADDTIP  Adds line tip to each curve in each view object

%  Author(s): John Glass
%  Revised  : Kamesh Subbarao 10-15-2001
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:23:23 $
this.installtip(this.Curves,tipfcn,info)
