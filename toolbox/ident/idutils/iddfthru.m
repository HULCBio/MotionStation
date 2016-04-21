function tdfthru(blk,Td,u0,bufsize)
%TDFTHRU  Helper function for Transport Delay with Feedthrough block
%         This function is called during MaskInitialization, and is
%         not intended for command-line usage.
  
% Greg Wolodkin 10-12-1998
% Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:18:35 $

% Only enter code if a state change is required ( initialization, changing
% number of delay)

% No Delay blocks currently
delayblk = find_system(blk,'FollowLinks','on','LookUnderMasks','all',...
    'Blocktype','TransportDelay');
% Td matches DelayTime in Block
delayblkTd = find_system(delayblk,'DelayTime',num2str(Td));

if (isempty(delayblk) & any(Td>0)) ... % Change from Td=0 to Td being nonzero
        | (~isempty(delayblk) & isempty(delayblkTd)), % Any change in Td after it exists
    N = length(Td);
    if N ~= prod(size(Td))
        local_invalid(blk,'Delay Time');
        return
    end
    Td = reshape(Td,1,N);
    
    M = length(u0);
    if M ~= prod(size(u0))
        local_invalid(blk,'Initial Input');
        return
    end
    u0 = reshape(u0,1,M);
    
    P = max(M,N);
    
    must_split = (P>1) & any(Td == 0) & any(Td ~= 0);
    if must_split 
        if N == 1, Td = Td*ones(1,M); end
        if M == 1, u0 = u0*ones(1,N); end
        if length(Td) ~= length(u0)
            local_invalid(blk,'Initial Input',' (size mismatch with Delay Time)');
            return
        end
    end
    
    % First delete everything.. start from scratch
    delete_contents(blk);
    
    % add I/O ports
    % inpos  = [ 30 50  60 64];
    % outpos = [365 50 395 64];
    % add_block('built-in/Inport',[blk '/Inport'],'Position',inpos);
    % add_block('built-in/Outport',[blk '/Outport'],'Position',outpos);
    
    iselpos  = [ 85 36 120 74];
    demuxpos = [150 36 155 74];
    muxpos   = [270 36 275 74];
    oselpos  = [305 36 340 74];
    
    if ~must_split
        % Single delay of zero or vector of zeros
        if Td == 0
            add_line(blk,'Inport/1','Outport/1'); 
            set_param(blk,'MaskDisplay','plot([0 1],[0.5 0.5])');
            set_param(blk,'ShowName','off');
            
            % Single (or vectorized with no zeros) delay
        else 
            delaypos = [195 40 225 70];
            add_block('built-in/Transport Delay',[blk '/Transport Delay'],...
                'Position',delaypos);
            add_line(blk,'Inport/1','Transport Delay/1');
            add_line(blk,'Transport Delay/1','Outport/1');
            set_param([blk '/Transport Delay'],'DelayTime',mat2str(Td),...
                'InitialInput',mat2str(u0),'BufferSize',int2str(bufsize));
            set_param(blk,'MaskDisplay','block_icon(''Transport Delay'')');
            set_param(blk,'ShowName','on');
        end
        
    else
        % Vector of delays, some zero
        
        iz = find(Td == 0);		% those with zero delay
        inz = find(Td ~= 0);
        inx = [iz inz];		% permutation puts zero delay at the top
        [junk,outx] = sort(inx);	% inverse permutation
        
        delaypos = [195 50 225 80];
        add_block('built-in/Selector',[blk '/ISelect'],'Position',iselpos,...
            'Elements',mat2str(inx),'InputPortWidth',int2str(P));
        add_block('built-in/Demux',[blk '/Demux'],'Position',demuxpos,...
            'BackgroundColor','black','ShowName','off',...
            'Outputs',mat2str([length(iz) length(inz)]));
        add_block('built-in/Transport Delay',...
            [blk '/Transport Delay'],'Position',delaypos);
        add_block('built-in/Mux',[blk '/Mux'],'Position',muxpos,...
            'DisplayOption','bar','ShowName','off','Inputs','2')
        add_block('built-in/Selector',[blk '/OSelect'],'Position',oselpos,...
            'Elements',mat2str(outx),'InputPortWidth',int2str(P));
        add_line(blk,'Inport/1','ISelect/1');
        add_line(blk,'ISelect/1','Demux/1');
        add_line(blk,'Demux/1','Mux/1');
        add_line(blk,'Demux/2','Transport Delay/1');
        add_line(blk,'Transport Delay/1','Mux/2');
        add_line(blk,'Mux/1','OSelect/1');
        add_line(blk,'OSelect/1','Outport/1');
        
        set_param([blk '/Transport Delay'],'DelayTime',mat2str(Td(inz)),...
            'InitialInput',mat2str(u0(inz)),'BufferSize',int2str(bufsize));
        set_param(blk,'MaskDisplay','block_icon(''Transport Delay'')');
        set_param(blk,'ShowName','on');
    end
end

% local subfunctions 
%----------------------------------------------------------------------

function delete_contents(blk)
% Given the particular transport delay with feedthrough subsystem,
% delete its contents in order to build it up from scratch later.

tdlist = find_system(blk,'FollowLinks','on',...
                         'LookUnderMasks','on','FindAll','on');
blist = []; llist = [];

for k=1:length(tdlist)
  switch get_param(tdlist(k),'Type')
  case 'line'
    llist = [llist; tdlist(k)];
    % do nothing
  case 'block'
    switch get_param(tdlist(k),'BlockType')
    case {'TransportDelay','Mux','Demux','Selector'}
      blist = [blist; tdlist(k)];
    otherwise
      % do nothing
    end
  case 'port'
    % do nothing    
  otherwise
    disp(sprintf('Unknown case: %sType',get_param(tdlist(k))));
  end
end

for k=1:length(llist)
   delete_line(llist(k));
end

for k=1:length(blist)
   delete_block(blist(k));
end

%----------------------------------------------------------------------

function local_invalid(blk, str, str1)
% Throw an error dialog up
  if nargin < 3
    str1 = [];
  end
  errordlg(sprintf('Invalid setting in block ''%s'' for parameter ''%s''%s', blk,str,str1),...
            'Transport Delay Error');

%----------------------------------------------------------------------
