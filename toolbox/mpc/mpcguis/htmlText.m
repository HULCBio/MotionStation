function NewText = htmlText(Text)

% Copyright 2003 The MathWorks, Inc.

% Add html editing tags to beginning and end of a text string.
% This also sets the font.

NewText = ['<html><font face="Arial" size="2">', Text, '</font>'];
