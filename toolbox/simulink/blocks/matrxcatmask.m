function xy = matrxcatmask(action, varargin)
%MATRXCATMASK Matrix Concatenation block helper function.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.5 $

% Cache current block
curBlk = gcb;
action = 'icon';

if strcmp(action,'icon'),
    concatMethod = get_param(curBlk,'catMethod');

    % Build icon text
    if (strcmp(concatMethod,'Horizontal') == 1),
        % Display HORIZONTAL concatenation icon representation
        xy.x        = 1.9 * [  .2  .25 .25 .2  .2 NaN ...
		               .3  .5  .5  .3  .3 NaN ...
		               .55 .6  .6  .55 .55 ] - .25;
        xy.y        = 1.6 * [  .3  .3  .7  .7 .3 NaN ...
		               .3  .3  .7  .7 .3 NaN ...
		               .3  .3  .7  .7 .3   ] - .42;
        xy.label    = 'Horiz Cat';
    else
        % Display VERTICAL concatenation icon representation
        xy.x        = 2.0 * [ .2 .6 .6  .2  .2 NaN ...
		              .2 .6 .6  .2  .2 ] - .3;
        xy.y        = 2.0 * [ .15 .15 .35 .35 .15 NaN ...
		              .4  .4  .48 .48 .4 ] - .25;
        xy.label    = 'Vert Cat';
    end
end

% [EOF] matrxcatmask.m
