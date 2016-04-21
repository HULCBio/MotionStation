function sv = checkerforinputnames(nn,usersSV)
% Private. If 'inputnames' is set, also set 'MangledInputNames' property.

%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/11/30 23:08:13 $

sv = usersSV;
if ~isempty(usersSV)
    for i=1:length(usersSV)
        m_inputnames{i} = p_manglename(nn,usersSV{i},'off');
    end
    set(nn,'MangledInputnames',m_inputnames);
end

% [EOF] checkerforinputnames.m