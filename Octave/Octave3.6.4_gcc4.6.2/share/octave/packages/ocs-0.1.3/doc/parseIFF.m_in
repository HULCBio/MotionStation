function outstruct = parseIFF(name)

  ######
  ## init
  ######
  
  version ="0.1b1";
  outstruct = struct("NLC",[],...
                     "LCR",[],...
                     "totextvar",0);
  
  ######
  ## open cir file
  ######

  filename = [name ".cir"];
  fid = fopen(filename,"r");

  ######
  ## Check version
  ######
  
  line = fgetl(fid);
  
  if line(1)~="%"
    error(["missing version number in file " filename]);
  end
  
  if ~strcmp(version,sscanf(line(2:end),'%s'));
    error(["conflicting version number in file " filename]);
  end

  ######
  ## NLC section
  ######
  NLCcount = 0;
  while ~strcmp(line,"END")
    line
    ######
    ## skip  comments
    ######
    
    while line(1)=="%"
      line = fgetl(fid)
    end

    if strcmp(line,"END")
      break
    else
      NLCcount++;
    end
    
    ######
    ## parse block header
    ######
    [outstruct]=parseNLCblockheader(fid,line,outstruct,NLCcount);

    ######
    ## parse block par-value matrix
    ######
    [outstruct.NLC(NLCcount).pvmatrix]=...
	fscanf(fid,"%g",[outstruct.NLC(NLCcount).npar,...
			 outstruct.NLC(NLCcount).nrows])';

    ######
    ## parse block var-number matrix
    ######
    [outstruct.NLC(NLCcount).vnmatrix]=...
	fscanf(fid,"%g",[outstruct.NLC(NLCcount).nextvar,...
			 outstruct.NLC(NLCcount).nrows])';
    
    outstruct.totextvar = max([max(outstruct.NLC(NLCcount).vnmatrix(:)) 
                               outstruct.totextvar]);

    ######
    ## skip the newline char after the matrix
    ######
    line = fgetl(fid)
    
    ######
    ## proceed to next line
    ######
    line = fgetl(fid)
  end



  ######
  ## LCR section
  ######
  LCRcount = 0;
  line = fgetl(fid)

  while ~strcmp(line,"END")
    ######
    ## skip  comments
    ######

    while line(1)=="%"
      line = fgetl(fid)
    end

    if strcmp(line,"END")
      break
    else
      LCRcount++;
    end
    
    ######
    ## parse block header
    ######
    [outstruct]=parseLCRblockheader(fid,line,outstruct,LCRcount);
    
    ######
    ## parse block par-value matrix
    ######
    [outstruct.LCR(LCRcount).pvmatrix]=...
	fscanf(fid,"%g",[outstruct.LCR(LCRcount).npar,...
			 outstruct.LCR(LCRcount).nrows])';
    
    ######
    ## parse block var-number matrix
    ######
    [outstruct.LCR(LCRcount).vnmatrix]=...
	fscanf(fid,"%g",[outstruct.LCR(LCRcount).nextvar,...
			 outstruct.LCR(LCRcount).nrows])';

    outstruct.totextvar = max([max(outstruct.LCR(LCRcount).vnmatrix(:)) 
                               outstruct.totextvar]);
    
    ######
    ## skip the newline char after the matrix
    ######
    line = fgetl(fid)
    
    ######
    ## proceed to next line
    ######
    line = fgetl(fid)

  end

  ######
  ## fclose cir file
  ######
  fclose(fid); 

  ######
  ## open nms file
  ######
  
  filename = [name ".nms"];
  fid = fopen(filename,"r");
  

  ######
  ## Check version
  ######
  
  line = fgetl(fid)
  
  if line(1)~="%"
    error(["missing version number in file " filename]);
  end
  
  if ~strcmp(version,sscanf(line(2:end),'%s'));
    error(["conflicting version number in file " filename]);
  end

  ######
  ## Init
  ######
  
  cnt = 1;
  outstruct.namesn = [];
  outstruct.namess = {};
  nnames = 0;
  
  while cnt
    [nn,cnt] = fscanf(fid,"%d","C");
    [ns,cnt] = fscanf(fid,"%s","C");
    if cnt
       outstruct.namesn(++nnames)=nn;
       outstruct.namess(nnames)=ns;
    end
  end
  
  ######
  ## fclose cir file
  ######

endfunction


##############################################
function [outstruct]=parseNLCblockheader(fid,line,outstruct,NLCcount);

  [func,section,nextvar,npar]=sscanf(line,"%s %s %g %g","C");
  outstruct.NLC(NLCcount).func = func;
  outstruct.NLC(NLCcount).section = section;
  outstruct.NLC(NLCcount).nextvar = nextvar;
  outstruct.NLC(NLCcount).npar = npar;
  [nrows,nparnames]=fscanf(fid,"%g %g","C");
  outstruct.NLC(NLCcount).nrows = nrows;
  outstruct.NLC(NLCcount).nparnames = nparnames;
  outstruct.NLC(NLCcount).parnames = {};
  for ii=1:nparnames
    outstruct.NLC(NLCcount).parnames{ii}=fscanf(fid,"%s","C");
  end
endfunction

##############################################
function     [outstruct]=parseLCRblockheader(fid,line,outstruct,LCRcount);

  [func,section,nextvar,npar]=sscanf(line,"%s %s %g %g","C");
  outstruct.LCR(LCRcount).func = func;
  outstruct.LCR(LCRcount).section = section;
  outstruct.LCR(LCRcount).nextvar = nextvar;
  outstruct.LCR(LCRcount).npar = npar;
  [nrows,nparnames]=fscanf(fid,"%g %g","C");
  outstruct.LCR(LCRcount).nrows = nrows;
  outstruct.LCR(LCRcount).nparnames = nparnames;
  outstruct.LCR(LCRcount).parnames = {};
  for ii=1:nparnames
    outstruct.LCR(LCRcount).parnames{ii}=fscanf(fid,"%s","C");
  end
endfunction
