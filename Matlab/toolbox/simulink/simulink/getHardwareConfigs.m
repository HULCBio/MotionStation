function ret = getHardwareConfigs(varargin)
% GETHARDWARECONFIGS -- get the harware configuration table
% $Revision: 1.1.6.5 $
  
  persistent configTable;
  
  if isempty(configTable)
    
    % Configuration table
    index = 1;

    % By default: enabled = false; visible = true;
    
    configTableDefault.Name            = '';
    configTableDefault.Type            = '';
    configTableDefault.Char.Value      = 8;
    configTableDefault.Char.Enabled    = false;
    configTableDefault.Char.Visible    = true;
    configTableDefault.Short.Value     = 16;
    configTableDefault.Short.Enabled   = false;    
    configTableDefault.Short.Visible   = true;    
    configTableDefault.Int.Value       = 32;
    configTableDefault.Int.Enabled     = false;
    configTableDefault.Int.Visible     = true;
    configTableDefault.Long.Value      = 32;
    configTableDefault.Long.Enabled    = false;
    configTableDefault.Long.Visible    = true;
    configTableDefault.Endian.Value    = 'Unspecified';
    configTableDefault.Endian.Enabled  = false;
    configTableDefault.Endian.Visible  = true;
    configTableDefault.NatWdSize.Value = 32;
    configTableDefault.NatWdSize.Enabled = false;
    configTableDefault.NatWdSize.Visible = true;
    configTableDefault.SftRht.Value    = true;
    configTableDefault.SftRht.Enabled  = false;
    configTableDefault.SftRht.Visible  = true;
    configTableDefault.IntDiv.Value    = 'Undefined';
    configTableDefault.IntDiv.Enabled  = false;
    configTableDefault.IntDiv.Visible  = true;
    configTableDefault.ForProd         = true;
    configTableDefault.ForTarget       = true;
 
    configTable = configTableDefault;
    configTable(index).Name      = 'Unspecified (assume 32-bit Generic)';
    configTable(index).Type      = '32-bit Generic';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 32;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Unspecified';
    configTable(index).NatWdSize.Value = 32;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;
    
    configTable(index) = configTableDefault;    
    configTable(index).Name            = 'Custom';    
    configTable(index).Type            = 'Specified';
    configTable(index).Char.Value      = 8;
    configTable(index).Char.Enabled    = true;
    configTable(index).Short.Value     = 16;
    configTable(index).Short.Enabled   = true;    
    configTable(index).Int.Value       = 32;
    configTable(index).Int.Enabled     = true;
    configTable(index).Long.Value      = 32;
    configTable(index).Long.Enabled    = true;
    configTable(index).Endian.Value    = 'Unspecified';
    configTable(index).Endian.Enabled  = true;
    configTable(index).NatWdSize.Value = 32;
    configTable(index).NatWdSize.Enabled = true;
    configTable(index).SftRht.Value    = true;
    configTable(index).SftRht.Enabled  = true;
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd         = true;
    configTable(index).ForTarget       = true;
    index = index+1;
    
    configTable(index) = configTableDefault;
    configTable(index).Name      = '32-bit Generic Embedded Processor';
    configTable(index).Type      = '32-bit Embedded Processor';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 32;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Unspecified';
    configTable(index).Endian.Enabled  = true;
    configTable(index).NatWdSize.Value = 32;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;
    
    configTable(index) = configTableDefault;
    configTable(index).Name      = 'MATLAB Host Computer';
    configTable(index).Type      = 'MATLAB Host';
    if exist('rtwhostwordlengths') == 2 |  exist('rtwhostwordlengths') == 6
      wl = rtwhostwordlengths;
      configTable(index).Char.Value      = wl.CharNumBits;
      configTable(index).Short.Value     = wl.ShortNumBits;
      configTable(index).Int.Value       = wl.IntNumBits;
      configTable(index).Long.Value      = wl.LongNumBits;
    else
      configTable(index).Char.Value      = 8;
      configTable(index).Char.Visible    = false;      
      configTable(index).Short.Value     = 16;
      configTable(index).Short.Visible   = false;
      configTable(index).Int.Value       = 32;
      configTable(index).Int.Visible     = false;
      configTable(index).Long.Value      = 32;
      configTable(index).Long.Visible    = false';
    end     
    if exist('rtw_host_implementation_props') == 2 | ...
          exist('rtw_host_implementation_props') == 6
      imp = rtw_host_implementation_props;
      configTable(index).Endian.Value    = 'Unspecified';
      configTable(index).Endian.Visible  = false;
      configTable(index).NatWdSize.Value = 32;
      configTable(index).NatWdSize.Visible = false;
      if imp.ShiftRightIntArith
        configTable(index).SftRht.Value    = true;
      else
        configTable(index).SftRht.Value    = false;
      end
      configTable(index).IntDiv.Value    = 'Undefined';
      configTable(index).IntDiv.Visible  = false;
    else
      configTable(index).Endian.Value    = 'Unspecified';
      configTable(index).Endian.Visible    = false;
      configTable(index).NatWdSize.Value = 32;
      configTable(index).NatWdSize.Visible = false;
      configTable(index).SftRht.Value    = true;
      configTable(index).SftRht.Visible    = false;
      configTable(index).IntDiv.Value    = 'Undefined';
      configTable(index).IntDiv.Visible    = false;
    end
    configTable(index).ForProd   = false;
    configTable(index).ForTarget = true;
    index = index+1;
  
    configTable(index) = configTableDefault;
    configTable(index).Name      = 'ARM 7/8/9';
    configTable(index).Type      = 'ARM7';    
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 32;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Little';
    configTable(index).Endian.Enabled  = true;
    configTable(index).NatWdSize.Value = 32;
    configTable(index).NatWdSize.Enabled = true;    
    configTable(index).SftRht.Value    = true;
    configTable(index).SftRht.Enabled  = true;    
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;    
    
    configTable(index) = configTableDefault;
    configTable(index).Name      = 'Hitachi SH-2, SH-3, SH-4';
    configTable(index).Type      = 'Hitachi SH-2';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 32;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Big';
    configTable(index).Endian.Enabled  = true;
    configTable(index).NatWdSize.Value = 32;
    configTable(index).SftRht.Value    = true;
    configTable(index).SftRht.Enabled  = true;    
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;
    
    configTable(index) = configTableDefault;
    configTable(index).Name      = 'Infineon TriCore';
    configTable(index).Type      = 'Infineon TriCore';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 32;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Little';
    configTable(index).NatWdSize.Value = 32;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;

    configTable(index) = configTableDefault;
    configTable(index).Name      = 'Motorola 32-bit PowerPC';
    configTable(index).Type      = 'Motorola PowerPC';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 32;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Big';
    configTable(index).NatWdSize.Value = 32;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;
    
    configTable(index) = configTableDefault;
    configTable(index).Name      = 'Motorola 68332';
    configTable(index).Type      = 'Motorola 68332';    
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 32;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Big';
    configTable(index).NatWdSize.Value = 32;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;
    
    configTable(index) = configTableDefault;
    configTable(index).Name      = 'NEC V850';
    configTable(index).Type      = 'NEC 85x';    
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 32;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Little';
    configTable(index).Endian.Enabled  = true;
    configTable(index).NatWdSize.Value = 32;
    configTable(index).SftRht.Value    = true;
    configTable(index).SftRht.Enabled  = true;    
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;    

    configTable(index) = configTableDefault;
    configTable(index).Name      = 'TI C6000';
    configTable(index).Type      = 'TI C6000';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 32;
    configTable(index).Long.Value      = 40;
    configTable(index).Endian.Value    = 'Little';
    configTable(index).Endian.Enabled  = true;
    configTable(index).NatWdSize.Value = 32;
    configTable(index).NatWdSize.Enabled = false;    
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Zero';
    configTable(index).IntDiv.Enabled  = false;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;
    
    configTable(index) = configTableDefault;
    configTable(index).Name      = '16-bit Generic Embedded Processor';
    configTable(index).Type      = '16-bit Generic';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 16;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Unspecified';
    configTable(index).Endian.Enabled  = true;
    configTable(index).NatWdSize.Value = 16;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;

    configTable(index) = configTableDefault;
    configTable(index).Name      = 'Infineon C16x, XC16x';
    configTable(index).Type      = 'Infineon C16x';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 16;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Little';
    configTable(index).NatWdSize.Value = 16;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Zero';
    configTable(index).IntDiv.Enabled  = false;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;
    
    configTable(index) = configTableDefault;
    configTable(index).Name      = 'Motorola HC(S)12';
    configTable(index).Type      = 'Motorola HC12';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 16;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Big';
    configTable(index).NatWdSize.Value = 16;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;
    
    configTable(index) = configTableDefault;
    configTable(index).Name      = 'STMicroelectronics ST10';
    configTable(index).Type      = 'ST Microelectronics ST10';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 16;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Little';
    configTable(index).NatWdSize.Value = 16;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Zero';
    configTable(index).IntDiv.Enabled  = false;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;    

    configTable(index) = configTableDefault;
    configTable(index).Name      = 'TI C2000';
    configTable(index).Type      = 'TI C2000';
    configTable(index).Char.Value      = 16;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 16;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Little';
    configTable(index).Endian.Enabled  = true;
    configTable(index).NatWdSize.Value = 16;
    configTable(index).NatWdSize.Enabled = false;    
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Zero';
    configTable(index).IntDiv.Enabled  = false;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;
        
    configTable(index) = configTableDefault;
    configTable(index).Name      = '8-bit Generic Embedded Processor';
    configTable(index).Type      = '8-bit Generic';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 16;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Unspecified';
    configTable(index).Endian.Enabled  = true;
    configTable(index).NatWdSize.Value = 8;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;

    configTable(index) = configTableDefault;
    configTable(index).Name      = 'Motorola 68HC11';
    configTable(index).Type      = 'Motorola 68HC11';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 16;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Big';
    configTable(index).NatWdSize.Value = 8;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;   
    
    configTable(index) = configTableDefault;
    configTable(index).Name      = 'Motorola HC08';
    configTable(index).Type      = 'Motorola HC08';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 16;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Big';
    configTable(index).NatWdSize.Value = 8;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;
    
    configTable(index) = configTableDefault;
    configTable(index).Name      = '32-bit Generic Real Time Simulator';
    configTable(index).Type      = '32-bit Generic Real Time Simulator';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 32;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Unspecified';
    configTable(index).Endian.Enabled  = true;
    configTable(index).NatWdSize.Value = 32;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1;     

    configTable(index) = configTableDefault;
    configTable(index).Name      = '32-bit Real-Time Windows Target';
    configTable(index).Type      = '32-bit Real-Time Windows Target';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 32;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Little';
    configTable(index).NatWdSize.Value = 32;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Zero';
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1; 

    configTable(index) = configTableDefault;
    configTable(index).Name      = '32-bit xPC Target (Intel Pentium)';
    configTable(index).Type      = '32-bit xPC Target (Intel Pentium)';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 32;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Little';
    configTable(index).NatWdSize.Value = 32;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'floor';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1; 

    configTable(index) = configTableDefault;
    configTable(index).Name      = '32-bit xPC Target (AMD Athlon)';
    configTable(index).Type      = '32-bit xPC Target (AMD Athlon)';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 32;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Little';
    configTable(index).NatWdSize.Value = 32;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'floor';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1; 

    configTable(index) = configTableDefault;
    configTable(index).Name      = 'SGI UltraSPARC IIi';
    configTable(index).Type      = 'SGI UltraSPARC IIi';
    configTable(index).Char.Value      = 8;
    configTable(index).Short.Value     = 16;
    configTable(index).Int.Value       = 32;
    configTable(index).Long.Value      = 32;
    configTable(index).Endian.Value    = 'Big';
    configTable(index).NatWdSize.Value = 32;
    configTable(index).SftRht.Value    = true;
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Enabled  = true;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = true;
    index = index+1; 
     
    configTable(index) = configTableDefault;
    configTable(index).Name      = 'ASIC/FPGA';
    configTable(index).Type      = 'ASIC/FPGA';
    configTable(index).Char.Value      = 8;
    configTable(index).Char.Visible      = false;
    configTable(index).Short.Value     = 16;
    configTable(index).Short.Visible     = false;
    configTable(index).Int.Value       = 32;
    configTable(index).Int.Visible       = false;
    configTable(index).Long.Value      = 32;
    configTable(index).Long.Visible      = false;
    configTable(index).Endian.Value    = 'Unspecified';
    configTable(index).Endian.Visible    = false;
    configTable(index).NatWdSize.Value = 32;
    configTable(index).NatWdSize.Visible = false;
    configTable(index).SftRht.Value    = true;
    configTable(index).SftRht.Visible    = false;
    configTable(index).IntDiv.Value    = 'Undefined';
    configTable(index).IntDiv.Visible    = false;
    configTable(index).ForProd   = true;
    configTable(index).ForTarget = false;
    index = index + 1;
    
  end

  ret = [];
  if nargin == 1
    name = varargin{1};
    if isempty(name)
      ret = configTable;
    else
      switch name
       case 'production'
        ret = configTable(find([configTable.ForProd]));
       case 'target'
        ret = configTable(find([configTable.ForTarget]));        
       otherwise
        for i = 1:length(configTable)
          if strcmp(configTable(i).Type, name)
            ret = configTable(i);
            break;
          end
        end
      end
    end
  else
    mode = varargin{1};
    val  = varargin {2};

    switch mode
     case 'Type'
      for i = 1:length(configTable)
        if strcmp(configTable(i).Type, val)
          ret = configTable(i);
          break;
        end
      end
      
     case 'Name'
      for i = 1:length(configTable)
        if strcmp(configTable(i).Name, val)
          ret = configTable(i);
          break;
        end
      end
    end
  end
      
%% EOF