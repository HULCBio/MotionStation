function varargout = dspblkwinfcn(action,Rs,beta)
% DSPBLKWINFCN Signal Processing Blockset Window Function block helper function
% for mask parameters.


% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.11.4.2 $ $Date: 2004/04/12 23:07:44 $

if nargin==0, action = 'dynamic'; end
blk = gcbh;

switch action
case 'icon'
   [x,y,str]=get_window(blk,Rs,beta);
   ports = get_labels(blk);
   varargout = {x,y,str,ports};
   
case 'dynamic'
   mask_enables_orig = get_param(blk,'maskenables');
   mask_enables = mask_enables_orig;
   
   % Determine if input width edit box is required (only if generate mode)
   % Determine if # channels edit box is visible (not if generate mode)
   wmode = get_param(blk,'winmode');
   if strcmp(wmode,'Generate window'),
      mask_enables{3}='on';
      mask_enables{7}='off';
   else
      mask_enables{3}='off';
      mask_enables{7}='on';
   end
   
   
   % Determine if Ripple, Beta, or Sampling modes are required:
   wtype = get_param(blk,'wintype');
   
   % Generalized cosine windows:
   i=strmatch(wtype,{'Blackman','Hamming','Hanning','Hann'});
   
   if ~isempty(i),
      mask_enables{4} = 'off';
      mask_enables{5} = 'off';
      mask_enables{6} = 'on';
      
   else
      % Only generalized cosine windows can have periodic sampling:
      mask_enables{6} = 'off';
      
      if strcmp(wtype,'Chebyshev'),
         mask_enables{4} = 'on';
         mask_enables{5} = 'off';
         
      elseif strcmp(wtype,'Kaiser'),
         mask_enables{4} = 'off';
         mask_enables{5} = 'on';
      else
         mask_enables{4} = 'off';
         mask_enables{5} = 'off';
      end
   end
   
   if ~isequal(mask_enables,mask_enables_orig),
      set_param(blk,'maskenables',mask_enables);
   end
   
end
return

% ----------------------------------------------------------
function [xw,yw,wtxt] = get_window(blk,Rs,beta)

N=32;
wintype = get_param(blk,'wintype');
winsamp = get_param(blk,'winsamp');

use_samp = ~isempty(strmatch(wintype,{'Blackman','Hamming','Hanning','Hann'}));
sflag = lower(winsamp);

switch wintype,
  case 'Bartlett',
    s={'bartlett',N};
  case 'Blackman',
    s={'blackman',N,sflag};
  case 'Boxcar',
    s={'boxcar',N};
  case 'Chebyshev',
    s={'chebwin',N,Rs};
  case 'Hamming',
    s={'hamming',N,sflag};
  case 'Hann',
    s={'hann',N,sflag};
  case 'Hanning',
    s={'hanning',N,sflag};
  case 'Kaiser',
    s={'kaiser',N,beta};
  case 'Triang',
    s={'triang',N};
end

% For icon:
try
   % None of the window fcn arguments should be empty.
   % It's either a user mistake, or the mask variable
   % was undefined.  We wish to suppress all warnings
   % from the window design functions, and to produce
   % a default icon for the block:
   anyEmpty = 0;
   for i=2:length(s),
      if isempty(s{i}),
         anyEmpty=1;
         break;
      end
   end
   if anyEmpty,
      w=zeros(N,1);
   else
      w=feval(s{:});
   end
catch
   % Any other errors:
   w=zeros(N,1);
end

wtxt=s{1}; xw=(0:N-1)/(N-1)*0.75+0.05; yw=w*.65;

return

% ----------------------------------------------------------
function ports = get_labels(blk)   
wmode = get_param(blk,'winmode');

% Input port labels:
switch wmode
case 'Generate window'
   % One label on output:
   ports(1).type='output';
   ports(1).port=1;
   ports(1).txt='';
   
   ports(2).type='output';
   ports(2).port=1;
   ports(2).txt='';
   
   ports(3).type='output';
   ports(3).port=1;
   ports(3).txt='Win';
   
case 'Apply window to input'
   % No labels:
   ports(1).type='input';
   ports(1).port=1;
   ports(1).txt='';
   
   ports(2).type='output';
   ports(2).port=1;
   ports(2).txt='';
   
   ports(3).type='output';
   ports(3).port=1;
   ports(3).txt='';
   
case 'Generate and apply window'
   % Label all ports:
   ports(1).type='input';
   ports(1).port=1;
   ports(1).txt='In';
   
   ports(2).type='output';
   ports(2).port=1;
   ports(2).txt='Out';
   
   ports(3).type='output';
   ports(3).port=2;
   ports(3).txt='Win';
end

return

% [EOF] dspblkwinfcn.m
