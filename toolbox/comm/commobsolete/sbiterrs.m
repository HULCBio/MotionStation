function sbiterrs(h_fig, len_rate, len_u);
%SBITERRS reset the data
%    SBITERRS(H_FIG, LEN_RATE, LEN_U)
%
%WARNING: This is an obsolete function and may be removed in the future.

%   Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.13 $

handles = get(h_fig, 'UserData');

if len_rate < 2
    h_sym_bit = handles(2 : len_u*2);
else
    h_sym_bit = handles(2 : len_u*4-1);
end;
for i = 1 : length(h_sym_bit)
    set(h_sym_bit(i), 'UserData', 0, 'String', '0');
end;
