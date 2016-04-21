function dng_dial_set(varargin)
%DNG_DIAL_SET Callback that processes dial events.
%   This file is called when the specified event(s) occur on any
%   ActiveX block. It sets the dialOut parameter in the current block
%   and this, in turn, gets output from the ActiveX block.
  
%   Author(s): P. Barnard
%   Copyright 1998-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $ $Date: 2003/12/15 15:53:12 $
 
% Get the handle of the control.
% varargin{1} contains the activex block handle in this case.
hActx = varargin{1};
  
% Find the block that contains the control.

blkPath = get(hActx,'BlockPath');
try,
  blk = get_param(blkPath,'Handle');
catch,
   blk = [];
end    


% if we have found the block...
if ~isempty(blk)
    if( ~strcmp(get_param(bdroot(blk),'lock'), 'on' ) )
      % Get the property the control has output.
      outProps = get_param(blk, 'output');
        
      % Error case
      if isempty(outProps),
        error(sprintf('\nNo output property set for block %s',blk));
      end
     
      % Process the output properties into a cell array.
      outProps = ['{''' outProps '''}'];
      outProps = strrep(outProps,' ','');
      outProps = strrep(outProps,',',''',''');
      outProps = eval(outProps);

      % Get the property values of the dial.
      val = zeros(length(outProps),1);
      for i = 1:length(outProps),
          if( outProps{i}(1) ~= '%' ),
        val(i) = get(hActx,outProps{i});
      end
      end

      % Set the output param dialOut on the block.
      % Note: dialOut is expecting a column vector.
      set_param(blk,'DisableBlockRedraw','on','dialOut',mat2str(val));
      ax_block('dial_set',blk);
   end
end






