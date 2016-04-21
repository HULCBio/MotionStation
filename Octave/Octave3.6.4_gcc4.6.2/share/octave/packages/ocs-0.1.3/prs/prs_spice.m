## Copyright (C) 2012  Marco Merlin
##
## This file is part of: 
## OCS - A Circuit Simulator for Octave
##
## OCS  is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## OCS is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with OCS; If not, see <http://www.gnu.org/licenses/>.
##
## author: Marco Merlin <marcomerli _AT_ gmail.com>
## based on prs_iff which is (C) Carlo de Falco and Massimiliano Culpo

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{stuct}]} = prs_spice (@var{filename})
##
## Circuit file parser that can interpret a subset of the spice file format.
##
## @code{prs_spice} currently supports the following set of "Element Cards"
## @itemize @minus
## @item Capacitors:
## @example
## Cname n+ n- cvalue
## @end example
##
## @item Diodes:
## @example
## Cname anode knode modelname <parameters>
## @end example
##
## @item MOS:
## @example
## Mname gnode dnode snode bnode modelname <parameters>
## @end example
## 
## N.B.: one instance of a MOS element MUST be preceeded (everywhere in the file) by the declaration of the related model.
## For instance:
## @example
## .MODEL mynmos NMOS( k=1e-4 Vth=0.1 rd=1e6)
## M2 Vgate 0 Vdrain 0 mynmos
## @end example
## 
## @item Resistors:
## @example
## Rname n+ n- rvalue
## @end example
## 
## @item Voltage sources:
## @example
## Vname n+ n- <dcvalue> <transvalue>
## @end example
## 
## Transvalue specifies a transient voltage source
## @example
## SIN(VO  VA  FREQ TD  THETA)
## @end example
## where:
## @itemize @bullet
## @item VO    (offset)
## @item VA    (amplitude)
## @item FREQ  (frequency)
## @item TD    (delay)
## @item THETA (damping factor)
## @end itemize
##
## @itemize @bullet
## @item 0 to TD: V0 
## @item TD to TSTOP:  
## VO  + VA*exp(-(time-TD)*THETA)*sine(twopi*FREQ*(time+TD))
## @end itemize
## 
## Currently the damping factor has no effect.
## 
## Pulse
## @example
## PULSE(V1 V2 TD TR  TF  PW  PER)
## @end example
## 
## parameters meaning
## @itemize @bullet
## @item V1         (initial value)
## @item V2         (pulsed value)
## @item TD         (delay time)
## @item TR         (rise  time)
## @item TF         (fall time)
## @item PW         (pulse width)
## @item PER        (period)
## @end itemize 
## 
## Currently rise and fall time are not implemented yet.
## 
## @item .MODEL cards
## Defines a model for semiconductor devices
## 
## @example
## .MODEL MNAME TYPE(PNAME1=PVAL1 PNAME2=PVAL2 ... )
## @end example
## 
## TYPE can be:
## @itemize @bullet
## @item NMOS N-channel MOSFET model
## @item PMOS P-channel MOSFET model
## @item D    diode model
## @end itemize
## 
## The parameter "LEVEL" is currently assigned to the field "section" in the call
## of the element functions by the solver.
## Currently supported values for the parameter LEVEL for NMOS and PMOS are:
## @itemize @bullet
## @item simple
## @item lincap
## @end itemize
## (see documentation of function Mdiode).
## 
## Currently supported values for the parameter LEVEL for D are:
## @itemize @bullet
## @item simple
## @end itemize
## (see documentation of functions Mnmosfet and Mpmosfet).
## 
## @end itemize
## @seealso{prs_iff,Mdiode,Mnmosfet,Mpmosfet}
## @end deftypefn

function outstruct = prs_spice (name)

  ## Check input
  if (nargin != 1 || !ischar (name))
    error ("prs_spice: wrong input.")
  endif

  ## Initialization

  outstruct = struct ("LCR", [],
  "NLC", [],
  "totextvar", 0);

  global ndsvec;      # Vector of circuit nodes
  global nodes_list;
  global intvar_list;
  global models_list;

  ndsvec = [];
  outstruct.totintvar = 0; # Number of internal variables

  count = struct ("NLC", struct ("n", 0,
                                "list", {""}),
                  "LCR", struct ("n", 0,
                                "list", {""}));
  nodes_list = {"0"};
  intvar_list = {};
  models_list = struct ("mname", {""},
                        "melement", {""},
                        "msection", {""});

  ## File parsing

  ## Open circuit file
  filename = [name ".spc"];
  if (exist (filename) != 2) ## isempty (file_in_path (".", filename))
    error (["prs_spice: .spc file not found:" filename]);
  endif
  fid = fopen (filename, "r");

  if (fid>-1)
    line = '';
    fullline = '';
    lineCounter = 0;
    while (! feof (fid))
      line = strtrim (line);

      %% exclude empty lines
      if length (line)
        %% exclude comments
        if (! strncmpi (line, '*', 1))
          %% lines here aren't comments
          if (strncmpi (line, '+', 1))
            %% this line has to be concatenated to previous one
            line (1) = ' ';
            fullline = [fullline line];
          else
            %% these lines are not a concatenation

            %% line echo for debug
            %# disp (fullline);

            %% compute fullline here!
            %#[outstruct, intvar, count] = lineParse (upper (fullline), outstruct, count, intvar);

            %# NB: case-sensitive because of parameter names
            %#[outstruct, intvar, count] = lineParse (fullline, outstruct, intvar, count);
            [outstruct, count] = lineParse (fullline, outstruct, count);

            fullline = line;
          end %if (strncmpi (line, '+', 1))
        end %if (~strncmpi (line, '*', 1))
      end % if length (line)
      line = fgets (fid);
      lineCounter = lineCounter+1;
    end % while ~feof (fid)

    %% parse last line
    if length (fullline)
      ## NB: case-sensitive because of parameter names
      %#[outstruct, intvar, count] = lineParse (upper (fullline), outstruct, count, intvar);
      %#[outstruct, intvar, count] = lineParse (fullline, outstruct, intvar, count);
      [outstruct, count] = lineParse (fullline, outstruct, count);
    end
    fclose (fid);
  else
    error ('Input file not found!');
  end


  ## Set the number of internal and external variables
  nnodes = length (unique (ndsvec));
  maxidx = max (ndsvec);

  if  (nnodes <= (maxidx+1))
    ## If the valid file is a subcircuit it may happen
    ## that nnodes == maxidx, otherwise nnodes == (maxidx+1)
    outstruct.totextvar = max (ndsvec);
  else
    error ("prs_spice: hanging nodes in circuit %s", name);
  endif

  ## set node names as variable names
  for ii = 1:length (nodes_list)
    outstruct.namesn (ii) = ii-1;
  endfor
  outstruct.namess = horzcat (nodes_list, intvar_list);
  ##outstruct.namess

  ##outstruct.totintvar
endfunction

## NLC block intvar count update
function outstruct = NLCintvar (outstruct, NLCcount, name)

  global ndsvec;
  global intvar_list;

  ## set node names for NLC subcircuit
  ##for NLCcount = 1:count.NLC.n;
  ##NLCcount = count.NLC.n;
  ## set vnmatrix for NLC subcircuit
  ndsvec = [ndsvec ;
            outstruct.NLC(NLCcount).vnmatrix(:)];
  ## Compute internal variables cycling over each
  ## element in the section
  ##for iel = 1:outstruct.NLC(NLCcount).nrows
  iel = outstruct.NLC(NLCcount).nrows;
  [a, b, c] = feval (outstruct.NLC(NLCcount).func,
                   outstruct.NLC(NLCcount).section,
                   outstruct.NLC(NLCcount).pvmatrix(iel, :),
                   outstruct.NLC(NLCcount).parnames,
                   zeros (outstruct.NLC(NLCcount).nextvar, 1),
                   [],
                   0);

  ## FIXME: if all the element in the same section share the
  ## same number of internal variables, the for cycle can be
  ## substituted by only one call
  outstruct.NLC(NLCcount).nintvar(iel)  = columns (a) - outstruct.NLC(NLCcount).nextvar;
  outstruct.NLC(NLCcount).osintvar(iel) = outstruct.totintvar;

  outstruct.totintvar += outstruct.NLC(NLCcount).nintvar(iel);
  if outstruct.NLC(NLCcount).nintvar(iel)>0
    intvar_list{outstruct.totintvar} = ["I(" name ")"];
  endif
  ##endfor
  ##endfor # NLCcount = 1:count.NLC.n;
endfunction

## LCR block intvar count update
function outstruct = LCRintvar (outstruct, LCRcount, name)
  global ndsvec;
  global intvar_list;
  ## set node names for LCR subcircuit
  ##  for LCRcount = 1:count.LCR.n;
  ##   LCRcount = count.LCR.n;
  ## set vnmatrix for LCR subcircuit
  ndsvec = [ndsvec ;
            outstruct.LCR(LCRcount).vnmatrix(:)];

  ## Compute internal variables cycling over each
  ## element in the section
  ##for iel = 1:outstruct.LCR(LCRcount).nrows
  iel = outstruct.LCR(LCRcount).nrows;
  [a, b, c] = feval (outstruct.LCR(LCRcount).func,
                   outstruct.LCR(LCRcount).section,
                   outstruct.LCR(LCRcount).pvmatrix(iel, :),
                   outstruct.LCR(LCRcount).parnames,
                   zeros(outstruct.LCR(LCRcount).nextvar, 1),
                   [],
                   0);

  ## FIXME: if all the element in the same section share the
  ## same number of internal variables, the for cycle can be
  ## substituted by only one call
  outstruct.LCR(LCRcount).nintvar(iel)  = columns (a) - outstruct.LCR(LCRcount).nextvar;
  ##outstruct.LCR(LCRcount).osintvar(iel) = intvar;
  outstruct.LCR(LCRcount).osintvar(iel) = outstruct.totintvar;

  ##intvar += outstruct.LCR(LCRcount).nintvar(iel);
  outstruct.totintvar += outstruct.LCR(LCRcount).nintvar(iel);
  if outstruct.LCR(LCRcount).nintvar(iel)>0
    intvar_list{outstruct.totintvar} = ["I(" name ")"];
  endif
  ##endfor
  ##  endfor # LCRcount = 1:count.LCR.n;
endfunction

## Parses a single line
function [outstruct, count] = lineParse (line, outstruct, count)
  if length (line)
    switch (line (1))
      case 'B'
      case 'C'
        [outstruct, count] = prs_spice_C (line, outstruct, count);
      case 'D'
        [outstruct, count] = prs_spice_D (line, outstruct, count);
      case 'E'
        ##mspINP2E (line, lineCounter);
      case 'F'
        ##mspINP2F (line, lineCounter);
      case 'G'
        ##mspINP2G (line, lineCounter);
      case 'H'
        ##mspINP2H (line, lineCounter);
      case 'I'
        ##mspINP2I (line, lineCounter);
      case 'J'
      case 'K'
        ##mspINP2K (line, lineCounter);
      case 'L'
        ##mspINP2L (line, lineCounter);
      case 'M'
        ## FIXME: just for nMOS devices!
        [outstruct, count] = prs_spice_M (line, outstruct, count);
        ## case 'P'
        ## temporarily assigned to pMOS devices.
        ##[outstruct, count] = prs_spice_P (line, outstruct, count);
      case 'Q'
      case 'R'
        [outstruct, count] = prs_spice_R (line, outstruct, count);
      case 'S'
      case 'T'
      case 'U'
      case 'V'
        [outstruct, count] = prs_spice_V (line, outstruct, count);
      case 'W'
      case 'X'
      case 'Z'
      case '.'
        [outstruct, count] = prs_spice_dot (line, outstruct, count);
      otherwise
        warn = sprintf (['prs_spice: Unsupported circuit element in line: ' line ]);
        warning (warn);
    end %	switch (line (1))
  end	%if length (line)

endfunction

## adds an NLC element to outstruct
function [outstruct, count] = addNLCelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix)
  ## check whether the element type already exists in output structure
  ## the search key is (func, section)
  ##[tf, idx] = ismember ({element}, count.NLC.list);
  ##if !tf
  ## the element still does not exist
  ## update counters
  count.NLC.n++;
  count.NLC.list{count.NLC.n}        = element;

  ## if the element doesn't exists, add it to the output structure
  outstruct.NLC(count.NLC.n).func    = element;
  outstruct.NLC(count.NLC.n).section = section;
  outstruct.NLC(count.NLC.n).nextvar = nextvar;
  outstruct.NLC(count.NLC.n).npar    = npar;
  outstruct.NLC(count.NLC.n).nrows   = 1;
  outstruct.NLC(count.NLC.n).nparnames = nparnames;
  outstruct.NLC(count.NLC.n).parnames  = parnames;
  outstruct.NLC(count.NLC.n).vnmatrix  = vnmatrix;
  outstruct.NLC(count.NLC.n).pvmatrix  = pvmatrix;
  ##else
  ##  found = 0;
  ##  for ii = 1:length (idx)
  ##    if strcmp (outstruct.NLC(idx(ii)).section, section)
  ##	found = 1;
  ##	break;
  ##    endif #!strcmp (outstruct.NLC(idx(ii)).section, section)
  ##  endfor #ii = 1:length (idx)

  ##  if !found
  ## the section does not exist

  ## the element still does not exist
  ## update counters
  ##   count.NLC.n++;
  ##   count.NLC.list{count.NLC.n}        = element;

  ## if the element doesn't exists, add it to the output structure
  ##    outstruct.NLC(count.NLC.n).func    = element;
  ##    outstruct.NLC(count.NLC.n).section = section;
  ##    outstruct.NLC(count.NLC.n).nextvar = nextvar;
  ##    outstruct.NLC(count.NLC.n).npar    = npar;
  ##    outstruct.NLC(count.NLC.n).nrows   = 1;
  ##    outstruct.NLC(count.NLC.n).nparnames = nparnames;
  ##    outstruct.NLC(count.NLC.n).parnames  = parnames;
  ##    outstruct.NLC(count.NLC.n).vnmatrix  = vnmatrix;
  ##    outstruct.NLC(count.NLC.n).pvmatrix  = pvmatrix;

  ##  else
  ## the couple (element, section) already exists, so add a row in the structure
  ## add an element to the structure
  ##    outstruct.NLC(idx(ii)).nrows++;

  ## update parameter value and connectivity matrix
  ##    [outstruct.NLC(idx(ii)).vnmatrix] = [outstruct.NLC(idx(ii)).vnmatrix; vnmatrix];
  ##    [outstruct.NLC(idx(ii)).pvmatrix] = [outstruct.NLC(idx(ii)).pvmatrix; pvmatrix];
  ## endif
  ##endif
endfunction

## adds an LCR element to outstruct
function [outstruct, count] = addLCRelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix)
  ## check whether the element type already exists in output structure
  ## the search key is (func, section)
  [tf, idx] = ismember ({element}, count.LCR.list);
  if !tf
    ## the element still does not exist
    ## update counters
    count.LCR.n++;
    count.LCR.list{count.LCR.n}        = element;

    ## if the element doesn't exists, add it to the output structure
    outstruct.LCR(count.LCR.n).func    = element;
    outstruct.LCR(count.LCR.n).section = section;
    outstruct.LCR(count.LCR.n).nextvar = nextvar;
    outstruct.LCR(count.LCR.n).npar    = npar;
    outstruct.LCR(count.LCR.n).nrows   = 1;
    outstruct.LCR(count.LCR.n).nparnames = nparnames;
    outstruct.LCR(count.LCR.n).parnames  = parnames;
    outstruct.LCR(count.LCR.n).vnmatrix  = vnmatrix;
    outstruct.LCR(count.LCR.n).pvmatrix  = pvmatrix;
  else
    found = 0;
    for ii = 1:length (idx)
      if strcmp (outstruct.LCR(idx(ii)).section, section)
        found = 1;
        break;
      endif #!strcmp (outstruct.LCR(idx(ii)).section, section)
    endfor #ii = 1:length (idx)

    if (! found)
      ## the section does not exist

      ## the element still does not exist
      ## update counters
      count.LCR.n++;
      count.LCR.list{count.LCR.n}        = element;

      ## if the element doesn't exists, add it to the output structure
      outstruct.LCR(count.LCR.n).func    = element;
      outstruct.LCR(count.LCR.n).section = section;
      outstruct.LCR(count.LCR.n).nextvar = nextvar;
      outstruct.LCR(count.LCR.n).npar    = npar;
      outstruct.LCR(count.LCR.n).nrows   = 1;
      outstruct.LCR(count.LCR.n).nparnames = nparnames;
      outstruct.LCR(count.LCR.n).parnames  = parnames;
      outstruct.LCR(count.LCR.n).vnmatrix  = vnmatrix;
      outstruct.LCR(count.LCR.n).pvmatrix  = pvmatrix;

    else
      ## the couple (element, section) already exists, so add a row in the structure
      ## add an element to the structure
      outstruct.LCR(idx(ii)).nrows++;

      ## update parameter value and connectivity matrix
      [outstruct.LCR(idx(ii)).vnmatrix] = [outstruct.LCR(idx(ii)).vnmatrix; vnmatrix];
      [outstruct.LCR(idx(ii)).pvmatrix] = [outstruct.LCR(idx(ii)).pvmatrix; pvmatrix];
    endif
  endif
endfunction

## converts a blank separated values string into a cell array
function ca = str2ca (str)
  ca = regexpi (str, '[^ \s=]+', 'match');
endfunction

## replaces the tokens c_old with c_new in string inString
function outString = strReplace (inString, c_old, c_new)
  outString = inString;
  l = length (c_new);
  for idx = 1:length (c_old)
    if (idx<=l)
      outString = strrep (outString, c_old{idx}, c_new{idx});
    end
  end
endfunction

## returns the numeric value of a string
function num = literal2num (string)
  literals = {'MEG' 'MIL'     'A'    'F'     'P'    'N'   'U'   'M'   'K'  'G'  'T'};
  numerics = {'e6'  '*25.4e-6' 'e-18' 'e-15' 'e-12' 'e-9' 'e-6' 'e-3' 'e3' 'e9' 'e12'};
  newstr = strReplace (upper (string), literals, numerics);
  num = str2num (newstr);
end

function syntaxError (line)
  warnstr = sprintf ("Syntax error in line: %s", line);
  error (warnstr);
endfunction

function [outstruct, count] = prs_spice_C (line, outstruct, count)
  element = "Mcapacitors";
  ## check wheter the element type already exists in output structure
  [tf, idx] = ismember ({element}, count.NLC.list);
  if !tf
    ## update counters
    count.NLC.n++;
    count.NLC.list{count.NLC.n}        = element;
                                #idx=count.NLC.n;

    ## if the element doesn't exists, add it to the output structure
    outstruct.NLC(count.NLC.n).func    = element;
    outstruct.NLC(count.NLC.n).section = "LIN";
    outstruct.NLC(count.NLC.n).nextvar = 2;
    outstruct.NLC(count.NLC.n).npar    = 1;
    outstruct.NLC(count.NLC.n).nrows   = 0;
    outstruct.NLC(count.NLC.n).nparnames = 1;
    outstruct.NLC(count.NLC.n).parnames  = {"C"};
    outstruct.NLC(count.NLC.n).vnmatrix  = [];
    outstruct.NLC(count.NLC.n).pvmatrix  = [];
  endif

  ## add an element to the structure
  ##outstruct.NLC(idx).nrows++;
  outstruct.NLC(count.NLC.n).nrows++;

  ## convert input line string into cell array
  ca = str2ca (line);

  if length (ca)>3
    ## update parameter value and connectivity matrix
    ##[outstruct.NLC(idx).vnmatrix] = [outstruct.NLC(idx).vnmatrix; add_nodes(ca(2:3))];
    ##[outstruct.NLC(idx).pvmatrix] = [outstruct.NLC(idx).pvmatrix; literal2num(ca{4})];
    [outstruct.NLC(count.NLC.n).vnmatrix] = [outstruct.NLC(count.NLC.n).vnmatrix; add_nodes(ca(2:3))];
    [outstruct.NLC(count.NLC.n).pvmatrix] = [outstruct.NLC(count.NLC.n).pvmatrix; literal2num(ca{4})];
  else
    syntaxError (line);
  endif

  ##outstruct = NLCintvar (outstruct, idx, ca{1});
  outstruct = NLCintvar(outstruct, count.NLC.n, ca{1});
endfunction

function [outstruct, count] = prs_spice_D (line, outstruct, count)
  element = "Mdiode";
  ## check wheter the element type already exists in output structure
  ##[tf, idx] = ismember ({element}, count.NLC.list);
  ##if !tf
  ## update counters
  count.NLC.n++;
  count.NLC.list{count.NLC.n}        = element;
  ##idx = count.NLC.n;

  ## if the element doesn't exists, add it to the output structure
  outstruct.NLC(count.NLC.n).func    = element;
  outstruct.NLC(count.NLC.n).section = "simple";
  outstruct.NLC(count.NLC.n).nextvar = 2;
  outstruct.NLC(count.NLC.n).npar    = 0;
  outstruct.NLC(count.NLC.n).nrows   = 1;
  outstruct.NLC(count.NLC.n).nparnames = 0;
  outstruct.NLC(count.NLC.n).parnames  = {};
  outstruct.NLC(count.NLC.n).vnmatrix  = [];
  outstruct.NLC(count.NLC.n).pvmatrix  = [];
  ##endif

  ## convert input line string into cell array
  ca = str2ca (line);
  ## update parameter value and connectivity matrix
  ##[outstruct.NLC(idx).vnmatrix] = [outstruct.NLC(idx).vnmatrix; add_nodes(ca(2:3))];
  [outstruct.NLC(count.NLC.n).vnmatrix] = [outstruct.NLC(count.NLC.n).vnmatrix; add_nodes(ca(2:3))];

  ## check if parameters are specified
  for prm_idx = 1:(length (ca)-3)/2
    ## [tf, str_idx] = ismember (outstruct.NLC(count.NLC.n).parnames{prm_idx}, ca);
    ## TODO: can the loop be executed in a single operation?
    ## [tf, str_idx] = ismember (outstruct.NLC(count.NLC.n).parnames, ca);
    if length (ca) >= 1+prm_idx*2
      ## find specified parameter name
      ##if tf

      outstruct.NLC(count.NLC.n).npar++;
      outstruct.NLC(count.NLC.n).nparnames++;
      outstruct.NLC(count.NLC.n).parnames{1, prm_idx} = ca{2*prm_idx+2};
      outstruct.NLC(count.NLC.n).pvmatrix(1, prm_idx) = literal2num (ca{2*prm_idx+3});
      ##else
      ## TODO: set to a default value undefined parameters, instead of rising an error?
      ##        errstr = sprintf ("Undefined parameter %s in line: %s", outstruct.NLC(count.NLC.n).parnames{prm_idx}, line);
      ##        error (errstr);
      ##endif
    else
      syntaxError (line);
    endif
  endfor

  outstruct = NLCintvar(outstruct, count.NLC.n, ca{1});
endfunction

function [outstruct, count] = prs_spice_M (line, outstruct, count)
  global models_list;
  ##element = "Mnmosfet";
  ## check wheter the element type already exists in output structure
  ##[tf, idx] = ismember ({element}, count.NLC.list);
  ##if !tf
  ## update counters
  count.NLC.n++;
  ##count.NLC.list{count.NLC.n}        = element;
  ##idx = count.NLC.n;

  ## if the element doesn't exists, add it to the output structure
  ##outstruct.NLC(count.NLC.n).func    = element;
  ##outstruct.NLC(count.NLC.n).section = "simple";
  ##  outstruct.NLC(count.NLC.n).section = "lincap";
  outstruct.NLC(count.NLC.n).nextvar = 4;
  outstruct.NLC(count.NLC.n).npar    = 0;
  outstruct.NLC(count.NLC.n).nrows   = 1;
  outstruct.NLC(count.NLC.n).nparnames = 0;
  outstruct.NLC(count.NLC.n).parnames  = {};
  ##outstruct.NLC(count.NLC.n).vnmatrix  = [];
  outstruct.NLC(count.NLC.n).pvmatrix  = [];
  ##endif

  ## convert input line string into cell array
  ca = str2ca (line);
  ## update parameter value and connectivity matrix
  ##[outstruct.NLC(idx).vnmatrix] = [add_nodes(ca(2:5))];
  [outstruct.NLC(count.NLC.n).vnmatrix] = [add_nodes(ca(2:5))];

  [tf, idx] = ismember (ca{6}, models_list.mname);

  if (tf)
    outstruct.NLC(count.NLC.n).func    = models_list.melement{idx};
    outstruct.NLC(count.NLC.n).section = models_list.msection{idx};

    ## check if parameters are specified
    for prm_idx = 1:(length (ca)-6)/2
      if length (ca)>=4+prm_idx*2
        outstruct.NLC(count.NLC.n).npar++;
        outstruct.NLC(count.NLC.n).nparnames++;
        outstruct.NLC(count.NLC.n).parnames{1, prm_idx} = ca{2*prm_idx+5};
        outstruct.NLC(count.NLC.n).pvmatrix(1, prm_idx) = literal2num (ca{2*prm_idx+6});
      else
        syntaxError (line);
      endif
    endfor

    ## add model parameters to list
    prm_idx = outstruct.NLC(count.NLC.n).npar;
    len = length (models_list.plist{idx}.pnames);
    for mpidx = 1:len
      outstruct.NLC(count.NLC.n).parnames{prm_idx+mpidx}   = models_list.plist{idx}.pnames{mpidx};
      outstruct.NLC(count.NLC.n).pvmatrix(1, prm_idx+mpidx) = models_list.plist{idx}.pvalues(mpidx);
    endfor
    outstruct.NLC(count.NLC.n).npar        = outstruct.NLC(count.NLC.n).npar+len;
    outstruct.NLC(count.NLC.n).nparnanames = outstruct.NLC(count.NLC.n).nparnames+len;

    outstruct = NLCintvar(outstruct, count.NLC.n, ca{1});
  else
    syntaxError (line);
  endif
endfunction

function [outstruct, count]= prs_spice_P (line, outstruct, count)
  element = "Mpmosfet";
  ## check wheter the element type already exists in output structure
  ## update counters
  count.NLC.n++;
  count.NLC.list{count.NLC.n}        = element;

  ## if the element doesn't exists, add it to the output structure
  outstruct.NLC(count.NLC.n).func    = element;
  outstruct.NLC(count.NLC.n).section = "simple";
  ## outstruct.NLC(count.NLC.n).section = "lincap";
  outstruct.NLC(count.NLC.n).nextvar = 4;
  outstruct.NLC(count.NLC.n).npar    = 0;
  outstruct.NLC(count.NLC.n).nrows   = 1;
  outstruct.NLC(count.NLC.n).nparnames = 0;
  outstruct.NLC(count.NLC.n).parnames  = {};
  ##outstruct.NLC(count.NLC.n).vnmatrix  = [];
  outstruct.NLC(count.NLC.n).pvmatrix  = [];

  ## convert input line string into cell array
  ca = str2ca (line);
  ## update parameter value and connectivity matrix
  ##[outstruct.NLC(idx).vnmatrix] = [add_nodes(ca(2:5))];
  [outstruct.NLC(count.NLC.n).vnmatrix] = [add_nodes(ca(2:5))];

  ## check if parameters are specified
  for prm_idx = 1:(length (ca)-5)/2
    ## [tf, str_idx] = ismember (outstruct.NLC(count.NLC.n).parnames{prm_idx}, ca);
    ## TODO: can the loop be executed in a single operation?
    ## [tf, str_idx] = ismember (outstruct.NLC(count.NLC.n).parnames, ca);
    if (length (ca) >= 3+prm_idx*2)
      ## find specified parameter name
      ##if tf

      outstruct.NLC(count.NLC.n).npar++;
      outstruct.NLC(count.NLC.n).nparnames++;
      outstruct.NLC(count.NLC.n).parnames{1, prm_idx} = ca{2*prm_idx+4};
      outstruct.NLC(count.NLC.n).pvmatrix(1, prm_idx) = literal2num (ca{2*prm_idx+5});
      ##else
      ## TODO: set to a default value undefined parameters, instead of rising an error?
      ##        errstr=sprintf("Undefined parameter %s in line: %s", outstruct.NLC(count.NLC.n).parnames{prm_idx}, line);
      ##        error(errstr);
      ##endif
    else
      syntaxError (line);
    endif
  endfor

  outstruct = NLCintvar(outstruct, count.NLC.n, ca{1});
endfunction


function [outstruct, count]= prs_spice_R (line, outstruct, count)

  element = "Mresistors";
  ## check wheter the element type already exists in output structure
  [tf, idx] = ismember ({element}, count.LCR.list);
  if !tf
    ## update counters
    count.LCR.n++;
    count.LCR.list{count.LCR.n}        = element;
    ##idx = count.LCR.n;

    ## if the element doesn't exists, add it to the output structure
    outstruct.LCR(count.LCR.n).func    = element;
    outstruct.LCR(count.LCR.n).section = "LIN";
    outstruct.LCR(count.LCR.n).nextvar = 2;
    outstruct.LCR(count.LCR.n).npar    = 1;
    outstruct.LCR(count.LCR.n).nrows   = 0;
    outstruct.LCR(count.LCR.n).nparnames = 1;
    outstruct.LCR(count.LCR.n).parnames  = {"R"};
    outstruct.LCR(count.LCR.n).vnmatrix  = [];
    outstruct.LCR(count.LCR.n).pvmatrix  = [];
  endif

  ## add an element to the structure
  ##outstruct.LCR(idx).nrows++;
  outstruct.LCR(count.LCR.n).nrows++;

  ## convert input line string into cell array
  ca = str2ca (line);

  if (length (ca) > 3)
    ## update parameter value and connectivity matrix
    ##[outstruct.LCR(idx).vnmatrix] = [outstruct.LCR(idx).vnmatrix; add_nodes(ca(2:3))];
    ##[outstruct.LCR(idx).pvmatrix] = [outstruct.LCR(idx).pvmatrix; literal2num(ca{4})];
    [outstruct.LCR(count.LCR.n).vnmatrix] = [outstruct.LCR(count.LCR.n).vnmatrix; add_nodes(ca(2:3))];
    [outstruct.LCR(count.LCR.n).pvmatrix] = [outstruct.LCR(count.LCR.n).pvmatrix; literal2num(ca{4})];
  else
    syntaxError (line);
  endif

  outstruct = LCRintvar(outstruct, count.LCR.n, ca{1});
endfunction

function [outstruct, count] = prs_spice_V (line, outstruct, count)

  ## Sine
  ## SIN(VO  VA  FREQ TD  THETA)
  ##
  ## VO    (offset)
  ## VA    (amplitude)
  ## FREQ  (frequency)
  ## TD    (delay)
  ## THETA (damping factor)
  ##
  ## 0 to TD: V0
  ## TD to TSTOP:  VO  + VA*exp(-(time-TD)*THETA)*sine(twopi*FREQ*(time+TD)

  ## check if it is a sinwave generator
  sine = regexp (line, '(?<stim>SIN)[\s]*\((?<prms>.+)\)', 'names');

  ## Pulse
  ## PULSE(V1 V2 TD TR  TF  PW  PER)
  ##
  ## parameters  default values  units
  ## V1  (initial value) Volts or Amps
  ## V2  (pulsed value) Volts or Amps
  ## TD  (delay time)  0.0  seconds
  ## TR  (rise  time)  TSTEP  seconds
  ## TF  (fall time)  TSTEP  seconds
  ## PW  (pulse width)  TSTOP  seconds
  ## PER (period)  TSTOP  seconds

  ## check if it is a pulse generator
  pulse = regexp (line, '(?<stim>PULSE)[\s]*\((?<prms>.+)\)', 'names');

  if (! isempty (sine.stim))
    ## sinwave generator
    ca = str2ca (sine.prms);
    if (length (ca) == 5)
      vo = literal2num (ca{1});
      va = literal2num (ca{2});
      freq = literal2num (ca{3});
      td = literal2num (ca{4});
      theta = literal2num (ca{5});

      pvmatrix = [va freq td vo];

      element = "Mvoltagesources";
      section = "sinwave";

      nextvar = 2;
      npar    = 4;
      nparnames = 4;
      parnames  = {"Ampl", "f", "delay", "shift"};
      ## convert input line string into cell array
      ca = str2ca (line);
      vnmatrix  = add_nodes (ca(2:3));
      [outstruct, count] = addNLCelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
      outstruct = NLCintvar(outstruct, count.NLC.n, ca{1});
    else #length(ca) == 5
      syntaxError (line);
    endif #length (ca) == 5
  elseif (! isempty (pulse.stim))
    ca = str2ca (pulse.prms);
    if length (ca) == 7
      low = literal2num (ca{1});
      high = literal2num (ca{2});
      delay = literal2num (ca{3});
      ## TODO: add rise and fall times!
      ## tr = literal2num (ca{4});
      ## tf = literal2num (ca{5});
      thigh = literal2num (ca{6});
      period = literal2num (ca{7})
      tlow = period-thigh;

      pvmatrix = [low high tlow thigh delay];

      element = "Mvoltagesources";
      section = "squarewave";

      nextvar = 2;
      npar    = 5;
      nparnames = 5;
      parnames  = {"low", "high", "tlow", "thigh", "delay"};
      ## convert input line string into cell array
      ca = str2ca (line);
      vnmatrix  = add_nodes (ca(2:3));
      [outstruct, count] = addNLCelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
      outstruct = NLCintvar(outstruct, count.NLC.n, ca{1});
    else ##length (ca) == 7
      syntaxError (line);
    endif ##length (ca) == 7
  else ##~isempty (tran.stim)
    ## DC generator
    element = "Mvoltagesources";
    section = "DC";

    nextvar = 2;
    npar    = 1;
    nparnames = 1;
    parnames  = {"V"};
    ## convert input line string into cell array
    ca = str2ca (line);
    vnmatrix  = add_nodes (ca(2:3));

    pvmatrix  = literal2num (ca{4});
    [outstruct, count] = addLCRelement (outstruct, count, element, section, nextvar, npar, nparnames, parnames, vnmatrix, pvmatrix);
    outstruct = LCRintvar(outstruct, count.LCR.n, ca{1});
  endif #~isempty(tran.stim)
endfunction

function [outstruct, count] = prs_spice_dot (line, outstruct, count)
  ## .MODEL MNAME TYPE(PNAMEl = PVALl PNAME2 = PVAL2 ... )

  ## TYPE can be:
  ## R    resistor model
  ## C    capacitor model
  ## URC  Uniform Distributed RC model
  ## D    diode model
  ## NPN  NPN BIT model
  ## PNP  PNP BJT model
  ## NJF  N-channel JFET model
  ## PJF  P-channel lFET model
  ## NMOS N-channel MOSFET model
  ## PMOS P-channel MOSFET model
  ## NMF  N-channel MESFET model
  ## PMF  P-channel MESFET model
  ## SW   voltage controlled switch
  ## CSW  current controlled switch

  global models_list;

  model = regexp (line, '.MODEL[\s]+(?<mname>[\S]+)[\s]+(?<mtype>R|C|URC|D|NPN|PNP|NJF|PJF|NMOS|PMOS|NMF|PMF|SW|CSW)[\s]*\([\s]*(?<prms>.+)[\s]*\)', 'names');
  if !isempty (model)
    switch (model.mtype)
      case 'R'
      case 'C'
      case 'URC'
      case 'D'
        element = "Mdiode";
      case 'NPN'
      case 'PNP'
      case 'NJF'
      case 'PJF'
      case 'NMOS'
        element = "Mnmosfet";
      case 'PMOS'
        element = "Mpmosfet";
      case 'NMF'
      case 'PMF'
      case 'SW'
      case 'CSW'
      otherwise
        syntaxError (line);
    endswitch

    ## get model level (=section)
    level = regexp (model.prms, 'LEVEL=(?<level>[\S]+)[\s]+(?<prms>.+)', 'names');
    if isempty (level.level)
      section = "simple";
    else
      section = level.level;
      model.prms = level.prms;
    endif

    midx = length (models_list.mname)+1;

    models_list.mname{midx} = model.mname;
    models_list.melement{midx} = element;
    models_list.msection{midx} = section;

    ## set model parameters
    ca = str2ca (model.prms);
    midx = length (models_list.mname);

    models_list.plist{midx} = struct ("pnames", {""}, "pvalues", []);

    for prm_idx = 1:length (ca)/2
      ## save parameter name
      models_list.plist{midx}.pnames{prm_idx} = ca{2*prm_idx-1};
      ## save parameter value
      models_list.plist{midx}.pvalues = [models_list.plist{midx}.pvalues literal2num(ca{2*prm_idx})];
    endfor

  endif #!isempty (model)
endfunction

## adds nodes to nodes_list and returns the indexes of the added nodes
function indexes = add_nodes (nodes)
  global nodes_list;
  for ii = 1:length (nodes)
    [tf, idx] = ismember (nodes(ii), nodes_list);
    if tf
      indexes(ii) = idx-1;
    else
      indexes(ii) = length (nodes_list);
      nodes_list{length (nodes_list)+1} = nodes{ii};
    endif
  endfor
endfunction

%!demo
%! outstruct = prs_spice ("rlc");
%! vin = linspace (0, 10, 10);
%! x = zeros (outstruct.totextvar+outstruct.totintvar, 1);
%!
%! for idx = 1:length (vin)
%!   outstruct.NLC(1).pvmatrix(1) = vin(idx);
%!   out = nls_stationary (outstruct, x, 1e-15, 100);
%!   vout(idx) = out(2);
%! end
%!
%! plot (vin, vout);
%! grid on;

%!demo
%! ## Circuit
%! 
%! cir = menu ("Chose the circuit to analyze:",
%! 	       "AND (Simple algebraic MOS-FET model)",
%! 	       "AND (Simple MOS-FET model with parasitic capacitances)",
%! 	       "Diode clamper (Simple exponential diode model)",
%! 	       "CMOS-inverter circuit (Simple algebraic MOS-FET model)",
%! 	       "n-MOS analog amplifier (Simple algebraic MOS-FET model)",
%! 	       "Linear RC circuit",
%! 	       "Diode bridge rectifier",
%!             "RLC circuit");
%! 
%! switch cir
%!   case 1
%!     outstruct = prs_spice ("and");
%!     x         = [.5 .5 .33 .66 .5 1 0 0 1 ]';
%!     t         = linspace (0, .5, 100);
%!     pltvars   = {"Va", "Vb", "Va_and_b"};
%!     dmp       = .2;
%!     tol       = 1e-15;
%!     maxit     = 100;
%!   case 2
%!     outstruct = prs_spice ("and2");
%!     x         = [.8;.8;0.00232;0.00465;.8;
%! 		 .8;0.00232;0.00465;0.00000;
%! 		 0.0;0.0;0.0;0.00232;0.0;
%! 		 0.0;0.0;0.0;1.0;0.0;-0.0;
%! 		 0.0;1.0;0.00465;0.0;0.0;
%! 		 -0.0;1.0;0.00465;0.0;
%! 		 0.0;0.0;1.0;1.0;0.0;0.0;0.0;
%! 		 0.0;0.0;0.0];
%!     t       = linspace (.25e-6, .5e-6, 100);
%!     dmp     = .1;
%!     pltvars = {"Va", "Vb", "Va_and_b"};
%!     tol     = 1e-15;
%!     maxit   = 100;
%!   case 3
%!     outstruct = prs_spice ("diode");
%!     x   = [0 0 0 0 0]';
%!     t   = linspace (0, 3e-10, 200);
%!     dmp = .1;
%!     pltvars = {"Vin", "Vout", "V2"};
%!     tol   = 1e-15;
%!     maxit = 100;
%!   case 4
%!     outstruct = prs_spice ("inverter");
%!     x   = [.5  .5   1   0   0]';
%!     t   = linspace (0, 1, 100);
%!     dmp = .1;
%!     pltvars={"Vgate", "Vdrain"};
%!     tol   = 1e-15;
%!     maxit = 100;
%!   case 5
%!     outstruct = prs_spice ("nmos");
%!     x         = [1 .03 1 0 0]';
%!     t         = linspace (0, 1, 50);
%!     dmp       = .1;
%!     pltvars   = {"Vgate", "Vdrain"};
%!     tol   = 1e-15;
%!     maxit = 100;
%!   case 6
%!     outstruct = prs_spice ("rcs");
%!     x         = [0 0 0 0]';
%!     t         = linspace (0, 2e-5, 100);
%!     dmp       = 1;
%!     pltvars   = {"Vout"};
%!     tol   = 1e-15;
%!     maxit = 100;
%!   case 7
%!     outstruct = prs_spice ("rect");
%!     x         = [0 0 0 0 ]';
%!     t         = linspace (0, 3e-10, 60);
%!     dmp       = .1;
%!     pltvars   = {"Vin", "Voutlow", "Vouthigh"};
%!     tol   = 1e-15;
%!     maxit = 100;
%!   case 8
%!     outstruct = prs_spice ("rlc")
%!     #x         = [0 0 0 0 0]';
%!     #x         = [0 0 0 ]';
%!     #x         = [0 0 0 0]';
%!     x         = [0 0 0 0 0 0 ]';
%!     t         = linspace (0, 2e-5, 200);
%!     dmp       = 1;
%!     #pltvars   = {"Vin", "Vout"};
%!     pltvars   = {"I(C3)"};
%!     #pltvars   = {"Vout"};
%!     tol   = 1e-15;
%!     maxit = 100;
%!   otherwise
%!     error ("unknown circuit");
%! endswitch
%! 
%! clc;
%! slv = menu("Chose the solver to use:",
%! 	   "BWEULER", # 1
%! 	   "DASPK",   # 2
%! 	   "THETA",   # 3
%! 	   "ODERS",   # 4
%! 	   "ODESX",   # 5
%! 	   "ODE2R",   # 6
%! 	   "ODE5R"    # 7
%! 	   );
%! 
%! out   = zeros (rows (x), columns (t));
%! 
%! switch slv
%!   case 1
%!     out = tst_backward_euler (outstruct, x, t, tol, maxit, pltvars);
%!     # out = TSTbweuler (outstruct, x, t, tol, maxit, pltvars);
%!   case 2
%!     out = tst_daspk (outstruct, x, t, tol, maxit, pltvars);
%!     # out = TSTdaspk (outstruct, x, t, tol, maxit, pltvars);
%!   case 3
%!     out = tst_theta_method (outstruct, x, t, tol, maxit, .5, pltvars, [0 0]);
%!     # out = TSTthetamethod (outstruct, x, t, tol, maxit, .5, pltvars, [0 0]);
%!   case 4
%!     out = tst_odepkg (outstruct, x, t, tol, maxit, pltvars, "oders", [0, 1]);
%!     # out = TSTodepkg (outstruct, x, t, tol, maxit, pltvars, "oders", [0, 1]);
%!   case 5
%!     out = tst_odepkg (outstruct, x, t, tol, maxit, pltvars, "odesx", [0, 1]);
%!     # out = TSTodepkg (outstruct, x, t, tol, maxit, pltvars, "odesx", [0, 1]);
%!   case 6
%!     out = tst_odepkg (outstruct, x, t, tol, maxit, pltvars, "ode2r", [0, 1]);
%!     # out = TSTodepkg (outstruct, x, t, tol, maxit, pltvars, "ode2r", [0, 1]);
%!   case 7
%!     out = tst_odepkg (outstruct, x, t, tol, maxit, pltvars, "ode5r", [0, 1])
%!     # out = TSTodepkg (outstruct, x, t, tol, maxit, pltvars, "ode5r", [0, 1])
%!   otherwise
%!     error ("unknown solver");
%! endswitch
%! 
%! #utl_plot_by_name (t, out, outstruct, pltvars);
%! utl_plot_by_name (t, out, outstruct, pltvars);
%! axis ("tight");
