function x= vitplot2(input);
%WARNING: This is an obsolete function and may be removed in the future.

% VITPLOT2
%    X= VITPLOT2(INPUT);

%   Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.11 $

n_msg = input(1);
starter = input(2);
dec = input(3);
plot_flag(1) = input(4);
M = input(5);
n_std_sta = 2^M;

plot_y = get(plot_flag(1),'UserData');
plot_r = plot_y(2);
plot_y = plot_y(1);
flipped = zeros(1, n_std_sta);
for i = 1 : n_std_sta 
    flipped(i) =  bi2de(fliplr(de2bi(i-1, M)));
end;
 
plot_curv_x = [get(plot_r, 'XData'), n_msg-1+.1, n_msg, NaN];
plot_curv_y = [get(plot_r, 'YData'), flipped(starter+1), flipped(dec+1), NaN];
set(plot_r, 'XData', plot_curv_x, 'YData', plot_curv_y,'LineWidth',2);
%drawnow

