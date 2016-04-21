function plotlr(lr,t)
%PLOTLR Plot network learning rate vs epochs.
%  
%  This function is obselete.

nntobsf('barerr','Use BAR to make bar plots.')

%  PLOTLR(LR,T)
%    LR - row vector of network learning rates.
%         The first value is associated with
%         epoch 0, the second with epoch 1, etc.
%    T  - (Optional) String for graph title.
%         Default is 'Network Learning Rate'.

% Mark Beale, 1-31-92
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:15:30 $

if nargin > 2 | nargin < 1
  error('Wrong number of arguments.');
end

plot(0:length(lr)-1,lr);
xlabel('Epoch')
ylabel('Learning Rate')

if nargin == 1
  title('Network Learning Rate')
else
  title(t)
end
