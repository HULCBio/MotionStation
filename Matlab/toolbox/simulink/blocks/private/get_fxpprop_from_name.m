function fxpProp = get_fxpprop_from_name(name)

% Copyright 2003 The MathWorks, Inc.

  fxpProp.class    = '';
  fxpProp.dt       = '';
  fxpProp.scale    = 1;
  
  if strcmp(name,'double')
    
    fxpProp.class = 'FloatingPoint';
    fxpProp.dt    = float('double');
    
  elseif strcmp(name,'single')
    
    fxpProp.class = 'FloatingPoint';
    fxpProp.dt    = float('single');
    
  elseif strcmp(name,'boolean')
    
    fxpProp.class = 'Boolean';
    fxpProp.dt    = uint(8);
    
  else
    
    fxpProp.class = 'FixedPoint';
    
    fxpProp.isSigned = 1;
    fxpProp.slopeAdj = 1;
    fxpProp.fixedExp = 0;
    fxpProp.bias     = 0;
    fxpProp.numBits  = 8;
    
    switch name

     case 'int8'
    
      fxpProp.dt = sfix(8);
      
     case 'uint8'

      fxpProp.isSigned   = 0;

      fxpProp.dt = ufix(8);
      
     case 'int16'
    
      fxpProp.numBits    = 16;
      
      fxpProp.dt = sfix(16);
      
     case 'uint16'

      fxpProp.numBits    = 16;      
      fxpProp.isSigned   = 0;

      fxpProp.dt = ufix(16);
      
     case 'int32'
    
      fxpProp.numBits    = 32;
      
      fxpProp.dt = sfix(32);
      
     case 'uint32'

      fxpProp.numBits    = 32;      
      fxpProp.isSigned   = 0;

      fxpProp.dt = ufix(32);
      
     otherwise
      
      try
        
        stuff = rtwprivate('slbus','ResolveFixPtType',name);
        
        fxpProp.isSigned = stuff.signed;
        fxpProp.slopeAdj = stuff.slope * stuff.fraction;
        fxpProp.fixedExp = stuff.exponent;
        fxpProp.bias     = stuff.bias;
        fxpProp.numBits  = stuff.nBits;
        
        if fxpProp.slopeAdj < 1 || fxpProp.slopeAdj >= 2
          
          [fff,eee]=log2(fxpProp.slopeAdj);
          
          fxpProp.slopeAdj = 2*fff;
          
          fxpProp.fixedExp = fxpProp.fixedExp + eee - 1;
        end
        
      catch
        clear fxpProp
        
        fxpProp.class = 'Unknown';
    
      end
    
    end

    if strcmp(fxpProp.class,'FixedPoint')
      
      if fxpProp.isSigned 

        fxpProp.dt = sfix(fxpProp.numBits);
      else
        fxpProp.dt = ufix(fxpProp.numBits);
      end

      fxpProp.scale = [fxpProp.slopeAdj*2^fxpProp.fixedExp fxpProp.bias];
      
    end
  end
