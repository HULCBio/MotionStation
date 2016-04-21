function boo = isreal(sys)
%ISREAL  Checks if model is real-valued.

%	Author: P. Gahinet
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.3.4.2 $  $Date: 2004/04/10 23:13:11 $

boo = false;  % always assume complex for FRD's (no way to tell)