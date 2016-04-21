function y = wconv1(x,f,shape)
%WCONV1 1-D Convolution.
%   Y = WCONV1(X,F) performs the 1-D convolution of the 
%   vectors X and F.
%   Y = WCONV1(...,SHAPE) returns a subsection of the
%   convolution with size specified by SHAPE (See CONV2).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-May-2003.
%   Last Revision: 19-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:42:31 $

if nargin<3
    shape = 'full';
end
y = conv2(x(:)',f(:)',shape); 
if size(x,1)>1
    y = y';
end
