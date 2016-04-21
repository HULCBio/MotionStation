function [z,k] = iozero(sys)
%IOZERO   Get zeros and gains for each I/O transfer.
%
%  Single model, low-level utility.

%  Copyright 1986-2002 The MathWorks, Inc.
%  $Revision: 1.2 $ $Date: 2002/04/10 06:13:29 $
z = sys.z;
k = sys.k;