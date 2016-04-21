function nnguitools(event)
%NNGUITOOLS A helper function for NNTOOL.

% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.14 $  $Date: 2002/04/14 21:18:45 $

% NN GUI Data
persistent nnguidata;
mlock;

if (isempty(nnguidata))
    nnguidata.network.names = {};
    nnguidata.network.values = {};
    nnguidata.input.names = {};
    nnguidata.input.values = {};
    nnguidata.target.names = {};
    nnguidata.target.values = {};
    nnguidata.inputstate.names = {};
    nnguidata.inputstate.values = {};
    nnguidata.layerstate.names = {};
    nnguidata.layerstate.values = {};
    nnguidata.output.names = {};
    nnguidata.output.values = {};
    nnguidata.error.names = {};
    nnguidata.error.values = {};
end

% Abort if null event
if (size(event) == 0)
    return;
end

% Event Type
eventType = substring(elementAt(event,0),0);


switch eventType
    
case 'checkvalue'
    name = substring(elementAt(event,1),0);
    valueString = substring(elementAt(event,2),0);
    returnVector = elementAt(event,3);
    
    err = 0;
    value = [];
    eval(['value=' valueString  ';'],'err=1;');
    if (err)
        mstring = [name ' is not a legal value.'];
        jstring = java.lang.String(mstring);
        addElement(returnVector,jstring);
    end
    
case 'getweightnames'
    networkName = substring(elementAt(event,1),0);
    net = getValue(nnguidata,networkName);
    weightNames = elementAt(event,2);
    numInputs = net.numInputs;
    numLayers = net.numLayers;
    for j=1:numInputs
        for i=1:numLayers
            if net.inputConnect(i,j)
                weightName = sprintf('iw{%g,%g} - Weight to layer %g from input %g',i,j,i,j);
                jstring = java.lang.String(weightName);
                addElement(weightNames,jstring);
            end
        end
    end
    for j=1:numLayers
        for i=1:numLayers
            if net.layerConnect(i,j)
                weightName = sprintf('lw{%g,%g} - Weight to layer %g from layer %g',i,j);
                jstring = java.lang.String(weightName);
                addElement(weightNames,jstring);
            end
        end
    end
    for i=1:numLayers
        if net.biasConnect(i)
            weightName = sprintf('b{%g} - Bias to layer %g',i,i);
            jstring = java.lang.String(weightName);
            addElement(weightNames,jstring);
        end
    end
    
case 'getweightvalue'
    networkName = substring(elementAt(event,1),0);
    net = getValue(nnguidata,networkName);
    weightName = substring(elementAt(event,2),0);
    weightName = weightName(1:findstr(weightName,'}'));
    returnVector = elementAt(event,3);
    weightValue = eval(['net.' weightName]);
    mstring = nnmat2string(weightValue);
    jstring = java.lang.String(mstring);
    addElement(returnVector,jstring);
    
case 'checkweightvalue'
    networkName = substring(elementAt(event,1),0);
    net = getValue(nnguidata,networkName);
    weightName = substring(elementAt(event,2),0);
    weightName = weightName(1:findstr(weightName,'}'));
    weightValue = substring(elementAt(event,3),0);
    returnVector = elementAt(event,4);
    
    eval(['oldweight=net.' weightName ';']);
    [S,R] = size(oldweight);
    
    err = 0;
    range = [];
    eval(['weight=' weightValue ';'],'err=1;');
    if (err)
        jstring = java.lang.String('Value is not a legal matrix.');
        addElement(returnVector,jstring);
    elseif ~isa(weight,'double')
        jstring = java.lang.String('Value is not a matrix.');
        addElement(returnVector,jstring);
    elseif size(weight,1) ~= S
        jstring = java.lang.String(['Value does not have ' num2str(S) ' rows.']);
        addElement(returnVector,jstring);
    elseif size(weight,2) ~= R
        jstring = java.lang.String(['Value does not have ' num2str(R) ' columns.']);
        addElement(returnVector,jstring);
    end
    
case 'setweightvalue'
    networkName = substring(elementAt(event,1),0);
    net = getValue(nnguidata,networkName);
    weightName = substring(elementAt(event,2),0);
    weightName = weightName(1:findstr(weightName,'}'));
    weightValue = substring(elementAt(event,3),0);
    eval(['net.' weightName '=' weightValue ';']);
    nnguidata = setValue(nnguidata,networkName,net);
    
case 'getinputranges'
    networkName = substring(elementAt(event,1),0);
    net = getValue(nnguidata,networkName);
    returnVector = elementAt(event,2);
    rangesValue = net.inputs{1}.range;
    mstring = nnmat2string(rangesValue);
    jstring = java.lang.String(mstring);
    addElement(returnVector,jstring);
    
case 'checkinputranges'
    
    networkName = substring(elementAt(event,1),0);
    net = getValue(nnguidata,networkName);
    rangesValue = substring(elementAt(event,2),0);
    returnVector = elementAt(event,3);
    
    R = net.inputs{1}.size;
    
    err = 0;
    range = [];
    eval(['range=' rangesValue ';'],'err=1;');
    if (err)
        jstring = java.lang.String('Input Ranges is not a legal matrix.');
        addElement(returnVector,jstring);
    elseif ~isa(range,'double')
        jstring = java.lang.String('Input Ranges is not a matrix.');
        addElement(returnVector,jstring);
    elseif size(range,2) ~= 2
        jstring = java.lang.String('Input Ranges does not have 2 columns.');
        addElement(returnVector,jstring);
    elseif size(range,1) ~= R
        jstring = java.lang.String(['Input Ranges does not have ' num2str(R) ' rows.']);
        addElement(returnVector,jstring); 1
    end
    
case 'setinputranges'
    networkName = substring(elementAt(event,1),0);
    net = getValue(nnguidata,networkName);
    rangesValue = substring(elementAt(event,2),0);
    eval(['net.inputs{1}.range=' rangesValue ';']);
    nnguidata = setValue(nnguidata,networkName,net);
    
case 'getnetworkinfo'
    name = substring(elementAt(event,1),0);
    returnVector = elementAt(event,2);
    net = getValue(nnguidata,name);
    jtrue = java.lang.String('true');
    jfalse = java.lang.String('false');
    if (net.numInputs == 0)
        addElement(returnVector,jfalse);
    else
        addElement(returnVector,jtrue);
    end
    if (net.numOutputs == 0)
        addElement(returnVector,jfalse);
    else
        addElement(returnVector,jtrue);
    end
    if (net.numTargets == 0)
        addElement(returnVector,jfalse);
    else
        addElement(returnVector,jtrue);
    end
    if (net.numInputDelays == 0)
        addElement(returnVector,jfalse);
    else
        addElement(returnVector,jtrue);
    end
    if (net.numLayerDelays == 0)
        addElement(returnVector,jfalse);
    else
        addElement(returnVector,jtrue);
    end
    if strcmp(net.trainFcn,'')
        addElement(returnVector,jfalse);
    else
        addElement(returnVector,jtrue);
    end
    if strcmp(net.adaptFcn,'')
        addElement(returnVector,jfalse);
    else
        addElement(returnVector,jtrue);
    end
    
case 'getdata'
    name = substring(elementAt(event,1),0);
    returnVector = elementAt(event,2);
    value = getValue(nnguidata,name);
    if all(size(value) == [1 1])
        value = value{1,1};
        mstring = nnmat2string(value);
    else
        mstring = nncell2string(value);
    end
    jstring = java.lang.String(mstring);
    addElement(returnVector,jstring);
    
case 'getdatarange'
    name = substring(elementAt(event,1),0);
    returnVector = elementAt(event,2);
    value = getValue(nnguidata,name);
    range = minmax(cell2mat(value));
    mstring = mat2str(range);
    jstring = java.lang.String(mstring);
    addElement(returnVector,jstring);
    
case 'checkdata'
    mstring = substring(elementAt(event,1),0);
    returnVector = elementAt(event,2);
    
    err = 0;
    value = [];
    eval(['value=' mstring ';'],'err=1;');
    if (err)
        jstring = java.lang.String('Data is not a legal value.');
        addElement(returnVector,jstring);
    elseif isa(value,'double')
        % ok
    elseif isa(value,'cell')
        [r,c] = size(value);
        for i=1:r
            for j=1:c
                if (err == 0)
                    m = value{i,j};
                    if ~isa(m,'double')
                        jstring = java.lang.String(['Element {' num2str(i) ',' num2str(j) '} of the cell array is not a matrix.']);
                        addElement(returnVector,jstring);
                    elseif size(m,1) ~= size(value{i,1},1)
                        jstring = java.lang.String(['Row ' num2str(i) ' of the cell array has matrices with differing numbers of rows.']);
                        addElement(returnVector,jstring);
                    elseif size(m,2) ~= size(value{1,1},2)
                        jstring = java.lang.String(['The cell array has matrices with differing numbers of columns.']);
                        addElement(returnVector,jstring);
                    end
                end
            end
        end
    else
        jstring = java.lang.String('Data is not a matrix or a cell array of matrices.');
        addElement(returnVector,jstring);
    end
    
case 'setdata'
    name = substring(elementAt(event,1),0);
    mstring = substring(elementAt(event,2),0);
    value = eval(mstring);
    if isa(value,'double')
        value = {value};
    end
    nnguidata = setValue(nnguidata,name,value);
    
case 'newnet'
    % lower to workaround the case-sensitivity of UNIX
    networkName = substring(elementAt(event,1),0);
    func = lower(substring(elementAt(event,2),0));
    params = j2mparam(elementAt(event,3));
    for i=1:length(params)
        % Lower everything we can.  This is not the best solution.
        try
            params{i}=lower(params{i});
  catch
  end
    end
    returnVector = elementAt(event,4);

    try
        net=feval(func,params{:})         
        err = 0;
    catch
        err = 1;              
    end

    if (err)
        jstring = java.lang.String(lasterr);
        addElement(returnVector,jstring);
    else
        nnguidata.network = addDef(nnguidata.network,networkName,net);
    end
    
case 'newinput'
    name = substring(elementAt(event,1),0);
    value = eval(substring(elementAt(event,2),0));
    if isa(value,'double')
        value = {value};
    end
    nnguidata.input = addDef(nnguidata.input,name,value);
    
case 'newtarget'
    name = substring(elementAt(event,1),0);
    value = eval(substring(elementAt(event,2),0));
    if isa(value,'double')
        value = {value};
    end
    nnguidata.target = addDef(nnguidata.target,name,value);
    
case 'newinputstate'
    name = substring(elementAt(event,1),0);
    value = eval(substring(elementAt(event,2),0));
    if isa(value,'double')
        value = {value};
    end
    nnguidata.inputstate = addDef(nnguidata.inputstate,name,value);
    
case 'newlayerstate'
    name = substring(elementAt(event,1),0);
    value = eval(substring(elementAt(event,2),0));
    if isa(value,'double')
        value = {value};
    end
    nnguidata.layerstate = addDef(nnguidata.layerstate,name,value);
    
case 'newoutput'
    name = substring(elementAt(event,1),0);
    value = eval(substring(elementAt(event,2),0));
    if isa(value,'double')
        value = {value};
    end
    nnguidata.output = addDef(nnguidata.output,name,value);
    
case 'newerror'
    name = substring(elementAt(event,1),0);
    value = eval(substring(elementAt(event,2),0));
    if isa(value,'double')
        value = {value};
    end
    nnguidata.error = addDef(nnguidata.error,name,value);
    
case 'importnet'
    name = substring(elementAt(event,1),0);
    variable = substring(elementAt(event,2),0);
    value = evalin('base',variable);
    nnguidata.network = addDef(nnguidata.network,name,value);
    
case 'importinput'
    name = substring(elementAt(event,1),0);
    variable = substring(elementAt(event,2),0);
    value = evalin('base',variable);
    if isa(value,'double')
        value = {value};
    end
    nnguidata.input = addDef(nnguidata.input,name,value);
    
case 'importtarget'
    name = substring(elementAt(event,1),0);
    variable = substring(elementAt(event,2),0);
    value = evalin('base',variable);
    if isa(value,'double')
        value = {value};
    end
    nnguidata.target = addDef(nnguidata.target,name,value);
    
case 'importinputstate'
    name = substring(elementAt(event,1),0);
    variable = substring(elementAt(event,2),0);
    value = evalin('base',variable);
    if isa(value,'double')
        value = {value};
    end
    nnguidata.inputstate = addDef(nnguidata.inputstate,name,value);
    
case 'importlayerstate'
    name = substring(elementAt(event,1),0);
    variable = substring(elementAt(event,2),0);
    value = evalin('base',variable);
    if isa(value,'double')
        value = {value};
    end
    nnguidata.layerstate = addDef(nnguidata.layerstate,name,value);
    
case 'importoutput'
    name = substring(elementAt(event,1),0);
    variable = substring(elementAt(event,2),0);
    value = evalin('base',variable);
    if isa(value,'double')
        value = {value};
    end
    nnguidata.output = addDef(nnguidata.output,name,value);
    
case 'importerror'
    name = substring(elementAt(event,1),0);
    variable = substring(elementAt(event,2),0);
    value = evalin('base',variable);
    if isa(value,'double')
        value = {value};
    end
    nnguidata.error = addDef(nnguidata.error,name,value);
    
case 'loadnet'
    name = substring(elementAt(event,1),0);
    variable = substring(elementAt(event,2),0);
    path = substring(elementAt(event,3),0);
    s = load(path,variable);
    value = getfield(s,variable);
    nnguidata.network = addDef(nnguidata.network,name,value);
    
case 'loadinput'
    name = substring(elementAt(event,1),0);
    variable = substring(elementAt(event,2),0);
    path = substring(elementAt(event,3),0);
    s = load(path,variable);
    value = getfield(s,variable);
    if isa(value,'double')
        value = {value};
    end
    nnguidata.input = addDef(nnguidata.input,name,value);
    
case 'loadtarget'
    name = substring(elementAt(event,1),0);
    variable = substring(elementAt(event,2),0);
    path = substring(elementAt(event,3),0);
    s = load(path,variable);
    value = getfield(s,variable);
    if isa(value,'double')
        value = {value};
    end
    nnguidata.target = addDef(nnguidata.target,name,value);
    
case 'loadinputstate'
    name = substring(elementAt(event,1),0);
    variable = substring(elementAt(event,2),0);
    path = substring(elementAt(event,3),0);
    s = load(path,variable);
    value = getfield(s,variable);
    if isa(value,'double')
        value = {value};
    end
    nnguidata.inputstate = addDef(nnguidata.inputstate,name,value);
    
case 'loadlayerstate'
    name = substring(elementAt(event,1),0);
    variable = substring(elementAt(event,2),0);
    path = substring(elementAt(event,3),0);
    s = load(path,variable);
    value = getfield(s,variable);
    if isa(value,'double')
        value = {value};
    end
    nnguidata.layerstate = addDef(nnguidata.layerstate,name,value);
    
case 'loadoutput'
    name = substring(elementAt(event,1),0);
    variable = substring(elementAt(event,2),0);
    path = substring(elementAt(event,3),0);
    s = load(path,variable);
    value = getfield(s,variable);
    if isa(value,'double')
        value = {value};
    end
    nnguidata.output = addDef(nnguidata.output,name,value);
    
case 'loaderror'
    name = substring(elementAt(event,1),0);
    variable = substring(elementAt(event,2),0);
    path = substring(elementAt(event,3),0);
    s = load(path,variable);
    value = getfield(s,variable);
    if isa(value,'double')
        value = {value};
    end
    nnguidata.error = addDef(nnguidata.error,name,value);
    
case 'delete';
    name = substring(elementAt(event,1),0);
    nnguidata = deleteAllDefsByName(nnguidata,name);
    
case 'initialize'
    name = substring(elementAt(event,1),0);
    i = nameToIndex(nnguidata.network,name);
    if (i)
        nnguidata.network.values{i} = init(nnguidata.network.values{i});
    end
    
case 'revert'
    name = substring(elementAt(event,1),0);
    i = nameToIndex(nnguidata.network,name);
    if (i)
        nnguidata.network.values{i} = revert(nnguidata.network.values{i});
    end
    
case 'simulate'
    
    % Network
    networkName = substring(elementAt(event,1),0);
    
    % Sim data
    inputsName = substring(elementAt(event,2),0);
    initInputStatesName = substring(elementAt(event,3),0);
    initLayerStatesName = substring(elementAt(event,4),0);
    targetsName = substring(elementAt(event,5),0);
    
    % Sim results
    outputsName = substring(elementAt(event,6),0);
    finalInputStatesName = substring(elementAt(event,7),0);
    finalLayerStatesName = substring(elementAt(event,8),0);
    errorsName = substring(elementAt(event,9),0);
    
    % Error return vector
    returnVector = elementAt(event,10);
    
    % Get sim data
    net = getValueByName(nnguidata.network,networkName);
    if (strcmp(inputsName,'(zeros)'))
        P = inputZeros(net);
    else
        P = getValueByName(nnguidata.input,inputsName);
    end
    if (strcmp(initInputStatesName,'(zeros)'))
        Pi = {};
    else
        Pi = getValueByName(nnguidata.inputstate,initInputStatesName);
    end
    if (strcmp(initLayerStatesName,'(zeros)'))
        Ai = {};
    else
        Ai = getValueByName(nnguidata.layerstate,initLayerStatesName);
    end
    if (strcmp(targetsName,'(zeros)'))
        T = {};
    else
        T = getValueByName(nnguidata.target,targetsName);
    end
    
    % Sim
    err = 0;
    eval('[Y,Pf,Af,E] = sim(net,P,Pi,Ai,T);','err=1;');
    if (err)
        jstring = java.lang.String(lasterr);
        addElement(returnVector,jstring);
    else
        
        % Save sim results
        if (length(outputsName) > 0)
            nnguidata = deleteAllDefsByName(nnguidata,outputsName);
            nnguidata.output = addDef(nnguidata.output,outputsName,Y);
        end
        if (length(finalInputStatesName) > 0)
            nnguidata = deleteAllDefsByName(nnguidata,finalInputStatesName);
            nnguidata.inputstate = addDef(nnguidata.inputstate,finalInputStatesName,Pf);
        end
        if (length(finalLayerStatesName) > 0)
            nnguidata = deleteAllDefsByName(nnguidata,finalLayerStatesName);
            nnguidata.layerstate = addDef(nnguidata.layerstate,finalLayerStatesName,Af);
        end
        if (length(errorsName) > 0)
            nnguidata = deleteAllDefsByName(nnguidata,errorsName);
            nnguidata.error = addDef(nnguidata.error,errorsName,E);
        end
        
    end
    
    % TRAIN
case 'train'
    
    % Network
    networkName = substring(elementAt(event,1),0);
    
    % Training data
    inputsName = substring(elementAt(event,2),0);
    initInputStatesName = substring(elementAt(event,3),0);
    initLayerStatesName = substring(elementAt(event,4),0);
    targetsName = substring(elementAt(event,5),0);
    
    % Training results
    outputsName = substring(elementAt(event,6),0);
    finalInputStatesName = substring(elementAt(event,7),0);
    finalLayerStatesName = substring(elementAt(event,8),0);
    errorsName = substring(elementAt(event,9),0);
    
    % Error return vector
    returnVector = elementAt(event,18);
    
    % Get training data
    net = getValueByName(nnguidata.network,networkName);
    if (strcmp(inputsName,'(zeros)'))
        P = inputZeros(net);
    else
        P = getValueByName(nnguidata.input,inputsName);
    end
    if (strcmp(initInputStatesName,'(zeros)'))
        Pi = {};
    else
        Pi = getValueByName(nnguidata.inputstate,initInputStatesName);
    end
    if (strcmp(initLayerStatesName,'(zeros)'))
        Ai = {};
    else
        Ai = getValueByName(nnguidata.layerstate,initLayerStatesName);
    end
    if (strcmp(targetsName,'(zeros)'))
        T = {};
    else
        T = getValueByName(nnguidata.target,targetsName);
    end
    
    % Validation data
    vinputsName = substring(elementAt(event,10),0);
    vinitInputStatesName = substring(elementAt(event,11),0);
    vinitLayerStatesName = substring(elementAt(event,12),0);
    vtargetsName = substring(elementAt(event,13),0);
    
    % Get validation data
    if (length(vinputsName) == 0)
        VV = [];
    else
        if (strcmp(vinputsName,'(zeros)'))
            VV.P = inputZeros(net);
        else
            VV.P = getValueByName(nnguidata.input,vinputsName);
        end
        if (strcmp(vinitInputStatesName,'(zeros)'))
            VV.Pi = {};
        else
            VV.Pi = getValueByName(nnguidata.inputstate,vinitInputStatesName);
        end
        if (strcmp(vinitLayerStatesName,'(zeros)'))
            VV.Ai = {};
        else
            VV.Ai = getValueByName(nnguidata.layerstate,vinitLayerStatesName);
        end
        if (strcmp(vtargetsName,'(zeros)'))
            VV.T = {};
        else
            VV.T = getValueByName(nnguidata.target,vtargetsName);
        end
    end
    
    % Test data
    tinputsName = substring(elementAt(event,14),0);
    tinitInputStatesName = substring(elementAt(event,15),0);
    tinitLayerStatesName = substring(elementAt(event,16),0);
    ttargetsName = substring(elementAt(event,17),0);
    
    % Get test data
    if (length(tinputsName) == 0)
        TV = [];
    else
        if (strcmp(tinputsName,'(zeros)'))
            TV.P = inputZeros(net);
        else
            TV.P = getValueByName(nnguidata.input,tinputsName);
        end
        if (strcmp(tinitInputStatesName,'(zeros)'))
            TV.Pi = {};
        else
            TV.Pi = getValueByName(nnguidata.inputstate,tinitInputStatesName);
        end
        if (strcmp(tinitLayerStatesName,'(zeros)'))
            TV.Ai = {};
        else
            TV.Ai = getValueByName(nnguidata.layerstate,tinitLayerStatesName);
        end
        if (strcmp(ttargetsName,'(zeros)'))
            TV.T = {};
        else
            TV.T = getValueByName(nnguidata.target,ttargetsName);
        end
    end
    
    % Train
    err = 0;
    eval('[net,tr,Y,E,Pf,Af] = train(net,P,T,Pi,Ai,VV,TV);','err=1;');
    if (err)
        jstring = java.lang.String(lasterr);
        addElement(returnVector,jstring);
    else
        
        % Save training results
        nnguidata.network.values{nameToIndex(nnguidata.network,networkName)} = net;
        if (length(outputsName) > 0)
            nnguidata = deleteAllDefsByName(nnguidata,outputsName);
            nnguidata.output = addDef(nnguidata.output,outputsName,Y);
        end
        if (length(finalInputStatesName) > 0)
            nnguidata = deleteAllDefsByName(nnguidata,finalInputStatesName);
            nnguidata.inputstate = addDef(nnguidata.inputstate,finalInputStatesName,Pf);
        end
        if (length(finalLayerStatesName) > 0)
            nnguidata = deleteAllDefsByName(nnguidata,finalLayerStatesName);
            nnguidata.layerstate = addDef(nnguidata.layerstate,finalLayerStatesName,Af);
        end
        if (length(errorsName) > 0)
            nnguidata = deleteAllDefsByName(nnguidata,errorsName);
            nnguidata.error = addDef(nnguidata.error,errorsName,E);
        end
        
    end
    
case 'adapt'
    
    % Network
    networkName = substring(elementAt(event,1),0);
    
    % Adapt data
    inputsName = substring(elementAt(event,2),0);
    initInputStatesName = substring(elementAt(event,3),0);
    initLayerStatesName = substring(elementAt(event,4),0);
    targetsName = substring(elementAt(event,5),0);
    
    % Adapt results
    outputsName = substring(elementAt(event,6),0);
    finalInputStatesName = substring(elementAt(event,7),0);
    finalLayerStatesName = substring(elementAt(event,8),0);
    errorsName = substring(elementAt(event,9),0);
    
    % Error return vector
    returnVector = elementAt(event,10);
    
    % Get adapt data
    net = getValueByName(nnguidata.network,networkName);
    if (strcmp(inputsName,'(zeros)'))
        P = inputZeros(net);
    else
        P = getValueByName(nnguidata.input,inputsName);
    end
    if (strcmp(initInputStatesName,'(zeros)'))
        Pi = {};
    else
        Pi = getValueByName(nnguidata.inputstate,initInputStatesName);
    end
    if (strcmp(initLayerStatesName,'(zeros)'))
        Ai = {};
    else
        Ai = getValueByName(nnguidata.layerstate,initLayerStatesName);
    end
    if (strcmp(targetsName,'(zeros)'))
        T = {};
    else
        T = getValueByName(nnguidata.target,targetsName);
    end
    
    % Adapt
    err = 0;
    eval('[net,Y,E,Pf,Af] = adapt(net,P,T,Pi,Ai);','err=1;');
    if (err)
        jstring = java.lang.String(lasterr);
        addElement(returnVector,jstring);
    else
        
        % Save adapt results
        nnguidata.network.values{nameToIndex(nnguidata.network,networkName)} = net;
        if (length(outputsName) > 0)
            nnguidata = deleteAllDefsByName(nnguidata,outputsName);
            nnguidata.output = addDef(nnguidata.output,outputsName,Y);
        end
        if (length(finalInputStatesName) > 0)
            nnguidata = deleteAllDefsByName(nnguidata,finalInputStatesName);
            nnguidata.inputstate = addDef(nnguidata.inputstate,finalInputStatesName,Pf);
        end
        if (length(finalLayerStatesName) > 0)
            nnguidata = deleteAllDefsByName(nnguidata,finalLayerStatesName);
            nnguidata.layerstate = addDef(nnguidata.layerstate,finalLayerStatesName,Af);
        end
        if (length(errorsName) > 0)
            nnguidata = deleteAllDefsByName(nnguidata,errorsName);
            nnguidata.error = addDef(nnguidata.error,errorsName,E);
        end
        
    end
    
case 'gettrainparams'
    
    networkName = substring(elementAt(event,1),0);
    names = elementAt(event,2);
    values = elementAt(event,3);
    net = getValueByName(nnguidata.network,networkName);
    trainParam = net.trainParam;
    if (isempty(trainParam))
        fields = {};
    else
        fields = fieldnames(trainParam);
    end
    num = size(fields,1);
    for i=1:num
        field = fields{i};
        name = java.lang.String(field);
        value = java.lang.String(mat2str(getfield(trainParam,field)));
        addElement(names,name);
        addElement(values,value)
    end
    
case 'settrainparams'
    
    networkName = substring(elementAt(event,1),0);
    values = elementAt(event,2);
    net = getValueByName(nnguidata.network,networkName);
    trainParam = net.trainParam;
    if (isempty(trainParam))
        fields = {};
    else
        fields = fieldnames(trainParam);
    end
    num = size(fields,1);
    for i=1:num
        field = fields{i};
        value = eval(substring(elementAt(values,i-1),0));
        trainParam = setfield(trainParam,field,value);
    end
    net.trainParam = trainParam;
    nnguidata.network.values{nameToIndex(nnguidata.network,networkName)} = net;
    
case 'getadaptparams'
    
    networkName = substring(elementAt(event,1),0);
    names = elementAt(event,2);
    values = elementAt(event,3);
    net = getValueByName(nnguidata.network,networkName);
    adaptParam = net.adaptParam;
    if (isempty(adaptParam))
        fields = {};
    else
        fields = fieldnames(adaptParam);
    end
    num = size(fields,1);
    for i=1:num
        field = fields{i};
        name = java.lang.String(field);
        value = java.lang.String(mat2str(getfield(adaptParam,field)));
        addElement(names,name);
        addElement(values,value)
    end
    
case 'setadaptparams'
    
    networkName = substring(elementAt(event,1),0);
    values = elementAt(event,2);
    net = getValueByName(nnguidata.network,networkName);
    adaptParam = net.adaptParam;
    if (isempty(adaptParam))
        fields = {};
    else
        fields = fieldnames(adaptParam);
    end
    num = size(fields,1);
    for i=1:num
        value = eval(substring(elementAt(values,i-1),0));
        field = fields{i};
        adaptParam = setfield(adaptParam,field,value);
    end
    net.adaptParam = adaptParam;
    nnguidata.network.values{nameToIndex(nnguidata.network,networkName)} = net;
    
case 'getwsvars'
    
    names = elementAt(event,1);
    variables = evalin('base','who');
    for i=1:length(variables)
        variable = variables{i};
        addElement(names,java.lang.String(variable));
    end

case 'getwsvartype'
    
    name = substring(elementAt(event,1),0);
    returnVector = elementAt(event,2);
    
    value = evalin('base',name,'''UNKOWN''');
    if isa(value,'network')
      code = 'NETWORK';
    elseif isadatavalue(value)
      code = 'DATA';
    else
      code = 'UNKNOWN';
    end
    
    addElement(returnVector,java.lang.String(code));
    
case 'getfilevars'
    
    thepath = substring(elementAt(event,1),0);
    names = elementAt(event,2);
    variables = evalin('base',['who(''-file'',''' thepath ''')']);
    for i=1:length(variables)
        variable = variables{i};
        addElement(names,java.lang.String(variable));
    end
    
case 'getfilevartype'
    
    thepath = substring(elementAt(event,1),0);
    name = substring(elementAt(event,2),0);
    returnVector = elementAt(event,3);
    
    valueStruct = load(thepath,name);
    value = getfield(valueStruct,name);
    if isa(value,'network')
      code = 'NETWORK';
    elseif isadatavalue(value)
      code = 'DATA';
    else
      code = 'UNKNOWN';
    end
    
    addElement(returnVector,java.lang.String(code));
case 'export'
    
    variables = elementAt(event,1);
    count = double(size(variables));
    for i=1:count
        variable = substring(elementAt(variables,i-1),0);
        value = getValue(nnguidata,variable);
        if (all(size(value) == [1  1]))
            if isa(value,'cell')
                value = value{1,1};
            end
        end
    assignin('base',variable,value);
    end
    
case 'save'
    
    path = substring(elementAt(event,1),0);
    variables = elementAt(event,2);
    count = double(size(variables));
    names = {};
    for i=1:count
        variable = substring(elementAt(variables,i-1),0);
        value = getValue(nnguidata,variable);
        eval([variable ' = value;']);
        names = [names {variable}];
    end
    save(path,names{:});
    
case 'getdiagram'
    
    networkName = substring(elementAt(event,1),0);
    descVector = elementAt(event,2);
    net = getValueByName(nnguidata.network,networkName);
    getNetworkDescription(net,descVector)
    
case 'newdiagram'
    
    descVector = elementAt(event,1);
    func = lower(substring(elementAt(event,2),0));
    params = j2mparam(elementAt(event,3));
    net = feval(func,params{:});
    getNetworkDescription(net,descVector)
end


%==========================================
function getNetworkDescription(net,descVector)
% Puts a description of NET into Java vector DESCVECTOR

if (net.numInputs == 1)
    switch (net.numLayers)
    case 1
        if (net.inputConnect == 1) & (net.layerConnect == 0)
            % Single layer network
            % descVector = ['ff1' inputSize
            %   layerSize netInputFcn transferFcn]
            addElement(descVector,java.lang.String('ff1'));
            addElement(descVector,java.lang.String(num2str(net.inputs{1}.size)));
            addElement(descVector,java.lang.String(num2str(net.layers{1}.size)));
            n1 = net.layers{1}.netInputFcn;
            addElement(descVector,java.lang.String(n1));
            f1 = net.layers{1}.transferFcn;
            addElement(descVector,java.lang.String(f1));
        end
    case 2
        % Two layer feed-forward network
        % descVector = ['ff2' inputSize
        %   layerSize1 netInputFcn1 transferFcn1
        %   layerSize2 netInputFcn2 transferFcn2]
        if all(net.inputConnect==[1;0]) & all(net.layerConnect==[0 0;1 0])
            addElement(descVector,java.lang.String('ff2'));
            addElement(descVector,java.lang.String(num2str(net.inputs{1}.size)));
            addElement(descVector,java.lang.String(num2str(net.layers{1}.size)));
            n1 = net.layers{1}.netInputFcn;
            addElement(descVector,java.lang.String(n1));
            f1 = net.layers{1}.transferFcn;
            addElement(descVector,java.lang.String(f1));
            addElement(descVector,java.lang.String(num2str(net.layers{2}.size)));
            n2 = net.layers{2}.netInputFcn;
            addElement(descVector,java.lang.String(n2));
            f2 = net.layers{2}.transferFcn;
            addElement(descVector,java.lang.String(f2));
        end
    case 3
        if all(net.inputConnect==[1;0;0]) & all(net.layerConnect==[0 0 0;1 0 0;0 1 0])
            % Three layer feed-forward network
            % descVector = ['ff2' inputSize
            %   layerSize1 netInputFcn1 transferFcn1
            %   layerSize2 netInputFcn2 transferFcn2
            %   layerSize3 netInputFcn3 transferFcn3]
            addElement(descVector,java.lang.String('ff3'));
            addElement(descVector,java.lang.String(num2str(net.inputs{1}.size)));
            addElement(descVector,java.lang.String(num2str(net.layers{1}.size)));
            n1 = net.layers{1}.netInputFcn;
            addElement(descVector,java.lang.String(n1));
            f1 = net.layers{1}.transferFcn;
            addElement(descVector,java.lang.String(f1));
            addElement(descVector,java.lang.String(num2str(net.layers{2}.size)));
            n2 = net.layers{2}.netInputFcn;
            addElement(descVector,java.lang.String(n2));
            f2 = net.layers{2}.transferFcn;
            addElement(descVector,java.lang.String(f2));
            addElement(descVector,java.lang.String(num2str(net.layers{3}.size)));
            n3 = net.layers{3}.netInputFcn;
            addElement(descVector,java.lang.String(n3));
            f3 = net.layers{3}.transferFcn;
            addElement(descVector,java.lang.String(f3));
        end
    end
end
if (double(size(descVector)) == 0)
    % All other networks
    % descVector = ['unknown']
    addElement(descVector,java.lang.String('unknown'));
end

%==========================================
function P = inputZeros(net)

P = cell(net.numInputs,1);
for i=1:net.numInputs
    P{i,1} = zeros(net.inputs{i}.size);
end

%==========================================
function defs = setDef(defs,name,value)

i = nameToIndex(defs,name);
defs.values{i} = value;

%==========================================
function data = setValue(data,name,value)

i = nameToIndex(data.network,name);
if (i > 0) data.network.values{i} = value; return,end
i = nameToIndex(data.input,name);
if (i > 0) data.input.values{i} = value; return,end
i = nameToIndex(data.target,name);
if (i > 0) data.target.values{i} = value; return,end
i = nameToIndex(data.inputstate,name);
if (i > 0) data.inputstate.values{i} = value; return,end
i = nameToIndex(data.layerstate,name);
if (i > 0) data.layerstate.values{i} = value; return,end
i = nameToIndex(data.output,name);
if (i > 0) data.output.values{i} = value; return,end
i = nameToIndex(data.error,name);
if (i > 0) data.error.values{i} = value; return,end

%==========================================
function value = getValue(data,name)

i = nameToIndex(data.network,name);
if (i > 0) value = data.network.values{i}; return,end
i = nameToIndex(data.input,name);
if (i > 0) value = data.input.values{i}; return,end
i = nameToIndex(data.target,name);
if (i > 0) value = data.target.values{i}; return,end
i = nameToIndex(data.inputstate,name);
if (i > 0) value = data.inputstate.values{i}; return,end
i = nameToIndex(data.layerstate,name);
if (i > 0) value = data.layerstate.values{i}; return,end
i = nameToIndex(data.output,name);
if (i > 0) value = data.output.values{i}; return,end
i = nameToIndex(data.error,name);
if (i > 0) value = data.error.values{i}; return,end
value = [];

%==========================================
function value = getValueByName(defs,name)

i = nameToIndex(defs,name);
if (i > 0)
    value = defs.values{i};
else
    value = [];
end

%==========================================
function defs = addDef(defs,name,value)

defs.names = [defs.names {name}];
defs.values = [defs.values {value}];

%==========================================
function data = deleteAllDefsByName(data,name)

data.network = deleteDefByName(data.network,name);
data.input = deleteDefByName(data.input,name);
data.target = deleteDefByName(data.target,name);
data.inputstate = deleteDefByName(data.inputstate,name);
data.layerstate = deleteDefByName(data.layerstate,name);
data.output = deleteDefByName(data.output,name);
data.error = deleteDefByName(data.error,name);

%==========================================
function defs = deleteDefByName(defs,name)

i = nameToIndex(defs,name);
if (i>0)
    defs.names(i) = [];
    defs.values(i) = [];
end

%==========================================
function i = nameToIndex(defs,name)

for i=1:length(defs.names)
    if (strcmp(defs.names{i},name))
        return
    end
end
i = 0;

%==========================================
function mparam = j2mparam(jparam)

FUNCTIONNAME = 0;

if isa(jparam,'com.mathworks.toolbox.nnet.NNValue')
    string = char(getString(jparam));
    type = getType(jparam);
    if (type == FUNCTIONNAME)
        mparam = lower(string);
    else
        mparam = eval(string);
    end
elseif isa(jparam,'java.util.Vector')
    num = double(size(jparam));
    mparam = cell(1,num);
    for i=1:num
        mparam{i} = j2mparam(elementAt(jparam,i-1));
    end
else
    error(['J2MPARAM can not convert ' class(jparam) ' objects\n']);
end

%==========================================
function ok = isadatavalue(v)

% Must not have more than 2 dimensions
ok = 0;
if ndims(v) > 2
    return
end

% Ok if double
if isa(v,'double')
    ok = 1;
    return
end

% Or a cell array:
if ~isa(v,'cell')
    return
end
rows = size(v,1);
cols = size(v,2);
for i=1:rows
    for j=1:cols
        % must be double
        if ~isa(v{i,j},'double')
            return;
        end
        % must be 2D
        if ndims(v{i,j}) > 2
            return;
        end
        % must have same # of cols
        if size(v{i,j},2) ~= size(v(1,1),2)
            return;
        end
        % must have same # rows, if in same row
        if size(v{i,j},1) ~= size(v{1,j})
            return
        end
    end
end

ok = 1;
