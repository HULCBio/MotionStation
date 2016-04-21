function boo = isreal(sys)
%ISREAL Check for realness of state-space matrices

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.3.4.2 $  $Date: 2004/04/10 23:13:28 $

if ~all(cellfun('isreal',sys.a(:))) | ...
        ~all(cellfun('isreal',sys.b(:))) | ...
        ~all(cellfun('isreal',sys.c(:))) | ...
        ~all(cellfun('isreal',sys.e(:))) | ...
        ~isreal(sys.d),
    boo = false;
else
    boo = true;
end
