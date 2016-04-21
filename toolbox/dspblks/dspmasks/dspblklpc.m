function acf = dspblklpc(action, order)
% DSPBLKLPC Signal Processing Blockset Autocorrelation LPC block helper function

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.18.4.2 $ $Date: 2004/04/12 23:06:49 $

if nargin==0, action = 'dynamic'; end

% Propagate Frame-based and channel information to subsytem:
blk = gcb;

inherit_order =  strcmp(get_param(blk, 'inherit_prediction_order'),'on');

switch action

case 'init'

    acf_blk = [blk,'/Autocorrelation'];

    if inherit_order,
        acf = 0;
    else
        acf = order;
    end

    %
    % Side effects: update the underlying Autocorrelation (ACF) block
    %
    if inherit_order,
        remove_block(blk);

        w = warning;
        warning('off');

        dspsafe_set_param(acf_blk, 'AllPositiveLags', 'on');
        warning(w);

    else
        insert_block(blk);

        % ACF positive lags
        w = warning;
        warning('off');

        dspsafe_set_param(acf_blk, 'AllPositiveLags', 'off');
        warning(w);
    end

     %
     % Side effects: update the underlying Levinson-Durbin block
     %
     lpcCoeffOutFcn = get_param(blk,'lpcCoeffOutFcn');
	 lpcOutP        = get_param(blk,'lpcOutP');

     lvd_blk        = [blk,'/Levinson-Durbin'];
     lvd_blk_outfcn = get_param(lvd_blk,'coeffOutFcn');
	 lvdOutP        = get_param(lvd_blk,'outP');

	 AKchangeNeeded = ~strcmp(lpcCoeffOutFcn, lvd_blk_outfcn);
	 PchangeNeeded  = ~strcmp(lpcOutP,lvdOutP);

	 % FIRST - add or remove P port if necessary
     if PchangeNeeded,
		 % Just add or remove P output port
		 if (strcmp(lvd_blk_outfcn, 'K') | strcmp(lvd_blk_outfcn, 'A'))
			 % One coeff output port, one P port to add or delete
			 if strcmp(lpcOutP,'on')
				 newPosition = [550+115   120   570+115   140];
				 addPandWires2ndPort(blk, newPosition);
			 else
				 delPandWires2ndPort(blk);
			 end
		 else
			 % Two coeff output ports, one P port to add or delete
			 if strcmp(lpcOutP,'on')
				 newPosition = [550+115   120   570+115   140];
				 addPandWires3rdPort(blk, newPosition);
			 else
				 delPandWires3rdPort(blk);
			 end
		 end
	 end

	 % SECOND - change coeff output ports if necessary
	 if AKchangeNeeded,
		 if strcmp(lpcCoeffOutFcn, 'K'),
			 if exist_block(blk, 'K'),
				 % Currently two coeff output ports - change to one (K)
				 chngBlksAKtoK(blk, lvd_blk);
			 else
				 % Currently one coeff output port (A) - change to K
				 chngBlksAtoK(blk, lvd_blk);
			 end
		 elseif strcmp(lpcCoeffOutFcn, 'A'),
			 if exist_block(blk, 'A'),
				 % Currently two coeff output ports - change to one (A)
				 chngBlksAKtoA(blk, lvd_blk);
			 else
				 % Currently one coeff output port (K) - change to A
				 chngBlksKtoA(blk, lvd_blk);
			 end
		 else
			 if exist_block(blk, 'A'),
				 % Currently one coeff output port (A) - change to A AND K
				 chngBlksAtoAK(blk, lvd_blk);
			 else
				 % Currently one coeff output port (K) - change to A AND K
				 chngBlksKtoAK(blk, lvd_blk);
			 end
	     end
	 end
case 'dynamic'
    mask_enables = get_param(blk,'maskenables');
	if inherit_order
    	    mask_enables{4} = 'off';
        else
    	    mask_enables{4} = 'on';
	end
	set_param(blk,'maskenables',mask_enables);
    acf = 0;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chngBlksAtoK(blk, lvd_blk)
    pOutExistedBefore = exist_block(blk, 'P');
	if pOutExistedBefore
        oldPosition = delPandWires2ndPort(blk);
	end
    chngBlkNameAtoK(blk);
	set_param(lvd_blk,'coeffOutFcn','K');
	if pOutExistedBefore
    	addPandWires2ndPort(blk, oldPosition);
	end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chngBlksKtoA(blk, lvd_blk)
    pOutExistedBefore = exist_block(blk, 'P');
	if pOutExistedBefore
        oldPosition = delPandWires2ndPort(blk);
	end
    chngBlkNameKtoA(blk);
	set_param(lvd_blk,'coeffOutFcn','A');
	if pOutExistedBefore
		addPandWires2ndPort(blk, oldPosition);
	end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chngBlksAtoAK(blk, lvd_blk)
    pOutExistedBefore = exist_block(blk, 'P');
	if pOutExistedBefore
        oldPosition = delPandWires2ndPort(blk);
	end
	set_param(lvd_blk,'coeffOutFcn','A and K');
	addKandWires2ndPort(blk);
	if pOutExistedBefore
    	addPandWires3rdPort(blk, oldPosition);
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chngBlksAKtoA(blk, lvd_blk)
    pOutExistedBefore = exist_block(blk, 'P');
	if pOutExistedBefore
    	oldPosition = delPandWires3rdPort(blk);
	end
	delKandWires2ndPort(blk);
	set_param(lvd_blk,'coeffOutFcn','A');
	if pOutExistedBefore
    	addPandWires2ndPort(blk, oldPosition);
	end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chngBlksKtoAK(blk, lvd_blk)
    chngBlkNameKtoA(blk);
    pOutExistedBefore = exist_block(blk, 'P');
	if pOutExistedBefore
    	oldPosition = delPandWires2ndPort(blk);
	end
	set_param(lvd_blk,'coeffOutFcn','A and K');
	addKandWires2ndPort(blk);
	if pOutExistedBefore
    	addPandWires3rdPort(blk, oldPosition);
	end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chngBlksAKtoK(blk, lvd_blk)
    pOutExistedBefore = exist_block(blk, 'P');
	if pOutExistedBefore
    	oldPosition = delPandWires3rdPort(blk);
	end
	delKandWires2ndPort(blk);
	chngBlkNameAtoK(blk);
	set_param(lvd_blk,'coeffOutFcn','K');
	if pOutExistedBefore
    	addPandWires2ndPort(blk, oldPosition);
	end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function delKandWires2ndPort(blk)
    kBlk = [blk,'/K'];
    delete_line(blk,'Levinson-Durbin/2','K/1');
	delete_block(kBlk);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addKandWires2ndPort(blk)
    kBlk = [blk,'/K'];
	kPos = [550+115   95   570+115   115];
    add_block('built-in/Outport',kBlk,'position',kPos);
    add_line(blk,'Levinson-Durbin/2','K/1');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function oldPosition = delPandWires2ndPort(blk)
    pBlk = [blk,'/P'];
	oldPosition = get_param(pBlk,'position');
    delete_line(blk,'Levinson-Durbin/2','P/1');
	delete_block(pBlk);
    lvd_blk = [blk,'/Levinson-Durbin'];
	set_param(lvd_blk,'outP','off');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function oldPosition = delPandWires3rdPort(blk)
    pBlk = [blk,'/P'];
	oldPosition = get_param(pBlk,'position');
    delete_line(blk,'Levinson-Durbin/3','P/1');
	delete_block(pBlk);
    lvd_blk = [blk,'/Levinson-Durbin'];
	set_param(lvd_blk,'outP','off');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addPandWires2ndPort(blk, newPosition)
    lvd_blk = [blk,'/Levinson-Durbin'];
	set_param(lvd_blk,'outP','on');
    pBlk = [blk,'/P'];
    add_block('built-in/Outport',pBlk,'position',newPosition);
    add_line(blk,'Levinson-Durbin/2','P/1');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addPandWires3rdPort(blk, newPosition)
    lvd_blk = [blk,'/Levinson-Durbin'];
	set_param(lvd_blk,'outP','on');
    pBlk = [blk,'/P'];
    add_block('built-in/Outport',pBlk,'position',newPosition);
    add_line(blk,'Levinson-Durbin/3','P/1');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chngBlkNameAtoK(blk)
    aBlk = [blk,'/A'];
	set_param(aBlk,'Name','K');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chngBlkNameKtoA(blk)
    kBlk = [blk,'/K'];
	set_param(kBlk,'Name','A');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function present = exist_block(sys, name)
    present = ~isempty(find_system(sys,'searchdepth',1,...
        'followlinks','on','lookundermasks','on','name',name));


% [EOF] dspblklpc.m
