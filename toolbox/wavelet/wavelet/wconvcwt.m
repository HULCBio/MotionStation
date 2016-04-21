function y = wconv1(x,f,shape)
%WCONV1 1-D Convolution.
%   Y = WCONV1(X,F) performs the 1-D convolution of the 
%   vectors X and F.
%   Y = WCONV1(...,SHAPE) returns a subsection of the
%   convolution with size specified by SHAPE (See CONV2).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-May-2003.
%   Last Revision: 24-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/15 22:42:33 $

if nargin<3
    nx = length(x);
    nf = length(f);
    if ( (nx<2048) && (nf<nx) )     || ...
       ( (nx<4096) && (nx>10*nf) )  || ( (nx>64*nf) )
        y = conv2(x(:)',f(:)');
    else
        y = conv(x(:)',f(:)');
    end
else
    y = conv2(x(:)',f(:)',shape);
end
if size(x,1)>1
    y = y';
end
