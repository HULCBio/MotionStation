function display(mpcsimopt)
%DISPLAY Display an MPCSIMOPT object

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2003/12/04 01:33:07 $   

disp(sprintf('\n%s is an MPCSIMOPT object with fields\n',inputname(1)));
disp(struct(mpcsimopt))
