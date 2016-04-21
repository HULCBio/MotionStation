function [handle, pos] = ...
    uiarray(bigFramePos, m, n, border, spacing, style, callback, string)
% UIARRAY creates an array (or matrix)  of UI buttons.
%   UIARRAY(POS, M, N, BORDER, SPACING, STYLE, CALLBACK, STRING) creates
%   an M*N UI controls positioned as M by N array within POS. BORDER
%   specifies the spacing between UI's and the enclosing big frame;
%   SPACING specifies the spacing between UI's. STYLE, CALLBACK and
%   STRING are string matrices (with row dimension M*N) specifying the
%   styles, callbacks and strings, respectively, for the M*N UI controls.
%   If row dimension of these arguments are less then M*N, the last row
%   will be repeated as many times as necessary.
%
%   This function is used primarily for creating UI controls of demos
%   of the toolbox.
%
%   For example:
%
%   figure('name', 'uiarray', 'numbertitle', 'off');
%   figPos = get(gcf, 'pos');
%   bigFramePos = [0 0 figPos(3) figPos(4)];
%   m = 4; n = 3;
%   border = 20; spacing = 10;
%   style = str2mat('push', 'slider', 'radio', 'popup', 'check');
%   callback = 'disp([''This is a '' get(gco, ''style'')])';
%   string = str2mat('one', 'two', 'three', 'four-1|four-2|four-3', 'five');
%   uiarray(bigFramePos, m, n, border, spacing, style, callback, string);

%   J.-S. Roger Jang, 6-28-93.
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/14 22:16:54 $

% set defaults
if nargin <= 3, border = bigFramePos(3)/10; end
if nargin <= 4, spacing = border; end
if nargin <= 5, style = 'frame'; end
if nargin <= 6, callback = ' '; end
if nargin <= 7, string = ' '; end

% correct wrong arguments
if isempty(style), style = ' ', end
if isempty(callback), callback = ' ', end
if isempty(string), string = ' ', end

framecolor = 192/255*[1 1 1];
smallFrameW = (bigFramePos(3) - 2*border - (n-1)*spacing)/n;
smallFrameH = (bigFramePos(4) - 2*border - (m-1)*spacing)/m;

% fill style if it's not long enough
if size(style, 1) < m*n,
    len = size(style, 1);
    tmp = style(len, :);
    tmp = tmp(ones(m*n-len, 1), :);
    style = [style; tmp];
end
% fill callback if it's not long enough
if size(callback, 1) < m*n,
    len = size(callback, 1);
    tmp = callback(len, :);
    tmp = tmp(ones(m*n-len, 1), :);
    callback = [callback; tmp];
end
% fill string if it's not long enough
if size(string, 1) < m*n,
    len = size(string, 1);
    tmp = string(len, :);
    tmp = tmp(ones(m*n-len, 1), :);
    string = [string; tmp];
end

handle = zeros(m*n,1);
pos = zeros(m*n, 4);

for i = 1:m,
    for j = 1:n,
        count = (i-1)*n+j;
        x = bigFramePos(1)+(j-1)*(smallFrameW+spacing)+border; 
        y = bigFramePos(2)+(m-i)*(smallFrameH+spacing)+border;
        pos(count, :) = [x y smallFrameW smallFrameH];
        handle(count) = uicontrol( ...
                'Style',deblank(style(count,:)), ...
                'String', [' ' deblank(string(count,:))], ...
                'Callback',deblank(callback(count,:)), ...
                'Units','pixel', ...
                'Position',pos(count,:), ...
                'BackgroundColor',framecolor);
    end
end
