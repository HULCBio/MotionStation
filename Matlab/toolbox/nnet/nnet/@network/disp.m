function disp(net)
%DISP Display a neural network's properties.
%
%  Syntax
%
%    disp(net)
%
%  Description
%
%    DISP(NET) displays a network's properties.
%
%  Examples
%
%    Here a perceptron is created and displayed.
%
%      net = newp([-1 1; 0 2],3);
%      disp(net)
%
%  See also DISPLAY, SIM, INIT, TRAIN, ADAPT

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

isLoose = strcmp(get(0,'FormatSpacing'),'loose');

if (isLoose), fprintf('\n'), end
fprintf('    Neural Network object:\n');
if (isLoose), fprintf('\n'), end
fprintf('    architecture:\n');
if (isLoose), fprintf('\n'), end

fprintf('         numInputs: %g\n',net.numInputs);
fprintf('         numLayers: %g\n',net.numLayers);
fprintf('       biasConnect: %s\n',boolstr(net.biasConnect));
fprintf('      inputConnect: %s\n',boolstr(net.inputConnect));
fprintf('      layerConnect: %s\n',boolstr(net.layerConnect));
fprintf('     outputConnect: %s\n',boolstr(net.outputConnect));
fprintf('     targetConnect: %s\n',boolstr(net.targetConnect));
fprintf('\n');
fprintf('        numOutputs: %g  (read-only)\n',net.numOutputs);
fprintf('        numTargets: %g  (read-only)\n',net.numTargets);
fprintf('    numInputDelays: %g  (read-only)\n',net.numInputDelays);
fprintf('    numLayerDelays: %g  (read-only)\n',net.numLayerDelays);

if (isLoose), fprintf('\n'), end

fprintf('    subobject structures:\n');

if (isLoose), fprintf('\n'), end

fprintf('            inputs: {%gx1 cell} of inputs\n',net.numInputs);
fprintf('            layers: {%gx1 cell} of layers\n',net.numLayers);
fprintf('           outputs: {%gx%g cell} containing %s\n',size(net.outputs),nplural(active(net.outputs),'output'));
fprintf('           targets: {%gx%g cell} containing %s\n',size(net.targets),nplural(active(net.targets),'target'));
fprintf('            biases: {%gx%g cell} containing %s\n',size(net.biases),nplural(active(net.biases),'bias'));
fprintf('      inputWeights: {%gx%g cell} containing %s\n',size(net.inputWeights),nplural(active(net.inputWeights),'input weight'));
fprintf('      layerWeights: {%gx%g cell} containing %s\n',size(net.layerWeights),nplural(active(net.layerWeights),'layer weight'));

if (isLoose), fprintf('\n'), end

fprintf('    functions:\n');

if (isLoose), fprintf('\n'), end

fprintf('          adaptFcn: %s\n',functionStr(net.adaptFcn));
fprintf('           initFcn: %s\n',functionStr(net.initFcn));
fprintf('        performFcn: %s\n',functionStr(net.performFcn));
fprintf('          trainFcn: %s\n',functionStr(net.trainFcn));

if (isLoose), fprintf('\n'), end

fprintf('    parameters:\n');

if (isLoose), fprintf('\n'), end

fprintf('        adaptParam: '); parameterStr(net.adaptParam);
fprintf('         initParam: '); parameterStr(net.initParam);
fprintf('      performParam: '); parameterStr(net.performParam);
fprintf('        trainParam: '); parameterStr(net.trainParam);

if (isLoose), fprintf('\n'), end

fprintf('    weight and bias values:\n');

if (isLoose), fprintf('\n'), end

fprintf('                IW: {%gx%g cell} containing %s\n',size(net.inputWeights),nplural(active(net.inputWeights),'input weight matrix'));
fprintf('                LW: {%gx%g cell} containing %s\n',size(net.layerWeights),nplural(active(net.layerWeights),'layer weight matrix'));
fprintf('                 b: {%gx%g cell} containing %s\n',size(net.biases),nplural(active(net.biases),'bias vector'));

if (isLoose), fprintf('\n'), end

fprintf('    other:\n');

if (isLoose), fprintf('\n'), end

fprintf('          userdata: (user stuff)\n');

if (isLoose), fprintf('\n'), end

%====================================================================

function str = plural(n,s)

if n == 1
  str = s;
else
  if s(end) == 's'
    str = [s 'es'];
  elseif s(end) == 'x'
    str = [s(1:(end-1)) 'ces'];
  else
    str = [s 's'];
  end
end

%====================================================================

function str = nplural(n,s)

if n == 0
  str = sprintf('no %s',plural(n,s));
elseif n == 1
  str = sprintf('%g %s',n,s);
else
  str = sprintf('%g %s',n,plural(n,s));
end

%====================================================================

function str = functionStr(s)

if length(s) == 0
  str = '(none)';
else
  str = ['''' s ''''];
end

%====================================================================

function str = parameterStr(s)

if isempty(s)
  fprintf('(none)\n');
  return
end

f = fieldnames(s);
n = length(f);
if n == 1
  fprintf('.%s\n',f{1});
else
  fprintf('.%s',f{1});
  for i=2:n
    fprintf(', ')
    if rem(i,4) == 1
    fprintf('\n                    ')
  end
    fprintf('.%s',f{i});
  end
  fprintf('\n')
end

%====================================================================
function s=boolstr(b)

if prod(size(b)) > 12
  s = sprintf('[%gx%g boolean]',size(b,1),size(b,2));
else
  s = '[';
  for i=1:size(b,1)
    if (i > 1)
    s = [s '; '];
  end
    for j=1:size(b,2)
    if (j > 1)
        s = [s sprintf(' %g',b(i,j))];
      else
        s = [s sprintf('%g',b(i,j))];
    end
    end
  end
  s = [s ']'];
end
  
%====================================================================

