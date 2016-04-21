function [z,k] = iozero(sys)
%IOZERO   Get zeros and gains for each I/O transfer.
%
%  Single model, low-level utility.

%  Copyright 1986-2002 The MathWorks, Inc.
%  $Revision: 1.2.4.1 $ $Date: 2002/11/11 22:21:59 $
[a,b,c,d,e] = dssdata(sys);
[z,k] = getzeros(a,b,c,d,e,[],'io');

