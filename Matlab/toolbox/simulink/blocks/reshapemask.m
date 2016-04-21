function varargout = reshapemask(block, varargin)
% RESHAPEMASK Mask dynamic dialog function for Reshape block.
  
%   Modes of operation
%	varargin{1} = action =	'init' 
%          Indicates that the block initialization function is calling the 
%          code. The code should check the parameters, and report an error
%          in the case of invalid parameters. It also prepares the data
%          for the s-function block.
%  
%	varargin{1} = action =	'cbDimensionality' 
%          Enable/disable "Output dimension" field.
%
%   Author: Mojdeh Shakeri
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/10 18:16:40 $

nvarargin = nargin - 1;
switch nvarargin
 case 1
  action = varargin{1};
 otherwise
  return;
end;

dimensionality = 1;
dimensions     = 2;
Vals = get_param(block, 'maskvalues');


if(strcmp(action,'init'))

  s    = [];
  s.x1 = [];
  s.y1 = [];
  s.xc = [];
  s.yc = [];

  if(strcmp(Vals{dimensionality},'Column vector'))
    s.x1=[.4 .3 .3 .4 NaN .6 .7 .7 .6];
    s.y1=[.9 .9 .1 .1 NaN .9 .9 .1 .1];
    u=8; t=(0:u)'/u*2*pi; a=0.05;
    x=a*cos(t);y=a*sin(t);
    s.xc=x*ones(1,3) + ones(size(t))*[.5 .5 .5 ];
    s.yc=y*ones(1,3) + ones(size(t))*[.25 .5 .75];
    
  elseif(strcmp(Vals{dimensionality},'Row vector'))
    s.x1=[.2 .1 .1 .2 NaN .8 .9 .9 .8];
    s.y1=[.7 .7 .3 .3 NaN .7 .7 .3 .3];
    u=8; t=(0:u)'/u*2*pi; a=0.05;
    x=a*cos(t);y=a*sin(t);
    s.xc=x*ones(1,3) + ones(size(t))*[.25 .5 .75];
    s.yc=y*ones(1,3) + ones(size(t))*[.5 .5 .5 ];
  end
  
  if(strcmp(Vals{dimensionality},'1-D array'))
    dispStr = 'disp(''U( : )'')';
  elseif(strcmp(Vals{dimensionality},'Column vector'))
    dispStr = 'plot(s.x1,s.y1,s.xc,s.yc);';
  elseif(strcmp(Vals{dimensionality},'Row vector'))
    dispStr = 'plot(s.x1,s.y1,s.xc,s.yc);';
  else
    dispStr = 'disp(''Reshape'')';
  end
  set_param(block,'MaskDisplay',dispStr)

  varargout{1} = s; 
end

%******************************************************************************
% Function:      cbDimensionality
% Description:   Enable/Disable output dimension field
% Inputs:        current block
% Return Values: none
%******************************************************************************
if(strcmp(action,'cbDimensionality'))
  En = get_param(block, 'maskenables');
  if(strcmp(Vals{dimensionality},'Customize'))
    En{dimensions} = 'on';
  else
    En{dimensions} = 'off';
  end
  set_param(block,'maskenables', En);
end;

