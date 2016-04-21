function display(S)
% Display information

% Copyright 2004 The MathWorks, Inc.

disp('SBS25x0 Shared Memory Parition');
basec = [];
for inx = 1:length(S),
    basec = horzcat(basec,S(inx).smpartition);
end
display(basec)
