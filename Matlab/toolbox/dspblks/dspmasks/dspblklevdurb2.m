function varargout = dspblklevdurb2(action, varargin)
% DSPBLKLEVDURB Signal Processing Blockset Levinson-Durbin block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.3.4.2 $ $Date: 2004/04/12 23:06:47 $

if nargin==0, action = 'dynamic'; end
blk = gcbh;   % Cache handle to block

switch action
    
case 'init'
    dtInfo = dspGetFixptDataTypeInfo(blk,111);
    varargout = {dtInfo};
    
case 'setup'

    coeffOutFcn = varargin{1};
    outP = varargin{2};

    s    = [];
    s.o1 = 1; s.o1s = '';
    s.o2 = 1; s.o2s = '';
    s.o3 = 1; s.o3s = '';

    switch coeffOutFcn
    case 1,
        % CASE: A and K
        if (outP == 1)
        % 3 outputs (A,K,P)
        s.o1 = 1; s.o1s = 'A';
        s.o2 = 2; s.o2s = 'K';
        s.o3 = 3; s.o3s = 'P';
        else
        % 2 outputs (A,K)
        s.o2 = 1; s.o2s = 'A';
        s.o3 = 2; s.o3s = 'K';
        end
    case 2,
        % CASE: A
        if (outP == 1)
        % 2 outputs (A,P)
        s.o2 = 1; s.o2s = 'A';
        s.o3 = 2; s.o3s = 'P';
        else
        % 1 output (A)
        s.o3 = 1; s.o3s = 'A';
        end
    otherwise
	% CASE: K
        if (outP == 1)
        % 2 outputs (K,P)
        s.o2 = 1; s.o2s = 'K';
        s.o3 = 2; s.o3s = 'P';
        else
        % 1 output (K)
        s.o3 = 1; s.o3s = 'K';
        end
    end
    varargout = {s};

case 'dynamic'
  curVis = get_param(blk,'maskvisibilities');
  [curVis,lastVis] = dspProcessFixptMaskParams(blk,curVis);
  if ~isequal(curVis,lastVis)
    set_param(blk,'maskvisibilities',curVis);
  end
  
otherwise
    error('unhandled case');
end

% [EOF] dspblklevdurb2.m
