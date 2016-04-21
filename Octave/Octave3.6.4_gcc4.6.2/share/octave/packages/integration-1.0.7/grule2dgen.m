function [bpxv,wfxv,bpyv,wfyv] = grule2dgen (nquadx,nquady)
%
%usage:  [bpxv,wfxv,bpyv,wfyv] = grule2dgen (nquadx,nquady);
%
	[bpxv,wfxv]=grule(nquadx);
	[bpyv,wfyv]=grule(nquady);
endfunction
