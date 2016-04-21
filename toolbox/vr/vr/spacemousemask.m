function spacemousemask
%SPACEMOUSEMASK Mask callback for Space Mouse driver.
%
%   Not to be called directly.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2004/03/02 03:08:04 $  $Author: batserve $

% enable mask items accoring to OutputType
% set new InitialRotation default if OutputType changed

switch(get_param(gcbh, 'OutputType'))
  case 'Speed';
    masken = {'on', 'on', 'on', 'on', 'on', 'off', 'on', 'on', 'off', 'off'};

  case 'Position';
    masken = {'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on', 'on'};
    if length(str2num(get_param(gcbh, 'InitialRotation'))) ~= 3    %#ok need str2num for vectors
      set_param(gcbh, 'InitialRotation', '[0 0 0]');
    end;

  case 'Viewpoint coordinates';
    masken = {'on', 'on', 'on', 'on', 'on', 'off', 'on', 'on', 'on', 'on'};
    if length(str2num(get_param(gcbh, 'InitialRotation'))) ~= 4    %#ok need str2num for vectors
      set_param(gcbh, 'InitialRotation', '[0 0 1 0]');
    end;

end;

set_param(gcbh, 'MaskEnables', masken);
