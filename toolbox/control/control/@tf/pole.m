function v = pole(sys)
%POLE  Compute the poles of LTI models.
%
%   P = POLE(SYS) computes the poles P of the LTI model SYS (P is 
%   a column vector).
%
%   For state-space models, the poles are the eigenvalues of the A 
%   matrix or the generalized eigenvalues of the (A,E) pair in the 
%   descriptor case.
%
%   If SYS is an array of LTI models with sizes [NY NU S1 ... Sp],
%   the array P has as many dimensions as SYS and P(:,1,j1,...,jp) 
%   contains the poles of the LTI model SYS(:,:,j1,...,jp).  The 
%   vectors of poles are padded with NaN values for models with 
%   relatively fewer poles.
%
%   See also DAMP, ESORT, DSORT, PZMAP, ZERO, LTIMODELS.

%   Author(s): P. Gahinet, 4-9-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/10 06:07:15 $

sizes = size(sys.num);
nsys = prod(sizes(3:end));

if all(sizes(1:2)<=1),
   % SISO case. Dimension V based on max denominator length
   ld = cellfun('length',sys.den);
   nrv = max([1;ld(:)])-1;
   v = zeros([nrv 1 sizes(3:end)]);   
   
   % Compute poles
   NanZero = NaN;
   npmax = 0;
   for k=1:(nrv>0)*nsys,
      pk = roots(sys.den{k});
      npmax = max(npmax,length(pk));
      % RE: pad missing zeros with NaN (pole at infinity)
      v(:,1,k) = [pk ; NanZero(ones(nrv-length(pk),1),1)];
   end
   
else
   % MIMO case
   [ro,co] = tforder(sys.num,sys.den); % row-wise and column-wise orders
   nrv = max([0;min(ro(:),co(:))]);
   v = zeros([nrv 1 sizes(3:end)]);
   npmax = 0;
   
   for m=1:nsys,
      nm = sys.num(:,:,m);
      dm = sys.den(:,:,m);
      npoles = cellfun('length',dm)-1;
      vm = zeros(0,1);
      
      % Zero entries contribute no dynamics
      for k=1:prod(sizes(1:2)),
         npoles(k) = any(nm{k}) * npoles(k);
      end
      
      if ro(m)<co(m),
         % Compute poles row-wise
         for i=1:sizes(1),
            jdyn = find(npoles(i,:));  % dynamic entries
            if length(jdyn)<2 | ~isequal(dm{i,jdyn}),
               for j=jdyn,
                  vm = [vm ; roots(dm{i,j})];
               end
            else
               % Common denominator
               vm = [vm ; roots(dm{i,jdyn(1)})];
            end
         end
      else
         % Compute poles column-wise
         for j=1:sizes(2),
            idyn = find(npoles(:,j)');   % dynamic entries
            if length(idyn)<2 | ~isequal(dm{idyn,j})
               for i=idyn,
                  vm = [vm ; roots(dm{i,j})];
               end
            else        
               % Common denominator
               vm = [vm ; roots(dm{idyn(1),j})];
            end
         end
      end
      
      % Store resulting pole list VM
      lvm = length(vm);
      npmax = max(npmax,lvm);
      v(1:lvm,1,m) = vm;
      v(lvm+1:nrv,1,m) = NaN;
    end
   
end

% Delete extra NaNs (improper case)
if nrv>npmax,
   v(npmax+1:nrv,:) = [];
   v = reshape(v,[npmax 1 sizes(3:end)]);
end

