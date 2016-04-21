function [ro,co] = tforder(num,den)
%TFORDER   Computes order of ZPK models
%
%   [RO,CO] = TFORDER(NUM,DEN) compute the row-wise and
%   column-wise orders RO and CO for the TF models 
%   with data NUM,DEN.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 06:08:43 $

sizes = size(num);
ro = zeros([sizes(3:end) 1 1]);
co = zeros([sizes(3:end) 1 1]);

% Loop over each model
for m=1:prod(size(ro)),
   % Gain and poles of model #m (discard poles where gain=zero)
   nm = num(:,:,m);
   dm = den(:,:,m);
   npoles = cellfun('length',dm)-1;
   
   % Zero entries contribute no dynamics
   for k=1:prod(sizes(1:2)),
      npoles(k) = any(nm{k}) * npoles(k);
   end
   
   % Determine row-wise order
   rom = 0;
   for i=1:sizes(1),
      jdyn = find(npoles(i,:));  % dynamic entries
      if length(jdyn)<2 | ~isequal(dm{i,jdyn}),
         rom = rom + sum(npoles(i,jdyn));
      else
         % Common denominator
         rom = rom + npoles(i,jdyn(1));
      end
   end
   ro(m) = rom;
   
   % Determine column-wise order
   com = 0;
   for j=1:sizes(2),
      idyn = find(npoles(:,j));   % dynamic entries
      if length(idyn)<2 | ~isequal(dm{idyn,j})
         com = com + sum(npoles(idyn,j));
      else        
         % Common denominator
         com = com + npoles(idyn(1),j);
      end
   end
   co(m) = com;
end
