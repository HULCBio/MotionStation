function varargout = commblkapp(block, varargin)
% COMMBLKAPP Mask dynamic dialog function for APP Decoder block.
  
%   Modes of operation
%	varargin{1} = action =	'init' 
%          Indicates that the block initialization function is calling the 
%          code. The code should check the parameters, and report an error
%          in the case of invalid parameters. It also prepares the data
%          for the s-function block.
%
%	varargin{1} = 'cbAlgorithm'
%         Enables/Disables 'Number of scaling bits'  based on algorithm.

%   Author: Mojdeh Shakeri
%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/03/24 02:01:01 $

nvarargin = nargin - 1;
switch nvarargin
case 1
    action = varargin{1};
case 5
    action     = varargin{1};
    trellis    = varargin{2};
    termMethod = varargin{3};
    algorithm  = varargin{4};
    maxStarNumScaleBits = varargin{5};
end;

%******************************************************************************
% Function:      initialize
% Description:   Check dialog parameters and fill the output structure.
% Inputs:        current block
% Return Values: s (structure with required fields for the S-function block)
%******************************************************************************
if(strcmp(action,'init'))
    s                  = [];
    s.k                = [];
    s.n                = [];
    s.numStates        = [];
    s.nextStates       = [];
    s.outputs          = [];
    s.termMethod       = [];
    s.algorithm        = [];
    s.maxStarTable     = [];
    s.maxStarTableLen  = 0 ;
    s.maxStarScale     = 1 ;
    s.status           = '';
    
    % Do not evaluate/check the parameters if the simulation status is 'stopped'.
    % This is the case when loading a model with the block in it. 
    simStat = get_param(bdroot(gcb),'SimulationStatus');
    if(strcmpi(simStat,'stopped'))
        varargout{1} = s;
        return;
    end;
    
    [isOk, status] = istrellis(trellis);
    if ~isOk, 
        s.status = sprintf('Invalid trellis structure. %s', status); 
    else,
        if algorithm == 2, % max*
            numBits = maxStarNumScaleBits;
            if isempty(numBits) | length(numBits) ~= 1 | ...
                    double(uint32(numBits)) ~= numBits | numBits > 8,
                s.status = ['Invalid number of bits specified for scale factor ' ...
                        'in max* algorithm. Number of scaling bits must be ' ...
                        'a nonnegative scalar between 0 and 8'];
            else
                % For 0 to 8, I generated the table. lookup is an over estimate of
                % points to be evaluated.
                lookup          = [10 10 10 30 60 140 320 720 1600];
                upTo            = lookup(numBits+1);
                t               = [0:upTo]; 
                scale           = 2 ^ numBits; 
                temp1             = round(scale*log(1+exp(-t/scale)));
                temp              = find(temp1);
                s.maxStarTableLen = temp(end);
                s.maxStarTable    = temp1(1:s.maxStarTableLen);
                s.maxStarScale    = 2^maxStarNumScaleBits;
            end
        else
            s.maxStarTableLen  = 0;
            s.maxStarTable     = [];
            s.maxStarScale     = 1;
        end        
        if isempty(s.status)
            s.k          = log2(trellis.numInputSymbols);
            s.n          = log2(trellis.numOutputSymbols);
            s.numStates  = trellis.numStates;
            s.nextStates = trellis.nextStates;
            s.outputs    = oct2dec(trellis.outputs);
            s.termMethod = termMethod;
            s.algorithm  = algorithm;
        end
    end
    varargout{1} = s;      
end;

%******************************************************************************
% Function:      cbAlgorithm
% Description:   Enable/Disable 'Number of scaling bits'  based on algorithm.
% Inputs:        current block
% Return Values: none
%******************************************************************************
if(strcmp(action,'cbAlgorithm'))
    Vals = get_param(block, 'maskvalues');
    % Field numbers
    %Trellis       = 1;
    %TermMethod    = 2;
    Algorithm      = 3;
    NumScalingBits = 4;
    
    En = get_param(block, 'maskenables');
    if(strcmp(Vals{Algorithm},'Max*'))
        En{NumScalingBits} = 'on';
    else
        En{NumScalingBits} = 'off';
    end
    set_param(block,'maskenables', En);
end;

% [EOF]
