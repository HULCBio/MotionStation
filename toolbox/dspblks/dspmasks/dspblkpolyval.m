function [p,xy] = dspblkpolyval(action,varargin)
% DSPBLKPOLYVAL is the mask function for the Signal Processing Blockset Polynomial Block


% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.5.4.2 $ $Date: 2004/04/12 23:07:04 $

if nargin==0
   action = 'dynamic';
else
   action = 'icon';
end

% Cache the block handle once
blk     = gcbh;
fullblk = getfullname(blk);

switch action 
   case 'dynamic',
      % Execute dynamic dialogs      
      mask_enables = get_param(blk,'maskenables');
      mask_visibilities = get_param(blk,'maskvisibilities');
   
      % Dynamic dialog callback: based on checkbox for Constant Coeffs.
      % If useConstCoeffs box is checked, then enable coeff param, o/w disable.
      if strcmp(get_param(blk,'useConstCoeffs'),'on'),
         mask_enables{2} = 'on';
         mask_visibilities{2} = 'on';
      else,
         mask_enables{2} = 'off';
         mask_visibilities{2} = 'on';
      end
   
      set_param(blk,'maskenables',mask_enables);
      set_param(blk,'maskvisibilities',mask_visibilities);   

   case 'icon',
      % Setup icon display

      % Setup Inport label(s). There could be one or two depending
      % on how the user sets up block for coefficients source.
      % No matter what, the first inport is always the 'X' input.

      p.in1 = 'input';    % Choose the side of block to label
      p.in2 = 'input';    % Choose the side of block to label
      p.i1 = 1; p.i1s = '';
      p.i2 = 1; p.i2s = ''; % Assume ONE input only for now

      % Setup Outport label.  Only one exists.
      p.out = 'output';  % Choose the side of block to label
      p.o1 = 1; p.o1s = '';

      coeffsAreNotConst = strcmp(get_param(blk,'useConstCoeffs'),'off');

      if(coeffsAreNotConst)
         % Setup the 1st input label to indicate input signal
         p.i1 = 1; p.i1s = 'In';
         % Setup the 2nd input label for poly coefficient inputs
         p.i2 = 2; p.i2s = 'Coeffs'; 
         % Setup the output label
         p.o1 = 1; p.o1s = 'Out';
      end

      % Setup block title
      xy.blklabel = 'Polynomial';

end % end of switch

% [EOF] dspblkpoly.m
