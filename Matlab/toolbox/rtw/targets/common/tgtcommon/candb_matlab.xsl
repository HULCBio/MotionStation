<?xml version="1.0" ?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" indent="no"/> 

  <!-- XSL Stylesheet for generating a matlab file.
       
       The matlab file when run will create a structure
       array called message.

	See readcandbdbc.m

	Copyright 2003-2004 The MathWorks, Inc.
	$Revision: 1.1.6.2 $
	$Date: 2004/04/19 01:21:43 $

   -->
  <xsl:template match="/">
   % CANdb A data file that represents candb data
   function message = candb 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %         SIGNAL FIELDS             %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    signal_fields = { ...
      'name' ...
      'start_bit' ... 
      'bit_length' ... 
      'byte_layout' ... 
      'sign' ... 
      'data_type' ... 
      'multiplex_type' ... 
      'multiplex_value' ... 
      'offset' ...
      'factor' ...
      'min' ... 
      'max' ... 
      'units' ... 
      'receivers' ... 
    };

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %         MESSAGE FIELDS            %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    message_fields = { ...
        'name' ...
        'id' ...
        'idtype' ...
        'dlc' ...
        'transmitter' ...
        'signal' ...
    };

  % Variable referenced by the nested functions
  message = [];
  signal_idx = 0;
  message_idx = 0;

  % ADDMESSAGE nested function that creates a new message
  %
  % c = { name id idtype dlc transmitter signals }
  %
  % signals should be an empty array
  function addMessage(c)
     message_idx = message_idx + 1;
     signal_idx = 0;
     struct = cell2struct(c, message_fields, 2);
     if message_idx == 1
        message = struct;
     else
        message(message_idx) = struct;
     end
  end

  % ADDSIGNAL nested function that creates a new signal
  %
  % s = { name 
  %   start_bit  
  %   bit_length  
  %   byte_layout  
  %   sign  
  %   data_type  
  %   multiplex_type  
  %   multiplex_value  
  %   offset 
  %   factor
  %   min  
  %   max  
  %   units  
  %   receivers 
  %  } 
  function addSignal(s)
    signal_idx = signal_idx + 1;
    struct = cell2struct(s,signal_fields,2);    
    mess = message(message_idx);
    if signal_idx == 1
        mess.signal = struct;
    else
        mess.signal(signal_idx) = struct;
    end
    message(message_idx) = mess;
  end

    <!--Process each message-->
    <xsl:for-each select="candb/message">
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %%               MESSAGE                 %%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      addMessage( { '<xsl:value-of select="name" />', <xsl:value-of select="id" />, '<xsl:value-of select="idtype" />', <xsl:value-of select="dlc" />, '<xsl:value-of select="transmitter" />', [] }); 
      <xsl:for-each select="signals/signal">
      addSignal( {  '<xsl:value-of select="name"/>',<xsl:value-of select="start_bit"/>, <xsl:value-of select="bit_length"/>, <xsl:value-of select="byte_layout"/>, '<xsl:value-of select="sign"/>', '<xsl:value-of select="data_type"/>', '<xsl:value-of select="multiplex_type"/>', '<xsl:value-of select="multiplex_value"/>', <xsl:value-of select="offset"/>, <xsl:value-of select="factor"/>, <xsl:value-of select="min"/>, <xsl:value-of select="max"/>, '<xsl:value-of select="units"/>', { <xsl:for-each select="receivers/receiver"> <xsl:if test="not(position() = 1)">,</xsl:if> '<xsl:value-of select="text()"/>' </xsl:for-each> } } );
      </xsl:for-each>
    </xsl:for-each>
end
  </xsl:template>



</xsl:stylesheet>

