function dspfixptcopycallback
%DSPFIXPTCOPYCALLBACK Set Copy Callback of Fixed Point capable 
%blocks in Signal Processing Blockset.             

%This is the callback function that is used to set the foreground
%color of a fixed point capable block to black when it is copied
%into a model
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $ $Date: 2004/04/12 23:07:49 $
 
set_param(gcbh,'ForegroundColor','black');

% mfilename should be "dspfixptcopycallback"
current_filename = mfilename;

% Get initial state of CopyFcn
cpyfcn_cb = get_param(gcbh,'CopyFcn');

% Find 'dspfixptcopycallback' in CopyFcn
% and remove the string if it exists
start_indx = findstr(cpyfcn_cb, current_filename);
if ~isempty(start_indx)
    cpyfcn_cb(start_indx:1+length(current_filename)-1) = '';
    set_param(gcbh,'CopyFcn',cpyfcn_cb); 
end
   
% [EOF] dspfixptcopycallback
