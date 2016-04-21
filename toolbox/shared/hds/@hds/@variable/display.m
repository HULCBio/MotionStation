function display(this)
% Display method for @variable class

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:29:40 $
for ct=1:length(this)
   disp(sprintf('Data set variable %s',this(ct).Name))
end