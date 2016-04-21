echo off
%   CASE STUDIES IN SYSTEM IDENTIFICATION
%   *************************************
%
%   In this selection of case studies we illustrate typical techniques
%   and useful tricks when dealing with various system identification
%   problems.
%   
%   Case studies:
%
%   1) A glass tube manufacturing process
%   2) Energizing a transformer
%
%   0) Quit
%
 
%   L. Ljung
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2001/04/06 14:21:45 $

while (1)
        help cs
        k = input('Select a case study number: ');
	if isempty(k),k=3;end
        if k == 0, break, end
        if k==1, cs1, end
        if k==2, cs2, end
end
