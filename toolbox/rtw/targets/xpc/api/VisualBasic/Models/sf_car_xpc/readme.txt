
xPC Target API COM 2.0 Interface Example for Visual Basic.

 -------------
|Introduction:|
 --------------

The "sf_car_xpc.exe" application is a stand alone demo that demonstates the use of the xPC
Target API using xPC Target API COm Inteterface from Visual basic with the xPC Target PC running
version 2.0 of xPC Target. This application is built and written in Visual Basic Professional
Edition Version 6.0. The application is designed to interface with an xPC Target 
application "sf_car_xpc.dlm" which has been built in house from the xPC system Target file 
"xpctarget.tlc".

The target applicaction is built from the Simulink model "sf_car_xpc.mdl" which  models an 
Automatic Transmission Control system composed of modules which represent the engine, 
transmission and vehicle, whith an additional logic block to control the transmission 
ratio.  User inputs to the model are in the form of throttle (%) and brake torque(ft-lb). 

The Actual Simulink model the Target Application is built from is not needed since the 
target application "sf_car_xpc.dlm" is built for you and provided with the Visual Basic 
application demo.

If you wish to explore the dynamics and the design of the "sf_car.mdl" further, you can 
access the original model from the following directory:

$:\<MATLABROOT>\toolbox\stateflow\sfdemos\sf_car.mdl

or the xPC version "sf_car_xpc.mdl" from the following directory:

$:\<MATLABROOT>\C_API\VisualBasic


Please note, Stateflow would have to be installed and licensed on your system to access
the Simulink model, since the model contains a Stateflow chart. 

The MathWorks also provides automotive examples in the Simulink Automotive Examples 
Booklet. This booklet contains a collection of automotive models developed to solve 
real-world problems in engineering and design, including "sf_car.mdl". In addition 
it contains a thorough discussion in modeling the "sf_car" model and the steps 
involved in building the model.

To receive a copy of the complete booklet with the technical explanations and documentation
for the sf_car model, send an email request to: info@mathworks.com.  Ask for the Using 
Simulink and Stateflow in Automotive Applications booklet and include your mailing address.  
International customers should contact their distributors directly to order this booklet.

 ---------------
| **IMPORTANT** |
 --------------- 

Prior to using the application you must have the Visual Basic 6.0 Service Pack 4 run-time files 
installed. The VB 6.0 run-time files are absolutely needed for all applications created with 
Visual Basic 6.0 to run. If the Visual Basic 6.0 run time files are not installed on your system, 
run time errors may occur when launching the application. 

To install the Visual Basic 6.0 Service Pack 4 run-time files you would need to download a self-
extracting executable file "VBRun60sp4.exe" that installs the latest versions of the Microsoft 
Visual Basic run-time files from the Microsoft website at the following address:

http://support.microsoft.com/support/kb/articles/Q235/4/20.ASP



 --------------------------------
|Using the sfcarxpc application:|
 -------------------------------- 

Prior to using tbe application you must have a host PC to run the VB Application from and a second Target 
PC booted with the xPC kernel ready for the Host PC to connect to via Serial Communication using the RS232 
ports or via Network Communication link using the TCP/IP protocol.


Run the Executable:
------------------

	 To Launch the application, double click on the "sfcarxpc.exe" or launch the application from the start
	 menu and select 'Run' then browse to the following directory and select the "sfcarxpc.exe" file:
     
	 <XPCAPIROOT>\VisualBasic

Placing the xpcapi.dll:
----------------------

	 The "xpcapi.dll" could be placed in either the following directories:

	        - The Directory containing the sf_car_xpc .exe file:
             
        	  <XPCAPIROOT>\VisualBasic   

	        - Windows system directory (often but not necessarily \Windows\System)
	
        	- Windows directory (not necessarily \Windows)



Using the Application:
----------------------

Step 1:  Connecting the Host PC and the Target PC.  From the "Setup Comms" menu choose the proper
         communication link option "serial" or "TCP/IP" depending on the communication the Target
         PC is setup for. 


         Connection Serial: If the Serial Communication is selected a Serial dialog box appears to 
                            select the proper COM ports. Selcect the proper check box for Com 1 or
                            Com 2

         Connection TCP/IP: If TCP/IP is selected a TCP/IP dialog box appeears and prompts to enter
                            the Target IP address and Port Number. For example, if the Target IP 
                            address is:  121.100.10.123 and the Port number is: 22222. Then the 
                            dotted decimal string "121.100.10.123" would be entered in the IP 
                            address text field without the quotes. And the port number string 
                            "22222" would be entered in the port number Text field also without 
                            the quotes.  


Step 2:  Loading the sfcar Target Application to the Target PC.

         The Target application used for this demo application is "sf_car_xpc.dlm" and is placed 
         in the following directory:

         $:\<MATLABROOT>\C_API\VisualBasic

         To load the sf_car_xpc target application to the target PC, select the 'load car' option from 
         the "Load/Unload" menu.  This will bring up a Load dialog box and detect the directory path
         to the Target application name "sf_car_xpc.dlm". The target application must be in the same
         directory of the VB application. The text fields are disabled since the application is only 
	 designed to interface with the sf_car_xpc.dlm target application, and the information needed
         for the Load dialog box is hardcoded in the application


Step 3:  Interfacing with the Target Application:

         The Application allows to control the Target application using the following control features:

         - Start Engine button: To start the Engine of the Target Application on the Target PC
         - Stop  Engine button: To stop the Engine of the Target Application on the Target PC
         - Edit Stop Time: When Target application is stopped you can change the Stop Time (-1 mapps to infinity).
         - Edit Sample Time: When the Target application is stopped you can change the Sample Time.
         - Throttle Slider: User input to the Target application  that represents the throttle percentage
           (Range of slider covers (0-100). To change slider value, left click and scroll to the proper 
           percentage value displayed with the Percentage indicator. 
         - Brake Slider: User input to the Target application that represents braking (ft-lb)
           (Range of Slider covers (0-4000). To change slider value, left click and scroll to the proper 
           value displayed with the Brake Display.  


Saving Settings:
---------------

	Upon Exit of the Application, you will be prompted to save the current settings.
	The settings will be saved in an ascii file "sfcarset.dat".
	You can also save the settings at any point once the original settings has changed.
	Do not delete the "sfcarset.dat" file from its Directory.




 ------------------------
|Running Under WINNT 4.0:|
 ------------------------


	If your running the Application on WINNT 4.0, and the following error occurs:

 		Runtime Error '429' : ActiveX Component Can't Create Object 

	
        it means that the Microsoft Scripting Runtime Library is not installed on your system.
        Microsoft Scripting Runtime must be installed through the use of a self-extracting .exe 
        file located at: 

        http://www.microsoft.com/msdownload/vbscript/scripting.asp 






In order to rebuild the "sfcarxpc.exe" executable, you will need to have a
copy of Visual Basic 6.0. The project file sf_carxpcapi.vbp can then be opened
with Microsoft Visual Basic 6.0, and the application rebuilt.

If Building a standard executable from scratch using Visual Basic, you will need 
to add a reference to the xPC Target API COM Type library. This is done  by selecting "Referecnes" under
the project menu and checking the  xPC Target API COM Type library.




