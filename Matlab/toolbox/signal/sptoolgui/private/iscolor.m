function bool = iscolor(c)
%ISCOLOR  True if input is a color.
%   ISCOLOR(C) is 1 if c is a valid colorspec and 0 else.
%   Valid colorspecs are: 'r','g','b','w',... (a single character).
%                         [r g b] where r,g and b are scalars in [0,1]
%                         n-by-3 matrix with elements in the range [0,1]

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

% Author: T. Krauss

if isstr(c)
    colorStr = {'y' 'm' 'c' 'r' 'g' 'b' 'w' 'k'};  % see 'help plot'
    bool = ~isempty(findcstr(colorStr,c));
else
    if any(abs(imag(c))>0.0)
        bool = 0;
    elseif min(size(c))>1
        if size(c,2)~=3
            bool = 0;
        else
            bool = max(max(c))<=1.0 & min(min(c))>=0.0;
        end
    else
        bool = max(max(c))<=1.0 & min(min(c))>=0.0;
    end
end