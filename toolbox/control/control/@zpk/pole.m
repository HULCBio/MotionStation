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

%       Author(s): P. Gahinet, 5-1-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.15 $  $Date: 2002/04/10 06:12:12 $

sizes = size(sys.k);
nsys = prod(sizes(3:end));

if all(sizes(1:2)<=1),
   % SISO case. Dimension V based on the max number of poles
   npmax = max([0;cellfun('length',sys.p(:))]);
   v = zeros([npmax 1 sizes(3:end)]);   
   
   % Compute zeros
   NanZero = NaN;
   for k=1:(npmax>0)*nsys,
      pk = sys.p{k};
      % RE: pad missing zeros with NaN (pole at infinity)
      v(:,1,k) = [pk ; NanZero(ones(npmax-length(pk),1),1)];
   end
   
else
   % MIMO case
   [ro,co] = zpkorder(sys.z,sys.p,sys.k); % row-wise and column-wise orders
   npmax = max([0;min(ro(:),co(:))]);
   v = zeros([npmax 1 sizes(3:end)]);
   
   for m=1:nsys,
      pm = sys.p(:,:,m);
      km = sys.k(:,:,m);
      npoles = cellfun('length',pm);
      vm = zeros(0,1);
      
      if ro(m)<co(m),
         % Compute poles row-wise
         for i=1:sizes(1),
            jdyn = find(km(i,:)~=0 & npoles(i,:));  % dynamic entries
            if length(jdyn)<2 | ~isequal(pm{i,jdyn}),
               for j=jdyn,
                  vm = [vm ; pm{i,j}];
               end
            else
               % Common denominator
               vm = [vm ; pm{i,jdyn(1)}];
            end
         end
      else
         % Compute poles column-wise
         for j=1:sizes(2),
            idyn = find(km(:,j)~=0 & npoles(:,j))';   % dynamic entries
            if length(idyn)<2 | ~isequal(pm{idyn,j})
               for i=idyn,
                  vm = [vm ; pm{i,j}];
               end
            else        
               % Common denominator
               vm = [vm ; pm{idyn(1),j}];
            end
         end
      end
      
      % Store resulting pole list VM
      lvm = length(vm);
      v(1:lvm,1,m) = vm;
      v(lvm+1:npmax,1,m) = NaN;
    end
   
end

