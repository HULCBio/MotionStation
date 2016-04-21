function out=getfis(fis,arg1,arg2,arg3,arg4,arg5)
%GETFIS Get fuzzy inference system properties.
%   OUT = GETFIS(FIS) returns a list of general information about the
%   fuzzy inference system FIS. 
%   OUT = GETFIS(FIS,'fisProp') returns the current value of the FIS
%   property called 'fisProp'.
%   OUT = GETFIS(FIS, 'vartype', 'varindex') returns a general list
%   of information on 'vartype' of 'varindex'.      
%   OUT = GETFIS(FIS, 'vartype', 'varindex', 'varprop') returns the
%   current value in 'varprop' for 'vartype' of 'varindex'. 
%   OUT = GETFIS(FIS, 'vartype', 'varindex', 'mf', 'mfindex')
%   returns a general list of information on membership function
%   'mfindex'
%   OUT = GETFIS(FIS, 'vartype', 'varindex', 'mf', 'mfindex', 'mfprop') 
%   returns the current value in 'mfprop' for 'mf' of 'mfindex'  
%
%   For example:
%
%           a=newfis('tipper');
%           a=addvar(a,'input','service',[0 10]);
%           a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%           a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%           getfis(a)
%
%   See also SETFIS, SHOWFIS.


%   Ned Gulley, 2-2-94, Kelly Liu 7-10-96
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.33 $  $Date: 2002/04/14 22:23:34 $


if isfield(fis, 'input')
  numInputs=length(fis.input);
else
  numInputs=0;
end

if isfield(fis, 'output')
  numOutputs=length(fis.output);
else
  numOutputs=0;
end


switch nargin
 case 1,
  % ===============================================
  % Handle generic inquiries related to the whole fis
  % ===============================================
  
  fprintf('      Name      = %s\n',fis.name);
  fprintf('      Type      = %s\n',fis.type);
  fprintf('      NumInputs = %s\n',num2str(numInputs));
  fprintf('      InLabels  = \n');
  if numInputs~=0,
    for i=1:length(fis.input)
      fprintf('            %s\n',fis.input(i).name);
    end
  end
  fprintf('      NumOutputs = %s\n',num2str(numOutputs));
  fprintf('      OutLabels = \n');
  if numOutputs~=0,
    for i=1:length(fis.output)
      fprintf('            %s\n',fis.output(i).name);
    end
  end
  fprintf('      NumRules = %s\n',num2str(length(fis.rule)));
  fprintf('      AndMethod = %s\n',fis.andMethod);
  fprintf('      OrMethod = %s\n',fis.orMethod);
  fprintf('      ImpMethod = %s\n',fis.impMethod);
  fprintf('      AggMethod = %s\n',fis.aggMethod);
  fprintf('      DefuzzMethod = %s\n',fis.defuzzMethod);
  out=fis.name;
  
case 2,
  % ===============================================
  propName=lower(arg1);
  switch propName
   case 'name'
    out=fis.name;
   case 'type';
    out=fis.type;
   case 'numinputs'
    out=numInputs;
   case 'numoutputs'
    out=numOutputs;
   case 'numinputmfs'
    numInputMFs=[];
    for i=1:length(fis.input)
      numInputMFs(i)=length(fis.input(i).mf);
    end
    out=numInputMFs;
   case 'numoutputmfs'
    numOutputMFs=[];
    for i=1:length(fis.output)
      numOutputMFs(i)=length(fis.output(i).mf);
    end
    out=numOutputMFs;
    
   case 'numrules'
    out=length(fis.rule);
   case 'andmethod'
    out=fis.andMethod;
   case 'ormethod'
    out=fis.orMethod;
   case 'impmethod'
    out=fis.impMethod;
   case 'aggmethod'
    out=fis.aggMethod;
   case 'defuzzmethod'
    out=fis.defuzzMethod;
    
   case 'inlabels'
    out=[];
    for i=1:numInputs
      out=strvcat(out, fis.input(i).name);
    end
    
   case 'outlabels'
    out=[];
    for i=1:numOutputs
      out=strvcat(out, fis.output(i).name);
    end
    
   case 'inrange'
    for i=1:numInputs
      out(i, 1:2)=fis.input(i).range;
    end
    
   case 'outrange'
    for i=1:numOutputs
      out(i,1:2)=fis.output(i).range;
    end
    
   case 'inmfs'
    for i=1:numInputs
      out(i)=length(fis.input(i).mf);
    end
    
   case 'outmfs'
    for i=1:numOutputs
      out(i)=length(fis.output(i).mf);
    end
    
   case 'inmflabels'
    out=[];
    for i=1:numInputs
      for j=1:length(fis.input(i).mf)
        out=strvcat(out, fis.input(i).mf(j).name);
      end
    end
    
   case 'outmflabels'
    out=[];
    for i=1:numOutputs
      for j=1:length(fis.output(i).mf)
        out=strvcat(out, fis.output(i).mf(j).name);
      end
    end
    
   case 'inmftypes'
    out=[];
    for i=1:numInputs
      for j=1:length(fis.input(i).mf)
        out=strvcat(out, fis.input(i).mf(j).type);
      end
    end
    
   case 'outmftypes'
    out=[];
    for i=1:numOutputs
      for j=1:length(fis.output(i).mf)
        out=strvcat(out, fis.output(i).mf(j).type);
      end
    end
    
   case 'inmfparams'
    numInputMFs=[];
    for i=1:length(fis.input)
      numInputMFs(i)=length(fis.input(i).mf);
    end
    totalInputMFs=sum(numInputMFs);
    k=1;
    out=zeros(totalInputMFs, 4);
    for i=1:numInputs
      for j=1:length(fis.input(i).mf)
        temp=fis.input(i).mf(j).params;
        out(k,1:length(temp))=temp;
        k=k+1;
      end
    end
    
   case 'outmfparams'
    numOutputMFs=[];
    for i=1:length(fis.output)
      numOutputMFs(i)=length(fis.output(i).mf);
    end
    totalOutputMFs=sum(numOutputMFs);
    k=1;
    out=zeros(totalOutputMFs, 4);
    for i=1:numOutputs
      for j=1:length(fis.output(i).mf)
        temp=fis.output(i).mf(j).params;
        out(k, 1:length(temp))=temp;
        k=k+1;
      end
    end
    
   case 'rulelist'
    out=[];
    if length(fis.rule)~=0,
      for i=1:length(fis.rule)
        rules(i, 1:numInputs)=fis.rule(i).antecedent;
        rules(i, (numInputs+1):(numInputs+numOutputs))=fis.rule(i).consequent;
        rules(i, numInputs+numOutputs+1)=fis.rule(i).weight;
        rules(i, numInputs+numOutputs+2)=fis.rule(i).connection;
      end
      out=rules;
    end  
    
   case 'inputs'
    fprintf('      Name =       %s\n',fis.name);
    fprintf('      NumInputs =  %s\n',num2str(numInputs));
    fprintf('      InLabels  = \n');
    if numInputs~=0,
      for i=1:length(fis.input)
        fprintf('            %s\n',fis.input(i).name);
      end
    end
    out=[];
    
   case 'outputs'       
    fprintf('      Name =       %s\n',fis.name);
    fprintf('      NumOutputs = %s\n',num2str(numOutputs));
    fprintf('      OutLabels = \n');
    if numOutputs~=0,
      for i=1:length(fis.output)
        fprintf('            %s\n',fis.output(i).name);
      end
    end
    out=[];
   otherwise
    error(sprintf('There is no FIS system property called ''%s''', propName));
  end
  
 case 3,
  % ===============================================
  % Handle generic inquiries related to VARIABLES
  % ===============================================
  if strcmp(arg1,'input') | strcmp(arg1,'output'),
    varType=lower(arg1);
    varIndex=arg2;
    
    numMFs=getfis(fis,varType,varIndex,'NumMFs');
    fprintf('      Name =     %s\n',getfis(fis,varType,varIndex,'Name'));
    fprintf('      NumMFs =   %s\n',num2str(numMFs));
    fprintf('      MFLabels = \n');
    if numMFs~=0,
      mfLabels=getfis(fis,varType,varIndex,'MFLabels');
      for n=1:numMFs,
        fprintf('            %s\n',mfLabels(n,:));
      end
    end
    range=getfis(fis,varType,varIndex,'Range');
    fprintf('      Range =    %s\n',mat2str(range));
    out=[];
    
  end
  
 case 4,
  % ===============================================
  % Handle specific inquiries related to VARIABLES
  % ===============================================
  varType=lower(arg1);
  varIndex=arg2;
  varProp=lower(arg3);
  switch varType
   case 'input',
    if varIndex>numInputs,
      error(sprintf('There are only %i input variables.', numInputs));
    end
    
    switch varProp
     case 'name'
      out=fis.input(varIndex).name;
     case 'range'
      out=fis.input(varIndex).range;
     case 'nummfs'
      out=length(fis.input(varIndex).mf);
     case 'mflabels'
      numMFs=length(fis.input(varIndex).mf);
      MFList=[];
      for n=1:numMFs,
        MFList=strvcat(MFList,fis.input(varIndex).mf(n).name);
      end
      out=MFList;
     otherwise
      error(sprintf(['Invalid variable properties : ''%s'' \n' ...
                     'Valid entries are: \n'...
                     '\tname \n' ...
                     '\trange \n' ...
                     '\tnummfs \n'...
                     '\tmflabels '], varProp));
    end
    
   case 'output',
    if varIndex>numOutputs,
      error(['There are not that many output variables.']);
    end
    
    switch varProp
     case 'name'
      out=fis.output(varIndex).name;
     case 'range',
      out=fis.output(varIndex).range;
     case 'nummfs',
      out=length(fis.output(varIndex).mf);
     case 'mflabels',
      numMFs=length(fis.output(varIndex).mf);
      MFList=[];
      for n=1:numMFs,
        MFList=strvcat(MFList,fis.output(varIndex).mf(n).name);
      end
      out=MFList;
     otherwise
      error(sprintf(['Invalid variable property : ''%s'' \n' ...
                     'Valid properties are: \n'...
                     '\tname \n' ...
                     '\trange \n' ...
                     '\tnummfs \n'...
                     '\tmflabels '], varProp));
    end
    
   otherwise
    error(['Variable type must be either "input" or "output"']);
    
  end
  
 case 5,
  % ===============================================
  % Handle generic inquiries related to MEMBERSHIP FUNCTIONS
  % ===============================================
  if strcmp(arg1,'input') | strcmp(arg1,'output'),
    varType=lower(arg1);
    varIndex=arg2;
    MFIndex=arg4;
    
    MFLabels=getfis(fis,varType,varIndex,'MFLabels');
    fprintf('      Name = %s\n',getfis(fis,varType,varIndex,'MF',MFIndex,'Name'));
    fprintf('      Type = %s\n',getfis(fis,varType,varIndex,'MF',MFIndex,'Type'));
    params=getfis(fis,varType,varIndex,'MF',MFIndex,'Params');
    fprintf('      Params = %s\n',mat2str(params))
    out=[];
  end
  
 case 6,
  % ===============================================
  % Handle specific inquiries related to MEMBERSHIP FUNCTIONS
  % ===============================================
  varType=lower(arg1);
  varIndex=arg2;
  MFIndex=arg4;
  MFProp=lower(arg5);
  
  switch varType 
   case 'input'
    if varIndex>numInputs,
      errStr=['There are only ',int2str(length(fis.input)), ...
              ' input variables'];
      error(errStr)
    end
    
    if MFIndex>length(fis.input(varIndex).mf),
      errStr=['There are only ',int2str(length(fis.input(varIndex).mf)), ...
              ' MFs associated with that variable'];
      error(errStr)
    end
    
    switch MFProp
     case 'name'
      out=fis.input(varIndex).mf(MFIndex).name;
     case 'type'
      out=fis.input(varIndex).mf(MFIndex).type;
     case 'params'
      out=fis.input(varIndex).mf(MFIndex).params;
     otherwise
      error(sprintf(['Invalid Membership Function property : ''%s'' \n' ... 
                     'Valid properties are : \n' ...
                     '\tname \n' ...
                     '\ttype \n' ...
                     '\tparams \n'], MFProp));
    end
    
   case 'output'
    if varIndex>numOutputs,
      errStr=['There are only ',int2str(length(fis.output)), ...
              ' output variables'];
      error(errStr)
    end
    
    if MFIndex>length(fis.output(varIndex).mf),
      errStr=['There are only ',int2str(length(fis.output(varIndex).mf)), ...
              ' MFs associated with that variable'];
      error(errStr)
    end
    
    switch MFProp
     case 'name'
      out=fis.output(varIndex).mf(MFIndex).name;
     case 'type'
      out=fis.output(varIndex).mf(MFIndex).type;
     case 'params'
      out=fis.output(varIndex).mf(MFIndex).params;
     otherwise
      error(sprintf(['Invalid Membership Function property : ''%s'' \n' ... 
                     'Valid properties are : \n' ...
                     '\tname \n' ...
                     '\ttype \n' ...
                     '\tparams \n'], MFProp));
    end
    
   otherwise
    error(['Variable type must be either "input" or "output"']);
    
  end
  
end
