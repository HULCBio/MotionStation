function [num,den] = ndorder(num,den)
%NDORDER  Eliminates common leading zeros created by operations 
%         like  s * 1/s

%      Copyright 1986-2002 The MathWorks, Inc. 
%      $Revision: 1.1.6.1 $  $Date: 2002/11/11 22:22:15 $

i = find(num~=0 | den~=0); 
num(1:i(1)-1) = [];
den(1:i(1)-1) = [];