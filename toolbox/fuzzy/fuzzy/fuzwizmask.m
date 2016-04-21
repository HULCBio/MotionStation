function fuzwizmask(CB,varargin)
%FUZWIZMASK  Initialization for FIS Wizard components.
%
%  See also FUZBLOCK.

%   Authors: P. Gahinet and R. Jang
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.14.2.2 $ $Date: 2004/04/10 23:15:26 $
Model = bdroot(CB);
Dirty = get_param(Model,'Dirty');

% Initialization functions for various components
switch get_param(CB,'MaskType')
   case 'FIS Wizard'
      % FIS Wizard initialization
      fis = varargin{1};  % valid FIS at this point
      % Store current FIS in block UserData to prevent multiple updates
      if ~isequal(fis,get_param(CB,'UserData'))
         set_param(gcb,'UserData',fis)
         LocalCreateFIS(CB,fis);
      end

   case 'Input MF Eval'
      % Initialize input MF blocks
      LocalCreateInputMF(CB,varargin{:});

   case 'Output MF Eval'
      % Initialize output MF blocks
      LocalCreateOutputMF(CB,varargin{:});

   case 'FIS Rule'
      % Build rule block
      LocalCreateRule(CB,varargin{:});
end

set_param(Model,'Dirty',Dirty)

%----------------- Local Functions ------------------------------

%%%%%%%%%%%%%%%%%%
% LocalCreateFIS % 
%%%%%%%%%%%%%%%%%%
function LocalCreateFIS(CB,fis)
% Builds subsystem representing FIS

load_system('fuzwiz')

% Clear existing FIS (except I/O ports to prevent disconnecting the block
InPort = get_param([CB '/In1'],'handle');
OutPort = get_param([CB '/Out1'],'handle');
AllBlocks = get_param(find_system(CB,'SearchDepth',1,'FollowLinks','on',...
    'LookUnderMasks','all','Type','block'),'handle');
AllBlocks = cat(1,AllBlocks{:});
AllBlocks(ismember(AllBlocks,[InPort;OutPort;get_param(CB,'handle')])) = [];
for ct=1:length(AllBlocks)
    delete_block(AllBlocks(ct));
end
AllLines = get_param(CB,'lines');
for ct=1:length(AllLines)
    delete_line(AllLines(ct).Handle);
end

% FIS parameters
nin = length(fis.input);
nout = length(fis.output);
nrule = length(fis.rule);
isSugeno = strcmpi(fis.type,'sugeno');

% Protect / in input and output names (leads to invalid block path in ADDBLOCK)
for ct=1:nin
    fis.input(ct).name = strrep(fis.input(ct).name,'/','//');
end
for ct=1:nout
    fis.output(ct).name = strrep(fis.output(ct).name,'/','//');
end

% Draw new FIS 
% RE: Positions are [x1 y1 x2 y2] with (0,0) in upper left corner
set_param(InPort,'Position',[30 100 60 115]);
DemuxBlock = sprintf('%s/Demux',CB);
add_block('built-in/Demux',DemuxBlock,'Outputs',num2str(nin),'ShowName','off');
add_line(CB,'In1/1','Demux/1');

% Input MF blocks
y0 = 40;
rule_ant = cat(1,fis.rule.antecedent);
ctTerm = 1;
for ct=1:nin,
    Dest = sprintf('%s',fis.input(ct).name);
    dy = 16+8*length(fis.input(ct).mf);
    add_block('fuzwiz/FIS Input MF',sprintf('%s/%s',CB,Dest),...
        'Position',[150 y0 200 y0+dy],...
        'MaskValues',{'fis',sprintf('%d',ct)});
    add_line(CB,sprintf('Demux/%d',ct),[Dest '/1']);
    % Add terminator to unconnected output ports
    unused_mf = find(~ismember(1:length(fis.input(ct).mf),rule_ant(:,ct)));
    for ctp=1:length(unused_mf)
        dyt = 8*unused_mf(ctp);
        add_block('built-in/Terminator',sprintf('%s/Term%d',CB,ctTerm),...
            'ShowName','off','Position',[220 y0+dyt 230 y0+dyt+10]);
        add_line(CB,sprintf('%s/%d',Dest,unused_mf(ctp)),sprintf('Term%d/1',ctTerm));
        ctTerm = ctTerm+1;
    end
    y0 = y0 + dy + 30;
end
set_param(DemuxBlock,'Position',[110 20 115 y0])

% Output MF blocks
y0 = y0 + 30;
rule_conseq = cat(1,fis.rule.consequent);
for ct=1:nout,
    Dest = sprintf('%s',fis.output(ct).name);
    dy = 16+8*length(fis.output(ct).mf);
    add_block('fuzwiz/FIS Output MF',sprintf('%s/%s',CB,Dest),...
        'Position',[130 y0 200 y0+dy],...
        'MaskValues',{'fis',sprintf('%d',ct)});
    if isSugeno & any(strcmpi({fis.output(ct).mf.type},'linear'))
        add_line(CB,'In1/1',[Dest '/1']);
    end
    % Add terminator to unconnected output ports
    unused_mf = find(~ismember(1:length(fis.output(ct).mf),rule_conseq(:,ct)));
    for ctp=1:length(unused_mf)
        dyt = 8*unused_mf(ctp);
        add_block('built-in/Terminator',sprintf('%s/Term%d',CB,ctTerm),...
            'ShowName','off','Position',[220 y0+dyt 230 y0+dyt+10]);
        add_line(CB,sprintf('%s/%d',Dest,unused_mf(ctp)),sprintf('Term%d/1',ctTerm));
        ctTerm = ctTerm+1;
    end
    y0 = y0 + dy + 30;
end

% Defuzz blocks for output MF values (one per output)
InputPortWidth = sum(cat(1,fis.rule.consequent)>0,1);
x0 = 500;
y0 = 50;
yout = zeros(1,nout);
if isSugeno
   % Sugeno systems
   for ct=1:nout,
      MplxBlock = 'Mux';
      add_block('built-in/Mux',sprintf('%s/Mux%d',CB,ct),...
         'ShowName','off','DisplayOption','bar',...
         'Inputs',num2str(InputPortWidth(ct)),...
         'Position',[x0 y0 x0+5 y0+20+10*InputPortWidth(ct)]);
      yout(ct) = y0+10+5*InputPortWidth(ct);
      y0 = y0+50+10*InputPortWidth(ct);
   end
elseif nrule==1
   % Mamdani system with single rule. Watch for behavior of Sum block on
   % single vector input (sums all inputs)
   MplxBlock = 'AggMethod';
   add_block('built-in/Gain',sprintf('%s/%s',CB,'AggMethod1'),...
      'Gain','1','Position',[x0-30 y0 x0 y0+20+10*InputPortWidth]);
   yout = y0+10+5*InputPortWidth;
   y0 = y0+50+10*InputPortWidth;
   
else
   % Mamdani system 
   for ct=1:nout,
      if strcmp(fis.aggMethod,'max')
         MplxBlock = 'AggMethod';
         add_block('built-in/MinMax',sprintf('%s/%s%d',CB,'AggMethod',ct),...
            'Function','max','Inputs',num2str(InputPortWidth(ct)),...
            'Position',[x0-30 y0 x0 y0+20+10*InputPortWidth(ct)]);
      elseif strcmp(fis.aggMethod,'sum')
         MplxBlock = 'AggMethod';
         symb = '+';
         for id = 1:InputPortWidth(ct) - 1
            symb = sprintf('+%s',symb);
         end
         add_block('built-in/Sum',sprintf('%s/%s%d',CB,'AggMethod',ct),...
            'Inputs',symb, 'iconshape','rectangular', ...
            'Position',[x0-30 y0 x0 y0+20+10*InputPortWidth(ct)]);
      elseif strcmp(fis.aggMethod,'probor')
         MplxBlock = 'Mux';
         probor_system_path = sprintf('%s/%s%d',CB,'AggMethod',ct);
         % Add a mux to accept all inputs and pass them into subsystem block
         add_block('built-in/Mux',sprintf('%s/Mux%d',CB,ct),...
            'ShowName','off','DisplayOption','bar',...
            'Inputs',num2str(InputPortWidth(ct)),...
            'Position',[x0-50 y0 x0-45 y0+20+10*InputPortWidth(ct)]);
         % Add a subsystem block in which to build the probor rule aggregation
         add_block('built-in/Subsystem', probor_system_path,...
            'Position',[x0 y0 x0+50 y0+20+10*InputPortWidth(ct)], ...
            'MaskDisplay','disp(''Probor\n System'')');
         % Call the probor rule aggregation method     
         LocalProborAggMethod( InputPortWidth(ct), probor_system_path);
         add_line(CB, sprintf('Mux%d/1',ct), sprintf('AggMethod%d/1',ct));
      end
      yout(ct) = y0+10+5*InputPortWidth(ct);
      y0 = y0+50+10*InputPortWidth(ct);
   end
end    
  
% Total firing strength
TFS = sprintf('Total Firing\nStrength');
add_block('built-in/Sum',[CB '/' TFS],...
    'Inputs',num2str(nrule),...
    'Position',[x0 y0 x0+20 y0+20+10*nrule]);
xytfs = [x0 y0+10+5*nrule];

% Add rule blocks
x0 = 300;
y0 = 30;
mplxport = ones(1,nout);
for ct=1:nrule,
    Rule = fis.rule(ct);
    nantec = length(find(Rule.antecedent));
    nconseq = length(find(Rule.consequent));
    dym1 = 8+8*nantec;
    dym2 = 8+8*nconseq;
    dyr = max(0,(dym1+dym2+5)/2-20);
    % Mux rule antecedents and consequents
    aMux = sprintf('aMux%d',ct);
    add_block('built-in/Mux',[CB '/' aMux],'Inputs',num2str(nantec),...
            'ShowName','off','DisplayOption','bar',...
            'Position',[x0 y0 x0+5 y0+dym1]);
    cMux = sprintf('cMux%d',ct);
    add_block('built-in/Mux',[CB '/' cMux],'Inputs',num2str(nconseq),...
            'ShowName','off','DisplayOption','bar',...
            'Position',[x0 y0+dym1+5 x0+5 y0+dym1+dym2+5]);
    % Rule block
    RuleBlock = sprintf('Rule%d',ct);
    add_block('fuzwiz/FIS Rule',sprintf('%s/%s',CB,RuleBlock),...
        'Position',[x0+30 y0+dyr x0+80 y0+dyr+40],...
        'MaskValues',{'fis',sprintf('%d',ct)});
    % Demux rule outputs
    cDemux = sprintf('cDemux%d',ct);
    add_block('built-in/Demux',[CB '/' cDemux],'Outputs',num2str(nconseq),...
            'ShowName','off','Position',[x0+100 y0 x0+105 y0+dym1]);
    % Wiring
    add_line(CB,[aMux '/1'],[RuleBlock '/1'])
    add_line(CB,[cMux '/1'],[RuleBlock '/2'])
    add_line(CB,[RuleBlock '/1'],[cDemux '/1'])
    % Wire antecedents
    ctport = 1;
    for ctin=find(Rule.antecedent),
        add_line(CB,...
            sprintf('%s/%d',fis.input(ctin).name,Rule.antecedent(ctin)),...
            sprintf('%s/%d',aMux,ctport));
        ctport = ctport+1;
    end
    % Wire consequents and outputs
    ctport = 1;
    for ctout=find(Rule.consequent),
        add_line(CB,sprintf('%s/%d',fis.output(ctout).name,Rule.consequent(ctout)),...
            sprintf('%s/%d',cMux,ctport));
        add_line(CB,sprintf('%s/%d',cDemux,ctport),...
             sprintf('%s%d/%d',MplxBlock,ctout,mplxport(ctout)));
        ctport = ctport+1;
        mplxport(ctout) = mplxport(ctout)+1;
    end
    % Wire FS outputs
    add_line(CB,[RuleBlock '/2'],sprintf('%s/%d',TFS,ct));
    y0 = y0 + dym1 + dym2 + 30;
end

% Defuzzification stage
x0 = 580;
if isSugeno
   % Sugeno-> library block supporting wtaver and wtsum (inputs = MF values + FS)
   switch lower(fis.defuzzMethod)
   case 'wtsum'
       for ct=1:nout,
           Dest = sprintf('Defuzzification%d',ct);
           add_block('fuzwiz/wtsum Defuzz',sprintf('%s/%s',CB,Dest),...
               'Position',[x0 yout(ct)-15 x0+50 yout(ct)+15]);
           add_line(CB,sprintf('%s%d/1',MplxBlock,ct),[Dest '/1']);
       end
   case 'wtaver'
       for ct=1:nout,
           Dest = sprintf('Defuzzification%d',ct);
           add_block('fuzwiz/wtaver Defuzz',sprintf('%s/%s',CB,Dest),...
               'Position',[x0 yout(ct)-15 x0+50 yout(ct)+15]);
           add_line(CB,sprintf('%s%d/1',MplxBlock,ct),[Dest '/1']);
           add_line(CB,[TFS '/1'],[Dest '/2']);
       end
   end
else
   % Mamdani
   for ct=1:nout,
       Dest = sprintf('Defuzzification%d',ct);
       add_block('fuzwiz/Centroid of Area',sprintf('%s/%s',CB,Dest),...
           'Position',[x0 yout(ct)-15 x0+50 yout(ct)+15],...
           'MaskValues',{sprintf('fis.output(%d).range',ct)});
       % Connect the aggMethod to the defuzz block
       add_line(CB,sprintf('AggMethod%d/1',ct),[Dest '/1']);
   end
end

% Mux outputs
x0 = 650;
add_block('built-in/Mux',sprintf('%s/MuxOut',CB),...
    'ShowName','off','DisplayOption','bar',...
    'Inputs',num2str(nout),'Position',[x0 yout(1)-30 x0+5 yout(nout)+30]);
for ct=1:nout,
    add_line(CB,sprintf('Defuzzification%d/1',ct),sprintf('MuxOut/%d',ct));
end

% Default output values when total firing strength is zero
add_block('built-in/RelationalOperator',[CB,'/Zero Firing Strength?'],...
    'Operator','>','Position',[xytfs+[100,-10],xytfs+[120,20]]);
add_block('built-in/Constant',[CB,'/Zero'],'ShowName','off',...
    'Value','0','Position',[xytfs+[50,40],xytfs+[70,60]]);
add_line(CB,[TFS '/1'],'Zero Firing Strength?/1');
add_line(CB,'Zero/1','Zero Firing Strength?/2');
add_block('built-in/Constant',[CB,'/MidRange'],...
    'Value','mean(cat(1,fis.output.range),2)',...
    'Position',[x0-20 xytfs(2)+60 x0+10 xytfs(2)+80]);

% Construct output
add_block('built-in/Switch',[CB '/Switch'],...
    'Position',[x0+50 xytfs(2)-40 x0+80 xytfs(2)+60],...
    'Threshold','1');
set_param(OutPort,'Position',[x0+120 xytfs(2)+2 x0+140 xytfs(2)+22]);
add_line(CB,'MuxOut/1','Switch/1');
add_line(CB,'Zero Firing Strength?/1','Switch/2');
add_line(CB,'MidRange/1','Switch/3');
add_line(CB,'Switch/1','Out1/1');


%%%%%%%%%%%%%%%%%%%%%%
% LocalCreateInputMF % 
%%%%%%%%%%%%%%%%%%%%%%
function LocalCreateInputMF(CB,fis,j_in)
% Builds subsystem evaluating all MF's for input No. J_IN
% RE: Cannot redraw itself!

% Quick exit if block is uptodate or uninitialized
if isempty(fis) | ~isempty(get_param(CB,'lines'))
    return
end

% Parameters
InputMF = fis.input(j_in).mf;
nmf = length(InputMF);

% Quick exit if no MF (cf. SLBTU)
if nmf==0,
    add_block('built-in/Terminator',[CB '/Term'],'Position',[100 30 120 50]);
    add_line(CB,'In1/1','Term/1');
    return
end

% Check if MF names are unique, override them otherwise
InputMF = LocalCheckMFName(InputMF,sprintf('in%d',j_in));

% Add MF blocks
load_system('fuzblock')
MFLIB = find_system('fuzblock','SearchDepth',1,'MaskType','MF Library');
for ct=1:nmf,
    % Add MF block
    MFblock = find_system(MFLIB{1},'SearchDepth',1,'MaskType',InputMF(ct).type);
    MFblock = MFblock{1};
    Nparams = length(get_param(MFblock,'MaskValues'));
    MaskValues = cell(1,Nparams);
    for ctp = 1:Nparams
        MaskValues{ctp} = sprintf('fis.input(%d).mf(%d).params(%d)',j_in,ct,ctp);
    end
    Dest = sprintf('%s',InputMF(ct).name);
    add_block(MFblock,sprintf('%s/%s',CB,Dest),...
        'Position',[120 55*ct-25 150 55*ct-5],...
        'MaskValues',MaskValues);
    add_line(CB,'In1/1',[Dest '/1']);
    % Add Outport block
    add_block('built-in/Outport',sprintf('%s/Out%d',CB,ct),...
        'Position',[200 55*ct-25 220 55*ct+10]);
    add_line(CB,[Dest '/1'],sprintf('Out%d/1',ct));
end



%%%%%%%%%%%%%%%%%%%%%%%
% LocalCreateOutputMF % 
%%%%%%%%%%%%%%%%%%%%%%%
function LocalCreateOutputMF(CB,fis,j_out)
% Builds subsystem evaluating all MF's for output No. j_out
% RE: Cannot redraw itself!

% Quick exit if block is uptodate or uninitialized
if isempty(fis) | ~isempty(get_param(CB,'lines'))
    return
end

% Parameters
OutputMF = fis.output(j_out).mf;
nmf = length(OutputMF);

% Add Out blocks (one per MF)
for ct=1:nmf,
    add_block('built-in/Outport',sprintf('%s/Out%d',CB,ct),...
        'Position',[280 60*ct-25 300 60*ct-5]);
end

% Check if MF names are unique, override them otherwise
OutputMF = LocalCheckMFName(OutputMF,sprintf('out%d',j_out));

switch lower(fis.type)
case 'mamdani'
    % Mamdani system
    Range = sprintf('linspace(fis.output(%d).range(1),fis.output(%d).range(2),101)',...
        j_out,j_out);
    for ct=1:nmf,
        Params = sprintf('fis.output(%d).mf(%d).params',j_out,ct);
        MFvalue = sprintf('%s(%s,%s)',OutputMF(ct).type,Range,Params);
        Dest = sprintf('%s',OutputMF(ct).name);
        add_block('built-in/Constant',sprintf('%s/%s',CB,Dest),...
            'Position',[150 60*ct-30 180 60*ct],...
            'Value',MFvalue);
        add_line(CB,[Dest '/1'],sprintf('Out%d/1',ct));
    end
    
case 'sugeno'
    % Sugeno system
    nin = length(fis.input);
    % Add input port for linear MF
    if any(strcmpi({OutputMF.type},'linear'))
        add_block('built-in/Inport',sprintf('%s/In1',CB),...
            'Position',[50 100 70 120]);
        load_system('fuzwiz');
    end

    for ct=1:nmf,
        if strcmp(OutputMF(ct).type,'constant')
            Dest = sprintf('%s(Constant)',OutputMF(ct).name);
            Params = sprintf('fis.output(%d).mf(%d).params(1)',j_out,ct);
            add_block('built-in/Constant',sprintf('%s/%s',CB,Dest),...
                'Position',[150 60*ct-30 180 60*ct],...
                'Value',Params);
        else
            Dest = sprintf('%s',OutputMF(ct).name);
            a = sprintf('fis.output(%d).mf(%d).params(1:%d)',j_out,ct,nin);
            b = sprintf('fis.output(%d).mf(%d).params(%d)',j_out,ct,nin+1);
            add_block('fuzwiz/FIS Linear MF',sprintf('%s/%s',CB,Dest),...
                'Position',[150 60*ct-30 200 60*ct],'MaskValues',{a,b});
            add_line(CB,'In1/1',[Dest '/1']);
        end
        add_line(CB,[Dest '/1'],sprintf('Out%d/1',ct));
    end
    
end



%%%%%%%%%%%%%%%%%%%
% LocalCreateRule % 
%%%%%%%%%%%%%%%%%%%
function LocalCreateRule(CB,fis,j_rule)
% Builds subsystem evaluating rule No. J_RULE
% Input ports  = antecedents + consequents (in this order)
% Output ports = firing strength (scalar) + output MF values for consequents
% RE: Cannot redraw itself!

% Quick exit if no fis model
if isempty(fis)
    return
end
Rule = fis.rule(j_rule);

% AND/OR Method
Connection = [CB '/andorMethod'];
Position = get_param(Connection,'Position');
delete_block(Connection);
switch Rule.connection
case 1
    % AND connector
    switch lower(fis.andMethod)
    case 'min'
        add_block('built-in/MinMax',Connection,'Inputs','1',...
            'Function','min','Position',Position);
    case 'prod'
        add_block('built-in/Product',Connection,'Inputs','1','Position',Position);
    end
case 2
    % OR connector
    switch lower(fis.orMethod)
    case 'max'
        add_block('built-in/MinMax',Connection,'Inputs','1',...
            'Function','max','Position',Position);
     case 'probor'
        LocalProborOrMethod(Connection, Position);
    end
end  

% Imply Method
Imply = [CB '/impMethod'];
Position = get_param(Imply,'Position');
delete_block(Imply);
if strcmpi(fis.type,'mamdani') & strcmpi(fis.impMethod,'min')
    add_block('built-in/MinMax',Imply,'Inputs','2',...
        'Function', 'min','Position',Position);
else
    add_block('built-in/Product',Imply,...
        'Inputs','2','Position',Position);
end


%%%%%%%%%%%%%%%%%%%%
% LocalCheckMFName %
%%%%%%%%%%%%%%%%%%%%
function ioMF = LocalCheckMFName(ioMF,iostr)

Names = {ioMF.name};
if length(unique(Names))~=length(Names),
    % Some names are repeated: override all names
    for ct=1:length(Names)
        ioMF(ct).name = sprintf('%smf%d',iostr,ct);
    end
else
    % Replace / by // to make names ADDBLOCK-friendly
    for ct=1:length(Names)
        ioMF(ct).name = strrep(ioMF(ct).name,'/','//');
    end
end
    

%%%%%%%%%%%%%%%%%%%%%%%
% LocalProborOrMethod %
%%%%%%%%%%%%%%%%%%%%%%%
function LocalProborOrMethod(Connection, Position)
% Builds a subsystem to implement the probor 'OR' method
% The block has scalar input and output
% Connection is the path and name of the andorMethod block
% Position is the position of the andorMethod block

% Find the path to the fuzzy block libraries
MFLIB = find_system('fuzblock','SearchDepth',1,'MaskType','MF Library');
proborblock_path = find_system(MFLIB{1},'SearchDepth',1,'MaskType','probor OR method');
proborblock_path = proborblock_path{1};

% Add the probor block and connect it to the inports and outports
add_block(proborblock_path, Connection,'Position',Position);


%%%%%%%%%%%%%%%%%%%%%%%%
% LocalProborAggMethod %
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalProborAggMethod(nconseq, Connection)
% Builds a subsystem to implement the probor rule aggregation method
% The block has vector input and output
% nconseq is the number of rule consequents
% Connection is the path to the probor subsystem

% Find the path to the fuzzy block libraries
MFLIB = find_system('fuzblock','SearchDepth',1,'MaskType','MF Library');
proborblock_path = find_system(MFLIB{1},'SearchDepth',1,'MaskType','probor rule agg method');
proborblock_path = proborblock_path{1};

% Add an inport and outport
add_block('built-in/Inport', [Connection '/In1'], 'Position',  [ 30 82  60 98]);
add_block('built-in/Outport',[Connection '/Out1'], 'Position', [635 82 665 98]);

dx = 0; dy = 0;
if nconseq == 1
    % Only one rule consequent, therefore probor function should just directly output the input
    add_line(Connection, 'In1/1','Out1/1');
else
    % There is more than one rule antecedent/consequent therefore add a demux
    add_block('built-in/Demux',[Connection '/aDemux'],'Outputs',num2str(nconseq),...
        'ShowName','off','Position',[85 60  90 120]);
    add_line(Connection, 'In1/1', 'aDemux/1');
    
    for id = 1 :  nconseq - 1
        add_block(proborblock_path,[Connection sprintf('/Probor Block%i',id)],'Position',[160+dx 65+dy 210+dx 105+dy]);
        if id == 1 
            % The first probor block has both inputs connected to the demux
            for jd = 1:2
                add_line(Connection, sprintf('aDemux/%i',id-1+jd), sprintf('Probor Block%i/%i',id,jd));
            end
        else
            % The other probor blocks, first connect to the previous block then to the demux
            add_line(Connection,sprintf('Probor Block%i/%i',id-1,1), sprintf('Probor Block%i/%i',id,1));
            add_line(Connection,sprintf('aDemux/%i',id-1+jd),        sprintf('Probor Block%i/%i',id,2));
        end
        dx = dx+100; dy = dy+50;
    end
    % Connect the last block to the output port
    add_line(Connection,sprintf('Probor Block%i/1',nconseq - 1), 'Out1/1');
end