function filename = gentrainrm(net,simfunc,bpfunc)

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $  $Date: 2002/04/14 21:18:39 $

% CALCULATION
% ===========

% Constants
numLayers = net.numLayers;
numInputs = net.numInputs;
numLayerDelays = net.numLayerDelays;
needGradient = net.hint.needGradient;
performFcn = net.performFcn;
if length(performFcn) == 0
  performFcn = 'nullpf';
end
performParam = net.performParam;
dPerformFcn = feval(performFcn,'deriv');

% FILENAME
[filename,name]=newnntempfile;

traincode = ...
  {
  ['function [net,tr,Ac,El]= ' name '(net,Pd,Tl,Ai,Q,TS,VV,TV)']'
  ' '
  '%% Constants';
  'this = ''TRAINR'';';
  'epochs = net.trainParam.epochs;';
  'goal = net.trainParam.goal;';
  'show = net.trainParam.show;';
  'time = net.trainParam.time;';
  ' ';
  '%% Divide Up Batches';
  'Pd_div = batchdiv(Pd,Q);';
  'Tl_div = batchdiv(Tl,Q);';
  'Ai_div = batchdiv(Ai,Q);';
  ' ';
  ['%% Signals'];
  ['gIW = cell(' num2str(net.numLayers) ',' num2str(net.numInputs) ',TS);'];
  ['gLW = cell(' num2str(net.numLayers) ',' num2str(net.numLayers) ',TS);'];
  ['gB = cell(' num2str(net.numLayers) ',1,TS);'];
  ['gA = cell(' num2str(net.numLayers) ',TS);'];
  ['IWLS = cell(' num2str(net.numLayers) ',' num2str(net.numInputs) ');'];
  ['LWLS = cell(' num2str(net.numLayers) ',' num2str(net.numLayers) ');'];
  ['BLS = cell(' num2str(net.numLayers) ',1);'];
  ' ';
  ['%% Initialize'];
  ['flag_stop=0;']
  ['stop = '''';'];
  ['startTime = clock;'];
  ['tr = newtr(epochs,''perf'');'];
  ['X = getx(net);'];
  ['[perf,El,Ac] = ' simfunc '(net,Pd,Ai,Tl,Q,TS);'];
  ' ';
  ['for epoch=0:epochs'];
  ['  '];
  ['  %% Training Record'];
  ['  tr.perf(epoch+1) = perf;'];
  ['  '];
  ['  %% Stopping Criteria'];
  ['  currentTime = etime(clock,startTime);'];
  ['  if (epoch == epochs)'];
  ['    stop = ''Maximum epoch reached.'';'];
  ['  elseif (perf <= goal)'];
  ['    stop = ''Performance goal met.'';'];
  ['  elseif (currentTime > time)'];
  ['    stop = ''Maximum time elapsed.'';'];
  ['  elseif flag_stop'];
  ['    stop = ''User stop.'';'];
  ['  end'];
  ['  '];
  ['  %% Progress'];
  ['  if isfinite(show) & (~rem(epoch,show) | length(stop))'];
  ['    fprintf(''TRAINR'');'];
  ['    if isfinite(epochs) fprintf('', Epoch %%g/%%g'',epoch, epochs); end'];
  ['    if isfinite(time) fprintf('', Time %%g%%%%'',currentTime/time/100); end'];
  ['    fprintf(''\\n'')'];
  ['    if length(stop) fprintf(''TRAINR, %%s\\n\\n'',stop); end'];
  ['    flag_stop=plotperf(tr,goal,this,epoch);'];
  ['  end'];
  ['  if length(stop), break; end'];
  ['  '];
  ['  % Each vector (or sequence of vectors) in order'];
  ['  for q=randperm(Q)'];
  ['    '];
  ['    % Select vectors'];
  ['    Pdq = Pd_div{q};'];
  ['    Tlq = Tl_div{q};'];
  ['    Aiq = Ai_div{q};'];
  ['    '];
  ['    %% Performance'];
  ['    [perfq,Elq,Ac,N,Zl,Zi,Zb] = ' simfunc '(net,Pdq,Aiq,Tlq,1,TS);'];
  ['    X = getx(net);'];
  ['  '];
  };

    if (needGradient)
      line =['    [gB,gIW,gLW,gA] = ' bpfunc '(net,Pdq,Zb,Zi,Zl,N,Ac,Elq,1,TS);'];
      traincode = [traincode; {'    %% Backpropagate'; line; ' '}];
    end

    % Update with Weight and Bias Learning Functions
    line = ['    for ts=1:TS'];
    traincode = [traincode; {line}];

      for i=1:numLayers
        istr = num2str(i);

        traincode = [traincode; {' '; ['    %% Update Layer ' istr]}];

        % Update Input Weight Values
        for j=find(net.inputConnect(i,:))
          jstr = num2str(j);

          learnFcn = net.inputWeights{i,j}.learnFcn;
          if length(learnFcn)
            line = ['    [dw,IWLS{' istr ',' jstr '}] = ' learnFcn '(net.IW{' istr ',' jstr '},' ...
              'Pdq{' istr ',' jstr ',ts},Zi{' istr ',' jstr '},N{' istr '},Ac{' istr ',ts+' ...
               num2str(numLayerDelays) '},Tlq{' istr ',ts},Elq{' istr ',ts},gIW{' istr ',' jstr ',ts},' ...
              'gA{' istr ',ts},net.layers{' istr '}.distances,net.inputWeights{' istr ',' jstr ...
              '}.learnParam,IWLS{' istr ',' jstr '});'];
            traincode = [traincode; {line}];
            line = ['    net.IW{' istr ',' jstr '} = net.IW{' istr ',' jstr '} + dw;'];
            traincode = [traincode; {line}];
          end
        end
  
        % Update Layer Weight Values
        for j=find(net.layerConnect(i,:))
          jstr = num2str(j);
          learnFcn = net.layerWeights{i,j}.learnFcn;
          if length(learnFcn)
            line = ['    Ad = cell2mat(Ac(' jstr ',ts+' num2str(numLayerDelays-net.layerWeights{i,j}.delays) ')'');'];
            traincode = [traincode; {line}];
            line = ['    [dw,LWLS{' istr ',' jstr '}] = ' learnFcn '(net.LW{' istr ',' jstr '},' ...
              'Ad,Zl{' istr ',' jstr '},N{' istr '},Ac{' istr ',ts+' num2str(numLayerDelays) ...
              '},Tlq{' istr ',ts},Elq{' istr ',ts},gLW{' istr ',' jstr ',ts},' ...
              'gA{' istr ',ts},net.layers{' istr '}.distances,net.layerWeights{' istr ',' ...
              jstr '}.learnParam,LWLS{' istr ',' jstr '});'];
            traincode = [traincode; {line}];
            line = ['    net.LW{' istr ',' jstr '} = net.LW{' istr ',' jstr '} + dw;'];
            traincode = [traincode; {line}];
          end
        end

        % Update Bias Values
        if net.biasConnect(i)
          learnFcn = net.biases{i}.learnFcn;
          if length(learnFcn)
            line = ['    [db,BLS{' istr '}] = ' learnFcn '(net.b{' istr '},' ...
              '1,Zb{' istr '},N{' istr '},Ac{' istr ',ts+ ' num2str(numLayerDelays) '},Tlq{' istr ',ts},Elq{' istr ',ts},gB{' istr ',ts},' ...
              'gA{' istr ',ts},net.layers{' istr '}.distances,net.biases{' istr '}.learnParam,BLS{' istr '});'];
            traincode = [traincode; {line}];
            line = ['    net.b{' istr '} = net.b{' istr '} + db;'];
            traincode = [traincode; {line}];
          end
        end
      end

traincode = [ traincode;
  {
  ['  end'];
  ['  '];
  ['  %% Collect errors'];
  ['  for j=1:TS'];
  ['    for i=1:net.numLayers'];
  ['      if ~isempty(El{i,j})'];
  ['        El{i,j}(:,q) = Elq{i,j};'];
  ['      end'];
  ['    end'];
  ['  end'];
  ['  perf = ' performFcn '(El,X,net.performParam);'];
  ['  end'];
  ['end'];
  [' '];
  ['%% Finish'];
  ['[perf,El,Ac] = ' simfunc '(net,Pd,Ai,Tl,Q,TS);'];
  ['tr = cliptr(tr,epoch);'];
  [' '];
  [' '];
  ['%%==============================================================='];
  ['function b_div = batchdiv(b,Q)'];
  [' '];
  ['[rows,cols] = size(b);'];
  ['b_div = cell(1,Q);'];
  ['for q=1:Q'];
  ['  b_div{q} = cell(rows,cols);'];
  ['end'];
  [' '];
  ['for i=1:rows'];
  ['  for j=1:cols'];
  ['    if ~isempty(b{i,j})'];
  ['      for q=1:Q'];
  ['        b_div{q}{i,j} = b{i,j}(:,q);'];
  ['      end'];
  ['    end'];
  ['  end'];
  ['end'];
  }];

% SAVE
addnntemppath;
[fid,message] = fopen(filename,'w');
for i=1:length(traincode)
  fprintf(fid,traincode{i});
  fprintf(fid,'\n');
end
fclose(fid);

