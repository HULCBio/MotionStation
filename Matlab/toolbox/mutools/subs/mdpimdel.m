% function mdpimdel(pim,depthvec,rows,cols)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function mdpimdel(pim,depthvec,rows,cols)

if ~isempty(pim)
	for i=1:length(depthvec)
		ii = depthvec(i);
		for j=1:rows(i)
			for k=1:cols(i)
				tmp = mdxpii(pim,ii,j,k);
				if ~isempty(tmp)
					delete(tmp)
				end
			end
		end
	end
end