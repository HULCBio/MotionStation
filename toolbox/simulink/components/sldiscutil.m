function varargout = sldiscutil(flag, varargin)
%DISCUTIL Utilities for Simulink Model Discretizer
%used by Simulink Model Discretizer only

% $Revision: 1.6.4.3 $ $Date: 2004/04/06 01:10:56 $
% Copyright 1990-2003 The MathWorks, Inc.

if(nargin > 1)
    tmpargin = varargin{1};
else
    tmpargin = [];
end
n = length(tmpargin);
switch lower(flag)
case 'hide_transportdelay'
    [discrules, type] = rules;
    themdl = tmpargin;
    tdblk = sprintf('%s/Discretized\nTransport Delay', themdl);
    vtdblk = sprintf('%s/Discretized\nVariable\nTransport Delay', themdl);
    if(type==1 | type ==3)
        bgcolor = get_param(tdblk, 'backgroundcolor');
        set_param(tdblk, 'foregroundcolor', bgcolor);
        bgcolor = get_param(vtdblk, 'backgroundcolor');
        set_param(vtdblk, 'foregroundcolor', bgcolor);        
    else
        set_param(tdblk, 'foregroundcolor', 'black');
        set_param(vtdblk, 'foregroundcolor', 'black');
    end
case 'save_report'
    filename = tmpargin{1};
    content = tmpargin{2};
    fid = fopen(filename, 'w');
    fprintf(fid, '%s', sprintf(content));
    fclose(fid);
case 'restore_subsystem'
    tmp = tmpargin{1};
    sys = bdroot(tmp{2});
    for k = 1:n,
        tmp = tmpargin{k};
        srcBlk = tmp{1};
        desBlk = tmp{2};
        replace_block(sys, 'handle', get_param(desBlk,'handle'), srcBlk, 'noprompt');
        set_param(desBlk, 'LinkStatus', 'none');
    end
case 'get_blocktype'
    block = tmpargin{1};
    varargout{1} = get_param(block, 'blocktype');
case 'check_writable'
    import java.lang.*;
    if(n == 1)
        file1 = tmpargin{1};    
    else
        file1 = 'mdldisc_check_writable_001';
    end
    isFileExist = exist(file1);
    tmp1 = fopen(file1,'w');
    if tmp1==-1
        varargout{1} = Integer(0);
    else
        fclose(tmp1);
        if(~isFileExist)
            delete(file1);
        end        
        varargout{1} = Integer(1);
    end
case 'check_dirty'
    import java.lang.*;
    mdl1 = tmpargin{1};    
    if(strcmpi(get_param(mdl1, 'dirty'), 'on'))
        varargout{1} = Integer(1);
    else
        varargout{1} = Integer(0);
    end
case 'eval_string'
    import java.lang.*;
    for k = 1:n,
        try
            evalin('base', [tmpargin{k} ';']);
        catch
            varargout{1} = Integer(0);
            return;
        end
    end
    varargout{1} = Integer(1);
case 'discstatespace'    
    SampleTime = tmpargin{1};
    method     = tmpargin{2};
    cf         = tmpargin{3};    
    A          = tmpargin{4};
    B          = tmpargin{5};
    C          = tmpargin{6};
    D          = tmpargin{7};
    ic         = tmpargin{8};
    
    sys = ss(A,B,C,D);
    if strcmp(method,'prewarp')
        WcRad = cf*2*pi;
        [sysd, G] = c2d(sys,SampleTime,method,WcRad);
    else
        [sysd, G] = c2d(sys,SampleTime,method);
    end
    Ad = get(sysd,'A');
    Bd = get(sysd,'B');
    Cd = get(sysd,'C');
    Dd = get(sysd,'D');
    [ra,ca] = size(A);
    [rb,cb] = size(B);
    iuc = zeros(cb,1);
    if length(ic) == 1
      icc = ic * ones(ca,1);
    else
      icc = ic;
    end
    xarg = [icc;iuc];
    [rx,cx] = size(xarg);
    if length(G) == 1
      G = G*ones(1,rx);
    end
    icd = G*xarg;
    
    varargout{1} = Ad;
    varargout{2} = Bd;
    varargout{3} = Cd;
    varargout{4} = Dd;
    varargout{5} = icd;
case 'disctransferfcn'
    SampleTime  = tmpargin{1};
    method      = tmpargin{2};
    cf          = tmpargin{3};    
    Numerator   = tmpargin{4};
    Denominator = tmpargin{5};
    
    m = tf(Numerator, Denominator);    
    if strcmp(method,'prewarp')
      WcRad = cf*2*pi;
      md = c2d(m,SampleTime,method,WcRad);
    else
      md = c2d(m,SampleTime,method);
    end
    numdc = get(md,'num');
    numd = numdc{1};
    dendc = get(md,'den');
    dend = dendc{1};
    
    varargout{1} = numd;
    varargout{2} = dend;
case 'disczpk'
    SampleTime  = tmpargin{1};
    method      = tmpargin{2};
    cf          = tmpargin{3};
    Zeros       = tmpargin{4};
    Poles       = tmpargin{5};
    Gain        = tmpargin{6};
    
    m = zpk(Zeros, Poles,Gain);
    if strcmp(method,'prewarp')
      WcRad = cf*2*pi;
      md = c2d(m,SampleTime,method,WcRad);
    else
      md = c2d(m,SampleTime,method);
    end
    zerosdc = get(md,'z');
    zerosd = zerosdc{1}';
    polesdc = get(md,'p');
    polesd = polesdc{1}';
    gaind = get(md,'k')';
    
    varargout{1} = zerosd;
    varargout{2} = polesd;
    varargout{3} = gaind;    
case 'disclti'
    SampleTime  = tmpargin{1};
    method      = tmpargin{2};
    cf          = tmpargin{3};
    sysc        = tmpargin{4};
    cic         = tmpargin{5};
    
    if(ischar(sysc))
        sysc = evalin('base', sysc);
    end
        
    if(isa(sysc,'ss'))
        if strcmp(method,'prewarp')
            WcRad = Wc*2*pi;		
            [discsys, G] = c2d(sysc, SampleTime, method,WcRad);
		else
			[discsys, G] = c2d(sysc, SampleTime, method);
		end
        As = get(sysc, 'A');
        Bs = get(sysc, 'B');
        Ad = get(discsys,'A');
        Bd = get(discsys,'B');
        Cd = get(discsys,'C');
        Dd = get(discsys,'D');
        [ra,ca] = size(As);
        [rb,cb] = size(Bs);
        iuc = zeros(cb,1);
        if length(cic)==1
          icc = cic * ones(ca,1);
        else
          icc = cic;
        end
        xarg=[icc;iuc];
        [rx,cx] = size(xarg);
        if length(G)==1
          G = G*ones(1,rx);
        end
        discic = G*xarg;
	else
        if strcmp(method,'prewarp')
            WcRad = Wc*2*pi;		
            discsys = c2d(sysc, SampleTime, method,WcRad);
		else
			discsys = c2d(sysc, SampleTime, method);
		end
        discic = 0;
    end   
    varargout{1} = discsys;
    varargout{2} = discic;
case 'initrampmask'    
    st = processSampleTime(tmpargin);
    processClock(st);
case 'initrepeatsequencemask'
    st = processSampleTime(tmpargin);
    processClock(st);
case 'initsiggenmask'
    st = processSampleTime(tmpargin);
    pgenBlk = [gcb, '/Pulse Generator'];
    if st>0
        % discrete case
        executeInBase('set_param', pgenBlk, ...
            'PulseType', 'Sample based', ...
            'Period', 'PeriodSamples', ...
            'PulseWidth', 'halfSamples', ...
            'PhaseDelay', 'halfSamples');
    else
        % continuous case
        executeInBase('set_param', pgenBlk, ...
            'PulseType', 'Time based', ...
            'Period', 'Period', ...
            'PulseWidth', '50', ...
            'PhaseDelay', 'Period/2');
    end    
case 'initchirpmask'
    st = processSampleTime(tmpargin);
    processClock(st);
case 'initderivativemask'
    st = processSampleTime(tmpargin);
    curblk  = find_system(gcb,'FollowLinks','on','LookUnderMasks','all','searchdepth', 1, 'BlockType','Derivative');
    curblkd = find_system(gcb,'FollowLinks','on','LookUnderMasks','all','searchdepth', 1, 'BlockType','DiscreteTransferFcn');
    if(st==0)
        if(isempty(curblk))
            ReplaceBlock(curblkd, 'built-in/Derivative');
            if(iscell(curblkd))
                curblkd = curblkd{1};
            end
            executeInBase('set_param', curblkd, 'Name', 'Derivative');
        end
    else
        if(isempty(curblkd))
            ReplaceBlock(curblk, 'built-in/DiscreteTransferFcn', ...
                'Sampletime', 'SampleTime', ...
                'Numerator', 'numd', ...
                'Denominator', 'dend');
            if(iscell(curblk))
                curblk = curblk{1};
            end
            executeInBase('set_param', curblk, 'Name', 'Discrete Transfer Fcn');
        end
    end

case 'initssmask'
    st = processSampleTime(tmpargin);
    curblk  = find_system(gcb,'FollowLinks','on','LookUnderMasks','all','searchdepth', 1, 'BlockType','StateSpace');
    curblkd = find_system(gcb,'FollowLinks','on','LookUnderMasks','all','searchdepth', 1, 'BlockType','DiscreteStateSpace');
    if(st==0)
        if(isempty(curblk))
            ReplaceBlock(curblkd, 'built-in/StateSpace',...
                'A', 'A',...
                'B', 'B',...
                'C', 'C',...
                'D', 'D',...
                'X0','ic',...
                'AbsoluteTolerance', 'auto');            
            if(iscell(curblkd))
                curblkd = curblkd{1};
            end
            executeInBase('set_param', curblkd, 'Name', 'State Space');
        end
    else
        if(isempty(curblkd))
            ReplaceBlock(curblk, 'built-in/DiscreteStateSpace', ...
                'Sampletime', 'SampleTime', ...
                'A', 'Ad',...
                'B', 'Bd',...
                'C', 'Cd',...
                'D', 'Dd',...
                'X0','icd');                
            if(iscell(curblk))
                curblk = curblk{1};
            end
            executeInBase('set_param', curblk, 'Name', 'Discrete State Space');
        end
    end
    
case 'inittfmask'
    st = processSampleTime(tmpargin);
    curblk  = find_system(gcb,'FollowLinks','on','LookUnderMasks','all','searchdepth', 1, 'BlockType','TransferFcn');
    curblkd = find_system(gcb,'FollowLinks','on','LookUnderMasks','all','searchdepth', 1, 'BlockType','DiscreteTransferFcn');
    if(st==0)
        if(isempty(curblk))
            ReplaceBlock(curblkd, 'built-in/TransferFcn',...
                'Numerator', 'Numerator',...
                'Denominator', 'Denominator',...
                'AbsoluteTolerance', 'auto');
            if(iscell(curblkd))
                curblkd = curblkd{1};
            end
            executeInBase('set_param', curblkd, 'Name', 'Transfer Fcn');
        end
    else
        if(isempty(curblkd))
            ReplaceBlock(curblk, 'built-in/DiscreteTransferFcn', ...
                'Sampletime', 'SampleTime', ...
                'Numerator', 'numd',...
                'Denominator', 'dend');
            if(iscell(curblk))
                curblk = curblk{1};
            end
            executeInBase('set_param', curblk, 'Name', 'Discrete Transfer Fcn');
        end
    end
    
case 'initzpkmask'
    st = processSampleTime(tmpargin);
    curblk  = find_system(gcb,'FollowLinks','on','LookUnderMasks','all','searchdepth', 1, 'BlockType','ZeroPole');
    curblkd = find_system(gcb,'FollowLinks','on','LookUnderMasks','all','searchdepth', 1, 'BlockType','DiscreteZeroPole');
    if(st==0)
        if(isempty(curblk))
            ReplaceBlock(curblkd, 'built-in/ZeroPole',...
                'Zeros', 'Zeros',...
                'Poles', 'Poles',...
                'Gain', 'Gain',...
                'AbsoluteTolerance', 'auto');            
            if(iscell(curblkd))
                curblkd = curblkd{1};
            end
            executeInBase('set_param', curblkd, 'Name', 'Zero Pole');
        end
    else
        if(isempty(curblkd))
            ReplaceBlock(curblk, 'built-in/DiscreteZeroPole', ...
                'Sampletime', 'SampleTime', ...
                'Zeros', 'zerosd',...
                'Poles', 'polesd',...
                'Gain', 'gaind');
            if(iscell(curblk))
                curblk = curblk{1};
            end
            executeInBase('set_param', curblk, 'Name', 'Discrete Zero Pole');
        end
    end
    
case 'inittransdelaymask'
    st = processSampleTime(tmpargin);
    curblkc  = find_system(gcb,'FollowLinks','on','LookUnderMasks','all','searchdepth', 1, 'BlockType','TransportDelay');
    curblkid = find_system(gcb,'FollowLinks','on','LookUnderMasks','all','searchdepth', 1, 'MaskType','Integer Delay');
    curblkfd = find_system(gcb,'FollowLinks','on','LookUnderMasks','all','searchdepth', 1, 'BlockType','DiscreteStateSpace');
    if(st==0)  %Continuous delay
        if(isempty(curblkc))
            if(isempty(curblkid))
              curblkd = curblkfd;
            else
              curblkd = curblkid;
            end
            
            ReplaceBlock(curblkd, 'built-in/TransportDelay',...
                'DelayTime', 'delay',...
                'InitialInput', 'ic');
            if(iscell(curblkd))
                curblkd = curblkd{1};
            end
            executeInBase('set_param', curblkd, 'Name', 'Transport Delay');
        end
    elseif(abs(abs(st)-round(st))<eps*abs(st))  %Integer delay
        if(isempty(curblkid))
            if(isempty(curblkc))
              curblk = curblkfd;
            else
              curblk = curblkc;
            end
           
            ReplaceBlock(curblk, 'simulink/Discrete/Integer Delay', ...
                'samptime', 'SampleTime', ...
                'NumDelays', 'samples',...
                'vinit', 'ic');
            if(iscell(curblk))
                curblk = curblk{1};
            end
            executeInBase('set_param', curblk, 'Name', 'Integer Delay');
        end
    else    %Fractional Delay
        if(isempty(curblkfd))
            if(isempty(curblkc))
              curblk = curblkid;
            else
              curblk = curblkc;
            end            
            ReplaceBlock(curblk, 'built-in/DiscreteStateSpace', ...
                'SampleTime', 'SampleTime', ...
                'A', 'A',...
                'B', 'B',...
                'C', 'C',...
                'D', 'Dd',...
                'X0', 'ic');
            if(iscell(curblk))
                curblk = curblk{1};
            end
            executeInBase('set_param', curblk, 'Name', sprintf('Discrete\nState Space'));
        end      
      
    end
    
case 'initvartransdelaymask'
    st = processSampleTime(tmpargin);
    
    curblk  = find_system(gcb,'FollowLinks','on','LookUnderMasks','all','searchdepth', 1, 'BlockType','VariableTransportDelay');
    curblkd = find_system(gcb,'FollowLinks','on','LookUnderMasks','all','searchdepth', 1, 'MaskType','Variable Integer Delay');
    if(st==0)
        if(isempty(curblk))
            ReplaceBlock(curblkd, 'built-in/VariableTransportDelay',...
                'MaximumDelay', 'MaximumDelay',...
                'InitialInput', 'InitialInput');
            if(iscell(curblkd))
                curblkd = curblkd{1};
            end
            executeInBase('set_param', curblkd, 'Name', 'Variable Transport Dealy');
        end
    else
        if(isempty(curblkd))
            if(isempty(find_system(0, 'searchdepth', 0, 'name', 'dspsigops')))
                load_system('dspsigops');
            end
            ReplaceBlock(curblk, sprintf('dspsigops/Variable\nInteger Delay'), ...
                'dmax', 'maxDelaySamples',...
                'ic', 'InitialInput');
            if(iscell(curblk))
                curblk = curblk{1};
            end
            executeInBase('set_param', curblk, 'Name', sprintf('Variable\nInteger Delay'));
        end
    end

otherwise
end

% end sldiscutil

%
%===============================================================================
%  Replaces a single block with a new block with specified parameters
%===============================================================================
%
function ReplaceBlock(oldBlock,newBlock,varargin)
% REPLACEBLOCK replaces a single block with a new block with specified parameters.

if iscell(oldBlock)
    oldBlock = oldBlock{1};
end

% the decorations must be preserved
decorations = GetDecorationParams(oldBlock);

% the old block's name and parent are needed for the new block

name   = strrep(disc_get_param(oldBlock,'Name'),'/','//');
parent = disc_get_param(oldBlock,'Parent');
   
% rename the old block, add the new block with the appropriate 
% parameters (as passed in as a varargs) and with the old 
% decorations, delete the old block
%
% To Do: get a unique block name
oldh = disc_get_param(oldBlock,'handle');
executeInBase('set_param',oldBlock, 'Name', [name '_backup']);

changedBlk = -1.0;
try
   newname = sprintf('%s/%s',parent,name);
   executeInBase('add_block', newBlock, newname, varargin{:}); 
   executeInBase('delete_block', oldh);
   executeInBase('set_param', oldBlock, 'LinkStatus', 'none');
   executeInBase('set_param', oldBlock, decorations{:});
catch
    lasterr
   if changedBlk == -1.0
      executeInBase('set_param', oldh, 'Name', name);
      fprintf('Cannot replace block for ''%s''\n',strrep(oldBlock,sprintf('\n'),' '));
   end
end

% end ReplaceBlock

%
%=============================================================================
% GetDecorationParams
% Return a cell array containing the parameter/value pairs for a block's
% decorations (i.e. FontSize, FontWeight, Orientation, etc.)
%=============================================================================
%
function decorations = GetDecorationParams(block)

decorations = {
  'Position',        [];
  'Orientation',     [];
  'ForegroundColor', [];
  'BackgroundColor', [];
  'DropShadow',      [];
  'NamePlacement',   [];
  'ShowName',        [];
  'Priority',        [];
  'RTWData',         [];
  'UserData',        [];
  'UserDataPersistent',[];  
  'FontName',        [];
  'FontSize',        [];
  'FontWeight',      [];
  'FontAngle',       [];
  'ShowName',        [];
  'Selected',        [];
  'Tag',             [];
  'HiliteAncestors', [];
};

for i = 1:size(decorations,1),
  decorations{i,2} = disc_get_param(block,decorations{i,1});
end

decorations = reshape(decorations',1,length(decorations(:)));

% end GetDecorationParams

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% execute arbitrary commands or functions in base workspace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function executeInBase(cmd, varargin)

n = length(varargin);
cmds = cmd;
for i=1:n,
    if(i==1)
        cmds = [cmds '('];
    end
    tmpstr = sprintf('tmp_disc_var_%d', i);
    assignin('base', tmpstr, varargin{i});
    cmds = [cmds tmpstr];
    if(i~=n)
        cmds = [cmds ','];
    end
    if(i==n)
        cmds = [cmds ')'];
    end
end

evalin('base', cmds);
evalin('base', 'clear tmp_disc_var_*');

% end executeInBase

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get block parameter and determine if the value is a cell array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = disc_get_param(block, param)

ret = get_param(block, param);
if iscell(ret)
    ret = ret{1};
end

% end disc_get_param

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Deal with clock and digital clock
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function processClock(st)

    curblkc  = find_system(gcb,'FollowLinks','on','LookUnderMasks','all','searchdepth', 1, 'BlockType','Clock');
    curblkdc = find_system(gcb,'FollowLinks','on','LookUnderMasks','all','searchdepth', 1, 'BlockType','DigitalClock');
    if(st==0)
        if(isempty(curblkc))
            ReplaceBlock(curblkdc, 'built-in/Clock');
            if(iscell(curblkdc))
                curblkdc = curblkdc{1};
            end
            executeInBase('set_param', curblkdc, 'Name', 'Clock');
        end
    else
        if(isempty(curblkdc))
            ReplaceBlock(curblkc, 'built-in/DigitalClock', 'Sampletime', 'SampleTime');
            if(iscell(curblkc))
                curblkc = curblkc{1};
            end
            executeInBase('set_param', curblkc, 'Name', 'Digital Clock');
        end
    end

% end processClock    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% process sample time for initializing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = processSampleTime(st)

if(iscell(st))
    ret = st{1};
else
    ret = st;
end

%end processSampleTime


%[EOF] sldiscutil.m
