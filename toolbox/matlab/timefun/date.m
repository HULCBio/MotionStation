function t = date
%DATE   Current date as date string.
%   S = DATE returns a string containing the date in dd-mmm-yyyy format.
%
%   See also NOW, CLOCK, DATENUM.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/15 03:20:04 $

c = clock;
mths = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';
        'Aug';'Sep';'Oct';'Nov';'Dec'];
d = sprintf('%.0f',c(3)+100);
t = [d(2:3) '-' mths(c(2),:) '-' sprintf('%.0f',c(1))];
