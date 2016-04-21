function newmoves=mpc_chkm(moves,p,default)

%MPC_CHKM Check control horizon

%    A. Bemporad
%    Copyright 2001-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2004/04/16 22:09:07 $ 

% checks if moves is ok.

swarn=warning;
warning backtrace off; % to avoid backtrace

verbose=warning('query','mpc:verbosity');
verbose=strcmp(verbose.state,'on');

if ~isa(moves,'double'),
   error('mpc:mpc_chkm:mtype','ControlHorizon must be a scalar or an array');
elseif isempty(moves)
   newmoves=min(default,p);
   if verbose,
      fprintf('-->No ControlHorizon specified. Assuming ControlHorizon=%d\n',newmoves);
   end
else
   [nrow,nb]=size(moves);
   if nrow>nb, 
      moves=moves';
      [nrow,nb]=size(moves);
   end
   if nrow ~= 1 | nb < 1
      error('mpc:mpc_chkm:msize','ControlHorizon has a wrong size');
   end
   if any(moves < 1)
      error('mpc:mpc_chkm:pos','ControlHorizon contains an element that is smaller than 1');
   end
   
   if nb == 1
      
      %  This section interprets "moves" as a number of moves, each
      %  of one sampling period duration.
      
      if moves > p
         warning('mpc:mpc_chkm:mtruncated','ControlHorizon > PredictionHorizon.  Truncated.')
         
         moves=p;
      elseif moves <= 0
         warning('mpc:mpc_chkm:mneg',sprintf('ControlHorizon <= 0.  Setting ControlHorizon = %d.',default));
         moves=default;
      end
      
   else
      
      % This section interprets "moves" as a vector of blocking factors.
      summoves=sum(moves);
      if summoves > p
         warning('mpc:mpc_chkm:summtruncated','sum(ControlHorizon) > PredictionHorizon. Control moves will be truncated.')
         nb=find(cumsum(moves) > p);
         nb=nb(1);
         moves=moves(1,1:nb-1);
         moves(nb)=p-sum(moves);
         if nb==1,    % If the vector has only one component,
            % than number of moves=1
            moves=1;
         end
      elseif summoves < p
         nb=nb+1;
         moves(nb)=p-summoves;
         %disp('Warning: sum(M) < P.  Will extend to P.')
         %disp(' ')
      end
      if moves(end)==0,
         moves(end)=[];
      end
   end
   newmoves=moves;   
end

% end mpc_chkm
