function solver_output = odefinalize(solver, sol,...
                                     outfun, outargs,...
                                     printstats, statvect,...
                                     nout, tout, yout,...
                                     haveeventfun, teout, yeout, ieout,...
                                     interp_data)
%ODEFINALIZE Helper function called by ODE solvers at the end of integration.
%
%   See also ODE113, ODE15I, ODE15S, ODE23, ODE23S, ODE23T, ODE23TB, ODE45, DDE23.

%   Jacek Kierzenka
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/02/09 07:49:49 $

if ~isempty(outfun)
  feval(outfun,[],[],'done',outargs{:});
end

fullstats = ismember(solver,{'ode15i','ode15s','ode23s','ode23t','ode23tb'});

stats = struct('nsteps',statvect(1),'nfailed',statvect(2),'nfevals',statvect(3)); 
if fullstats
  stats.npds     = statvect(4);
  stats.ndecomps = statvect(5);
  stats.nsolves  = statvect(6);  
else 
  statvect(4:6) = 0;   % Backwards compatibility
end  

if printstats
  fprintf('%g successful steps\n', stats.nsteps);
  fprintf('%g failed attempts\n', stats.nfailed);
  fprintf('%g function evaluations\n', stats.nfevals);
  if fullstats
    fprintf('%g partial derivatives\n', stats.npds);
    fprintf('%g LU decompositions\n', stats.ndecomps);
    fprintf('%g solutions of linear systems\n', stats.nsolves);
  end
end

solver_output = {};

if (nout > 0) % produce output
  if isempty(sol) % output [t,y,...]
    solver_output{1} = tout(1:nout).';
    solver_output{2} = yout(:,1:nout).';
    if haveeventfun
      solver_output{3} = teout.';
      solver_output{4} = yeout.';
      solver_output{5} = ieout.';
    end
    solver_output{end+1} = statvect(:);  % Column vector
  else % output sol  
    % Add remaining fields
    sol.x = tout(1:nout);
    sol.y = yout(:,1:nout);
    if haveeventfun
      sol.xe = teout;
      sol.ye = yeout;
      sol.ie = ieout;
    end
    sol.stats = stats;
    switch solver
     case 'ode113'
      [klastvec,phi3d,psi2d] = deal(interp_data{:});
      sol.idata.klastvec = klastvec(1:nout);
      kmax = max(sol.idata.klastvec);
      sol.idata.phi3d = phi3d(:,1:kmax+1,1:nout);
      sol.idata.psi2d = psi2d(1:kmax,1:nout);
     case 'ode15i'      
      [kvec,ypfinal] = deal(interp_data{:});
      sol.idata.kvec = kvec(1:nout);
      sol.extdata.ypfinal = ypfinal;
     case 'ode15s'      
      [kvec,dif3d] = deal(interp_data{:});
      sol.idata.kvec = kvec(1:nout);
      maxkvec = max(sol.idata.kvec);
      sol.idata.dif3d = dif3d(:,1:maxkvec+2,1:nout);
     case 'ode23'
      sol.idata.f3d = interp_data(:,:,1:nout);
     case 'ode23s'
      [k1data,k2data] = deal(interp_data{:});
      sol.idata.k1 = k1data(:,1:nout);
      sol.idata.k2 = k2data(:,1:nout);
     case 'ode23t'
      [zdata,znewdata] = deal(interp_data{:});
      sol.idata.z = zdata(:,1:nout);
      sol.idata.znew = znewdata(:,1:nout);      
     case 'ode23tb'
      [t2data,y2data] = deal(interp_data{:});
      sol.idata.t2 = t2data(1:nout);
      sol.idata.y2 = y2data(:,1:nout);           
     case 'ode45'
      sol.idata.f3d = interp_data(:,:,1:nout);      
     case 'dde23'
      [history,ypout] = deal(interp_data{:});
      sol.yp = ypout(:,1:nout);
      if isstruct(history)
        sol.x = [history.x sol.x];
        sol.y = [history.y sol.y];
        sol.yp = [history.yp sol.yp];
        if isfield(history,'xe')
          if isfield(sol,'xe')
            sol.xe = [history.xe sol.xe];
            sol.ye = [history.ye sol.ye];
            sol.ie = [history.ie sol.ie];
          else
            sol.xe = history.xe;
            sol.ye = history.ye;
            sol.ie = history.ie;
          end
        end
      end
     otherwise
      error('MATLAB:odefinalize:UnrecognizedSolver',...
            'Unrecognized solver: %s',solver);
    end  
    if isequal(solver,'dde23')
      solver_output = sol;
    else  
      solver_output{1} = sol;
    end  
  end
end    
