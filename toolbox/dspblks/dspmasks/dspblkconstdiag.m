function varargout = dspblkconstdiag(action,q)
% DSPBLKCONSTDIAG Signal Processing Blockset Constant Diagonal Matrix block
% helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.10.4.2 $ $Date: 2004/01/25 22:36:56 $

if nargin == 0
  action = 'dynamic';
end
blk = gcbh;
fullblk = getfullname(blk);
obj = get_param(blk,'object');

switch (action)
 case 'icon'
  % q is the desired diagonal
  q_elements = q(:);
  a = diag(q_elements);
  
  % For plotting
  x = [0,NaN,100,NaN,[20 10 10 20],NaN,[84 96 96 84],NaN,[20 80]];
  y = [0,NaN,100,NaN,[90 90 10 10],NaN,[90 90 10 10],NaN,[80 20]];
  varargout = {a,x,y};
  
 case 'init'
  const_obj = get_param([fullblk '/Constant'],'object');
  enable_frame_obj = get_param([fullblk '/Frame Status Conversion'],'object');
  
  % Set frame-based behavior in underlying Frame Status Conversion block
  currentFrameStr  = enable_frame_obj.outframe;

  if strcmp(obj.frame,'on')
    % Only set to Frame-based if it isn't already set
    if ( strcmp(currentFrameStr, 'Frame-based') == 0 )
      enable_frame_obj.outframe = 'Frame-based';
    end
  else
    % Only set to Sample-based if it isn't already set
    if ( strcmp(currentFrameStr, 'Sample-based') == 0 )
      enable_frame_obj.outframe = 'Sample-based';
    end
  end
  
  % Now to set the constant block
  % SL Constant data type
  switch obj.dataType
   case 'Fixed-point'
    % set the mode
    const_obj.OutDataTypeMode = 'Specify via dialog';
    wordLen = obj.wordLen;

    if strcmpi(obj.isSigned,'on')
      outDType = ['sfix(' wordLen ')'];
    else
      outDType = ['ufix(' wordLen ')'];
    end
    const_obj.OutDataType = outDType;
    % set the scaling
    if strcmp(obj.fracBitsMode,'Best precision')
      const_obj.conRadixGroup = 'Best precision: Vector-wise';
    else
      const_obj.conRadixGroup = 'Use specified scaling';
      outScaling = ['2^(-(' obj.numFracBits '))'];
      const_obj.OutScaling = outScaling;
    end
    
   case 'User-defined'
    % set the mode
    const_obj.OutDataTypeMode = 'Specify via dialog';
    % set the data type
    udDataType = obj.udDataType;
    const_obj.OutDataType = udDataType;
    % set the scaling, if necessary
    if ~dspDataTypeDeterminesFracBits(obj.udDataType)
      if strcmp(obj.fracBitsMode,'Best precision')
        const_obj.conRadixGroup = 'Best precision: Vector-wise';
      else
        const_obj.conRadixGroup = 'Use specified scaling';
        numBits = obj.numFracBits;
        outScaling = ['2^(-(' num2str(numBits) '))'];
        const_obj.OutScaling = outScaling;
      end
    end
    
   case 'Inherit from ''Constant(s) along diagonal'''
    const_obj.OutDataTypeMode = 'Inherit from ''Constant value''';
    
   otherwise
    % DSP Constant choice maps one-to-one to Simulink Constant choice
    const_obj.OutDataTypeMode = obj.dataType;
  end
  
 case 'dynamic'
  vis = obj.MaskVisibilities;
  [vis,lastVis]=dspProcessFixptSourceParams(obj,5,1,vis);
  
  if ~isequal(vis,lastVis)
    obj.MaskVisibilities = vis;
  end
  
end
