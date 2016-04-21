function str = dspblklogdata(action)
% DSPBLKLPC Signal Processing Blockset Autocorrelation LPC block helper function

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/12 23:05:37 $

if nargin==0, action = 'dynamic'; end

% Propagate Frame-based and channel information to subsytem:
blk = gcb;
isRowVect =  strcmpi(get_param(blk,'outType'),'Row vector');
isColVect =  strcmpi(get_param(blk,'outType'),'Column vector');
dataType = get_param(blk,'dType');
%isMatrix  =  strcmpi(get_param(blk,'outType'),'Matrix');

switch action
 
case 'init'

    const_blk = [blk,'/Constant'];
    Assign_blk = [blk,'/Assignment'];
    w = warning;
    warning('off');
    dspsafe_set_param(const_blk, 'OutDataTypeMode', dataType);
    
    if isRowVect 
        dspsafe_set_param(const_blk, 'Value', 'zeros(1,numCol)');
        dspsafe_set_param(Assign_blk, 'InputType', 'Vector');
        str = 'cIdx';
    elseif isColVect
        dspsafe_set_param(const_blk, 'Value', 'zeros(numRow,1)');
        dspsafe_set_param(Assign_blk, 'InputType', 'Vector');
        str = 'rIdx';
    else
        dspsafe_set_param(const_blk, 'Value', 'zeros(numRow,numCol)');
        dspsafe_set_param(Assign_blk, 'InputType', 'Matrix');
        str = 'cIdx';
    end
    warning(w);
case 'dynamic'
    mask_enables = get_param(blk,'maskenables');
	if isRowVect
    	    mask_enables{2} = 'off'; mask_enables{3} = 'on';
    elseif isColVect
    	    mask_enables{2} = 'on'; mask_enables{3} = 'off';
    else
            mask_enables{2} = 'on'; mask_enables{3} = 'on';    
	end
	set_param(blk,'maskenables',mask_enables);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function insert_block(blk)
%If the blocks don't exist, then insert them

fullblk  = getfullname(blk);
dTypeConst_blk  = [fullblk '/Constant'];
matrixConCat_blk  = [fullblk '/Matrix_Concatenation'];

if ((~exist_block(blk,'Constant')) & (~exist_block(blk,'Matrix_Concatenation')))
   delete_line(fullblk,'Reshape/1','Autocorrelation/1');
   str='simulink/Sources/Constant';
   add_block(str,dTypeConst_blk );
   set_param(dTypeConst_blk,'Position',[235   120   340   150]);
   set_param(dTypeConst_blk,'Value','zeros(1,order)''');
   set_param(dTypeConst_blk,'OutputDataTypeScalingMode','Inherit via back propagation');  
   add_block('simulink/Math Operations/Matrix Concatenation',matrixConCat_blk);
   %add_block('simulink3/Signals & Systems/Matrix Concatenation',matrixConCat_blk);
   set_param(matrixConCat_blk,'Position',[380    44   435    86]);
   set_param(matrixConCat_blk,'catMethod','Vertical');
   add_line(fullblk,'Reshape/1','Matrix_Concatenation/1');
   add_line(fullblk,'Constant/1','Matrix_Concatenation/2');
   add_line(fullblk,'Matrix_Concatenation/1','Autocorrelation/1');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function remove_block(blk)
%If the blocks exist, then remove them

fullblk  = getfullname(blk);
dTypeConst_blk  = [fullblk '/Constant'];
matrixConCat_blk  = [fullblk '/Matrix_Concatenation'];

if (exist_block(blk,'Constant') & exist_block(blk,'Matrix_Concatenation'))
   delete_line(fullblk,'Reshape/1','Matrix_Concatenation/1');
   delete_line(fullblk,'Constant/1','Matrix_Concatenation/2');
   delete_line(fullblk,'Matrix_Concatenation/1','Autocorrelation/1');
   delete_block(dTypeConst_blk);
   delete_block(matrixConCat_blk);
   add_line(fullblk,'Reshape/1','Autocorrelation/1');
end

% [EOF] dspblklpc.m
