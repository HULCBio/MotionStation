function [bpx,bpy,wfxy] = crule2d (nquadx,nquady)
%
%usage:  [bpx,bpy,wfxy] = crule2d (nquadx,nquady);
%
	[bpxv,wfxv]=crule(nquadx);
	[bpyv,wfyv]=crule(nquady);
	[bpx,bpy]=meshgrid(bpxv,bpyv);
	[wfx,wfy]=meshgrid(wfxv,wfyv);
%	[bpx,bpy]=meshdom(bpxv,bpyv);
%	[wfx,wfy]=meshdom(wfxv,wfyv);
	wfxy=wfx.*wfy;
endfunction
