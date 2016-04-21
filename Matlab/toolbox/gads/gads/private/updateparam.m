function [MeshSize,MeshContraction,how,deltaX,deltaF,scale,Iterate,X,Iter,infMessage] = ...
         updateparam(successPoll,successSearch,MeshAccelerator,RotatePattern,MaxMeshSize,minMesh,MeshExpansion, ...
                     MeshCont,MeshContraction,MeshSize,scale,nextIterate,Iterate,X,Iter,how,infMessage)
%UPDATEPARAM updates all the parameters of pattern search for next iteration
% 	
% 	SUCCESSPOLL,SUCCESSSEARCH: Flag indicating if poll or search was
% 	successful in last iteration
% 	
% 	MeshAccelerator: Used for fast mesh contraction when close to minima
% 	(might loose accuracy)
% 	
% 	MAXMESHSIZE,MINMESH: Maximum and minimum mesh size which can be used
% 	
% 	MeshExpansion,MeshContraction: These factors(scalar) are used to coarsen
% 	or refining the mesh
% 	
% 	MESHSIZE: Current mesh size used.
% 	
% 	NEXTITERATE,ITERATE: Iterates in last iteration and current iteration
                 
%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2004/01/16 16:49:57 $
%   Rakesh Kumar

how = '';
factor = 1e-2;

if successPoll
    MeshSize = min(MaxMeshSize,MeshExpansion*MeshSize);
else 
    if  (nextIterate.f < 0 && ~isfinite(nextIterate.f))
        infMessage ='Function has reached -Inf value';
    elseif ~successSearch
        how = [how,'Refine Mesh'];
        MeshSize = MeshContraction*MeshSize;
    end
end

%MeshAccelerator step; Speed up convergence when near the optimizer
if strcmpi(MeshAccelerator,'on')
    if abs(MeshSize) < min(factor,minMesh*(1/factor))
        %MeshSize is less than factor, we can use a fast convergence
        MeshContraction  =  max(factor,MeshContraction/2);
    else
         %MeshSize is greater than factor, reset the contraction factor
         MeshContraction = MeshCont;
    end
end

%How did last iteration go
if successSearch
    how = 'Successful Search';
elseif successPoll
    how = 'Successful Poll';
end

if strcmpi(RotatePattern,'on') && MeshSize < minMesh*1/factor && ~successPoll
    scale = -scale ;
    how = [how,'\Rotate'];
%    MeshContraction = MeshCont; %Reset the Contraction factor
end

%Other termination criteria
deltaX    = norm(nextIterate.x-Iterate.x);
deltaF   = abs(nextIterate.f-Iterate.f);
Iterate  = nextIterate;
Iter     = Iter + 1;
X(:)     = Iterate.x;

