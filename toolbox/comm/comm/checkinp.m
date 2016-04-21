function [y1,y2,y3,y4,y5,y6,y7,y8,y9,y10] = checkinp(x1,...
    x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17,x18,x19,x20)
%CHECKINP Checks input and fills in the default.
%       [y1, .., yN] = checkinp(x1, ..., xN, z1, ..., zN) checks if xi is
%       empty. If xi is empty, the function fills yi with the given default
%       value zi. Otherwise, the function assigns yi=xi. The number of
%       variable N is limited to less than 10.

%       Wes Wang 5/26/94, 9/30/95 
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.9 $

if (nargin ~= 2* nargout)
    error('The number of input and output variables in CHECKINP does not match.');
end

for i = 1: nargout
    eval(['test_flag = x', num2str(i),';']);
    if isempty(test_flag)
        eval(['y',num2str(i),'=x',num2str(nargout+i),';']);
    else
        eval(['y',num2str(i),'=x',num2str(i),';']);
    end
end

