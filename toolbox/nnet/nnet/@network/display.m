function display(net)
%DISPLAY Display the name and properties of a neural network variable.
%
%  Syntax
%
%    display(net)
%
%  Description
%
%    DISPLAY(NET) displays a network variable's name and properties.
%
%  Examples
%
%    Here a perceptron variable is defined and displayed.
%
%      net = newp([-1 1; 0 2],3);
%      display(net)
%
%    DISPLAY is automatically called as follows:
%
%      net
%
%  See also DISP, SIM, INIT, TRAIN, ADAPT

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

isLoose = strcmp(get(0,'FormatSpacing'),'loose');

if (isLoose), fprintf('\n'), end

fprintf('%s =\n',inputname(1));

disp(net)
