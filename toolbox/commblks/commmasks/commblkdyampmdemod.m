function varargout= commblkdyampmdemod(block,action,varargin)
% COMMBLKDYAMPMDEMOD Communications Blockset AM & PM demodulator block helper function.
%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/03/24 02:00:22 $

current_blk     = gcbh;
fullblk = getfullname(current_blk);
enable_mpsk_blk = [fullblk '/' block];

intype     = strcmp(get_param(current_blk,'OutType'),'Integer');
intypeStr   = get_param(enable_mpsk_blk, 'OutType');

if intype,
    if ~strcmp(intypeStr,'Integer')
        set_param(enable_mpsk_blk, 'OutType', 'Integer');  
    end
else 
    if ~strcmp(intypeStr,'Bit')
        set_param(enable_mpsk_blk, 'OutType', 'Bit');  
    end
end

if (~strcmp(block,'OQPSK Demodulator Baseband'))
    maptypeStr = get_param(enable_mpsk_blk, 'Dec');
    map        = strcmp(get_param(current_blk,'Dec'),'Binary');
    
    if map
        if ~strcmp(maptypeStr,'Binary')
            set_param(enable_mpsk_blk, 'Dec', 'Binary');  
        end
    else
        if ~strcmp(maptypeStr,'Gray')
            set_param(enable_mpsk_blk, 'Dec', 'Gray');  
        end
    end     
end

present_blk = get_param(gcb,'Name');
present_blk(abs(present_blk)==10) = ' ';

if ((strcmp(block,'M-PAM Demodulator Baseband')) | (strcmp(block,'Rectangular QAM Demodulator Baseband')))
    powtype    = get_param(current_blk,'PowType');

   if strcmp(powtype,'Min. distance between symbols')
       set_param(enable_mpsk_blk, 'PowType', 'Min. distance between symbols');
   elseif strcmp(powtype,'Average Power')
       set_param(enable_mpsk_blk, 'PowType', 'Average Power');
   elseif strcmp(powtype,'Peak Power')
       set_param(enable_mpsk_blk, 'PowType', 'Peak Power');
   else
       error('Unrecognized Normalization method');
   end
end
% [EOF] commblkdyampmdemod.m