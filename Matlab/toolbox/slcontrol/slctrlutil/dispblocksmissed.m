function dispblocksmissed(J)
%% DISPBLOCKSMISSED Display the blocks that do not contribute to a
%% linearization.
%%
%% DISPBLOCKSMISSED(J) Utility function to display the blocks that do not 
%% contribute to the linearization.  The input arguement is the return
%% arguement from the linearize method:
%%
%%                      [sys,J] = linearize(op,io);
%% 

%%  Author(s): John Glass
%%  Copyright 1986-2003 The MathWorks, Inc.

in = find(J.Mi.ForwardMark == 0);

disp(sprintf('\r Forward Path \r'))

for ct = 1:length(in)
    disp(sprintf('%s/%s\r',...
          regexprep(get_param(J.Mi.BlockHandles(in(ct)),'Parent'),'\n',' '),...
          regexprep(get_param(J.Mi.BlockHandles(in(ct)),'Name'),'\n',' ')))
end

disp(sprintf('\r Backward Path \r'))
out = find(J.Mi.BackwardMark == 0);
for ct = 1:length(out)
    disp(sprintf('%s/%s\r',...
        regexprep(get_param(J.Mi.BlockHandles(out(ct)),'Parent'),'\n',' '),...
        regexprep(get_param(J.Mi.BlockHandles(out(ct)),'Name'),'\n',' ')));
end

disp(sprintf('\r Total blocks missed \r'))
out = find((J.Mi.BackwardMark & J.Mi.ForwardMark) == 0);
for ct = 1:length(out)
    disp(sprintf('%s/%s\r',...
        regexprep(get_param(J.Mi.BlockHandles(out(ct)),'Parent'),'\n',' '),...
        regexprep(get_param(J.Mi.BlockHandles(out(ct)),'Name'),'\n',' ')));
end
