function filename = gentrainsm(net,simfunc,bpfunc)

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.8 $  $Date: 2002/04/14 21:18:42 $

% Constants
numLayers = net.numLayers;
numInputs = net.numInputs;
performFcn = net.performFcn;
if length(performFcn) == 0
  performFcn = 'nullpf';
end
dperformanceFcn = feval(performFcn,'deriv');
needGradient = net.hint.needGradient;
numLayerDelays = net.numLayerDelays;
passes = net.adaptParam.passes;

constantCode = ...
  {
  '%% Constants';
  'passes = net.trainParam.passes;';
  };

%Signals
sigcode = ...
  {
  ['%% Signals'];
  ['BP = ones(1,Q);'];
  ['IWLS = cell(' num2str(net.numLayers) ',' num2str(net.numInputs) ');'];
  ['LWLS = cell(' num2str(net.numLayers) ',' num2str(net.numLayers) ');'];
  ['BLS = cell(' num2str(net.numLayers) ',1);'];
  ['Ac = [Ai cell(' num2str(net.numLayers) ',TS)];'];
  ['El = cell(' num2str(net.numLayers) ',TS);'];
  ['gIW = cell(' num2str(net.numLayers) ',' num2str(net.numInputs) ');'];
  ['gLW = cell(' num2str(net.numLayers) ',' num2str(net.numLayers) ');'];
  ['gB = cell(' num2str(net.numLayers) ',1);'];
  ['gA = cell(' num2str(net.numLayers) ',1);'];
  ['AiInd = ' mat2str(0:(numLayerDelays-1)) ';'];
  ['AcInd = ' mat2str(0:numLayerDelays) ';'];
  };

% Initialize
initcode = ...
  {
  '%% Initialize';
  'tr.timesteps = 1:TS;'
  'tr.perf = zeros(1,TS);'
  };

% Train
traincode = {};
line = 'for pass=1:passes,for ts=1:TS';
traincode = [traincode; {line}];
  
    % Simulate
    line = ['  PDts = PD(:,:,ts);'];
    traincode = [traincode; {line}];
    line = ['  [perf,El(:,ts),Ac(:,ts+AcInd),N,LWZ,IWZ,BZ] = ' simfunc ...
       '(net,PDts,Ac(:,ts+AiInd),Tl(:,ts),Q,1);'];
    traincode = [traincode; {line}];
    line = ['  tr.perf(ts) = perf;']; % performFcn '(El(:,ts),net);'];
    traincode = [traincode; {line}];
  
    % Gradient
    if (needGradient)
      line = ['  [gB,gIW,gLW,gA] = ' bpfunc '(net,PDts,BZ,IWZ,LWZ,N,Ac(:,ts+AcInd),El(:,ts),Q,1);'];
      traincode = [traincode; {line}];
    end
  
    % Update
    for i=1:net.numLayers
      istr = num2str(i);

      % Layer title
      traincode = [traincode; {' '}];
      line = ['  %% Update Layer ' istr];
      traincode = [traincode; {line}];
  
      % Update Input Weight Values
      for j=find(net.inputConnect(i,:))
          jstr = num2str(j);
          learnFcn = net.inputWeights{i,j}.learnFcn;
        if length(learnFcn)
          line = ['  [dw,IWLS{' istr ',' jstr '}] = ' learnFcn '(net.IW{' istr ',' jstr '},' ...
            'PD{' istr ',' jstr ',ts},IWZ{' istr ',' jstr '},N{' istr '},Ac{' istr ',ts+' ...
            num2str(numLayerDelays) '},Tl{' istr ',ts},El{' istr ',ts},gIW{' istr ',' jstr '},'...
            'gA{' istr '},net.layers{' istr '}.distances,net.inputWeights{' istr ',' ...
            jstr '}.learnParam,IWLS{' istr ',' jstr '});'];
          traincode = [traincode; {line}];
          line = ['  net.IW{' istr ',' jstr '} = net.IW{' istr ',' jstr '} + dw;'];
          traincode = [traincode; {line}];
        end
      end
  
      % Update Layer Weight Values
      for j=find(net.layerConnect(i,:))
          jstr = num2str(j);
          learnFcn = net.layerWeights{i,j}.learnFcn;
        if length(learnFcn)
          line = ['  Ad = cell2mat(Ac(' jstr ',ts+' ...
            mat2str(numLayerDelays-net.layerWeights{i,j}.delays) ')'');'];
          traincode = [traincode; {line}];
          line = ['  [dw,LWLS{' istr ',' jstr '}] = ' learnFcn '(net.LW{' istr ',' jstr '},' ...
            'Ad,LWZ{' istr ',' jstr '},N{' istr '},Ac{' istr ',ts+' num2str(numLayerDelays) ...
            '},Tl{' istr ',ts},El{' istr ',ts},gLW{' istr ',' jstr '},'...
            'gA{' istr '},net.layers{' istr '}.distances,net.layerWeights{' istr ...
            ',' jstr '}.learnParam,LWLS{' istr ',' jstr '});'];
          traincode = [traincode; {line}];
          line = ['  net.LW{' istr ',' jstr '} = net.LW{' istr ',' jstr '} + dw;'];
          traincode = [traincode; {line}];
        end
      end
  
      % Update Bias Values
      if net.biasConnect(i)
         learnFcn = net.biases{i}.learnFcn;
        if length(learnFcn)
          line = ['  [db,BLS{' istr '}] = ' learnFcn '(net.b{' istr '},' ...
            'BP,BZ{' istr '},N{' istr '},Ac{' istr ',ts+ ' num2str(numLayerDelays) ...
            '},Tl{' istr ',ts},El{' istr ',ts},gB{' istr '},'...
            'gA{' istr '},net.layers{' istr '}.distances,net.biases{' istr '}.learnParam,BLS{' istr '});'];
          traincode = [traincode; {line}];
          line = ['  net.b{' istr '} = net.b{' istr '} + db;'];
          traincode = [traincode; {line}];
        end
      end
    end


line = 'end, end';
traincode = [traincode; {line}];

% Finish
line = ['tr.timesteps = TS;'];
traincode = [traincode; {line}];

% FILENAME
[filename,name]=newnntempfile;

% COMBINE CODE
code = ...
  [
  {['function [net,tr,Ac,El]= ' name '(net,PD,Tl,Ai,Q,TS,VV,TV)']};
  {' '};
  constantCode;
  {' '};
  sigcode;
  {' '};
  initcode;
  {' '};
  traincode;
  {' '};
  ];

% SAVE
addnntemppath;
[fid,message] = fopen(filename,'w');
for i=1:length(code)
  fprintf(fid,code{i});
  fprintf(fid,'\n');
  %fprintf(code{i});
  %fprintf('\n');
end
fclose(fid);

