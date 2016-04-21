function y = syslocked(sys)
% SYSLOCKED Determine whether a system is locked.
%  This function is error-protected against calls on
%  subsystems or blocks, which do not have a lock parameter.


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.8 $ $Date: 2002/04/14 20:51:40 $

y = ~isempty(sys);
if y,
   y = strcmpi(get_param(bdroot(sys),'lock'),'on');
end

% [EOF] syslocked.m
