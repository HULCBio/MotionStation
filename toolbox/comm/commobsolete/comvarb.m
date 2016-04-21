%COMVARB Script file for COMMGUI.
%
%WARNING: This is an obsolete function and may be removed in the future.

%  Wes Wang, original design
%  Jun Wu, last update, Mar-07, 1997
%  Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.16 $

handle_com_tmp = get(gcf, 'UserData');
value_com_tmp1 = get(handle_com_tmp(2), 'string');
%eval(['set(', num2str(handle_com_tmp(2), 20),...
%      ',''UserData'',' value_com_tmp1, ');']);
if isempty(value_com_tmp1)
    error('The Signal to noise ratio variable cannot be empty.')
end;
value_com_tmp2 = get(handle_com_tmp(3), 'string');
if isempty(value_com_tmp2)
    error('The Bit error ratio variable cannot be empty.')
end;

if handle_com_tmp(7)
    %export
    value_com_tmp = get(handle_com_tmp(6), 'UserData');
    eval([value_com_tmp1 '= value_com_tmp(1,:);'])
    eval([value_com_tmp2 '= value_com_tmp(2,:);'])
else
    if ~exist(value_com_tmp1)
        error(['Variable ', value_com_tmp1, ' does not exist.']);
    end;

    if ~exist(value_com_tmp2)
        error(['Variable ', value_com_tmp2, ' does not exist.']);
    end;

    %inport
    eval(['length_com_tmp = length(', value_com_tmp1,...
          ') - length(', value_com_tmp2, ');']);
    if length_com_tmp ~= 0
        error(['Variable ', value_com_tmp1, ' and ',...
               value_com_tmp2, 'Must have the same length.']);
    end;
    eval(['length_com_tmp = length(', value_com_tmp1, ');'])

    eval(['value_com_tmp = size(', value_com_tmp1, ', 1);']);    
    if value_com_tmp <= 0
        error('Cannot assign an empty matrix.');
    elseif value_com_tmp > 1
        eval([value_com_tmp1, '=', value_com_tmp1, '(1,:);']);
        disp('Warning: COMMGUI has input for only the first row.');
    end;

    eval(['value_com_tmp = size(', value_com_tmp2, ', 1);']);    
    if value_com_tmp <= 0
        error('Cannot assign an empty matrix.');
    elseif value_com_tmp > 1
        eval([value_com_tmp2, '=', value_com_tmp2, '(1,:);']);
        disp('Warning: COMMGUI has input for only the first row.');
    end;

    value_com_tmp = zeros(1,length_com_tmp);

    eval(['value_com_tmp(1,:) = ', value_com_tmp1, ';'])
    eval(['value_com_tmp(2,:) = ', value_com_tmp2, ';'])
    length_com_tmp = get(handle_com_tmp(6), 'UserData');
    set(length_com_tmp, 'UserData', value_com_tmp);
     
    %set(length_com_tmp, 'UserData', value_com_tmp,...
     %   'String', ['snr=',mat2str(value_com_tmp(1, :), 4),...
      %  '; bit_err_ratio=',mat2str(value_com_tmp(2, :), 4)],...
       % 'Visible', 'on'...
        %)
    clear length_com_tmp
end;
clear handle_com_tmp
clear value_com_tmp1
clear value_com_tmp2
clear value_com_tmp
drawnow;

