function varargout= maskpropupdate(block,param)
% MASKPROPUPDATE Mask variable propagation update function
%
%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/03/24 02:03:26 $

upper_blk = gcbh;
fullblk   = getfullname(upper_blk);
lower_blk = [fullblk '/' block];

upper_val = get_param(upper_blk,param);
lower_val = get_param(lower_blk,param);

if ~strcmp(upper_val,lower_val)
    set_param(lower_blk, param, upper_val);  
end

% [EOF] maskpropupdate.m