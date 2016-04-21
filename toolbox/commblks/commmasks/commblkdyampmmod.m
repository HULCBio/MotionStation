function varargout= commblkdyampmmod(block,action,varargin)
% COMMBLKDYAMPMMOD Communications Blockset baseband AM & PM modulator block helper function.
%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/03/24 02:00:25 $

current_blk   = gcbh;
fullblk       = getfullname(current_blk);
enable_mpsk_blk = [fullblk '/' block];

intype     = strcmp(get_param(current_blk,'InType'),'Integer');
intypeStr  = get_param(enable_mpsk_blk, 'InType');  

if intype,
    if ~strcmp(intypeStr,'Integer')
        set_param(enable_mpsk_blk, 'InType', 'Integer');  
    end
else 
    if ~strcmp(intypeStr,'Bit')
        set_param(enable_mpsk_blk, 'InType', 'Bit');  
    end
end

present_blk = get_param(gcb,'Name');
present_blk(abs(present_blk)==10) = ' ';

if (~strcmp(block,'OQPSK Modulator Baseband'))
    maptypeStr = get_param(enable_mpsk_blk, 'Enc');
    map        = strcmp(get_param(current_blk,'Enc'),'Binary');

    if map
        if ~strcmp(maptypeStr,'Binary')
            set_param(enable_mpsk_blk, 'Enc', 'Binary');  
        end
    else
        if ~strcmp(maptypeStr,'Gray')
            set_param(enable_mpsk_blk, 'Enc', 'Gray');  
        end
    end    
end

if ((strcmp(block,'M-PAM Modulator Baseband')) | (strcmp(block,'Rectangular QAM Modulator Baseband')))
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
% [EOF] commblkdyampammod.m