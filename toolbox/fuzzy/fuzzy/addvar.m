function out=addvar(fis,varType,varName,varRange,varargin)
%   Purpose
%   Add a variable to an FIS.
%
%   Synopsis
%   a = addvar(a,varType,varName,varBounds)
%
%   Description
%   addvar has four arguments in this order:
%   the FIS name
%   the type of the variable (input or output)
%   the name of the variable
%   the vector describing the limiting range for the variable
%   Indices are applied to variables in the order in which they are added, so
%   the first input variable added to a system will always be known as input
%   variable number one for that system. Input and output variables are
%   numbered independently.
%
%   Example
%   a=newfis('tipper');
%   a=addvar(a,'input','service',[0 10]);
%   getfis(a,'input',1)
%   MATLAB replies
%   	Name = service
%   	NumMFs = 0
%   	MFLabels =
%   	Range = [0 10]
%
%   See also 
%   addmf, addrule, rmmf, rmvar

%   The argument varagin = 'init' is a flag to create a default set of
%   three membership functions.

%   Kelly Liu, 7-10-96,   N. Hickey,27-02-01
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.30 $  $Date: 2002/04/14 22:21:40 $

out=fis;
numRules=length(fis.rule);
da = 0;  % A small increment to set mf parameter values

if strcmp(lower(varType),'input'),
    % Check that the input field exists
    if isfield(fis,'input')
        index = length(fis.input) + 1;
    else
        index = 1;
    end
    
    if index == 1
        out.input = struct('name',[],...
            'range',[],...
            'mf',[]);
    else
        out.input(index) = struct('name',[],...
            'range',[],...
            'mf',[]);
    end
    
    out.input(index).name=varName;
    out.input(index).range=varRange;
    
    if nargin == 5 & isempty(out.input(index).mf) 
        % Create default input membership functions
        out.input(index).mf = struct('name',cell(1,3),'type','trimf','params',[]);
        for id = 1:3
            out.input(index).mf(id).name   = sprintf('mf%i',id);
            out.input(index).mf(id).params = [-0.4+da 0.0+da 0.4+da];
            da = da + 0.5;
        end
    end
    
    % Need to insert a new column into the current rule list
    if numRules
        % Don't bother if there aren't any rules
        for i=1:numRules
            out.rule(i).antecedent(index)=0;
        end
    end
    
elseif strcmp(lower(varType),'output'),
    % Check that the output field exists
    if isfield(fis,'output')
        index = length(fis.output)+1;
    else
        index = 1;
    end
    
    if index == 1
        out.output = struct('name',[],...
            'range',[],...
            'mf',[]);
    else
        out.output(index) = struct('name',[],...
            'range',[],...
            'mf',[]);
    end
    
    out.output(index).name=varName;
    out.output(index).range=varRange;
    
    if nargin == 5 & isempty(out.output(index).mf) 
        if strcmp(fis.type,'mamdani')
            % Create default output membership functions
            out.output(index).mf = struct('name',cell(1,3),'type','trimf','params',[]);
            for id = 1:3
                out.output(index).mf(id).name   = sprintf('mf%i',id);
                out.output(index).mf(id).params = [-0.4+da 0.0+da 0.4+da];
                da = da + 0.5;
            end
        else % It must be a Sugeno type
            % Create default output membership functions
            out.output(index).mf = struct('name',cell(1,3),'type','constant','params',[]);
            for id = 1:3
                out.output(index).mf(id).name   = sprintf('mf%i',id);
                out.output(index).mf(id).params = da;
                da = da + 0.5;
            end
        end
    end
    % Need to insert a new column into the current rule list
    if numRules
        % Don't bother if there aren't any rules     
        for i=1:numRules
            out.rule(i).consequent(index)=0;
        end
    end   
    
end