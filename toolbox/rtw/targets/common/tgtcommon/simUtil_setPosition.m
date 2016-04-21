function setpos(block, xy, increment, iterator )
%SETPOS Set the position of a Simulink Block. 
%
% Parameters
%   xy      -    [ x y]                 % Absolute positioning
%                { block [ x y ] }      % Relative positioning
%
% increment -    [xinc yinc]            % Optional incremental argument
% iterator  -    an integer             % Optional argument
%
% Example :
%
% Create a column of blocks 50 pixels to the right of
% a base block.
%
%  set_pos(base_block,[100 50]);
%  for i=1:10
%     set_pos(block{i},{base_block [50 0]},[0 50],i)
%  end

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $
%   $Date: 2004/04/19 01:22:29 $

    pos = get_param(block,'Position');

    if nargin == 2
        %----------------------------------
        % Use the simple form
        if iscell(xy)
            posrel = get_param(xy{1},'Position');
            xy = xy{2};
            xy = xy + posrel(1:2);
        end
        pos = [0 0 pos(3)-pos(1) pos(4)-pos(2)] + [ xy(1) xy(2) xy(1) xy(2) ];
        set_param(block,'Position',pos);
    elseif nargin == 4
        %%-----------------------------
        %% Use the increment and iterator
        %% form
        if iscell(xy)
            posrel = get_param(xy{1},'Position');
            xy = xy{2};
            xy = xy + posrel(1:2);
        end
        xy = xy + increment * iterator;
        pos = [0 0 pos(3)-pos(1) pos(4)-pos(2)] + [ xy(1) xy(2) xy(1) xy(2) ];
        set_param(block,'Position',pos);
    else
        error('Wrong number of arguments');
    end
