function dspblkoffset(numInput)
% DSPBLKLPC Signal Processing Blockset Offset block helper function

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/12/06 15:25:14 $
blk = gcbh;
action = 'init';
if nargin==0, action = 'dynamic'; end

%blk = gcb;
switch action 
 
case 'init'
    try
        if (~isnumeric(numInput)||~isscalar(numInput) ||~isreal(numInput) || numInput<1)
            return;
        end
    catch
        return;
    end  
    %% Icon: port labels
    w = warning;
    warning('off');
    port_labels = '';
    if ((numInput > 0)&&(numInput <inf))
        for i=1:numInput,
            DatPortChar = ['In' num2str(i)];
            Datlabel = ['''' DatPortChar ''''];
            Data_label = ['port_label(''input'',' num2str(2*i-1), ', ' Datlabel '); '];
            
            OutPortChar = ['Out' num2str(i)];
            Outlabel = ['''' OutPortChar ''''];
            Out_label = ['port_label(''output'',' num2str(i), ', ' Outlabel '); '];

            WidPortChar = ['O' num2str(i)];
            Widlabel = ['''' WidPortChar ''''];
            Width_label = ['port_label(''input'',' num2str(2*i), ', ' Widlabel '); '];

            port_labels = [port_labels Data_label Out_label Width_label ];
        end
    end
    %Out_port_labels = ['port_label(''output'', 1, ''' 'Out' ''');'];
    disp_str = ['disp(''Offset'');'];
    str = [port_labels disp_str];
    set_param(blk,'maskdisplay',str);
warning(w);
case 'dynamic'
    mask_visibles     = get_param(blk, 'MaskVisibilities');
    old_mask_visibles = mask_visibles;
    mask_enables      = get_param(blk, 'MaskEnables');
    old_mask_enables  = mask_enables;
    puOUTWIDTHSPECstr = get_param(blk,'outWidthSpec');
    % Item-1: Output vector length same as input data vector length
    if strcmp(lower(puOUTWIDTHSPECstr),'same as input')
        temp = 'off';% no need to have edit box
    else
        temp = 'on';
    end    
    mask_enables(4) = {temp}; mask_visibles(4) = {temp}; 
    if (~isequal(mask_visibles, old_mask_visibles))
      set_param(blk, 'MaskVisibilities', mask_visibles);
    end
    if (~isequal(mask_enables, old_mask_enables))
      set_param(blk, 'MaskEnables', mask_enables);
    end
end    


% [EOF] dspblkoffset.m
