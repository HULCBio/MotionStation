## Copyright (C) 2006,2007,2008  Carlo de Falco            
##
## This file is part of:
## OCS - A Circuit Simulator for Octave
##
## OCS is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with OCS; If not, see <http://www.gnu.org/licenses/>.
##
## author: Carlo de Falco     <cdf _AT_ users.sourceforge.net> 
## author: Massimiliano Culpo <culpo _AT_ users.sourceforge.net>

## -*- texinfo -*-
## @deftypefn{Function File} @var{outstruct} = prs_iff(@var{name})
## Parse a netlist in IFF format and produce the system description
## structure @var{outstruct}.
##
## @var{name} is the basename of the CIR and NMS files to
## be parsed.
##
## See the @cite{IFF file format specifications} (distributed together
## with the OCS package) for more details on the file format.
##
## @var{outstruct} has the following fields:
##
## @example
## outstruct =
## @{
##  LCR:  struct      % the fields of LCR are shown below
##  NLC:  struct      % NLC has the same fields as LCR
##  namesn: matrix    % numbers of vars named in .nms file
##  namess: cell      % the names corresponding to the vars above
##  totextvar: scalar % the total number of external variables
##  totintvar: scalar % the total number of internal variables
## @}
##
## outstruct.LCR =
## outstruct.NLC =
## @{
##  struct array containing the fields: % array has one element per block
##
##    func     % name of the sbn file corresponding to each block
##    section  % string parameter to be passed to the sbn files
##    nextvar  % number of external variables for each element of the block
##    vnmatrix % numbers of the external variables of each element
##    nintvar  % number of internal variables for each element of the block
##    osintvar % number of the first internal variable
##    npar     % number of parameters
##    nparnames% number of parameter names
##    nrows    % number of rows in the block
##    parnames % list of parameter names
##    pvmatrix % list of parameter values for each element
##
## @}
## @end example
##
## See the @cite{IFF file format specifications} for details about 
## the output structures.
## @seealso{prs_spice}
## @end deftypefn

function outstruct = prs_iff(name)
  
  ## Check input
  if (nargin != 1 || !ischar(name))
    error("prs_iff: wrong input.")
  endif

  ## Initialization
  version ="0.1b1";
  outstruct = struct("NLC",[],\
                     "LCR",[],\
                     "totextvar",0);
  
  ## Open cir file
  filename = [name ".cir"];
  if isempty(file_in_path(".",filename))
    error(["prs_iff: .cir file not found:" filename]);
  endif
  fid = fopen(filename,"r");

  ## Check version
  ## FIXME: this part can be improved a lot!!
  line = fgetl(fid);
  
  if line(1)!="%"
    error(["prs_iff: missing version number in file " filename]);
  endif
  
  if ~strcmp(version,sscanf(line(2:end),"%s"));
    error(["prs_iff: conflicting version number in file " filename]);
  endif
  
  ndsvec = []; # Vector of circuit nodes
  intvar = 0;  # Number of internal variables
  
  ## NLC section
  NLCcount = 0;
  while !strcmp(line,"END")

    ## Skip  comments
    while line(1)=="%"
      line = fgetl(fid);
    endwhile

    if strcmp(line,"END")
      break
    else
      NLCcount++;
    endif
    
    ## parse NLC block
    [outstruct,intvar] = parseNLCblock(fid,line,outstruct,NLCcount,intvar);

    ndsvec = [ndsvec ; \
	      outstruct.NLC(NLCcount).vnmatrix(:)];

    ## skip the newline char after the matrix
    line = fgetl(fid);
    
    ## proceed to next line
    line = fgetl(fid);

  endwhile

  ## LCR section
  LCRcount = 0;
  line     = fgetl(fid);

  while (!strcmp(line,"END"))

    ## Skip  comments
    while line(1)=="%"
      line = fgetl(fid);
    endwhile

    if strcmp(line,"END")
      break
    else
      LCRcount++;
    endif
    
    ## parse block header
    [outstruct,intvar] = parseLCRblock(fid,line,outstruct,LCRcount,intvar);
    
    ndsvec = [ndsvec ; \
	      outstruct.LCR(LCRcount).vnmatrix(:)];
    
    ## skip the newline char after the matrix
    line = fgetl(fid);
    
    ## proceed to next line
    line = fgetl(fid);

  endwhile

  ## Set the number of internal and external variables
  outstruct.totintvar = intvar;
  nnodes = length(unique(ndsvec));
  maxidx = max(ndsvec);

  if  nnodes <= (maxidx+1)
    ## If the valid file is a subcircuit it may happen 
    ## that nnodes == maxidx, otherwise nnodes == (maxidx+1)
    outstruct.totextvar = max(ndsvec);
  else
    error("prs_iff: hanging nodes in circuit %s",name);
  endif
  ## fclose cir file
  fclose(fid); 

  ## Open nms file
  filename = [name ".nms"];
  if isempty(file_in_path(".",filename))
    error(["prs_iff: .nms file not found:" filename]);
  endif
  fid = fopen(filename,"r");

  ## Check version
  line = fgetl(fid);
  
  if line(1)~="%"
    error(["prs_iff: missing version number in file " filename]);
  endif
  
  if ~strcmp(version,sscanf(line(2:end),"%s"));
    error(["prs_iff: conflicting version number in file " filename]);
  endif

  ## Initialization
  cnt = 1;
  outstruct.namesn = [];
  outstruct.namess = {};
  nnames = 0;

  while cnt
    [nn,cnt] = fscanf(fid,"%d","C");
    [ns,cnt] = fscanf(fid,"%s","C");
    
    if cnt
      outstruct.namesn(++nnames)=nn;
      outstruct.namess{nnames}=ns;
    endif
  endwhile
  
  ## fclose nms file
  fclose(fid);

endfunction


##############################################
function [outstruct,intvar] = parseNLCblock(fid,line,outstruct,NLCcount,intvar);

  ## Parse first line of the header and retrieve:
  ## 1 - SBN function name
  ## 2 - Section
  ## 3 - Number of external variables
  ## 4 - Number of parameters
  [func,section,nextvar,npar]     = sscanf(line,"%s %s %g %g","C");
  outstruct.NLC(NLCcount).func    = func;
  outstruct.NLC(NLCcount).section = section;
  outstruct.NLC(NLCcount).nextvar = nextvar;
  outstruct.NLC(NLCcount).npar    = npar;
  ## Parse second line of the header and retrieve:
  ## 1 - Number of elements of this type
  ## 2 - Number of parameter names to be parsed
  [nrows,nparnames]                 = fscanf(fid,"%g %g","C");
  outstruct.NLC(NLCcount).nrows     = nrows;
  outstruct.NLC(NLCcount).nparnames = nparnames;
  outstruct.NLC(NLCcount).parnames  = {};
  for ii=1:nparnames
    outstruct.NLC(NLCcount).parnames{ii} = fscanf(fid,"%s","C");
  endfor

  ## Parse the matrix containing the values of parameters
  [outstruct.NLC(NLCcount).pvmatrix] = fscanf(fid,"%g",[npar,nrows])';

  ## Parse the connectivity matrix
  [outstruct.NLC(NLCcount).vnmatrix] = fscanf(fid,"%g",[nextvar,nrows])';

  ## Compute internal variables cycling over each 
  ## element in the section
  for iel = 1:nrows
    [a,b,c] = feval(func,section,outstruct.NLC(NLCcount).pvmatrix(iel,:),\
		    outstruct.NLC(NLCcount).parnames,zeros(nextvar,1),[],0);

    ## FIXME: if all the element in the same section share the
    ## same number of internal variables, the for cycle can be 
    ## substituted by only one call
    outstruct.NLC(NLCcount).nintvar(iel)  = columns(a) - outstruct.NLC(NLCcount).nextvar;
    outstruct.NLC(NLCcount).osintvar(iel) = intvar;
    
    intvar += outstruct.NLC(NLCcount).nintvar(iel);
  endfor

endfunction

##############################################
function [outstruct,intvar] = parseLCRblock(fid,line,outstruct,LCRcount,intvar);

  ## Parse first line of the header and retrieve:
  ## 1 - SBN function name
  ## 2 - Section
  ## 3 - Number of external variables
  ## 4 - Number of parameters
  [func,section,nextvar,npar]     = sscanf(line,"%s %s %g %g","C");
  outstruct.LCR(LCRcount).func    = func;
  outstruct.LCR(LCRcount).section = section;
  outstruct.LCR(LCRcount).nextvar = nextvar;
  outstruct.LCR(LCRcount).npar    = npar;
  ## Parse second line of the header and retrieve:
  ## 1 - Number of elements of this type
  ## 2 - Number of parameter names to be parsed
  [nrows,nparnames]                 = fscanf(fid,"%g %g","C");
  outstruct.LCR(LCRcount).nrows     = nrows;
  outstruct.LCR(LCRcount).nparnames = nparnames;
  outstruct.LCR(LCRcount).parnames  = {};
  for ii=1:nparnames
    outstruct.LCR(LCRcount).parnames{ii} = fscanf(fid,"%s","C");
  endfor
  
  ## Parse the matrix containing the values of parameters
  [outstruct.LCR(LCRcount).pvmatrix] = fscanf(fid,"%g",[npar,nrows])';
  
  ## Parse the connectivity matrix
  [outstruct.LCR(LCRcount).vnmatrix] = fscanf(fid,"%g",[nextvar,nrows])';

  ## Compute internal variables cycling over each 
  ## element in the section
  for iel = 1:nrows
    [a,b,c] = feval(func,section,outstruct.LCR(LCRcount).pvmatrix(iel,:),\
		    outstruct.LCR(LCRcount).parnames,zeros(nextvar,1),[],0);

    ## FIXME: if all the element in the same section share the
    ## same number of internal variables, the for cycle can be 
    ## substituted by only one call
    outstruct.LCR(LCRcount).nintvar(iel)  = columns(a) - outstruct.LCR(LCRcount).nextvar;
    outstruct.LCR(LCRcount).osintvar(iel) = intvar;
    
    intvar += outstruct.LCR(LCRcount).nintvar(iel);
  endfor

endfunction