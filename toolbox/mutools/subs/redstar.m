% function sys = redstar(top,bot,dim1,dim2)
%
%   interconnects two SYSTEM matrices as a Redheffer product.
%   main subroutine for STARP.
%
%   See also: STARP.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function sys = redstar(top,bot,dim1,dim2)
 if nargin < 4
   disp('usage: sys = redstar(top,bot,dim1,dim2)')
   return
 end
 [toptype,toprows,topcols,topnum] = minfo(top);
 [bottype,botrows,botcols,botnum] = minfo(bot);
 if toptype == 'syst'
   topstates = topnum;
   acttop = top(1:topnum+toprows,1:topnum+topcols);
 elseif toptype == 'cons'
   topstates = 0;
   acttop = top;
 else
   error('VARYING matrices not allowed')
   return
 end
 if bottype == 'syst'
   botstates = botnum;
   actbot = bot(1:botnum+botrows,1:botnum+botcols);
 elseif bottype == 'cons'
   botstates = 0;
   actbot = bot;
 else
   error('VARYING matrices not allowed')
   return
 end
 nrb = botstates + botrows;
 ncb = botstates + botcols;
 states = topstates+botstates;
 orderrow = [botstates+1:nrb 1:botstates];
 ordercol = [botstates+1:ncb 1:botstates];
 rebot = actbot(orderrow,ordercol);
 out = genlft(acttop,rebot,dim1,dim2);
 [nro nco] = size(out);
 orderrow = [1:topstates nro-botstates+1:nro topstates+1:nro-botstates];
 ordercol = [1:topstates nco-botstates+1:nco topstates+1:nco-botstates];
 out = out(orderrow,ordercol);
 if states == nro | states == nco
%  if ALL of the inputs and outputs are closed,
%  return the closed loop "A" matrix as a CONSTANT matrix
   sys = out;
 else
   sys = pck(out(1:states,1:states),out(1:states,states+1:nco),...
             out(states+1:nro,1:states),out(states+1:nro,states+1:nco));
 end
%
%