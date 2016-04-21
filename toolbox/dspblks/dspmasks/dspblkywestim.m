function  varargout = dspblkywestim(varargin)
% DSPBLKYWESTIM Signal Processing Blockset Yule-Walker AR Estimator block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.13.4.2 $ $Date: 2004/04/12 23:07:47 $

if nargin==0, 
  action = 'dynamic'; 
else
  action = varargin{1};
end
blk = gcb;
inheritOrder = strcmp(get_param(blk,'inheritOrder'),'on');

switch action
case 'computeVars'
    
    % Calculate esimation order for ACF block setup...
	
    % If we're inheriting, just set them to "legal" but arbitrary values.
    if inheritOrder,
        ord = 1;
    else
        ord = varargin{2};
        
        % NOTE: 'ord' parameter can be empty in early initialization passes
        %       when the block is inside a masked subsystem.
        if isempty(ord), 
            ord=1;
        end
    end
	
    varargout = {ord};
    
case 'init'
     %
     % Side effects: update the underlying Autocorrelation block
     %
     acf_blk  = [blk,'/Autocorrelation'];
     acf_lags = get_param(acf_blk, 'AllPositiveLags');
     
     if inheritOrder,
         if ~strcmp(acf_lags, 'on'),
             set_param(acf_blk, 'AllPositiveLags', 'on');
         end
	 elseif ~strcmp(acf_lags, 'off'),
         defwarn = warning; warning('off')
         set_param(acf_blk, 'AllPositiveLags', 'off');
         warning(defwarn)
     end
	 
	 %
	 % Side effects: update the underlying Levinson-Durbin block
	 % and possibly add an output port (for both A and K output case)
	 %
	 ywArOutputFcn     = get_param(blk,'ywArOutType');
	 lvd_blk           = [blk,'/Levinson-Durbin'];
	 lvd_blk_outfcn    = get_param(lvd_blk,'coeffOutFcn');

	 if ~strcmp(ywArOutputFcn, lvd_blk_outfcn),
		 if strcmp(ywArOutputFcn, 'K'),
			 if exist_block(blk, 'K'),
				 % Currently two output ports - change to one (K)
				 chngBlksAKtoK(blk, lvd_blk);
			 else
				 % Currently one output port (A) - change to K
				 chngBlksAtoK(blk, lvd_blk);
			 end
		 elseif strcmp(ywArOutputFcn, 'A'),
			 if exist_block(blk, 'A'),
				 % Currently two output ports - change to one (A)
				 chngBlksAKtoA(blk, lvd_blk);
			 else
				 % Currently one output port (K) - change to A
				 chngBlksKtoA(blk, lvd_blk);
			 end
		 else
			 if exist_block(blk, 'A'),
				 % Currently one output port (A) - change to A AND K
				 chngBlksAtoAK(blk, lvd_blk);
			 else
				 % Currently one output port (K) - change to A AND K
				 chngBlksKtoAK(blk, lvd_blk);
			 end
	     end
	 end

case 'dynamic'
    mask_enables      = get_param(blk,'maskenables');
    mask_enables_orig = mask_enables;
    
    if inheritOrder,
        mask_enables(3) = {'off'};
    else
        mask_enables(3) = {'on'};
    end
    
    if ~isequal(mask_enables_orig, mask_enables),
        set_param(blk,'maskenables',mask_enables);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chngBlksAtoK(blk, lvd_blk)
    chngBlkNameAtoK(blk);
	set_param(lvd_blk,'coeffOutFcn','K');

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chngBlksKtoA(blk, lvd_blk)
    chngBlkNameKtoA(blk);
	set_param(lvd_blk,'coeffOutFcn','A');

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chngBlksAtoAK(blk, lvd_blk)
	oldPosition = delGandWires2ndPort(blk);
	set_param(lvd_blk,'coeffOutFcn','A and K');
	addKandWires2ndPort(blk);
	addGandWires3rdPort(blk, oldPosition);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chngBlksAKtoA(blk, lvd_blk)
	oldPosition = delGandWires3rdPort(blk);
	delKandWires2ndPort(blk);
	set_param(lvd_blk,'coeffOutFcn','A');
	addGandWires2ndPort(blk, oldPosition);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chngBlksKtoAK(blk, lvd_blk)
    chngBlkNameKtoA(blk);
	oldPosition = delGandWires2ndPort(blk);
	set_param(lvd_blk,'coeffOutFcn','A and K');
	addKandWires2ndPort(blk);
	addGandWires3rdPort(blk, oldPosition);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chngBlksAKtoK(blk, lvd_blk)
	oldPosition = delGandWires3rdPort(blk);
	delKandWires2ndPort(blk);
	chngBlkNameAtoK(blk);
	set_param(lvd_blk,'coeffOutFcn','K');
	addGandWires2ndPort(blk, oldPosition);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function delKandWires2ndPort(blk)
    kBlk = [blk,'/K'];
    delete_line(blk,'Levinson-Durbin/2','K/1');
	delete_block(kBlk);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addKandWires2ndPort(blk)
    kBlk = [blk,'/K'];
	kPos = [670   95   690   115];
    add_block('built-in/Outport',kBlk,'position',kPos);
    add_line(blk,'Levinson-Durbin/2','K/1');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function oldPosition = delGandWires2ndPort(blk)
    gBlk = [blk,'/G'];
    delete_line(blk,'Levinson-Durbin/2','G/1');
	oldPosition = get_param(gBlk,'position');
	delete_block(gBlk);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function oldPosition = delGandWires3rdPort(blk)
    gBlk = [blk,'/G'];
    delete_line(blk,'Levinson-Durbin/3','G/1');
	oldPosition = get_param(gBlk,'position');
	delete_block(gBlk);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addGandWires2ndPort(blk, newPosition)
    gBlk = [blk,'/G'];
    add_block('built-in/Outport',gBlk,'position',newPosition);
    add_line(blk,'Levinson-Durbin/2','G/1');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addGandWires3rdPort(blk, newPosition)
    gBlk = [blk,'/G'];
    add_block('built-in/Outport',gBlk,'position',newPosition);
    add_line(blk,'Levinson-Durbin/3','G/1');


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


% [EOF] dspblkywestim.m
