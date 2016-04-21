function s = commblktimrec(resetMode, varargin)
%COMMBLKTIMREC Mask helper function for the timing recovery blocks.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/04/10 05:15:31 $

% Sets up the mask labels in the icon for the blocks
s = [];
if (resetMode == 3)
    s.i1 = 1; s.i1s = 'In';
    s.i2=  2; s.i2s = 'Rst';
else
    s.i1 = 1; s.i1s = '';
    s.i2 = 1; s.i2s = '';
end
s.o1 = 1; s.o1s = 'Sym';
s.o2 = 2; s.o2s = 'Ph';

% For MSK-type recovery block
if (nargin==2)
    if (varargin{1} == 1)
        s.type = 'MSK';
    else
        s.type = 'GMSK';
    end
end

% [EOF]
