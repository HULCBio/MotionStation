function dspskipblk(pblk, opts, skip)
% DSPSKIPBLK Replace selected blocks with a short-circuit.
%  The short-circuit is achieved by replacement with a MUX.

% This function is not intended for general use.
% In the LMS filter blocks, it is used to "switch out" energy
% normalization when the normalization option is deselected.

%  DSPSKIPBLK(parent, opts, skip)
%  Currently works only for blocks with an identical number of
%  inputs and outputs.  Connects inputs to corresponding outputs
%  in order or appearance.
%
% From a mask initialization command:
%    parent    = gcb;
%    opts.name = 'Normalization';
%    opts.src  = 'dspvect/Normalization';
%    opts.args = {'NormType','2', 'Bias','1e-10'};
%    skip      = skip_opt;  % 0=use block, 1=use MUX
%    dspskipblk(gcb,opts,skip)
%
% If the block's parent is a library link, the mask must be self-modifiable.

% D. Orofino
% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.6 $ $Date: 2002/04/14 20:53:12 $

error(nargchk(3,3,nargin));

if ~isstruct(opts),
   errordlg('Options must be specified as a structure','DSPSkipBlk');
   return;
end
if ~isfield(opts,'name') | ~isfield(opts,'src') | ~isfield(opts,'args'),
   errordlg({'Options structure must have the following fields:','.name, .src, .args'},'DSPSkipBlk');
   return;
end


for i=1:length(opts),
   
	% Block to replace:
   blk = [pblk '/' opts(i).name];
   
   % Record position and type of block:
   pos = get_param(blk,'position');
   typ = get_param(blk,'blocktype');
   
   if skip,
      % If block is already a MUX, nothing to do
      if strcmp(typ,'Mux'), return; end
      
      % Determine # of ports:
      % Can only have input and output ports (no state/enable/trigger)
      % Must have identical # of in and out ports
      ports = get_param(blk,'ports');
      if any(ports(3:5)),
		   errordlg({'Block cannot have state, enable, or trigger ports'},'DSPSkipBlk');
		   return;
      end
      if (ports(1) ~= ports(2)),
		   errordlg({'Block must have an equal number of input and output ports'},'DSPSkipBlk');
		   return;
		end
     
      % Otherwise, block is an S-Function
      delete_block(blk);
      
      % Add a MUX with recorded position and 1 input:
      add_block('built-in/Mux', blk, 'position',pos, ...
         'inputs',num2str(ports(1)));
      
   else
      % Disable not checked
      % If block is not a MUX, then assume we've already got the right block
      if ~strcmp(typ,'Mux'), return; end
      
      % Otherwise, block is a MUX
      delete_block(blk);
      
      % Add an S-Function with recorded position
      libName = fileparts(opts(i).src);
      load_system(libName);  % Make sure dependent library is loaded
      add_block(opts(i).src, blk, 'position',pos, ...
         opts(i).args{:});
   end
end

% end of dspskipblk.m
