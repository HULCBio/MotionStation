function net=subsasgn(net,subscripts,v)
%SUBSASGN Assign fields of a neural network.

% Mark Beale, 11-31-97
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.14 $ $ Date: $

% Assume no error
err = '';

% First subscript
[subscripts,field,type,moresubs] = nextsubs(subscripts);

switch type

case '.'
  field = matchstring(field,fieldnames(net));
  
  switch(field)
  
  % Network architecture
  case 'numInputs',
    [numInputs,err] = nsubsasn(net.numInputs,subscripts,v);
  if length(err), error(err), end
    [net,err]=setNumInputs(net,numInputs);
  net.hint.ok = 0;
  case 'numLayers',
    [numLayers,err] = nsubsasn(net.numLayers,subscripts,v);
  if length(err), error(err), end
    [net,err]=setNumLayers(net,numLayers);
  case 'numOutputs',
    error('"numOutputs" is a read only property.')
  case 'numTargets',
    error('"numTargets" is a read only property.')
  case 'numInputDelays',
    error('"numInputDelays" is a read only property.')
  case 'numLayerDelays',
    error('"numLayerDelays" is a read only property.')
  case 'biasConnect',
    [biasConnect,err] = nsubsasn(net.biasConnect,subscripts,v);
  if length(err), error(err), end
    [net,err]=setBiasConnect(net,biasConnect);
  net.hint.ok = 0;
  case 'inputConnect',
    [inputConnect,err] = nsubsasn(net.inputConnect,subscripts,v);
  if length(err), error(err), end
    [net,err]=setInputConnect(net,inputConnect);
  net.hint.ok = 0;
  case 'layerConnect',
    [layerConnect,err] = nsubsasn(net.layerConnect,subscripts,v);
  if length(err), error(err), end
    [net,err]=setLayerConnect(net,layerConnect);
  net.hint.ok = 0;
  case 'outputConnect',
    [outputConnect,err] = nsubsasn(net.outputConnect,subscripts,v);
  if length(err), error(err), end
    [net,err]=setOutputConnect(net,outputConnect);
  net.hint.ok = 0;
  case 'targetConnect',
    [targetConnect,err] = nsubsasn(net.targetConnect,subscripts,v);
  if length(err), error(err), end
    [net,err]=setTargetConnect(net,targetConnect);
  net.hint.ok = 0;

  % Inputs
  case 'inputs',
    if ~moresubs, error('You must assign to subobject properties individually.'), end
    [subscripts,subs,type,moresubs] = nextsubs(subscripts);
  if strcmp(type,'.'), error('Attempt to assign field of non-structure array'), end
  if strcmp(type,'()'), error('Attempt to assign cell array as a double array'), end
    if ~moresubs, error('You must assign to subobject properties individually.'), end
  [sub1,err] = subs1(subs,[net.numInputs 1]);
  if length(err), error(err), end

    [subscripts,field,type,moresubs] = nextsubs(subscripts);
    if strcmp(type,'{}'),error('Cell contents assignment to a non-cell array object.'),end
    if strcmp(type,'()'),error('Array contents assignment to a non-array object.'),end
    field = matchfield(field,nninput);
  
  for i=sub1,
      switch(field)
    case 'range'
        [range,err] = nsubsasn(net.inputs{i}.range,subscripts,v);
      if length(err), error(err), end
      [net,err] = setInputRange(net,i,range);
      net.hint.ok = 0;
    case 'size'
        [newSize,err] = nsubsasn(net.inputs{i}.size,subscripts,v);
      if length(err), error(err), end
      [net,err] = setInputSize(net,i,newSize);
      net.hint.ok = 0;
      case 'userdata',
        [net.inputs{i}.userdata,err] = nsubsasn(net.inputs{i}.userdata,subscripts,v);
    otherwise,
      error('Reference to non-existent field.')
    end
  end
    
  % Layers
  case 'layers',
    if ~moresubs, error('You must assign to subobject properties individually.'), end
    [subscripts,subs,type,moresubs] = nextsubs(subscripts);
  if strcmp(type,'.'), error('Attempt to assign field of non-structure array'), end
  if strcmp(type,'()'), error('Attempt to assign cell array as a double array'), end
    if ~moresubs, error('You must assign to subobject properties individually.'), end
  [sub1,err] = subs1(subs,[net.numLayers 1]);
  if length(err), error(err), end

    [subscripts,field,type,moresubs] = nextsubs(subscripts);
    if strcmp(type,'{}'),error('Cell contents assignment to a non-cell array object.'),end
    if strcmp(type,'()'),,error('Array contents assignment to a non-array object.'),end
    field = matchfield(field,nnlayer);
  
  for i=sub1,
      switch(field)
    case 'dimensions'
        [newDimensions,err] = nsubsasn(net.layers{i}.dimensions,subscripts,v);
      if length(err), error(err), end
      [net,err] = setLayerDimensions(net,i,newDimensions);
      net.hint.ok = 0;
    case 'distanceFcn'
        [distanceFcn,err] = nsubsasn(net.layers{i}.distanceFcn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setLayerDistanceFcn(net,i,distanceFcn);
      net.hint.ok = 0;
    case 'distances',
        error('"net.layers{i}.distances" is a read only property.')
    case 'initFcn'
        [initFcn,err] = nsubsasn(net.layers{i}.initFcn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setLayerInitFcn(net,i,initFcn);
      net.hint.ok = 0;
    case 'netInputFcn'
        [netInputFcn,err] = nsubsasn(net.layers{i}.netInputFcn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setLayerNetInputFcn(net,i,netInputFcn);
      net.hint.ok = 0;
    case 'positions',
        error('"net.layers{i}.distances" is a read only property.')
    case 'size'
        [newSize,err] = nsubsasn(net.layers{i}.size,subscripts,v);
      if length(err), error(err), end
      [net,err] = setLayerSize(net,i,newSize);
      net.hint.ok = 0;
    case 'topologyFcn'
        [topologyFcn,err] = nsubsasn(net.layers{i}.topologyFcn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setLayerTopologyFcn(net,i,topologyFcn);
      net.hint.ok = 0;
    case 'transferFcn'
        [transferFcn,err] = nsubsasn(net.layers{i}.transferFcn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setLayerTransferFcn(net,i,transferFcn);
      net.hint.ok = 0;
      case 'userdata',
        [net.layers{i}.userdata,err] = nsubsasn(net.layers{i}.userdata,subscripts,v);
    otherwise,
      error('Reference to non-existent field.')
    end
  end
  
  % Biases
  case 'biases',
    if ~moresubs, error('You must assign to subobject properties individually.'), end
    [subscripts,subs,type,moresubs] = nextsubs(subscripts);
  if strcmp(type,'.'), error('Attempt to assign field of non-structure array'), end
  if strcmp(type,'()'), error('Attempt to assign cell array as a double array'), end
    if ~moresubs, error('You must assign to subobject properties individually.'), end
    [sub1,err] = subs1(subs,[net.numLayers 1]);
  if length(err), error(err), end

    [subscripts,field,type,moresubs] = nextsubs(subscripts);
    if strcmp(type,'{}'),error('Cell contents assignment to a non-cell array object.'),end
    if strcmp(type,'()'),,error('Array contents assignment to a non-array object.'),end
    field = matchfield(field,nnoutput);
  
  for i=sub1
    if ~isempty(net.biases{i}), switch(field)
    case 'initFcn'
        [initFcn,err] = nsubsasn(net.biases{i}.initFcn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setBiasInitFcn(net,i,initFcn);
      net.hint.ok = 0;
    case 'learn'
        [learn,err] = nsubsasn(net.biases{i}.learn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setBiasLearn(net,i,learn);
      net.hint.ok = 0;
    case 'learnFcn'
        [learnFcn,err] = nsubsasn(net.biases{i}.learnFcn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setBiasLearnFcn(net,i,learnFcn);
      net.hint.ok = 0;
    case 'learnParam'
        [learnParam,err] = nsubsasn(net.biases{i}.learnParam,subscripts,v);
      if length(err), error(err), end
      [net,err] = setBiasLearnParam(net,i,learnParam);
    case 'size'
        error('"net.biases{i}.size" is a read only property.')
      case 'userdata',
        [net.biases{i}.userdata,err] = nsubsasn(net.biases{i}.userdata,subscripts,v);
    otherwise,
      error('Reference to non-existent field.')
    end, end
  end

  % Input weights
  case 'inputWeights',
    if ~moresubs, error('You must assign to subobject properties individually.'), end
    [subscripts,subs,type,moresubs] = nextsubs(subscripts);
  if strcmp(type,'.'), error('Attempt to assign field of non-structure array'), end
  if strcmp(type,'()'), error('Attempt to assign cell array as a double array'), end
    if ~moresubs, error('You must assign to subobject properties individually.'), end
    [sub1,sub2,err] = subs2(subs,[net.numLayers net.numInputs]);
  if length(err), error(err), end

    [subscripts,field,type,moresubs] = nextsubs(subscripts);
    if strcmp(type,'{}'),error('Cell contents assignment to a non-cell array object.'),end
    if strcmp(type,'()'),,error('Array contents assignment to a non-array object.'),end
    field = matchfield(field,nnweight);

  for k=1:length(sub1)
    i = sub1(k);
    j = sub2(k);
    if ~isempty(net.inputWeights{i,j}), switch(field)
    case 'delays'
        [delays,err] = nsubsasn(net.inputWeights{i,j}.delays,subscripts,v);
      if length(err), error(err), end
      [net,err] = setInputWeightDelays(net,i,j,delays);
      net.hint.ok = 0;
    case 'initFcn'
        [initFcn,err] = nsubsasn(net.inputWeights{i,j}.initFcn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setInputWeightInitFcn(net,i,j,initFcn);
      net.hint.ok = 0;
    case 'learn'
        [learn,err] = nsubsasn(net.inputWeights{i,j}.learn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setInputWeightLearn(net,i,j,learn);
      net.hint.ok = 0;
    case 'learnFcn'
        [learnFcn,err] = nsubsasn(net.inputWeights{i,j}.learnFcn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setInputWeightLearnFcn(net,i,j,learnFcn);
      net.hint.ok = 0;
    case 'learnParam'
        [learnParam,err] = nsubsasn(net.inputWeights{i,j}.learnParam,subscripts,v);
      if length(err), error(err), end
      [net,err] = setInputWeightLearnParam(net,i,j,learnParam);
    case 'size'
        error('"net.inputWeights{i,j}.size" is a read only property.')
      case 'userdata',
        [net.inputWeights{i,j}.userdata,err] = nsubsasn(net.inputWeights{i,j}.userdata,subscripts,v);
    case 'weightFcn'
        [weightFcn,err] = nsubsasn(net.inputWeights{i,j}.weightFcn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setInputWeightWeightFcn(net,i,j,weightFcn);
      net.hint.ok = 0;
    otherwise,
      error('Reference to non-existent field.')
    end, end
  end  

  % Layer weights
  case 'layerWeights',
    if ~moresubs, error('You must assign to subobject properties individually.'), end
    [subscripts,subs,type,moresubs] = nextsubs(subscripts);
  if strcmp(type,'.'), error('Attempt to assign field of non-structure array'), end
  if strcmp(type,'()'), error('Attempt to assign cell array as a double array'), end
    if ~moresubs, error('You must assign to subobject properties individually.'), end
    [sub1,sub2,err] = subs2(subs,[net.numLayers net.numLayers]);
  if length(err), error(err), end

    [subscripts,field,type,moresubs] = nextsubs(subscripts);
    if strcmp(type,'{}'),error('Cell contents assignment to a non-cell array object.'),end
    if strcmp(type,'()'),,error('Array contents assignment to a non-array object.'),end
    field = matchfield(field,nnweight);

  for k=1:length(sub1)
    i = sub1(k);
    j = sub2(k);
    if ~isempty(net.layerWeights{i,j}), switch(field)
    case 'delays'
        [delays,err] = nsubsasn(net.layerWeights{i,j}.delays,subscripts,v);
      if length(err), error(err), end
      [net,err] = setLayerWeightDelays(net,i,j,delays);
      net.hint.ok = 0;
    case 'initFcn'
        [initFcn,err] = nsubsasn(net.layerWeights{i,j}.initFcn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setLayerWeightInitFcn(net,i,j,initFcn);
      net.hint.ok = 0;
    case 'learn'
        [learn,err] = nsubsasn(net.layerWeights{i,j}.learn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setLayerWeightLearn(net,i,j,learn);
      net.hint.ok = 0;
    case 'learnFcn'
        [learnFcn,err] = nsubsasn(net.layerWeights{i,j}.learnFcn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setLayerWeightLearnFcn(net,i,j,learnFcn);
      net.hint.ok = 0;
    case 'learnParam'
        [learnParam,err] = nsubsasn(net.layerWeights{i,j}.learnParam,subscripts,v);
      if length(err), error(err), end
      [net,err] = setLayerWeightLearnParam(net,i,j,learnParam);
      net.hint.ok = 0;
    case 'size'
        error('"net.layerWeights{i,j}.size" is a read only property.')
      case 'userdata',
        [net.layerWeights{i,j}.userdata,err] = nsubsasn(net.layerWeights{i,j}.userdata,subscripts,v);
    case 'weightFcn'
        [weightFcn,err] = nsubsasn(net.layerWeights{i,j}.weightFcn,subscripts,v);
      if length(err), error(err), end
      [net,err] = setLayerWeightWeightFcn(net,i,j,weightFcn);
      net.hint.ok = 0;
    otherwise,
      error('Reference to non-existent field.')
    end, end
  end  
  
  % Outputs
  case 'outputs',
    if ~moresubs, error('You must assign to subobject properties individually.'), end
    [subscripts,subs,type,moresubs] = nextsubs(subscripts);
  if strcmp(type,'.'), error('Attempt to assign field of non-structure array'), end
  if strcmp(type,'()'), error('Attempt to assign cell array as a double array'), end
    if ~moresubs, error('You must assign to subobject properties individually.'), end
    [sub1,err] = subs1(subs,[net.numLayers 1]);
  if length(err), error(err), end

    [subscripts,field,type,moresubs] = nextsubs(subscripts);
    if strcmp(type,'{}'),error('Cell contents assignment to a non-cell array object.'),end
    if strcmp(type,'()'),,error('Array contents assignment to a non-array object.'),end
    field = matchfield(field,nnoutput);
  
  for i=sub1
    if ~isempty(net.outputs{i}), switch(field)
    case 'size'
        error('"net.outputs{i}.size" is a read only property.')
      case 'userdata',
        [net.outputs{i}.userdata,err] = nsubsasn(net.outputs{i}.userdata,subscripts,v);
    
    otherwise,
      error('Reference to non-existent field.')
    end, end
  end  
  
  % Targets
  case 'targets',
    if ~moresubs, error('You must assign to subobject properties individually.'), end
    [subscripts,subs,type,moresubs] = nextsubs(subscripts);
  if strcmp(type,'.'), error('Attempt to assign field of non-structure array'), end
  if strcmp(type,'()'), error('Attempt to assign cell array as a double array'), end
    if ~moresubs, error('You must assign to subobject properties individually.'), end
    [sub1,err] = subs1(subs,[net.numLayers 1]);
  if length(err), error(err), end

    [subscripts,field,type,moresubs] = nextsubs(subscripts);
    if strcmp(type,'{}'),error('Cell contents assignment to a non-cell array object.'),end
    if strcmp(type,'()'),,error('Array contents assignment to a non-array object.'),end
    field = matchfield(field,nnoutput);
  
  for i=sub1
    if ~isempty(net.outputs{i}), switch(field)
    case 'size'
        error('"net.targets{i}.size" is a read only property.')
      case 'userdata',
        [net.targets{i}.userdata,err] = nsubsasn(net.targets{i}.userdata,subscripts,v);
    
    otherwise,
      error('Reference to non-existent field.')
    end, end
  end  
  
  % Network functions and parameters
  case 'adaptFcn',
    [adaptFcn,err] = nsubsasn(net.adaptFcn,subscripts,v);
  if length(err), error(err), end
    [net,err]=setAdaptFcn(net,adaptFcn);
  case 'adaptParam',
    [adaptParam,err] = nsubsasn(net.adaptParam,subscripts,v);
  if length(err), error(err), end
    [net,err]=setAdaptParam(net,adaptParam);
  case 'initFcn',
    [initFcn,err] = nsubsasn(net.initFcn,subscripts,v);
  if length(err), error(err), end
    [net,err]=setInitFcn(net,initFcn);
      net.hint.ok = 0;
  case 'initParam',
    [initParam,err] = nsubsasn(net.initParam,subscripts,v);
  if length(err), error(err), end
    [net,err]=setInitParam(net,initParam);
  case 'performFcn',
    [performFcn,err] = nsubsasn(net.performFcn,subscripts,v);
  if length(err), error(err), end
    [net,err]=setPerformFcn(net,performFcn);
  case 'performParam',
    [performParam,err] = nsubsasn(net.performParam,subscripts,v);
  if length(err), error(err), end
    [net,err]=setPerformParam(net,performParam);
  case 'trainFcn',
    [trainFcn,err] = nsubsasn(net.trainFcn,subscripts,v);
  if length(err), error(err), end
    [net,err]=setTrainFcn(net,trainFcn);
  case 'trainParam',
    [trainParam,err] = nsubsasn(net.trainParam,subscripts,v);
  if length(err), error(err), end
    [net,err]=setTrainParam(net,trainParam);

  % Weight and bias values
  case 'IW'
    [IW,err] = nsubsasn(net.IW,subscripts,v);
  if length(err), error(err), end
  [net,err] = setiw(net,IW);
  case 'LW'
    [LW,err] = nsubsasn(net.LW,subscripts,v);
  if length(err), error(err), end
  [net,err] = setlw(net,LW);
  case 'b'
    [B,err] = nsubsasn(net.b,subscripts,v);
  if length(err), error(err), end
  [net,err] = setb(net,B);
  
  % other
  case 'userdata',
    [net.userdata,err] = nsubsasn(net.userdata,subscripts,v);

  otherwise, error('Reference to non-existent field.');
  end
  
case '{}',error('Cell contents assignment to a non-cell array object.')
case '()',error('Array contents assignment to a non-array object.')
end

% Read only values
net.numOutputs = sum(net.outputConnect);
net.numTargets = sum(net.targetConnect);
net.numInputDelays = 0;
for i=1:net.numLayers
  for j=find(net.inputConnect(i,:))
    net.numInputDelays = max([net.numInputDelays net.inputWeights{i,j}.delays]);
  end
end
net.numLayerDelays = 0;
for i=1:net.numLayers
  for j=find(net.layerConnect(i,:))
    net.numLayerDelays = max([net.numLayerDelays net.layerWeights{i,j}.delays]);
  end
end
for i=1:net.numLayers
  net.layers{i}.positions = feval(net.layers{i}.topologyFcn,net.layers{i}.dimensions);
  if length(net.layers{i}.distanceFcn) > 0
    net.layers{i}.distances = feval(net.layers{i}.distanceFcn,net.layers{i}.positions);
  else
    net.layers{i}.distances = [];
  end
end

% Error message
if length(err), error(err), end

% % Update hints if not OK and UPDATE is on
if ~net.hint.ok
  net = hint(net);
end

% ===========================================================
%                          WEIGHT AND BIAS VALUES
% ===========================================================
function [net,err] = setiw(net,IW)

err = '';

if ~isa(IW,'cell')
  err = sprintf('net.IW must be a %g-by-%g cell array.',net.numLayers,net.numInputs);
  return
end
if any(size(IW) ~= [net.numLayers net.numInputs])
  err = sprintf('net.IW must be a %g-by-%g cell array.',net.numLayers,net.numInputs);
  return
end
for i=1:net.numLayers
  for j=1:net.numInputs
    if ~isa(IW{i,j},'double')
      if (net.inputConnect(i,j))
        err = sprintf('net.IW{%g,%g} must be a %g-by-%g matrix.',i,j,net.inputWeights{i,j}.size);
    return
      else
        err = sprintf('net.IW{%g,%g} must be an empty matrix.',i,j,net.inputWeights{i,j}.size);
    return
      end
    end
  if net.inputConnect(i,j)
      if any(size(IW{i,j}) ~= net.inputWeights{i,j}.size)
        err = sprintf('net.IW{%g,%g} must be a %g-by-%g matrix.',i,j,net.inputWeights{i,j}.size);
    return
      end
      net.IW{i,j} = IW{i,j};
    else
      if prod(size(IW{i,j})) ~= 0
      err = sprintf('net.IW{%g,%g} must be an empty matrix.',i,j);
    return
      end
    end
  end
end

% ===========================================================
function [net,err] = setlw(net,LW)

err = '';

if ~isa(LW,'cell')
  err = sprintf('net.LW must be a %g-by-%g cell array.',net.numLayers,net.numLayers);
  return
end
if any(size(LW) ~= [net.numLayers net.numLayers])
  err = sprintf('net.LW must be a %g-by-%g cell array.',net.numLayers,net.numLayers);
  return
end
for i=1:net.numLayers
  for j=1:net.numLayers
    if ~isa(LW{i,j},'double') & ~islogical(LW{i,j})
      if (net.layerConnect(i,j))
        err = sprintf('net.LW{%g,%g} must be a %g-by-%g matrix.',i,j,net.layerWeights{i,j}.size);
    return
      else
        err = sprintf('net.LW{%g,%g} must be an empty matrix.',i,j,net.layerWeights{i,j}.size);
    return
      end
    end
  if net.layerConnect(i,j)
      if any(size(LW{i,j}) ~= net.layerWeights{i,j}.size)
        err = sprintf('net.LW{%g,%g} must be a %g-by-%g matrix.',i,j,net.layerWeights{i,j}.size);
    return
      end
      net.LW{i,j} = LW{i,j};
    else
      if prod(size(LW{i,j})) ~= 0
      err = sprintf('net.LW{%g,%g} must be an empty matrix.',i,j);
    return
      end
    end
  end
end

% ===========================================================
function [net,err] = setb(net,B)

err = '';

if ~isa(B,'cell')
  err = sprintf('net.b must be a %g-by-1 cell array.',net.numLayers);
  return
end
if any(size(B) ~= [net.numLayers 1])
  err = sprintf('net.b must be a %g-by-1 cell array.',net.numLayers);
  return
end
for i=1:net.numLayers
    if ~isa(B{i},'double')
      if (net.biasConnect(i))
        err = sprintf('net.b{%g} must be a %g-by-1 matrix.',i,net.biases{i}.size);
    return
      else
        err = sprintf('net.b{%g} must be an empty matrix.',i,net.biases{i}.size);
    return
      end
    end
  if net.biasConnect(i)
      if any(size(B{i}) ~= [net.biases{i}.size 1])
        err = sprintf('net.b{%g} must be a %g-by-1 matrix.',i,net.biases{i}.size);
    return
      end
      net.b{i} = B{i};
    else
      if prod(size(B{i})) ~= 0
      err = sprintf('net.b{%g} must be an empty matrix.',i);
    return
      end
    end
end

% ===========================================================
%                          ARCHITECTURE
% ===========================================================
function [net,err] = setNumInputs(net,numInputs)

err = '';
if ~isposint(numInputs)
  err = '"numInputs" must be a positive integer or zero.';
  return
end

if (numInputs < net.numInputs)

  keep = 1:numInputs;
  net.inputs = net.inputs(keep);
  
  net.inputConnect = net.inputConnect(:,keep);
  net.inputWeights = net.inputWeights(:,keep);
  
  net.IW = net.IW(:,keep);
  
elseif (numInputs > net.numInputs)
  Input = {nninput};
  extend = numInputs - net.numInputs;
  net.inputs = [net.inputs; Input(ones(extend,1))];
  
  net.inputConnect = [net.inputConnect zeros(net.numLayers,extend)];
  net.inputWeights = [net.inputWeights cell(net.numLayers,extend)];
  
  net.IW = [net.IW cell(net.numLayers,extend)];
end

net.numInputs = numInputs;

% ===========================================================
function [net,err] = setNumLayers(net,numLayers)

err = '';
if ~isposint(numLayers)
  err = '"numLayers" must be a positive integer or zero.';
  return
end

if (numLayers < net.numLayers)

  keep = 1:numLayers;
  net.layers = net.layers(keep);
  
  net.biasConnect = net.biasConnect(keep,1);
  net.inputConnect = net.inputConnect(keep,:);
  net.layerConnect = net.layerConnect(keep,keep);
  net.outputConnect = net.outputConnect(1,keep);
  net.targetConnect = net.outputConnect(1,keep);

  net.biases = net.biases(keep,1);
  net.inputWeights = net.inputWeights(keep,:);
  net.layerWeights = net.layerWeights(keep,keep);
  net.outputs = net.outputs(1,keep);
  net.targets = net.targets(1,keep);
  
  net.b = net.b(1:numLayers,1);
  net.IW = net.IW(keep,:);
  net.LW = net.LW(keep,keep);
  
elseif (numLayers > net.numLayers)

  Layer = {nnlayer};
  extend = numLayers-net.numLayers;
  net.layers = [net.layers; Layer(ones(extend,1))];
  
  net.biasConnect = [net.biasConnect; zeros(extend,1)];
  net.inputConnect = [net.inputConnect; zeros(extend,net.numInputs)];
  net.layerConnect = [net.layerConnect zeros(net.numLayers,extend); zeros(extend,numLayers)];
  net.outputConnect = [net.outputConnect zeros(1,extend)];
  net.targetConnect = [net.targetConnect zeros(1,extend)];
  
  net.biases = [net.biases; cell(extend,1)];
  net.inputWeights = [net.inputWeights; cell(extend,net.numInputs)];
  net.layerWeights = [net.layerWeights cell(net.numLayers,extend); cell(extend,numLayers)];
  net.outputs = [net.outputs cell(1,extend)];
  net.targets = [net.targets cell(1,extend)];
  
  net.b = [net.b; cell(extend,1)];
  net.IW = [net.IW; cell(extend,net.numInputs)];
  net.LW = [net.LW cell(net.numLayers,extend); cell(extend,numLayers)];
end

net.numLayers = numLayers;

% ===========================================================
function [net,err] = setBiasConnect(net,biasConnect)

err = '';
if ~isbool(biasConnect,net.numLayers,1);
  err = sprintf('"biasConnect" must be a %gx1 boolean matrix.',net.numLayers);
  return
end

for i=findne(net.biasConnect,biasConnect)'
  if biasConnect(i) == 1
    net.biases{i} = nnbias;
    net.biases{i}.size = net.layers{i}.size;
  net.b{i} = zeros(net.layers{i}.size,1);
  else
    net.biases{i} = [];
  net.b{i} = [];
  end
end

net.biasConnect = biasConnect;

% Invalidate Hints
net.hint.ok = 0;

% ===========================================================
function [net,err] = setInputConnect(net,inputConnect)

% Check value
err = '';
if ~isbool(inputConnect,net.numLayers,net.numInputs);
  err = sprintf('"inputConnect" must be a %gx%g boolean matrix.',net.numLayers,net.numInputs);
  return
end

% Add and remove weights
for i=1:net.numLayers
  for j=findne(inputConnect(i,:),net.inputConnect(i,:))
    if inputConnect(i,j)
    net.inputWeights{i,j} = nnweight;
    rows = net.layers{i}.size;
      cols = net.inputs{j}.size * length(net.inputWeights{i,j}.delays);
      net.inputWeights{i,j}.size = [rows cols];
      net.IW{i,j} = zeros(rows,cols);
    else
    net.inputWeights{i,j} = [];
    net.IW{i,j} = [];
  end
  
  end
end

% Change input connect
net.inputConnect = inputConnect;

% ===========================================================
function [net,err] = setLayerConnect(net,layerConnect)

err = '';
if ~isbool(layerConnect,net.numLayers,net.numLayers);
  err = sprintf('"layerConnect" must be a %gx%g boolean matrix.',net.numLayers,net.numLayers);
  return
end

% Add and remove weights
for i=1:net.numLayers
  for j=findne(layerConnect(i,:),net.layerConnect(i,:))
  
  if layerConnect(i,j)
      net.layerWeights{i,j} = nnweight;
    rows = net.layers{i}.size;
    cols = net.layers{j}.size * length(net.layerWeights{i,j}.delays);
    net.layerWeights{i,j}.size = [rows cols];
    net.LW{i,j} = zeros(rows,cols);
  else
   net.layerWeights{i,j} = [];
   net.LW{i,j} = [];
  end
  
  end
end

% Change layer connect
net.layerConnect = layerConnect;

% ===========================================================
function [net,err] = setOutputConnect(net,outputConnect)

err = '';
if ~isbool(outputConnect,1,net.numLayers);
  err = sprintf('"outputConnect" must be a 1x%g boolean matrix.',net.numLayers);
  return
end

for i=findne(net.outputConnect,outputConnect)
  if outputConnect(i) == 1
    net.outputs{i} = nnoutput;
    net.outputs{i}.size = net.layers{i}.size;
  else
    net.outputs{i} = [];
  end
end

net.outputConnect = outputConnect;

% ===========================================================
function [net,err] = setTargetConnect(net,targetConnect)

err = '';
if ~isbool(targetConnect,1,net.numLayers);
  err = sprintf('"targetConnect" must be a 1x%g boolean matrix.',net.numLayers);
  return
end

for i=findne(net.targetConnect,targetConnect)
  if targetConnect(i) == 1
    net.targets{i} = nntarget;
  net.targets{i}.size = net.layers{i}.size;
  else
    net.targets{i} = [];
  end
end

net.targetConnect = targetConnect;

% ===========================================================
%                          INPUT PROPERTIES
% ===========================================================

function [net,err] = setInputRange(net,j,range)

% Check value
err = '';
if ~isrealmat(range,NaN,2)
  err = sprintf('"inputs{%g}.range" must an Rx2 real matrix.',j);
  return
end
if any(range(:,1) > range(:,2))
  err = sprintf('First column elements in "inputs{%g}.range" must be smaller than the second.',j);
  return
end

% Change input size
newSize = size(range,1);
net.inputs{j}.size = newSize;

% Change range size
net.inputs{j}.range = range;

% Change weight sizes
for i=find(net.inputConnect(:,j)')
  rows = net.layers{i}.size;
  cols = net.inputs{j}.size * length(net.inputWeights{i,j}.delays);
  net.inputWeights{i,j}.size = [rows cols];
  net.IW{i,j} = resizem(net.IW{i,j},rows,cols);
end

% ===========================================================

function [net,err] = setInputSize(net,j,newSize)

% Check value
err = '';
if ~isposint(newSize)
  err = sprintf('"inputs{%g}.size" must be a positive integer.',j);
  return
end

% Change input size
net.inputs{j}.size = newSize;

% Change range size
net.inputs{j}.range = setmrows(net.inputs{j}.range,newSize,[0 1]);

% Change weight value size
for i=find(net.inputConnect(:,j)')
  rows = net.layers{i}.size;
  cols = net.inputs{j}.size * length(net.inputWeights{i,j}.delays);
  net.inputWeights{i,j}.size = [rows cols];
  net.IW{i,j} = resizem(net.IW{i,j},rows,cols);
end

% ===========================================================
%                          LAYER PROPERTIES
% ===========================================================

function [net,err] = setLayerDimensions(net,i,newDimensions)

% Check value
err = '';
if ~isa(newDimensions,'double')
  err = sprintf('"layers{%g}.dimensions" must be an integer row vector.',i);
  return
end
if size(newDimensions,1) ~= 1
  err = sprintf('"layers{%g}.dimensions" must be an integer row vector.',i);
  return
end
if any(newDimensions ~= floor(newDimensions))
  err = sprintf('"layers{%g}.dimensions" must be an integer row vector.',i);
  return
end

% Change layer size
[net,err] = setLayerSize(net,i,prod(newDimensions));

% Change layer dimensions
net.layers{i}.dimensions = newDimensions;

% ===========================================================

function [net,err] = setLayerDistanceFcn(net,i,distanceFcn)

% Check value
err = '';
if ~isstr(distanceFcn)
  err = sprintf('"layers{%g}.distanceFcn" must be the name of a distance function or ''''.',i);
  return
end
if length(distanceFcn) ~= 0
  if ~exist(distanceFcn)
    err = sprintf('"layers{%g}.distanceFcn" cannot be set to non-existing function "%s".',i,distanceFcn);
    return
  end
end

% Change transfer function
net.layers{i}.distanceFcn = distanceFcn;

% ===========================================================

function [net,err] = setLayerInitFcn(net,i,initFcn)

% Check value
err = '';
if ~isstr(initFcn)
  err = sprintf('"layers{%g}.initFcn" must be '''' or the name of a bias initialization function.',i);
  return
end
if length(initFcn) & ~exist(initFcn)
  err = sprintf('"layers{%g}.initFcn" cannot be set to non-existing function "%s".',i,initFcn);
  return
end

% Change initialization function
net.layers{i}.initFcn = initFcn;

% ===========================================================

function [net,err] = setLayerSize(net,ind,newSize)

% Check value
err = '';
if ~isposint(newSize)
  err = sprintf('"layers{%g}.size" must be a positive integer.',ind);
  return
end

% Change layer size
net.layers{ind}.size = newSize;

% Change layer dimensions
net.layers{ind}.dimensions = newSize;

% Change bias size
if net.biasConnect(ind)
  net.biases{ind}.size = newSize;
  net.b{ind} = resizem(net.b{ind},newSize,1);
end

% Change weights from input sizes
rows = newSize;
for j=find(net.inputConnect(ind,:))
  cols = net.inputs{j}.size * length(net.inputWeights{ind,j}.delays);
  net.inputWeights{ind,j}.size = [rows cols];
  net.IW{ind,j} = resizem(net.IW{ind,j},rows,cols);
end

% Change weights from layer sizes
rows = newSize;
for j=find(net.layerConnect(ind,:))
  cols = net.layers{j}.size * length(net.layerWeights{ind,j}.delays);
  net.layerWeights{ind,j}.size = [rows cols];
  net.LW{ind,j} = resizem(net.LW{ind,j},rows,cols);
end

% Change weights from layer sizes
for i=find(net.layerConnect(:,ind)')
  rows = net.layers{i}.size;
  cols = newSize * length(net.layerWeights{i,ind}.delays);
  net.layerWeights{i,ind}.size = [rows cols];
  net.LW{i,ind} = resizem(net.LW{i,ind},rows,cols);
end

% Change output size
if net.outputConnect(ind)
  net.outputs{ind}.size = newSize;
end

% Change target size
if net.targetConnect(ind)
  net.targets{ind}.size = newSize;
end

% ===========================================================

function [net,err] = setLayerTopologyFcn(net,i,topologyFcn)

% Check value
err = '';
if ~isstr(topologyFcn)
  err = sprintf('"layers{%g}.topologyFcn" must be the name of a topology function.',i);
  return
end
if ~exist(topologyFcn)
  err = sprintf('"layers{%g}.topologyFcn" cannot be set to non-existing function "%s".',i,topologyFcn);
  return
end

% Change transfer function
net.layers{i}.topologyFcn = topologyFcn;

% ===========================================================

function [net,err] = setLayerTransferFcn(net,i,transferFcn)

% Check value
err = '';
if ~isstr(transferFcn)
  err = sprintf('"layers{%g}.transferFcn" must be the name of a transfer function.',i);
  return
end
if ~exist(transferFcn)
  err = sprintf('"layers{%g}.transferFcn" cannot be set to non-existing function "%s".',i,transferFcn);
  return
end

% Change transfer function
net.layers{i}.transferFcn = transferFcn;

% ===========================================================

function [net,err] = setLayerNetInputFcn(net,i,netInputFcn)

% Check value
err = '';
if ~isstr(netInputFcn)
  err = sprintf('"layers{%g}.netInputFcn" must be the name of a net input function.',i);
  return
end
if ~exist(netInputFcn)
  err = sprintf('"layers{%g}.netInputFcn" cannot be set to non-existing function "%s".',i,netInputFcn);
  return
end

% Change net input function
net.layers{i}.netInputFcn = netInputFcn;

% ===========================================================
%                          OUTPUT PROPERTIES
% ===========================================================

function [net,err] = setOutputTarget(net,i,target)

% Check value
err = '';
if ~isboolmat(target,1,1)
  err = sprintf('"outputs{%g}.target" must be 0 or 1.',i);
  return
end

% Change net input function
net.outputs{i}.target = target;

% ===========================================================
%                          BIAS PROPERTIES
% ===========================================================

function [net,err] = setBiasInitFcn(net,i,initFcn)

% Check value
err = '';
if ~isstr(initFcn)
  err = sprintf('"biases{%g}.initFcn" must be '''' or the name of a bias initialization function.',i);
  return
end
if length(initFcn) & ~exist(initFcn)
  err = sprintf('"biases{%g}.initFcn" cannot be set to non-existing function "%s".',i,initFcn);
  return
end

% Change init function
net.biases{i}.initFcn = initFcn;

% ===========================================================

function [net,err] = setBiasLearn(net,i,learn)

% Check value
err = '';
if ~isbool(learn,1,1)
  err = sprintf('"biases{%g}.learn" must be 0 or 1.',i);
  return
end

% Change learn function
net.biases{i}.learn = learn;

% ===========================================================

function [net,err] = setBiasLearnFcn(net,i,learnFcn)

% Check value
err = '';
if ~isstr(learnFcn)
  err = sprintf('"biases{%g}.learnFcn" must be '''' or the name of a bias learning function.',i);
  return
end
if length(learnFcn) & ~exist(learnFcn)
  err = sprintf('"biases{%g}.learnFcn" cannot be set to non-existing function "%s".',i,learnFcn);
  return
end

% Change learn function
net.biases{i}.learnFcn = learnFcn;

% Default learn parameters
if length(learnFcn)
  net.biases{i}.learnParam = feval(learnFcn,'pdefaults');
else
  net.biases{i}.learnParam = [];
end

% ===========================================================

function [net,err] = setBiasLearnParam(net,i,learnParam)

% Check value
err = '';

% Change learn paramters
net.biases{i}.learnParam = learnParam;

% ===========================================================
%                          INPUT WEIGHT PROPERTIES
% ===========================================================

function [net,err] = setInputWeightDelays(net,i,j,delays)

% Check value
err = '';
if ~isdelay(delays)
  err = sprintf('"inputWeights{%g,%g}.delays" must be a row vector of increasing integer values.',i,j);
  return
end

% Change learn parameters
net.inputWeights{i,j}.delays = delays;

% Change value
rows = net.layers{i}.size;
cols = net.inputs{j}.size * length(net.inputWeights{i,j}.delays);
net.inputWeights{i,j}.size = [rows cols];
net.IW{i,j} = resizem(net.IW{i,j},rows,cols);

% ===========================================================

function [net,err] = setInputWeightInitFcn(net,i,j,initFcn)

% Check value
err = '';
if ~isstr(initFcn)
  err = sprintf('"inputWeights{%g,%g}.initFcn" must be '''' or the name of a weight initialization function.',i,j);
  return
end
if length(initFcn) & ~exist(initFcn)
  err = sprintf('"inputWeights{%g,%g}.initFcn" cannot be set to non-existing function "%s".',i,j,initFcn);
  return
end

% Change init function
net.inputWeights{i,j}.initFcn = initFcn;

% ===========================================================

function [net,err] = setInputWeightLearn(net,i,j,learn)

% Check value
err = '';
if ~isbool(learn,1,1)
  err = sprintf('"inputWeights{%g,%g}.learn" must be 0 or 1.',i,j);
  return
end

% Change learn function
net.inputWeights{i,j}.learn = learn;

% ===========================================================

function [net,err] = setInputWeightLearnFcn(net,i,j,learnFcn)

% Check value
err = '';
if ~isstr(learnFcn)
  err = sprintf('"inputWeights{%g,%g}.learnFcn" must be '''' or the name of a weight learning function.',i,j);
  return
end
if length(learnFcn) & ~exist(learnFcn)
  err = sprintf('"inputWeights{%g,%g}.learnFcn" cannot be set to non-existing function "%s".',i,j,learnFcn);
  return
end

% Change learn function
net.inputWeights{i,j}.learnFcn = learnFcn;

% Default learn parameters
if length(learnFcn)
  net.inputWeights{i,j}.learnParam = feval(learnFcn,'pdefaults');
else
  net.inputWeights{i,j}.learnParam = [];
end

% ===========================================================

function [net,err] = setInputWeightLearnParam(net,i,j,learnParam)

% Check value
err = '';

% Change learn parameters
net.inputWeights{i,j}.learnParam = learnParam;

% ===========================================================

function [net,err] = setInputWeightWeightFcn(net,i,j,weightFcn)

% Check value
err = '';
if ~isstr(weightFcn)
  err = sprintf('"inputWeights{%g,%g}.weightFcn" must be the name of a weight function.',i,j);
  return
end
if ~exist(weightFcn)
  err = sprintf('"inputWeights{%g,%g}.weightFcn" cannot be set to non-existing function "%s".',i,j,weightFcn);
  return
end

% Change net input function
net.inputWeights{i,j}.weightFcn = weightFcn;


% ===========================================================
%                          LAYER WEIGHT PROPERTIES
% ===========================================================

function [net,err] = setLayerWeightDelays(net,i,j,delays)

% Check value
err = '';
if ~isdelay(delays)
  err = sprintf('"layerWeights{%g,%g}.delays" must be a row vector of increasing integer values.',i,j);
  return
end

% Change learn parameters
net.layerWeights{i,j}.delays = delays;

% Change value
rows = net.layers{i}.size;
cols = net.layers{j}.size * length(net.layerWeights{i,j}.delays);
net.layerWeights{i,j}.size = [rows cols];
net.LW{i,j} = resizem(net.LW{i,j},rows,cols);

% ===========================================================

function [net,err] = setLayerWeightInitFcn(net,i,j,initFcn)

% Check value
err = '';
if ~isstr(initFcn)
  err = sprintf('"layerWeights{%g,%g}.initFcn" must be '''' or the name of a weight initialization function.',i,j);
  return
end
if length(initFcn) & ~exist(initFcn)
  err = sprintf('"layerWeights{%g,%g}.initFcn" cannot be set to non-existing function "%s".',i,j,initFcn);
  return
end

% Change init function
net.layerWeights{i,j}.initFcn = initFcn;

% ===========================================================

function [net,err] = setLayerWeightLearn(net,i,j,learn)

% Check value
err = '';
if ~isbool(learn,1,1)
  err = sprintf('"layerWeights{%g,%g}.learn" must be 0 or 1.',i,j);
  return
end

% Change learn function
net.layerWeights{i,j}.learn = learn;

% ===========================================================

function [net,err] = setLayerWeightLearnFcn(net,i,j,learnFcn)

% Check value
err = '';
if ~isstr(learnFcn)
  err = sprintf('"layerWeights{%g,%g}.learnFcn" must be '''' or the name of a weight learning function.',i,j);
  return
end
if length(learnFcn) & ~exist(learnFcn)
  err = sprintf('"layerWeights{%g,%g}.learnFcn" cannot be set to non-existing function "%s".',i,j,learnFcn);
  return
end

% Change learn function
net.layerWeights{i,j}.learnFcn = learnFcn;

% Default learn parameters
if length(learnFcn)
  net.layerWeights{i,j}.learnParam = feval(learnFcn,'pdefaults');
else
  net.layerWeights{i,j}.learnParam = [];
end

% ===========================================================

function [net,err] = setLayerWeightLearnParam(net,i,j,learnParam)

% Check value
err = '';

% Change learn parameters
net.layerWeights{i,j}.learnParam = learnParam;

% ===========================================================

function [net,err] = setLayerWeightWeightFcn(net,i,j,weightFcn)

% Check value
err = '';
if ~isstr(weightFcn)
  err = sprintf('"layerWeights{%g,%g}.weightFcn" must be the name of a weight function.',i,j);
  return
end
if ~exist(weightFcn)
  err = sprintf('"layerWeights{%g,%g}.weightFcn" cannot be set to non-existing function "%s".',i,j,weightFcn);
  return
end

% Change net input function
net.layerWeights{i,j}.weightFcn = weightFcn;

% ===========================================================
%                          FUNCTIONS AND PARAMETERS
% ===========================================================

function [net,err] = setAdaptFcn(net,adaptFcn)

% Check value
err = '';
if ~isstr(adaptFcn)
  err = sprintf('"adaptFcn" must be '''' or the name of a network adapt function.');
  return
end
if length(adaptFcn) & ~exist(adaptFcn)
  err = sprintf('"adaptFcn" cannot be set to non-existing function "%s".',adaptFcn);
  return
end

% Change function
net.adaptFcn = adaptFcn;

% Default parameters
if length(adaptFcn)
  net.adaptParam = feval(adaptFcn,'pdefaults');
else
  net.adaptParam = [];
end

% ===========================================================

function [net,err] = setAdaptParam(net,adaptParam)

% Check value
err = '';

% Change paramters
net.adaptParam = adaptParam;

% ===========================================================

function [net,err] = setInitFcn(net,initFcn)

% Check value
err = '';
if ~isstr(initFcn)
  err = sprintf('"initFcn" must be '''' or the name of a network initialization function.');
  return
end
if length(initFcn) & ~exist(initFcn)
  err = sprintf('"initFcn" cannot be set to non-existing function "%s".',initFcn);
  return
end

% Change function
net.initFcn = initFcn;

% Default parameters
if length(initFcn)
  net.initParam = feval(initFcn,'pdefaults');
else
  net.initParam = [];
end

% ===========================================================

function [net,err] = setInitParam(net,initParam)

% Check value
err = '';

% Change paramters
net.initParam = initParam;

% ===========================================================

function [net,err] = setPerformFcn(net,performFcn)

% Check value
err = '';
if ~isstr(performFcn)
  err = sprintf('"performFcn" must be '''' or the name of a network performance function.');
  return
end
if length(performFcn) & ~exist(performFcn)
  err = sprintf('"performFcn" cannot be set to non-existing function "%s".',performFcn);
  return
end

% Change function
net.performFcn = performFcn;

% Default parameters
if length(performFcn)
  net.performParam = feval(performFcn,'pdefaults');
else
  net.performParam = [];
end

% ===========================================================

function [net,err] = setPerformParam(net,performParam)

% Check value
err = '';

% Change paramters
net.performParam = performParam;

% ===========================================================

function [net,err] = setTrainFcn(net,trainFcn)

% Check value
err = '';
if ~isstr(trainFcn)
  err = sprintf('"trainFcn" must be '''' or the name of a network adapt function.');
  return
end
if length(trainFcn) & ~exist(trainFcn)
  err = sprintf('"trainFcn" cannot be set to non-existing function "%s".',trainFcn);
  return
end

% Change function
net.trainFcn = trainFcn;

% Default parameters
if length(trainFcn)
  net.trainParam = feval(trainFcn,'pdefaults');
else
  net.trainParam = [];
end

% ===========================================================

function [net,err] = setTrainParam(net,trainParam)

% Check value
err = '';

% Change paramters
net.trainParam = trainParam;

% ===========================================================
%                          UTILITY FUNCTIONS
% ===========================================================

function [subscripts,subs,type,moresubs]=nextsubs(subscripts)
% NEXTSUBS get subscript data from a subscript array.

subs = subscripts(1).subs;
type = subscripts(1).type;
subscripts(1) = [];
moresubs = length(subscripts) > 0;

% ===========================================================

function field = matchstring(field,strings)
% MATCHFIELD replaces FIELD with any field belonging to STRUCTURE
% that is the same when case is ignored.

field2 = lower(field);

for i=1:length(strings)
  if strcmp(field2,lower(strings{i}))
    field = strings{i};
    break;
  end
end

% ===========================================================

function field = matchfield(field,structure)
% MATCHFIELD replaces FIELD with any field belonging to STRUCTURE
% that is the same when case is ignored.

f = matchstring(field,fieldnames(structure));

% ===========================================================

function m=resizem(m,r,c)
%RESIZEM Resize matrix by truncating or adding zeros.

[R,C] = size(m);
if (r < R)
  m = m(1:r,:);
elseif (r > R)
  m = [m; zeros(r-R,C)];
end
if (c < C)
  m = m(:,1:c);
elseif (c > C)
  m = [m zeros(r,c-C)];
end
% ===========================================================

function mat = setmrows(mat,rows,row)
% SETMROWS removes or adds rows to MAT so that it has ROWS rows.
% If rows are added they are set to ROW.

[m,n] = size(mat);
if (rows < m)
  mat = mat(1:rows,:);
elseif (rows > m)
  mat = [mat; row(ones(rows-m,1),:)];
end

% ===========================================================

function flag = ismat(mat,m,n)
% ISMAT(MAT,M,N) is true if MAT is a MxN  matrix.
% If M or N is NaN, that dimension to be anything.

flag = isa(mat,'double');
if ~flag, return, end
if isnan(m), m = size(mat,1); end
if isnan(n), n = size(mat,2); end
flag = all(size(mat) == [m n]);

% ===========================================================

function flag = isdelay(v)
% ISDELAY(V) is true if V is a delay vector which
% means it must be a vector of increasing integer values.


flag = 1;
if size(v,2) == 0, return, end

flag = 0;
if ~isa(v,'double'); return, end
if any(~isfinite(v)), return; end
if any(v ~= floor(v)), return; end
if size(v,1) ~= 1, return; end
if any(diff(v) <= 0), return; end

flag = 1;

% ===========================================================

function flag = isrealmat(mat,m,n)
% ISREALMAT(MAT,M,N) is true if MAT is a MxN real matrix.
% If M or N is NaN, that dimension to be anything.

flag = isa(mat,'double');
if ~flag, return, end
flag = isreal(mat);
if ~flag, return, end
if isnan(m), m = size(mat,1); end
if isnan(n), n = size(mat,2); end
flag = all(size(mat) == [m n]);

% ===========================================================

function flag = isboolmat(mat,m,n)
% ISBOOLMAT(MAT,M,N) is true if MAT is a MxN bool matrix.
% If M or N is NaN, that dimension to be anything.

flag = isa(mat,'double');
if ~flag, return, end
flag = isreal(mat);
if ~flag, return, end
flag = all(all((mat == 0) | (mat == 1)));
if ~flag, return, end
if isnan(m), m = size(mat,1); end
if isnan(n), n = size(mat,2); end
flag = all(size(mat) == [m n]);

% ===========================================================

function [sub1,err] = subs1(subs,dim)
% SUBS1(SUBS,DIM) converts N-D subscripts SUBS to 1-D equivalents
% given the dimensions DIM of the index space.

err = '';
sub1 = 0;

m = 1:prod(dim);
m = reshape(m,dim);
eval('sub1 = m(subs{:});','err = lasterr;');

sub1 = sub1(:)';

% ===========================================================

function [sub1,sub2,err] = subs2(subs,dim)
% [SUB1,SUB2]=SUBS2(SUBS,DIM) converts N-D subscripts SUBS to
% 1-D equivalents given the dimensions DIM of the index space.

err = '';
sub1 = 0;
sub2 = 0;

m1 = [1:dim(1)]';
m1 = m1(:,ones(1,dim(2)),:);
eval('sub1 = m1(subs{:});','err = lasterr;');

if length(err), return, end

m2 = 1:dim(2);
m2 = m2(ones(1,dim(1)),:);
sub2 = m2(subs{:});

sub1 = sub1(:)';
sub2 = sub2(:)';

% ===========================================================

function flag = isint(mat)
% ISINT checks that a matrix contains only integer values.

flag = 0;
if ~isa(mat,'double'), flag = 1; return, end
if ~isreal(mat), flag = 1; return, end
if any(any(mat ~= floor(mat))), flag = 1; return, end

% ===========================================================

function [o,err]=nsubsasn(o,subscripts,v)
%NSUBSASN General purpose subscript assignment.

% Assume no error
err = '';

% Null case
if length(subscripts) == 0
  o = v;
  return
end

type = subscripts(1).type;
subs = subscripts(1).subs;
subscripts(1) = [];
o2 = [];

  % Paretheses
  switch type
  
  case '()'
    eval('o2=o(subs{:});','err=lasterr');
  if length(err), return, end
    [v,err] = nsubsasn(o2,subscripts,v);
  if length(err), return, end
  
    eval('o(subs{:})=v;','err=lasterr;')
  
  % Curly bracket
  case '{}'
    eval('o2=o{subs{:}};','err=lasterr');
  if length(err), return, end
    [v,err] = nsubsasn(o2,subscripts,v);
  if length(err), return, end
  
    eval('o{subs{:}}=v;','err=lasterr;')
    
  % Dot
  case '.'

    % Match field name regardless of case
    if isa(o,'struct') | isa(o,'network')
    found = 0;
      f = fieldnames(o);
    for i=1:length(f)
      if strcmp(subs,lower(f{i}))
        subs = f{i};
      found = 1;
      break;
      end
    end
    if (~found)
      eval(['o.' subs '=v;'],'err=lasterr');
    return
    end
  else
    err = 'Attempt to reference field of non-structure array.';
    return
  end

    eval(['o2=o.' subs ';'],'err=lasterr');
  if length(err), return, end
    [v,err] = nsubsasn(o2,subscripts,v);
  if length(err), return, end

  eval(['o.' subs '=v;'],'err=lasterr;')
    
  end
  
% ===========================================================
%                          NEW SUBOBJECTS
% ===========================================================

function structure=nninput
% NNINPUT Construct an input structure.

structure.range = [0 1];
structure.size = 1;
structure.userdata.note = 'Put your custom input information here.';

% ===========================================================

function structure=nnlayer
%NNLAYER Construct a layer structure.

structure.dimensions = 1;
structure.distanceFcn = '';
structure.distances = [0];
structure.initFcn = 'initwb';
structure.netInputFcn = 'netsum';
structure.positions = [0];
structure.size = 1;
structure.topologyFcn = 'hextop';
structure.transferFcn = 'purelin';
structure.userdata.note = 'Put your custom layer information here.';

% ===========================================================

function structure=nnbias(a1)
%NNBIAS Construct a bias structure.

structure.initFcn = '';
structure.learn = 1;
structure.learnFcn = '';
structure.learnParam = '';
structure.size = 0;
structure.userdata.note = 'Put your custom bias information here.';

% ===========================================================

function structure=nnweight
%NNWEIGHT Construct a weight structure.

structure.delays = [0];
structure.initFcn = '';
structure.learn = 1;
structure.learnFcn = '';
structure.learnParam = '';
structure.size = [0 0];
structure.userdata.note = 'Put your custom weight information here.';
structure.weightFcn = 'dotprod';

% ===========================================================

function structure=nnoutput
% NNOUTPUT Construct an output structure.

structure.size = 0;
structure.userdata.note = 'Put your custom output information here.';

% ===========================================================

function structure=nntarget
% NNTARGET Construct a target structure.

structure.size = 0;
structure.userdata.note = 'Put your custom output information here.';

% ===========================================================

function i=findne(a,b)
% FINDNE Find not equal.
% Get around warning for [] == [].

if length(a) == 0
  i = [];
else
  i = find(a ~= b);
end

% ===========================================================
function [net,err]=hint(net)

% INPUTS
% ======
% inputSizes(i), totalInputSize

net.hint.inputSizes = zeros(net.numInputs,1);
for i=1:net.numInputs
  net.hint.inputSizes(i) = net.inputs{i}.size;
end
net.hint.totalInputSize = sum(net.hint.inputSizes);

% LAYERS
% ======
% layerSizes(i), totalLayerSize,

net.hint.layerSizes = zeros(net.numLayers,1);
for i=1:net.numLayers
  net.hint.layerSizes(i) = net.layers{i}.size;
end
net.hint.totalLayerSize = sum(net.hint.layerSizes);


% OUTPUTS
% =======
% outputInd, outputSizes(i), totalOutputSize

net.hint.outputInd = find(net.outputConnect);
net.hint.outputSizes = zeros(net.numOutputs,1);
for i=1:net.numOutputs
  net.hint.outputSizes(i) = net.outputs{net.hint.outputInd(i)}.size;
end
net.hint.totalOutputSize = sum(net.hint.outputSizes);

% TARGETS
% =======
% targetInd, targetSizes(i), totalTargetSize

net.hint.targetInd = find(net.targetConnect);
net.hint.targetSizes = zeros(net.numTargets,1);
for i=1:net.numTargets
  net.hint.targetSizes(i) = net.targets{net.hint.targetInd(i)}.size;
end
net.hint.totalTargetSize = sum(net.hint.targetSizes);

% CONNECT
% =======

% inputConnectFrom{i}, inputConnectTo{i}
net.hint.inputConnectFrom = cell(net.numLayers,1);
for i=1:net.numLayers
  net.hint.inputConnectFrom{i} = find(net.inputConnect(i,:));
end
net.hint.inputConnectTo = cell(net.numInputs,1);
for i=1:net.numInputs
  net.hint.inputConnectTo{i} = find(net.inputConnect(:,i)');
end

% layerConnectFrom{i}, layerConnectTo{i}
net.hint.layerConnectFrom = cell(net.numLayers,1);
net.hint.layerConnectTo = cell(net.numLayers,1);
for i=1:net.numLayers
  net.hint.layerConnectFrom{i} = find(net.layerConnect(i,:));
  net.hint.layerConnectTo{i} = find(net.layerConnect(:,i)');
end

% biasConnectTo, biasConnectFrom
net.hint.biasConnectFrom = cell(net.numLayers,1);
for i=1:net.numLayers
  net.hint.biasConnectFrom{i} = find(net.biasConnect(i));
end
net.hint.biasConnectTo = find(net.biasConnect)';

% LAYER ORDERS
% ============

% simLayerOrder, bpLayerOrder
[net.hint.simLayerOrder,net.hint.zeroDelay] = simlayorder(net);
[net.hint.bpLayerOrder,net.hint.zeroDelay] = bplayorder(net);

% CHECK LAYERS HAVE WEIGHTS
% =========================
net.hint.noWeights = find(~any([net.inputConnect net.layerConnect],2));

% DELAYS
% ======

% layerDelays, layerConnectOZD, layerConnectWZD
net.hint.layerDelays = cell(net.numLayers,net.numLayers);
net.hint.layerConnectOZD = zeros(net.numLayers,net.numLayers);
net.hint.layerConnectWZD = zeros(net.numLayers,net.numLayers);
for i=1:net.numLayers
  for j=net.hint.layerConnectFrom{i}
    net.hint.layerDelays{i,j} = net.layerWeights{i,j}.delays;
  net.hint.layerConnectOZD(i,j) = all(net.hint.layerDelays{i,j} == 0);
  net.hint.layerConnectWZD(i,j) = any(net.hint.layerDelays{i,j} == 0);
  end
end
net.hint.layerConnectOZD = net.hint.layerConnectOZD & net.hint.layerConnectWZD;
net.hint.layerConnectWZD = net.hint.layerConnectWZD & ~net.hint.layerConnectOZD;

% layerConnectToOZD, layerConnectToWZD
net.hint.layerConnectToZD = net.hint.layerConnectTo;
for i=1:net.numLayers
  net.hint.layerConnectToOZD{i} = find(net.hint.layerConnectOZD(:,i)');
  net.hint.layerConnectToWZD{i} = find(net.hint.layerConnectWZD(:,i)');
end

% FUNCTIONS
% =========

% inputWeightFcn, layerWeightFcn
% netInputFcn, dNetInputFcn, transferFcn, dTransferFcn
net.hint.inputWeightFcn = cell(net.numLayers,net.numInputs);
net.hint.dInputWeightFcn = net.hint.inputWeightFcn;
net.hint.layerWeightFcn = cell(net.numLayers,net.numInputs);
net.hint.dLayerWeightFcn = net.hint.layerWeightFcn;
net.hint.netInputFcn = cell(net.numLayers,1);
net.hint.dNetInputFcn = net.hint.netInputFcn;
net.hint.transferFcn = cell(net.numLayers,1);
net.hint.dTransferFcn = net.hint.transferFcn;

for i=1:net.numLayers

  for j=net.hint.inputConnectFrom{i}
    net.hint.inputWeightFcn{i,j} = net.inputWeights{i,j}.weightFcn;
  net.hint.dInputWeightFcn{i,j} = feval(net.hint.inputWeightFcn{i,j},'deriv');
  if ~length(net.hint.dInputWeightFcn{i,j})
    net.hint.dInputWeightFcn{i,j} = 'dnullwf';
  end
  end
  
  for j=net.hint.layerConnectFrom{i}
    net.hint.layerWeightFcn{i,j} = net.layerWeights{i,j}.weightFcn;
  net.hint.dLayerWeightFcn{i,j} = feval(net.hint.layerWeightFcn{i,j},'deriv');
  if ~length(net.hint.dLayerWeightFcn{i,j})
    net.hint.dLayerWeightFcn{i,j} = 'dnullwf';
  end
  end
  
  net.hint.netInputFcn{i} = net.layers{i}.netInputFcn;
  net.hint.dNetInputFcn{i} = feval(net.hint.netInputFcn{i},'deriv');

  net.hint.transferFcn{i} = net.layers{i}.transferFcn;
  net.hint.dTransferFcn{i} = feval(net.hint.transferFcn{i},'deriv');
  if ~length(net.hint.dTransferFcn{i})
    net.hint.dTransferFcn{i} = 'dnulltf';
  end
end

% WEIGHT & BIAS LEARNING RULES
% ============================
% net.hint.needGradient
net.hint.needGradient = 0;
for i=1:net.numLayers
  for j=find(net.inputConnect(i,:))
  learnFcn = net.inputWeights{i,j}.learnFcn;
    if length(learnFcn) & feval(learnFcn,'needg');
    net.hint.needGradient = 1;
    break;
  end
  end
  if (net.hint.needGradient), break, end
  for j=find(net.layerConnect(i,:))
  learnFcn = net.layerWeights{i,j}.learnFcn;
    if length(learnFcn) & feval(learnFcn,'needg');
    net.hint.needGradient = 1;
    break;
  end
  end
  if (net.hint.needGradient), break, end
  if net.biasConnect(i)
  learnFcn = net.biases{i}.learnFcn;
    if length(learnFcn) & feval(learnFcn,'needg');
    net.hint.needGradient = 1;
  end
  end
end

% WEIGHT & BIASES COLUMNS
% =======================
net.hint.inputWeightCols = zeros(net.numLayers,net.numInputs);
net.hint.layerWeightCols = zeros(net.numLayers,net.numLayers);
for i=1:net.numLayers
  for j=find(net.inputConnect(i,:))
    net.hint.inputWeightCols(i,j) = ...
    net.inputs{j}.size * length(net.inputWeights{i,j}.delays);;
  end
  for j=find(net.layerConnect(i,:))
  net.hint.layerWeightCols(i,j) = ...
     net.layers{j}.size * length(net.layerWeights{i,j}.delays);
  end
end

% WEIGHT & BIASES LEARNING
% ========================

% inputLearn, layerLearn, biasLearn
net.hint.inputLearn = net.inputConnect;
net.hint.layerLearn = net.layerConnect;
net.hint.biasLearn = net.biasConnect;
for i=1:net.numLayers
  for j=find(net.inputConnect(i,:))
    net.hint.inputLearn(i,j) = net.inputWeights{i,j}.learn;
  end
  for j=find(net.layerConnect(i,:))
    net.hint.layerLearn(i,j) = net.layerWeights{i,j}.learn;
  end
  if (net.biasConnect(i))
    net.hint.biasLearn(i) = net.biases{i}.learn;
  end
end

% inputLearnFrom, layerLearnFrom
net.hint.inputLearnFrom = cell(net.numLayers,1);
for i=1:net.numLayers
  net.hint.inputLearnFrom{i} = find(net.hint.inputLearn(i,:));
end
net.hint.layerLearnFrom = cell(net.numLayers,1);
for i=1:net.numLayers
  net.hint.layerLearnFrom{i} = find(net.hint.layerLearn(i,:));
end

% WEIGHT & BIAS INDICES INTO X VECTOR
% ===================================
net.hint.inputWeightInd = cell(net.numLayers,net.numInputs);
net.hint.layerWeightInd = cell(net.numLayers,net.numLayers);
net.hint.biasInd = cell(1,net.numLayers);
net.hint.xLen = 0;
for i=1:net.numLayers
  for j=find(net.hint.inputLearn(i,:))
  cols = net.hint.inputWeightCols(i,j);
    len = net.layers{i}.size * cols;
    net.hint.inputWeightInd{i,j} = [net.hint.xLen + (1:len)];
  net.hint.xLen = net.hint.xLen + len;
  end
  for j=find(net.hint.layerLearn(i,:))
  cols = net.hint.layerWeightCols(i,j);
  len = net.layers{i}.size * cols;
  net.hint.layerWeightInd{i,j} = [net.hint.xLen + (1:len)];
  net.hint.xLen = net.hint.xLen + len;
  end
  if (net.hint.biasLearn(i))
    len = net.layers{i}.size;
  net.hint.biasInd{i} = [net.hint.xLen + (1:len)];
  net.hint.xLen = net.hint.xLen + len;
  end
end

% ===========================================================
function [order,zeroDelay]=simlayorder(net)
%SIMLAYORDER Order to simulate layers in.

% INITIALIZATION
order = zeros(1,net.numLayers);
unordered = ones(1,net.numLayers);

% FIND ZERO-DELAY CONNECTIONS BETWEEN LAYERS
dependancies = zeros(net.numLayers,net.numLayers);
for i=1:net.numLayers
  for j=find(net.layerConnect(i,:))
    if any(net.layerWeights{i,j}.delays == 0)
    dependancies(i,j) = 1;
  end
  end
end

% FIND LAYER ORDER
for k=1:net.numLayers
  for i=find(unordered)
    if ~any(dependancies(i,:))
    dependancies(:,i) = 0;
    order(k) = i;
    unordered(i) = 0;
    break;
  end
  end
end

% CHECK THAT ALL LAYERS WERE ORDERED
zeroDelay = any(unordered);

% ===========================================================
function [order,zeroDelay]=bplayorder(net)
%BPLAYORDER Order to backprop through layers.

% INITIALIZE
order = zeros(1,net.numLayers);
unordered = ones(1,net.numLayers);

% FIND ZERO-DELAY CONNECTIONS BETWEEN LAYERS
dependancies = zeros(net.numLayers,net.numLayers);
for i=1:net.numLayers
  for j=find(net.layerConnect(i,:))
    if any(net.layerWeights{i,j}.delays == 0)
    dependancies(i,j) = 1;
  end
  end
end

% FIND LAYER ORDER
for k=1:net.numLayers
  for i=find(unordered)
    if ~any(dependancies(:,i))
    dependancies(i,:) = 0;
    order(k) = i;
    unordered(i) = 0;
    break;
  end
  end
end

% CHECK THAT ALL LAYERS WERE ORDERED
zeroDelay = any(unordered);

% ===========================================================

