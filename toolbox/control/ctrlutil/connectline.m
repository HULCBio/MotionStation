function vararout = connectline(varargin);
%CONNECTLINE contains the callbacks for the Model Inputs and Output diagram
%   CONNECTLINE(ACTION) performs the block callback specified by ACTION, 
%   
%   ACTION must be one of the following strings:   
%      1) copy:   (CopyFcn)   Changes the name of the block to the line 
%                             it was copied onto
%      2) delete: (DeleteFcn) Reconnects the line through the block
%      3) open:   (OpenFcn)   Connects/disconnects the block into the 
%                             line crossing the block.

%   Karen Gondoly, 12-2-96
%   Copyright 1986-2002 The MathWorks, Inc. 
% $Revision: 1.16 $

ni = nargin;
error(nargchk(1,2,ni));

action=varargin{1};
if isempty(strmatch(action,{'start';'copy';'open';'delete'}))
   error('Invalid ACTION string')
end

if nargin>1,
   CB=varargin{2};
   try
      diagram_name = get_param(CB,'Parent');
   catch
      error('Invalid Simulink block handle.');
   end
else
   CB=gcb; % Should be the connector block
   diagram_name=gcs;
end

blockname=get_param(CB,'Name');
blockhandle=get_param(CB,'Handle');

lines = get_param(diagram_name,'Lines');
if isempty(lines),
   return
end

%---Set up preliminary data
AllLines = LocalGetBranches(lines);
for ctL=1:length(AllLines), % Pad the empty Src/Dst block with zeros
   if isempty(AllLines(ctL).SrcBlock),
      AllLines(ctL).SrcBlock=-1;
   end
   if isempty(AllLines(ctL).DstBlock),
      AllLines(ctL).DstBlock=-1;
   end
end

%---Check if the blocks is currently connected, or not
AllSrcBlocks = [AllLines.SrcBlock];
AllDstBlocks = [AllLines.DstBlock];

if isempty(AllSrcBlocks);AllSrcBlocks=blockhandle+1;end
if isempty(AllDstBlocks);AllDstBlocks=blockhandle+1;end

indSrcBlock = find(AllSrcBlocks==blockhandle);
indDstBlock = find(AllDstBlocks==blockhandle);

%----Perform callbacks
switch action
case 'copy',
   
  %---CopyFcn, get the name of the line feeding into the block
  % LocalRenameBlock(CB,diagram_name);
   
case 'delete',
   %---DeleteFcn for the Model Input and Output blocks
   %---If block is deleted from an Undo, the line is automatically reconnected and
   %----indSrcBlock/indDstBlock are empty. Otherwise, the lines is not reconnected
   %----and the line needs to be patched.
   if ~isempty(indSrcBlock) & ~isempty(indDstBlock)
      LocalHealLine(diagram_name,CB,AllLines,indSrcBlock,indDstBlock)
   end % if ~isempty(Ind...   
   
case 'open',
   %---Execute the OpenFcn only if block is completely connected or disconnected
   if any(AllSrcBlocks==blockhandle) & any(AllDstBlocks==blockhandle), 
      % Disconnect the block and replace with old line
      LocalHealLine(diagram_name,CB,AllLines,indSrcBlock,indDstBlock)      
   elseif  ~any(AllSrcBlocks==blockhandle) & ~any(AllDstBlocks==blockhandle)
      % Reconnect the block
      LocalReconnectLine(diagram_name,CB,AllLines)
      %LocalRenameBlock(CB,diagram_name);
   end % if/else ConnectFlag
   
end % switch

%------------------------------Internal Functions---------------------------
%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCheckPoints %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function [Points] = LocalCheckPoints(Points)

if size(Points,1)>2 & isequal(Points(end,1),Points(end-1,1)) & ...
      isequal(Points(end,2),Points(end-1,2)),
   Points= Points(1:end-1,:);
end

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalGetBranches %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function [Branches] = LocalGetBranches(l,Branches);

ni=nargin;
switch ni
case 0
   return
case 1
   fields = fieldnames(l(1));
   Branches = cell2struct(cell(size(fields,1),0),fields);
end

for ctl=1:length(l)
   Branches = [Branches;l(ctl)];
   
   B=l(ctl).Branch;
   if ~isempty(B),
      for ctB=1:length(B),
         if ~isempty(B(ctB).DstBlock),
            Branches=[Branches;B(ctB)];
         else
            Branches = LocalGetBranches(B(ctB),Branches);
         end 
      end % for ctB
   end % if ~isempty(B)
end % for ctl

%%%%%%%%%%%%%%%%%%%%%
%%% LocalHealLine %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalHealLine(diagram_name,CB,AllLines,indSrcBlock,indDstBlock)

OutPort=get_param(CB,'OutputPorts');
InPort=get_param(CB,'InputPorts');

delete_line([AllLines(indDstBlock).Handle]);
delete_line([AllLines(indSrcBlock).Handle]);

DstLines = LocalGetBranches(AllLines(indDstBlock));
SrcLines = LocalGetBranches(AllLines(indSrcBlock));

%---There probably is never more then 1 DstLine!
for ctD = 1:length(DstLines),
   P = DstLines(ctD).Points;
   if ishandle(DstLines(ctD).SrcBlock),
      AddPos = get_param(DstLines(ctD).SrcBlock,'OutputPorts');
      P = [AddPos(str2double(DstLines(ctD).SrcPort),:);P];
   end
   P=[P;AllLines(indSrcBlock).Points(1,:);SrcLines(1).Points];
   if ishandle(SrcLines(1).DstBlock),
      AddPos = get_param(SrcLines(1).DstBlock,'InputPorts');
      P = [P;AddPos(str2double(SrcLines(1).DstPort),:)];
   end
   add_line(diagram_name,P);
end % for ctD

for ctS = 2:length(SrcLines),
   P = SrcLines(ctS).Points;
   if ishandle(SrcLines(ctS).DstBlock),
      AddPos = get_param(SrcLines(ctS).DstBlock,'InputPorts');
      P = [P;AddPos(str2double(SrcLines(ctS).DstPort),:)];
   end % if ishandle
   add_line(diagram_name,P);
end % for ctS

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalRenameBlock %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalRenameBlock(CB,diagram_name)

inName = get_param(CB,'InputSignalNames');
outName = get_param(CB,'OutputSignalNames');

NewBlockName=[];
if ~isempty(char(outName)),
   %---Look at OutputSignalName first, 
   lenN=length(char(outName));
   NewBlockName = outName;
elseif ~isempty(char(inName)),
   lenN=length(char(inName));
   NewBlockName = inName;
end

%---One of the lines would have inherited any previous name.

if ~isempty(NewBlockName), 
   %---Make sure there are no other blocks with this name
   AllBlocks = get_param(diagram_name,'Blocks');
   IndMatch = find(strncmpi(NewBlockName,AllBlocks,lenN));
   if ~isempty(IndMatch),
      MatchNames = strvcat(AllBlocks{IndMatch});
      strVals = real(MatchNames(:,lenN+1:end));
      strVals(find(strVals(:,1)<48 | strVals(:,1)>57),:)=[];
      MatchNums = zeros(size(strVals,1),1);
      for ctR=1:size(strVals,1),
         MatchNums(ctR,1) = str2double(char(strVals(ctR,:)));
      end
      if ~isnan(MatchNums),
         NextInd = setdiff(1:max(MatchNums)+1,MatchNums);
         NextInd = NextInd(1);
      else
         NextInd=1;
      end
      
      NewBlockName=[char(NewBlockName),num2str(NextInd)];
   else
      NewBlockName=char(NewBlockName);
   end
   set_param(CB,'Name',NewBlockName);
end, % if ~isempty(NewBlockName)


%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalReconnectLine %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalReconnectLine(diagram_name,CB,AllLines)
LineInd=[];
pos = get_param(CB,'Position');
for ct = 1:length(AllLines), 
  linepos = AllLines(ct).Points;

  % Check if the source port is of type 'connection'
  src = get_param(AllLines(ct).Handle, 'SrcPortHandle');
  if ishandle(src),
    srcType = strcmp(get_param(src, 'PortType'), 'connection');
  else
    srcType = 0;
  end
  % Check if the destionation port is of type 'connection'
  dst = get_param(AllLines(ct).Handle, 'DstPortHandle');
  if ishandle(dst),
    dstType = strcmp(get_param(dst, 'PortType'), 'connection');
  else
    dstType = 0;
  end
  
  % Do not connect line if it is a Connection line, i.e. either one of the
  % source/destination ports of the line is a Physical Modeling block.
  if ~(srcType | dstType)
    for ctinner=1:size(linepos,1)-1,
      [Xmin,XminInd] = min(linepos(ctinner:ctinner+1,1));
      [Xmax,XmaxInd] = max(linepos(ctinner:ctinner+1,1));
      [Ymin,YminInd] = min(linepos(ctinner:ctinner+1,2));
      [Ymax,YmaxInd] = max(linepos(ctinner:ctinner+1,2));
      %---Look for Horizontal crossings
      if (Xmin<=pos(1)) & (Xmax>=pos(3)) & (Ymin>=pos(2)) & (Ymax<=pos(4))
	if XminInd==2, % The line is going right to left
	  set_param(CB,'Orientation','left');
	else
	  set_param(CB,'Orientation','right');
	end
	LineInd=ct;
	PointInd=ctinner;
      end
      %---Look for Vertical crossings
      if (Xmin>=pos(1)) & (Xmax<=pos(3)) & (Ymin<=pos(2)) & (Ymax>=pos(4)) 
	if YminInd==2, % The line is going down
	  set_param(CB,'Orientation','up');
	else
	  set_param(CB,'Orientation','down');
	end % if/else YminInd
	LineInd=ct;
	PointInd=ctinner;
      end % if Xmin...
      
      if ~isempty(LineInd),
	%---Look at the first line. All other lines should either be
	%---children of this one and will be handled when the branches are
	%---drawn or are other independent lines, which can not also be
	%---connected into the Inport/Outport and so will be ignored.
	
	% Delete the first line going thru the block (and its Branches)
	delete_line([AllLines(LineInd).Handle]); 
	
	InportPoint=get_param(CB,'InputPorts');
	OutportPoint=get_param(CB,'OutputPorts');
	
	[LinePoints] = LocalCheckPoints(AllLines(LineInd).Points);
	
	%---Check that other branches don't double back, if they do,
	%---the line must be extended back to the point it doubles back
	%---to, otherwise SL automatically truncates it
	LineParent = AllLines(LineInd).Parent;
	AddPoints=[];
	if ~isequal(LineParent,get_param(diagram_name,'Handle')),
	  indParent = find(LineParent==[AllLines.Handle]);
	  OtherBranches = LocalGetBranches(AllLines(indParent));
	  indAllLine = find([OtherBranches.Handle]==AllLines(LineInd).Handle);
	  OtherBranches(indAllLine)=[];
	  ParentPoints = AllLines(indParent).Points;
	  for ctOB = 1:length(OtherBranches),
	    if isequal(LineParent,OtherBranches(ctOB).Parent),
	      OBpoints = OtherBranches(ctOB).Points;
	      if (any(OBpoints(2,1)==ParentPoints(1,1)) ) & ...
		    (any(OBpoints(2,2)>min(ParentPoints(end-1:end,2))) ) & ...
		    (any(OBpoints(2,2)<max(ParentPoints(end-1:end,2))) )
		AddPoints = OBpoints(2,:);
	      elseif (any(OBpoints(2,2)==ParentPoints(1,2)) ) & ...
		    (any(OBpoints(2,1)>min(ParentPoints(end-1:end,1))) ) & ...
		    (any(OBpoints(2,1)<max(ParentPoints(end-1:end,1))) ),
		AddPoints = OBpoints(2,:);
	      end % if any
	    end, % if isequal
	  end, % for ctOB
	end, % if ~isequal
	
	% Add the new line to the LTI In/Outport Block
	ToBlockPoints = [AddPoints;LinePoints(1:PointInd,:);InportPoint];
	FromBlockPoints = [OutportPoint;LinePoints(PointInd+1:end,:)];
	add_line(diagram_name,ToBlockPoints);
	
	% Add the new line from the LTI In/Outport Block
	add_line(diagram_name,FromBlockPoints);
	
	%---Add any branches
	AllBranches = LocalGetBranches(AllLines(LineInd));
	for ctB=2:length(AllBranches),
	  %---Check if the branch is going thru the line, if so,
	  %---get rid of this part of the line
	  branchpos = AllBranches(ctB).Points;
	  if (any(branchpos(2,1)==FromBlockPoints(1,1)) ) & ...
		(any(min(branchpos(2,1:2))<min(FromBlockPoints(:,2))) ) & ...
		(any(max(branchpos(2,1:2))>min(FromBlockPoints(:,2))) ),
	    %---Doubles back in X
	    branchpos = [branchpos(1,:);branchpos(3,:)];
	  elseif (any(branchpos(2,2)==FromBlockPoints(1,2)) ) & ...
		(any(min(branchpos(1:2,1))<min(FromBlockPoints(:,1))) ) & ...
		(any(max(branchpos(1:2,1))>min(FromBlockPoints(:,1))) ),
	    %---Doubles back in Y
	    branchpos = [branchpos(1,:);branchpos(3:end,:)];                  
	  end
	  PointInd2=1;
	  for ctinner2=1:size(branchpos,1)-1,
	    [Xmin,XminInd] = min(branchpos(ctinner2:ctinner2+1,1));
	    [Xmax,XmaxInd] = max(branchpos(ctinner2:ctinner2+1,1));
	    [Ymin,YminInd] = min(branchpos(ctinner2:ctinner2+1,2));
	    [Ymax,YmaxInd] = max(branchpos(ctinner2:ctinner2+1,2));
	    %---Look for Horizontal crossings
	    if (Xmin<=pos(1)) & (Xmax>=pos(3)) & (Ymin>=pos(2)) & (Ymax<=pos(4))
	      PointInd2=ctinner2;
	    end
	    %---Look for Vertical crossings
	    if (Xmin>=pos(1)) & (Xmax<=pos(3)) & (Ymin<=pos(2)) & (Ymax>=pos(4)) 
	      PointInd2=ctinner2;
	    end % if Xmin...
	  end % for ctinner
	  add_line(diagram_name,branchpos(PointInd2:end,:));
	end
	
	return % end loop after connecting the block
      end % if ~isempty(LineInd)
    end % for ctinner
  end % if ~(srcType | dstType)
end % for ct
