function [a,b,c,d] = fastss(sys)
%FASTSS  Fast conversion to state space.
%
%   Used in SISOTOOL and optimized for speed.
%
%   See also SISOTOOL.

%   Author: P. Gahinet 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 06:13:17 $

[a,b,c,d] = comden(sys.k,sys.z,sys.p{1});