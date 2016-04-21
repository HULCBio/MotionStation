function out=setfis(fis,arg1,arg2,arg3,arg4,arg5,arg6)
%SETFIS Set fuzzy inference system properties.
%   FIS2 = SETFIS(FIS1,'fisPropName',newPropValue) returns the FIS matrix
%   FIS2 which is identical to FIS1 except that the FIS property 
%   corresponding to 'fisPropName' is set to newPropValue.
%
%   FIS2 = SETFIS(FIS1,varType,varIndex,'varPropName',newPropValue)
%   returns FIS2, in which a property associated with the variable
%   specified by varType and varIndex has been set to a new value.
%
%   FIS2 = SETFIS(FIS1,varType,varIndex,'mf',mfIndex, ...
%           'mfPropName',newPropValue) returns FIS2, in which a property 
%   associated with the membership function specified by varType,
%   varIndex, and mfIndex has been set to a new value.
%
%   For example:
%
%           a=newfis('tipper');
%           a=addvar(a,'input','service',[0 10]);
%           a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
%           a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);
%           getfis(a)
%           a=setfis(a,'Name','tip_example');
%           a=setfis(a,'DefuzzMethod','bisector');
%           a=setfis(a,'input',1,'Name','quality');
%           getfis(a)
%
%   See also GETFIS.

%   Kelly Liu 4-30-96
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/14 22:22:24 $

numInputs=length(fis.input);
numOutputs=length(fis.output);


if nargin==1,
   indent=32*ones(1,8);
   fprintf('      Name\n');
   fprintf('      Type\n');
   fprintf('      AndMethod\n');
   fprintf('      OrMethod\n');
   fprintf('      ImpMethod\n');
   fprintf('      AggMethod\n');
   fprintf('      DefuzzMethod\n');
   fprintf('      InMFParams\n');
   fprintf('      OutMFParams\n');
   fprintf('      RuleList\n');

elseif nargin==3,
    propName=lower(arg1);
    newVal=arg2;
 
    if strcmp(propName,'name'),
        fis.fisName=arg2;
        out=fis;

    elseif strcmp(propName,'type'),
        fis.fisType=arg2;
        out=fis;

    elseif strcmp(propName,'andmethod'),
        fis.andMethod=arg2;
        out=fis;

    elseif strcmp(propName,'ormethod'),
        fis.orMethod=arg2;
        out=fis;

    elseif strcmp(propName,'impmethod'),
        fis.impMethod=arg2;
        out=fis;

    elseif strcmp(propName,'aggmethod'),
        fis.affMethod=arg2;
        out=fis;

    elseif strcmp(propName,'defuzzmethod'),
        fis.defuzzMethod=arg2;
        out=fis;

    elseif strcmp(propName,'inlabels'),
        error('You may not set this property directly');

    elseif strcmp(propName,'outlabels'),
        error('You may not set this property directly');

    elseif strcmp(propName,'inmflabels'),
        error('You may not set this property directly');

    elseif strcmp(propName,'outmflabels'),
        error('You may not set this property directly');

    elseif strcmp(propName,'inrange'),
        error('You may not set this property directly');

    elseif strcmp(propName,'outrange'),
        error('You may not set this property directly');

    elseif strcmp(propName,'inmftypes'),
        error('You may not set this property directly');

    elseif strcmp(propName,'outmftypes'),
        error('You may not set this property directly');
 
    elseif strcmp(propName,'rulelist'),
        
        fis.ruleList=arg2;
        out=fis;

    else
        error(['There is no FIS system property called ', propName]);

    end

% ===============================================
% Handle VARIABLES
% ===============================================
elseif nargin==5,
    % Name assignment
    % ===========================================
    varType=lower(arg1);
    varIndex=arg2;
    varProp=lower(arg3);
    newVal=arg4;
 
    if strcmp(varType,'input'),
        if varIndex>numInputs,
            error(['There are not that many input variables.']);
        end

        if strcmp(varProp,'name'),            
            fis.FSInput(arg2).name=arg4;
            out=fis;
        end

        if strcmp(varProp,'range'),
            fis.FSInput(arg2).range=arg4;
            out=fis;
        end

        if strcmp(varProp,'nummfs'),
            error('You may not set this property directly');
        end

        if strcmp(varProp,'mflist'),
            error('You may not set this property directly');
        end

    elseif strcmp(varType,'output'),
        % Range checking
        if varIndex>numOutputs,
            error(['There are not that many output variables.']);
        end

        if strcmp(varProp,'name'),
           
           fis.Output(arg2).name=arg4;
            out=fis;
        end

        if strcmp(varProp,'range'),
            fis.Output(arg2).range=arg4;
            out=fis;
        end

        if strcmp(varProp,'nummfs'),
            error('You may not set this property directly');
        end

        if strcmp(varProp,'mflist'),
            error('You may not set this property directly');
        end

    else
        disp(['Variable type must be either "input" or "output"']);

    end

 
% ===============================================
% Handle MEMBERSHIP FUNCTIONS
% ===============================================
elseif nargin==7,
    % Name assignment
    % ===========================================
    varType=lower(arg1);
    varIndex=arg2;
    MFIndex=arg4;
    MFProp=lower(arg5);
    newVal=arg6;

 
    if strcmp(varType,'input'),

        % Range checking
        % =======================================
        if varIndex>numInputs,
            error(['There are not that many input variables.']);
        end

        if MFIndex>size(fis.FSInput(varIndex).MF, 2),
            errStr=['There are only ',int2str(size(fis.FSInput(varIndex).MF, 2)), ...
                ' MFs associated with that variable'];
            error(errStr)
        end
        
        

        if strcmp(MFProp,'name'),
            
            fis.FSInput(arg2).MF(arg4).MFLabel=arg6;
            out=fis;
        end

        if strcmp(MFProp,'type'),
            fis.FSInput(arg2).MF(arg4).MFType=arg6;
            out=fis;
        end

        if strcmp(MFProp,'params'),
            fis.FSInput(arg2).MF(arg4).MFParams=arg6;
            out=fis;
        end

    elseif strcmp(varType,'output'),
        % Range checking
        % =======================================
        if varIndex>numOutput,
            error(['There are not that many output variables.']);
        end

        MFRowIndex=sum(numOutputMFs(1:(varIndex-1)))+MFIndex;

        if strcmp(MFProp,'name'),
            fis.Output(arg2).MF(arg4).MFLabel=arg6;
            out=fis;
        end

        if strcmp(MFProp,'type'),
            fis.Output(arg2).MF(arg4).MFType=arg6;
            out=fis;
        end

        if strcmp(MFProp,'params'),            
            fisType=fis.Type;
            MFType=fis.Output(arg2).MF(arg4).MFType;
            if strcmp(fisType,'sugeno') & strcmp(MFType,'constant'),
                % Sugeno systems with constant output functions should only have
                % one parameter, and it should go in the numInputs+1 column
                arg6=[0 arg6];
            end

            fis.Output(arg2).MF(arg4).MFParams=arg6;
            out=fis;
        end
    end
end


