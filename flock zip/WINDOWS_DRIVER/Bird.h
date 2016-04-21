/****************************************************************************
*****************************************************************************

	Bird.h			Bird driver header file

    Version:		3.07

    Written for:    Ernie Blood
                    Ascension Technology Corporation
					P.O.Box 527
					Burlington, VT 05402
					802-860-6440 (voice)
					802-860-6439 (fax)

    Written by:     Bruce Larson
                    Microprocessor Designs, Inc.
                    P.O.Box 160, 1 Pine Haven Shore
                    Shelburne, VT  05482
                    802-985-2535 (voice)
                    802-985-9106 (fax)

	Remarks:		The bird driver routines are described in this header file.
					To use them, simply include this header file in your source 
					code, link with the library module "Bird.lib", and put the
					dynamic-link library "Bird.dll" anywhere on the DLL search 
					path.

					If you are using ISA birds on an NT platform, you must 
					do the following before running your application for the
					first time:

					1. Copy the file WinRT.sys into the Windows NT
					   system32\drivers directory.

					2. Run the Registry.exe program.  This updates the NT
					   registry with the WinRT driver specs.  It takes two 
					   command line arguments - the port address of the first 
					   ISA bird, and the number of ISA birds in the system.
					   Both arguments are given in decimal.

					3. Run the Loader.exe program with the -L option.  This
					   actually loads the driver.  To unload, use the -U
					   option.
					
					========================================================

					The routines in this driver provide an interface to the
					Ascension Technology birds for Win32 applications.
					With the exception of the initialization routines, this
					interface is standardized across all platforms (whether
					TCP/IP, RS232, and ISA), so that the underlying protocol
					is transparent to the main application.

					Because there are many possible bird configurations,
					the routines attempt to maintain simplicity by dealing 
					with the birds on a group-by-group basis.  A "group" is
					either a single bird in stand-alone mode or a set of
					birds in master/slave mode.  Each group is treated as a
					separate entity - it is initialized, used, and destroyed
					independently from other groups.  You can specify as many
					groups as you need to, up to BIRD_MAX_GROUP_ID.

					To initialize a group, you call either birdTCPIPWakeUp(),
					birdRS232WakeUp(), or birdISAWakeUp(), depending on which
					communications protocol is to be used.  The first 
					parameter to these routines is a group ID number, chosen
					by the calling procedure, which will be used to identify
					the group in all subsequent procedure calls.

					After waking up the group, you will typically want to 
					change its configuration.  This done by obtaining a 
					copy of the configuration structure, modifying the 
					relevant fields, and then sending the structure back to 
					the group.  The routines that are used to do this are 
					birdGetSystemConfig() and birdSetSystemConfig() (for
					system configuration) and birdGetDeviceConfig() and 
					birdSetDeviceConfig() (for individual device 
					configuration.)
					
					After the group has been configured, you can either
					obtain individual frames of data upon request, or start
					a stream of data and collect the frames as they arrive:
					
						1) To get a single data frame, call 
						birdStartSingleFrame() to initiate the frame 
						capture, and then birdGetFrame() to retrieve 
						the frame.  In between, you can call 
						birdFrameReady() to find out if the frame is 
						ready yet.
					
						2) To start a stream of data, call 
						birdStartFrameStream().  If you want to collect all 
						the data frames in order, you should repeatedly call 
						birdGetFrame() to get them one by one.  If you only 
						want the most recently arrived data frame, you should
						instead call birdGetMostRecentFrame().  To find out 
						if a new frame is waiting to be retrieved, you can 
						call birdFrameReady().  To stop the stream of data, 
						call birdStopFrameStream().

					To shut down the group, call birdShutDown().  This stops
					all data transmission, turns off the transmitter, and
					disables all further communication with the group (until
					another wakeup command is issued.)

					In addition to this standardized interface, each
					communications mode also has several routines which
					provide low-level access to the communications 
					hardware.  In TCP/IP mode, you can send and receive
					generic packets using birdTCPIPSendCommand() and
					birdTCPIPGetResponse(), and you can clear the receiver
					buffer using birdTCPIPClearBuffer().  In RS232 mode, 
					you can do similar things using birdRS232SendCommand(),
					birdRS232GetResponse(), and birdRS232ClearBuffer().
					You can also resynchronize the data stream using
					birdRS232Resynch(), or trigger a reset using 
					birdRS232Reset().  All of these low-level RS232 commands
					are also implemented for ISA.


Modification History:        
------------------------------------------------------------------------------
$Log: /Asctech/Bird Driver/Pc_src/Bird.h $
 * 
 * 10    4/16/01 9:54a Kprei
 * Added definition for Laser Bird device and set minimum time resolution
 * for multimedia timer to 1ms.
 * 
 * 9     2/27/01 7:41a Kprei
 * Blars -   Added birdRS232SetGroupMode() to allow the user to specify 
 * whether or not the birds will be put into group mode during data 
 * collection.  Also replaced birdRS232NonGroupModeAllowed() with 
 * birdRS232GroupModeEnabled() for semantic clarity.
 * 
 * 9     2/21/01 10:24a Kprei
 * Use bird transmitter defaults when calling birdRS232Wakeup() and
 * birdISAWakeup().  Do not set transmitter to pulse mode.
 * 
 * 8     1/19/01 2:52p Kprei
 * Blars -   Added routines birdStartFrameReadyCallback() and 
 * birdStopFrameReadyCallback() to set up a callback function that is
 * called whenever a new frame of data is ready.
 * 
 * 7     1/18/01 2:34p Kprei
 * Added routines birdStartFrameReadyCallback() and 
 * birdStopFrameReadyCallback() to set up a callback function that is
 * called whenever a new frame of data is ready.
 * 
 * 6     11/08/00 11:48a Kprei
 * Added routine birdRS232NonGroupModeAllowed() to allow user to determine
 * whether or non the birds can collect data in non-group mode.  Also
 * added a check to birdEnableMeasurementCycleReporting() to signal an
 * error if called while non-group mode is not allowed.  This was done
 * because the master bird is unable to send the data-ready character
 * while the birds are in group mode. Adjusted timing delays for faster
 * initialization.
 * 
 * 5     8/28/00 10:23a Kprei
 * Deleted floating point reading structures used in 3D-Bird interface.
 * 
 * 4     8/25/00 8:52a Kprei
 * Stripped 3dbird interface from driver.
 * 
 * 2     12/23/99 11:18a Kprei
 * Added level of abstraction to 3DOF interface routines.  Changed 3DOF
 * driver to poll serial port every 50ms, convert data to angles or matrix
 * and save in data queue.  Interface functions query data queue, not
 * serial buffer.
 * 
 * Interface Changes:
 * 
 * Previous
 * -------------
 * BOOL DLLEXPORT birdTDFStartStream(int nGroupID);
 *      
 * BOOL DLLEXPORT birdTDFGetReading(int nGroupID, float *pfReading, 
 * int nDataFormat );
 *              
 * nDataFormat = 0, Euler Angles
 * nDataFormat = 1, Matrix
 * 
 * BOOL DLLEXPORT birdTDFGetMostRecentReading(int nGroupID, float
 * *pfReading, int nDataFormat);
 * 
 * nDataFormat = 0, Euler Angles
 * nDataFormat = 1, Matrix
 * 
 * Current
 * -----------
 * BOOL DLLEXPORT birdTDFStartStream(int nGroupID, int nDataFormat);
 * 
 * nDataFormat = BDF_ANGLES, Euler Angles
 * nDataFormat = BDF_MATRIX, Matrix
 * 
 * BOOL DLLEXPORT birdTDFGetReading(int nGroupID, float *pfReading);
 * 
 * BOOL DLLEXPORT birdTDFGetMostRecentReading(int nGroupID, float
 * *pfReading);
 * 
 *       01/23/98       bel
 * Created.
 *
 *       09/14/98       bel		
 * Added birdDisplayErrorDialogs() to allow enabling and disabling of error messages.
 *
 *       09/14/98       bel		
 * Modified birdGetReading(), birdGetFrame(), and birdGetMostRecentFrame() to return TRUE/FALSE 
 * instead of a bird error code.  Added birdGetErrorCode() as a means of retrieving the
 * error code when one of these funtions fails.
 *            
 *       11/05/98       bel		
 * Fixed on/off status of filters for RS232 and ISA modes.
 *
 *       12/17/98       bel		
 * Added "nNumDevices" argument to birdTCPIPWakeUp(),since querying for this value does not work on
 * wireless systems.
 *
 *       03/06/99       bel		
 * Added birdGetFastDeviceConfig() and birdSetFastDeviceConfig() to speed up initialization and 
 * reduce errors.
 *
 *       03/09/99       bel		
 * Optimized birdStartSingleFrame() for speed in RS232 mode.
 *
 *       04/28/99       bel		
 * Modified birdStartFrameStream() and birdGetFrame()to ignore bad packets in TCP/IP mode.  Fixed bug
 * in birdTCPIPClearBuffer().
 *
 *       07/15/99       bel		
 * Modified birdRS232WakeUp() and birdISAWakeUp() to put the transmitter into pulsed mode on startup.
 *
 *       08/17/99       bel
 * Added birdTDFWakeUp(), birdTDFStartStream(), birdTDFGetReading(), birdTDFGetMostRecentReading(),
 * birdTDFReadingReady(), and birdTDFStopStream()for controlling the new three-degree-of-freedom 
 * orientation sensor.
 *
 *       10/09/99       bel		
 * Added birdMB2WakeUp() for communication with the MiniBird2 device.
 *
 *       11/16/99       bel		
 * Fixed setting of measurement rate for post-3.63	firmware.
 *
 *       11/18/99       bel
 * Put workaround in birdGetFrame() to ignore invalid phasing bytes from pre-3.64 firmware.
 *
 *       11/19/99       bel	
 * Enabled group-mode data collection for MiniBird II mode.
 * 
 * 1     12/22/99 3:38p Kprei
 * Initial check in.

-------------------------------------------------------------------------------

          <<<< Copyright 1998 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/

#ifndef __BIRD_H__
#define __BIRD_H__

#if defined(__cplusplus)
extern "C"
{
#endif

// Macro for DLL export functions
#define DLLEXPORT	__declspec(dllexport) __cdecl

// Maximum allowable group identifier
#define BIRD_MAX_GROUP_ID			256		// maximum allowable group id #

// Maximum allowable bird number
#define BIRD_MAX_DEVICE_NUM			126		// maximum allowable bird #

// Bird errors
#define BE_NOERROR					0x00	// no error
#define BE_GENERICERROR				0x01	// generic error
#define BE_TCPIPERROR				0x10	// TCP/IP communications error
#define BE_BIRDERROR				0x11	// error signalled by birds
#define BE_INVALIDPACKETTYPEERROR	0x12	// invalid packet type received
#define BE_INVALIDBIRDNUMBERERROR	0x13	// invalid bird number received
#define BE_INVALIDDATAFORMATERROR	0x14	// invalid data format received
#define BE_RS232ERROR				0x20	// RS232 communications error
#define BE_PHASEERROR				0x21	// error in phasing bits (usually indicates lost or corrupted data)
#define BE_RESYNCHERROR				0x22	// unable to resynch after a phase error
#define BE_OVERRUNERROR				0x23	// measurement cycle was overrun
#define BE_ISAERROR					0x30	// ISA communications error

// Bird system status bits
#define BSS_RUNNING					0x80	// system is initialized and running
#define BSS_ERROR					0x40	// error in system occurred
#define BSS_FBB_ERROR				0x20	// error on FBB bus occurred
#define BSS_LOCAL_ERROR				0x10	// error in local chassis occurred
#define BSS_LOCAL_POWER				0x08	// error in local power status occurred
#define BSS_MASTER					0x04	// local chassis is a master
#define BSS_CRTSYNC_TYPE			0x02	// type of CRT sync being used
#define BSS_CRTSYNC					0x01	// CRT sync mode is enabled

// Bird transmitter number bits
#define BTN_FBBADDRESS              0xF0	// FBB address of transmitter
#define BTN_FBBADDRESS3				0x80
#define BTN_FBBADDRESS2				0x40
#define BTN_FBBADDRESS1				0x20
#define BTN_FBBADDRESS0				0x10
#define BTN_TRANSMITTERNUMBER		0x03	// index of transmitter
#define BTN_TRANSMITTERNUMBER1		0x02
#define BTN_TRANSMITTERNUMBER0		0x01

// Bird flock status bits
#define BFS_FBBACCESSIBLE			0x80	// device is accessible on the FBB
#define BFS_RUNNING					0x40	// device is initialized and running
#define BFS_RECEIVERPRESENT			0x20	// device has a receiver
#define BFS_ERC						0x10	// device is an ERC
#define BFS_ERT3					0x08	// if an ERC, ERT#3 is present
#define BFS_ERT2					0x04	// if an ERC, ERT#2 is present
#define BFS_ERT1					0x02	// if an ERC, ERT#1 is present
#define BFS_ERT0					0x01	// if an ERC, ERT#0 is present, else SRT is present

// Bird device status bits
#define BDS_ERROR					0x80	// error in device occurred
#define BDS_RUNNING					0x40	// device is initialized and running
#define BDS_BUTTONSPRESENT			0x08	// device has buttons
#define BDS_RECEIVERPRESENT			0x04	// device has a receiver
#define BDS_TRANSMITTERPRESENT		0x02	// device has a transmitter
#define BDS_TRANSMITTERRUNNING		0x01	// device has an active transmitter

// Bird device ID's
#define BDI_6DFOB					1		// Standalone (SRT)
#define BDI_6DERC					2		// Extended Range Controller
#define BDI_6DBOF					3		// Motionstar (old ID)
#define BDI_PCBIRD					4		// PC Bird
#define BDI_SPACEPAD				5		// Spacepad
#define BDI_MOTIONSTAR				6		// Motionstar (new ID)
#define BDI_LASERBIRD				8		// Laser Bird 
#define BDI_UNRECOGNIZED			255		// unrecognized device

// Bird device setup bits
#define BDS_SUDDENOUTPUTCHANGE		0x20	// sudden large data change will not update output data
#define BDS_XYZREFERENCE			0x10	// position is derived from XYZ reference frame angle table
#define BDS_APPENDBUTTONDATA		0x08	// button data is appended
#define BDS_ACNARROWNOTCHFILTER		0x04	// AC narrow notch filter is in use
#define BDS_ACWIDENOTCHFILTER		0x02	// AC wide notch filter is in use
#define BDS_DCFILTER				0x01	// DC filter is in use

// Bird data formats
#define BDF_NOBIRDDATA				0		// no data (NOTE: RS232 and ISA modes have no way of specifying this format)
#define BDF_POSITION				1		// position only
#define BDF_ANGLES					2		// angles only
#define BDF_MATRIX					3		// matrix only
#define BDF_POSITIONANGLES			4		// position and angles
#define BDF_POSITIONMATRIX			5		// position and matrix
#define BDF_QUATERNION				7		// quaternion only
#define BDF_POSITIONQUATERNION		8		// position and quaternion

// Bird hemisphere codes
#define BHC_FRONT					0		// front hemisphere
#define BHC_REAR					1		// rear hemisphere
#define BHC_UPPER					2		// upper hemisphere
#define BHC_LOWER					3		// lower hemisphere
#define BHC_LEFT					4		// left hemisphere
#define BHC_RIGHT					5		// right hemisphere

// Bird transmitter type bits
#define BTT_ERT						0x80	// ERT is present
#define BTT_SRT						0x40	// SRT is present
#define BTT_PCBIRD					0x20	// PCBIRD is present
#define BTT_ACTIVE					0x10	// transmitter is active
#define BTT_SELECTED1				0x08	// index of selected ERT
#define BTT_SELECTED0				0x04
#define BTT_NUMBER1					0x02	// number of ERT's present
#define BTT_NUMBER0					0x01

// RS232 group mode settings
enum GroupModeSettings
{
	GMS_DEFAULT,							// driver will determine whether or not to use RS232 group mode
	GMS_GROUP_MODE_NEVER,					// RS232 group mode will never be used
	GMS_GROUP_MODE_ALWAYS,					// RS232 group mode will always be used
	NUM_GROUP_MODE_SETTINGS
};

#pragma pack(1)	// pack the following structures on one-byte boundaries

// Bird position structure
typedef struct tagBIRDPOSITION
{
	short	nX;			// x-coordinate
	short	nY;			// y-coordinate
	short	nZ;			// z-coordinate
}
BIRDPOSITION;

// Bird angles structure
typedef struct tagBIRDANGLES
{
	short	nAzimuth;	// azimuth angle
	short	nElevation;	// elevation angle
	short	nRoll;		// roll angle
}
BIRDANGLES;

// Bird matrix structure
typedef struct tagBIRDMATRIX
{
	short	n[3][3];	// array of matrix elements
}
BIRDMATRIX;

// Bird quaternion structure
typedef struct tagBIRDQUATERNION
{
	short	nQ0;		// q0
	short	nQ1;		// q1
	short	nQ2;		// q2
	short	nQ3;		// q3
}
BIRDQUATERNION;

#pragma pack()	// resume normal packing of structures

// Bird reading structure
typedef struct tagBIRDREADING
{
	BIRDPOSITION	position;	// position of receiver
	BIRDANGLES		angles;		// orientation of receiver, as angles
	BIRDMATRIX		matrix;		// orientation of receiver, as matrix
	BIRDQUATERNION	quaternion; // orientation of receiver, as quaternion
	WORD			wButtons;	// button states
}
BIRDREADING;

// Bird frame structure
//
// NOTE: In stand-alone mode, the bird reading is stored in reading[0], and
//  all other array elements are unused.  In master/slave mode, the "reading"
//  array is indexed by bird number - for example, bird #1 is at reading[1],
//  bird #2 is at reading[2], etc., and reading[0] is unused.
typedef struct tagBIRDFRAME
{
	DWORD			dwTime;		// time at which readings were taken, in msecs
	BIRDREADING		reading[BIRD_MAX_DEVICE_NUM + 1];  // reading from each bird
}
BIRDFRAME;

// Bird system configuration structure
//
// NOTE: In TCP/IP mode, the following fields are NOT used:
//  byXtalSpeed
//
// NOTE: In RS232 and ISA modes, the following fields are NOT used:
//	bits BSS_FBB_ERROR, BSS_LOCAL_ERROR, BSS_LOCAL_POWER, and BSS_MASTER of bySystemStatus
//	byNumServers
//	byChassisNum
//	byNumChassisDevices
//	byFirstDeviceNum
//
typedef struct tagBIRDSYSTEMCONFIG
{
	BYTE	bySystemStatus;		// current system status (see bird system status bits, above)
	BYTE	byError;			// error code flagged by server or master bird
	BYTE	byNumDevices;		// number of devices in system
	BYTE	byNumServers;		// number of servers in system
	BYTE	byXmtrNum;			// transmitter number (see transmitter number bits, above)
	WORD	wXtalSpeed;			// crystal speed in MHz
	double	dMeasurementRate;	// measurement rate in frames per second
	BYTE	byChassisNum;		// chassis number
	BYTE	byNumChassisDevices; // number of devices within this chassis
	BYTE	byFirstDeviceNum;	// number of first device in this chassis
	WORD	wSoftwareRev;		// software revision of server application or master bird
	BYTE	byFlockStatus[BIRD_MAX_DEVICE_NUM + 1];	// status of all devices in flock, indexed by bird number (see note in BIRDFRAME definition) - see bird flock status bits, above
} 
BIRDSYSTEMCONFIG;

// Bird device configuration structure	
//
// NOTE: In RS232 and ISA modes, the following fields are NOT used:
//	bit BDS_BUTTONSPRESENT of byStatus
//	byID
//
typedef struct tagBIRDDEVICECONFIG
{
	BYTE	byStatus;			// device status (see bird device status bits, above)
	BYTE	byID;				// device ID code (see bird device ID's, above)
	WORD	wSoftwareRev;		// software revision of device
	BYTE	byError;			// error code flagged by device
	BYTE	bySetup;			// setup information (see bird device setup bits, above)
	BYTE	byDataFormat;		// data format (see bird data formats, above)
	BYTE	byReportRate;		// rate of data reporting, in units of frames
	WORD	wScaling;			// full scale measurement, in inches
	BYTE	byHemisphere;		// hemisphere of operation (see bird hemisphere codes, above)
	BYTE	byDeviceNum;		// bird number
	BYTE	byXmtrType;			// transmitter type (see bird transmitter type bits, above)
	WORD	wAlphaMin[7];		// filter constants (see Birdnet3 Protocol pp.26-27 for values)
	WORD	wAlphaMax[7];		// filter constants (see Birdnet3 Protocol pp.26-27 for values)
	WORD	wVM[7];				// filter constants (see Birdnet3 Protocol pp.26-27 for values)
	BIRDANGLES	anglesReferenceFrame;	// reference frame of bird readings
	BIRDANGLES	anglesAngleAlign;		// alignment of bird readings
}
BIRDDEVICECONFIG;

/*
	birdTCPIPWakeUp		Bird wakeup, TCP/IP mode

	Parameters Passed:  int nGroupID
						LPCTSTR lpszServerIPAddress
						WORD wServerIPPort
						int nNumDevices

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Wakes up a group of birds in TCP/IP mode.  "nGroupID"
						can be any number between 0 and BIRD_MAX_GROUP_ID 
						that the user wants to associate with this group of 
						birds.  "lpszServerIPAddress" is a string denoting 
						the IP address of the bird server.  "wServerIPPort" 
						is the server's port number.  "nNumDevices" is the 
						number of devices in the group, including any ERC's, 
						and should be equal to the bird number of the last 
						device.  If set to 0, the driver will attempt to query
						the value from the birds.
*/
BOOL DLLEXPORT birdTCPIPWakeUp(int nGroupID, LPCTSTR lpszServerIPAddress, 
							   WORD wServerIPPort, int nNumDevices);

/*
	birdRS232WakeUp		Bird wakeup, RS232 mode

	Parameters Passed:  int nGroupID
						BOOL bStandAlone
						int nNumDevices
						WORD *pwComport
						DWORD dwBaudRate
						DWORD dwReadTimeout
						DWORD dwWriteTimeout

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Wakes up a group of birds in RS232 mode.  "nGroupID" 
						can be any number between 0 and BIRD_MAX_GROUP_ID 
						that the user wants to associate with this group of 
						birds.  "bStandAlone" indicates if the group consists 
						of a single bird operating in stand-alone mode.  
						"nNumDevices" is the number of devices in the group, 
						including any ERC's, and should be equal to the bird 
						number of the last device.  (This field is only 
						relevant when bStandAlone = FALSE.)  "pwComport"
						points to an array of words, each of which is the
						number of the comport attached to one of the birds
						(e.g., COM1 = 1, COM2 = 2, etc.)  If bStandAlone = 
						TRUE, then the bird's comport number is passed in 
						pwComport[0].  Otherwise, the array is indexed by 
						bird number - for example, pwComport[2] would be the 
						comport attached to bird #2.  Any birds which do not 
						have a direct connection to a comport must be given a 
						comport number of zero.  "dwBaudRate" is the baud 
						rate to use.  "dwReadTimeout" is the maximum time, in 
						msecs, that the application will take when trying to 
						receive a character.  "dwWriteTimeout" is the maximum 
						time, in msecs, that the application will take when 
						trying to transmit a character.  

						NOTE: The first bird in this group must have a direct
							  connection to a comport.

						NOTE: The memory pointed to by "pwComport" may be
							  released after the function returns.
*/
BOOL DLLEXPORT birdRS232WakeUp(int nGroupID, BOOL bStandAlone, int nNumDevices,
							   WORD *pwComport, DWORD dwBaudRate, DWORD dwReadTimeout, 
							   DWORD dwWriteTimeout);

/*
	birdISAWakeUp		Bird wakeup, ISA mode

	Parameters Passed:  int nGroupID
						BOOL bStandAlone
						int nNumDevices
						WORD *pwAddress
						DWORD dwReadTimeout
						DWORD dwWriteTimeout

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Wakes up a group of birds in ISA mode.  "nGroupID" 
						can be any number between 0 and BIRD_MAX_GROUP_ID 
						that the user wants to associate with this group of 
						birds.  "bStandAlone" indicates if the group consists 
						of a single bird operating in stand-alone mode.  
						"nNumDevices" is the number of devices in the group, 
						including any ERC's, and should be equal to the bird
						number of the last device.  (This field is only 
						relevant when bStandAlone = FALSE.)  "pwAddress"
						points to an array of words, each of which is the
						memory-mapped address of one of the birds.  If 
						bStandAlone = TRUE, then the bird's address is 
						passed in pwAddress[0].  Otherwise, the array is 
						indexed by bird number - for example, pwAddress[2] 
						would be the address of bird #2.  Any birds which
						are external to the PC must be given an address
						of zero.  "dwReadTimeout" is the maximum time, in 
						msecs, that the application will take when trying to 
						receive a character.  "dwWriteTimeout" is the maximum
						time, in msecs, that the application will take when 
						trying to transmit a character.

						NOTE: The first bird in this group must be internal
							  to the PC (not an ERC).  Otherwise, use 
							  birdRS232WakeUp() instead of this routine.

						NOTE: The memory pointed to by "pwAddress" may be
							  released after the function returns.
*/
BOOL DLLEXPORT birdISAWakeUp(int nGroupID, BOOL bStandAlone, int nNumDevices, 
							 WORD *pwAddress, DWORD dwReadTimeout, 
							 DWORD dwWriteTimeout);

/*
	birdMB2WakeUp		Bird wakeup, MB2 mode

	Parameters Passed:  int nGroupID
						WORD wAddress
						DWORD dwReadTimeout
						DWORD dwWriteTimeout

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Wakes up a group of birds in MB2 mode.  "nGroupID" 
						can be any number between 0 and BIRD_MAX_GROUP_ID 
						that the user wants to associate with this group of 
						birds.  "wAddress" is the memory-mapped address of 
						the birds.  "dwReadTimeout" is the maximum time, in 
						msecs, that the application will take when trying to 
						receive a character.  "dwWriteTimeout" is the maximum
						time, in msecs, that the application will take when 
						trying to transmit a character.
*/
BOOL DLLEXPORT birdMB2WakeUp(int nGroupID, WORD wAddress, DWORD dwReadTimeout, 
							 DWORD dwWriteTimeout);

/*
	birdGetSystemConfig	 Get system configuration

	Parameters Passed:  int nGroupID
						BIRDSYSTEMCONFIG *psyscfg

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Gets the system configuration of a group of birds.
						"nGroupID" is the group identifier that was passed 
						to birdWakeUp().  The system configuration is 
						returned in "psyscfg".  See the definition of 
						BIRDSYSTEMCONFIG above for an explanation of this 
						structure.
*/
BOOL DLLEXPORT birdGetSystemConfig(int nGroupID, BIRDSYSTEMCONFIG *psyscfg);

/*
	birdSetSystemConfig	 Set system configuration

	Parameters Passed:  int nGroupID
						BIRDSYSTEMCONFIG *psyscfg

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Sets the system configuration of a group of birds.
						"nGroupID" is the group identifier that was passed 
						to birdWakeUp().  The system configuration is 
						passed in "psyscfg".  See the definition of 
						BIRDSYSTEMCONFIG above for an explanation of this 
						structure.

						NOTE: The memory pointed to by "psyscfg" may be
							  released after the function returns.
*/
BOOL DLLEXPORT birdSetSystemConfig(int nGroupID, BIRDSYSTEMCONFIG *psyscfg);

/*
	birdGetDeviceConfig	 Get device configuration

	Parameters Passed:  int nGroupID
						int nDeviceNum
						BIRDDEVICECONFIG *pdevcfg

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Gets the configuration of a single device.
						"nGroupID" is the group identifier that was passed 
						to birdWakeUp().  "nDeviceNum" specifies the bird 
						number (ignored for stand-alone mode).  The device 
						configuration is returned in "pdevcfg".  See the 
						definition of BIRDDEVICECONFIG above for an 
						explanation of this structure.
*/
BOOL DLLEXPORT birdGetDeviceConfig(int nGroupID, int nDeviceNum, 
								   BIRDDEVICECONFIG *pdevcfg);

/*
	birdSetDeviceConfig	 Set device configuration

	Parameters Passed:  int nGroupID
						int nDeviceNum
						BIRDDEVICECONFIG *pdevcfg

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Sets the configuration of a single device.
						"nGroupID" is the group identifier that was passed 
						to birdWakeUp().  "nDeviceNum" specifies the bird 
						number (ignored for stand-alone mode).  The device 
						configuration is passed in "pdevcfg".  See the 
						definition of BIRDDEVICECONFIG above for an 
						explanation of this structure.

						NOTE: The memory pointed to by "pdevcfg" may be
							  released after the function returns.
*/
BOOL DLLEXPORT birdSetDeviceConfig(int nGroupID, int nDeviceNum, 
								   BIRDDEVICECONFIG *pdevcfg);

/*
	birdGetFastDeviceConfig	 Get fast device configuration

	Parameters Passed:  int nGroupID
						int nDeviceNum
						BIRDDEVICECONFIG *pdevcfg

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Faster (and less error-prone) version of 
						birdGetDeviceConfig().  In RS232 and ISA modes,
						the following fields of "pdevcfg" are not used:

							bySetup (except for BDS_APPENDBUTTONDATA bit)
							byReportRate
							byHemisphere
							wAlphaMin[]
							wAlphaMax[]
							wVM[]
							anglesReferenceFrame
							anglesAngleAlign
*/
BOOL DLLEXPORT birdGetFastDeviceConfig(int nGroupID, int nDeviceNum, 
									   BIRDDEVICECONFIG *pdevcfg);

/*
	birdSetFastDeviceConfig	 Set fast device configuration

	Parameters Passed:  int nGroupID
						int nDeviceNum
						BIRDDEVICECONFIG *pdevcfg

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Faster (and less error-prone) version of 
						birdSetDeviceConfig().  In RS232 and ISA modes,
						the following fields of "pdevcfg" are not used:

							bySetup (except for BDS_APPENDBUTTONDATA bit)
							byReportRate
							byHemisphere
							wAlphaMin[]
							wAlphaMax[]
							wVM[]
							anglesReferenceFrame
							anglesAngleAlign
*/
BOOL DLLEXPORT birdSetFastDeviceConfig(int nGroupID, int nDeviceNum, 
									   BIRDDEVICECONFIG *pdevcfg);

/*
	birdStartReading	Start reading

	Parameters Passed:  int nGroupID
						int nDeviceNum

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Starts acquisition of a single bird reading in RS232
						or ISA mode.  "nGroupID" is the group identifier that
						was passed to birdWakeUp().  "nDeviceNum" specifies 
						the bird number (ignored for stand-alone mode).  The
						reading is retrieved by calling birdGetReading().

						NOTE: If the bird is accessible only via the FBB,
							  you should call birdGetReading() directly after
							  birdStartReading() - i.e., before issuing any
							  other bird commands.

						NOTE: In master/slave mode, the first call to
							  birdStartReading() may involve a substantial
							  delay, because the routine must take the birds 
							  out of group mode.  You should therefore make
							  at least one call to birdStartReading() before
							  doing so from a time-critical part of the code.
*/
BOOL DLLEXPORT birdStartReading(int nGroupID, int nDeviceNum);

/*
	birdGetReading		Get reading

	Parameters Passed:  int nGroupID
						int nDeviceNum
						BIRDREADING *preading

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Gets the bird reading that was started by
						birdStartReading().  "nGroupID" is the group 
						identifier that was passed to birdWakeUp().  
						"nDeviceNum" specifies the bird number (ignored for 
						stand-alone mode).  The data is returned in 
						"preading".  See the definition of BIRDREADING above
						for an explanation of this structure.
*/
BOOL DLLEXPORT birdGetReading(int nGroupID, int nDeviceNum, BIRDREADING *preading);

/*
	birdReadingReady	Reading ready?

	Parameters Passed:  int nGroupID
						int nDeviceNum

	Return Value:       TRUE if a reading is ready
						FALSE otherwise

	Remarks:            Determines if the bird reading that was started by
						birdStartReading() is ready.  "nGroupID" is the group
						identifier that was passed to birdWakeUp().  
						"nDeviceNum" specifies the bird number (ignored for 
						stand-alone mode).
*/
BOOL DLLEXPORT birdReadingReady(int nGroupID, int nDeviceNum);

/*
	birdStartSingleFrame  Start single frame

	Parameters Passed:  int nGroupID

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Starts acquisition of a single frame of bird data.
						"nGroupID" is the group identifier that was passed 
						to birdWakeUp().  The frame is retrieved by calling 
						birdGetFrame().

						NOTE: In TCP/IP mode, this function will not work if
							  the MotionStar is a tethered system using software
							  prior to version 14.29.  In such instances, you
							  must instead call birdStartFrameStream(),
							  birdGetFrame(), and birdStopFrameStream() to get a 
							  single frame of bird data.

						NOTE: In ISA mode, data is collected from internal birds
							  only.  If you need to collect data from external birds, 
							  use birdStartReading() instead of this routine to 
							  manually get readings from each bird.

						NOTE: In RS232 mode, if all the birds are connected to
							  RS232 ports, then data will be collected from each
							  bird directly.  Otherwise, the birds are put into 
							  group mode, and all of the data is collected via the 
							  master bird.

						NOTE: In master/slave mode, the first call to
							  birdStartSingleFrame() may involve a substantial
							  delay, because the routine must take the birds 
							  into or out of group mode.  You should therefore make
							  at least one call to birdStartSingleFrame() before
							  doing so from a time-critical part of the code.
*/
BOOL DLLEXPORT birdStartSingleFrame(int nGroupID);

/*
	birdStartFrameStream	Start frame stream

	Parameters Passed:  int nGroupID

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Starts streaming of bird data frames in TCP/IP or
						RS232 mode.  "nGroupID" is the group identifier that 
						was passed to birdWakeUp().  The frames are retrieved 
						by calling birdGetFrame().

						NOTE: Group-mode data collection under ISA has not
							  been tested by Ascension and appears to cause
							  errors.  This routine has therefore been
							  disabled for ISA (except in standalone mode).

						NOTE: This routine cannot be called while measurement
							  cycle reporting is enabled, i.e. between
							  calls to birdEnableMeasurementCycleReporting()
							  and birdDisableMeasurementCycleReporting().

						NOTE: In master/slave mode, the first call to
							  birdStartFrameStream() may involve a substantial
							  delay, because the routine must take the birds 
							  into group mode.  You should therefore make
							  at least one call to birdStartFrameStream() before
							  doing so from a time-critical part of the code.
*/
BOOL DLLEXPORT birdStartFrameStream(int nGroupID);

/*
	birdGetFrame		Get frame

	Parameters Passed:  int nGroupID
						BIRDFRAME *pframe

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Gets the next frame of bird data, during either
						single or streamed frame acquisition.  "nGroupID"
						is the group identifier that was passed to 
						birdWakeUp().  The data is returned in "pframe".  See
						the definition of BIRDFRAME above for an explanation 
						of this structure.
*/
BOOL DLLEXPORT birdGetFrame(int nGroupID, BIRDFRAME *pframe);

/*
	birdGetMostRecentFrame	Get most recent frame

	Parameters Passed:  int nGroupID
						BIRDFRAME *pframe

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Gets the most recent frame of bird data during 
						streamed frame acquisition.  "nGroupID" is the 
						group identifier that was passed to birdWakeUp().  
						The data is returned in "pframe".  See the definition
						of BIRDFRAME above for an explanation of this 
						structure.
*/
BOOL DLLEXPORT birdGetMostRecentFrame(int nGroupID, BIRDFRAME *pframe);

/*
	birdFrameReady		Frame ready?

	Parameters Passed:  int nGroupID

	Return Value:       TRUE if a new frame is ready
						FALSE otherwise

	Remarks:            Determines if a new frame of bird data is ready,
						during either single or streamed frame acquisition.
						"nGroupID" is the group identifier that was passed to
						birdWakeUp().  
*/
BOOL DLLEXPORT birdFrameReady(int nGroupID);

/*
	birdStopFrameStream	Stop frame stream

	Parameters Passed:  int nGroupID

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Stops streaming of bird data frames.  "nGroupID" is 
						the group identifier that was passed to birdWakeUp().
*/
BOOL DLLEXPORT birdStopFrameStream(int nGroupID);

/*
	birdStartFrameReadyCallback		Start frame ready callback

	Parameters Passed:  int nGroupID
						void (CALLBACK* lpfnFrameReadyCallback)(int, LPVOID)
						LPVOID lpvParam

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Sets up a callback function to be called whenever
						a new frame of bird data is ready.  "nGroupID"
						is the group identifier that was passed to 
						birdWakeUp().  "lpfnFrameReadyCallback" is the
						pointer to a callback function, which must take
						the following form:

							void CALLBACK FrameReadyCallback(int nGroupID, LPVOID lpvParam);

						where "nGroupID" is passed the value of the current
						group identifier, and "lpvParam" is a pointer to a
						user-defined parameter (for example, a window handle).  
						The callback function is called once when a new frame 
						of bird data is ready, but further calls are 
						suppressed until the frame is retrieved with 
						birdGetFrame().
*/
BOOL DLLEXPORT birdStartFrameReadyCallback(int nGroupID, void (CALLBACK* lpfnFrameReadyCallback)(int, LPVOID), LPVOID lpvParam);

/*
	birdStopFrameReadyCallback	Stop frame ready callback

	Parameters Passed:  int nGroupID

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Stops the callback function set up by
						birdStartFrameReadyCallback().  "nGroupID"
						is the group identifier that was passed to 
						birdWakeUp().
*/
BOOL DLLEXPORT birdStopFrameReadyCallback(int nGroupID);

/*
	birdEnableMeasurementCycleReporting		Enable Measurement Cycle Reporting

	Parameters Passed:  int nGroupID

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Causes the birds to signal every time they begin a new 
						measurement cycle.  The signal is detected using the routine
						birdNewMeasurementCycle().  "nGroupID" is the group 
						identifier that was passed to birdWakeUp().  

						NOTE: This routine cannot be called while streaming data.
							  To check for new measurement cycles in stream mode,
							  simply call birdFrameReady().

						NOTE: This routine cannot be called in RS232 mode if group mode 
							  is enabled.  This is so because the master bird can only 
							  send the data-ready character if the birds are in non-group 
							  mode.  To ensure that this is the case, first call 
							  birdRS232SetGroupMode() with an argument of 
							  GMS_GROUP_MODE_NEVER.
*/
BOOL DLLEXPORT birdEnableMeasurementCycleReporting(int nGroupID);

/*
	birdDisableMeasurementCycleReporting	Disable Measurement Cycle Reporting

	Parameters Passed:  int nGroupID

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Stops the birds from signalling the start of each
						measurement cycle.  "nGroupID" is the group identifier 
						that was passed to birdWakeUp().  
*/
BOOL DLLEXPORT birdDisableMeasurementCycleReporting(int nGroupID);

/*
	birdNewMeasurementCycle		New Measurement Cycle

	Parameters Passed:  int nGroupID

	Return Value:       TRUE if a new measurement cycle has begun
						FALSE otherwise

	Remarks:            Determines if a new measurement cycle has been reported
						by the birds.  Measurement cycle reporting must first
						be enabled by calling the routine birdEnableMeasurementCycleReporting().  
						"nGroupID" is the group identifier that was passed to 
						birdWakeUp().  

						WARNING: No other data should be pending from the master 
								 bird when the measurement cycle turns over - 
								 otherwise, the "new-measurement-cycle" message
								 will be interspersed with the bird data, thereby
								 corrupting it.  If this occurs, the function will
								 still return TRUE, but the bird error code will be
								 set to BE_OVERRUNERROR.
*/
BOOL DLLEXPORT birdNewMeasurementCycle(int nGroupID);

/*
	birdShutDown		Shut down

	Parameters Passed:  int nGroupID

	Return Value:       void

	Remarks:            Shuts down a group of birds.  "nGroupID" is the
						group identifier that was passed to birdWakeUp().
*/
void DLLEXPORT birdShutDown(int nGroupID);

/*
	birdTCPIPSendCommand  Send command, TCP/IP mode

	Parameters Passed:  int nGroupID
						void *pbuffer
						WORD wNumBytes

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Sends a generic command in TCP/IP mode.  "nGroupID"
						is the group identifier that was passed to 
						birdWakeUp().  The command bytes are passed in 
						"pbuffer", and the number of bytes is passed in 
						"wNumBytes".
*/
BOOL DLLEXPORT birdTCPIPSendCommand(int nGroupID, void *pbuffer, WORD wNumBytes);

/*
	birdTCPIPGetResponse  Get response, TCP/IP mode

	Parameters Passed:  int nGroupID
						void *pbuffer
						WORD wNumBytes

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Gets a generic response in TCP/IP mode.  "nGroupID"
						is the group identifier that was passed to
						birdWakeUp().  The response bytes are passed in 
						"pbuffer", and the number of bytes is passed in 
						"wNumBytes".
*/
BOOL DLLEXPORT birdTCPIPGetResponse(int nGroupID, void *pbuffer, WORD wNumBytes);

/*
	birdTCPIPClearBuffer  Clear buffer, TCP/IP mode

	Parameters Passed:  int nGroupID

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Clears the TCP/IP receiver buffer.  "nGroupID" is the
						group identifier that was passed to birdWakeUp().
*/
BOOL DLLEXPORT birdTCPIPClearBuffer(int nGroupID);

/*
	birdRS232SendCommand  Send command, RS232 mode

	Parameters Passed:  int nGroupID
						int nDeviceNum
						void *pbuffer
						WORD wNumBytes

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Sends a generic command in RS232 mode.  "nGroupID" is
						the group identifier that was passed to birdWakeUp().
						The bird number is passed in "nDeviceNum" (ignored
						for stand-alone mode), the command bytes are passed 
						in "pbuffer", and the number of bytes is passed in 
						"wNumBytes".

						NOTE: This routine will automatically add the
							  FBB-address prefix for devices that are not 
							  attached to a comport, so do not put this 
							  prefix in your command string.
*/
BOOL DLLEXPORT birdRS232SendCommand(int nGroupID, int nDeviceNum, void *pbuffer, 
									WORD wNumBytes);

/*
	birdRS232GetResponse  Get response, RS232 mode

	Parameters Passed:  int nGroupID
						int nDeviceNum
						void *pbuffer
						WORD wNumBytes

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Gets a generic response in RS232 mode.  "nGroupID" is
						the group identifier that was passed to birdWakeUp().
						The bird number is passed in "nDeviceNum" (ignored
						for stand-alone mode), the response bytes are passed 
						in "pbuffer", and the number of bytes is passed in 
						"wNumBytes".
*/
BOOL DLLEXPORT birdRS232GetResponse(int nGroupID, int nDeviceNum, void *pbuffer, 
									WORD wNumBytes);

/*
	birdRS232ClearBuffer  Clear buffer, RS232 mode

	Parameters Passed:  int nGroupID
						int nDeviceNum

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Clears the RS232 receiver buffer.  "nGroupID" is the
						group identifier that was passed to birdWakeUp().
						The bird number is passed in "nDeviceNum" (ignored
						for stand-alone mode).
*/
BOOL DLLEXPORT birdRS232ClearBuffer(int nGroupID, int nDeviceNum);

/*
	birdRS232Resynch    Resynchronize, RS232 mode

	Parameters Passed:  int nGroupID

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Resynchronizes the RS232 data stream during 
						streamed frame acquisition.  "nGroupID" is the 
						group identifier that was passed to birdWakeUp().
*/
BOOL DLLEXPORT birdRS232Resynch(int nGroupID);

/*
	birdRS232Reset		Reset, RS232 mode

	Parameters Passed:  int nGroupID

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Resets a group of birds by toggling the RS232 RTS 
						line.  "nGroupID" is the group identifier that was 
						passed to birdWakeUp().
*/
BOOL DLLEXPORT birdRS232Reset(int nGroupID);

/*
	birdRS232SetGroupMode	Set RS232 group mode

	Parameters Passed:  int nGroupID
						int nGroupModeSetting

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Allows the user to specify whether or not the birds will be
						put into group mode during data collection.  "nGroupID" is 
						the group identifier that was passed to birdWakeUp().  
						"nGroupModeSetting" may take one of three values:  GMS_DEFAULT, 
						GMS_GROUP_MODE_NEVER, or GMS_GROUP_MODE_ALWAYS.  The default 
						setting is for the birds to be put into group mode if and only 
						if there are one or more birds lacking a direct RS232 
						connection to the PC.
*/
BOOL DLLEXPORT birdRS232SetGroupMode(int nGroupID, int nGroupModeSetting);

/*
	birdRS232GroupModeEnabled	Group mode enabled, RS232 mode

	Parameters Passed:  int nGroupID

	Return Value:       TRUE if group mode is enabled
						FALSE otherwise

	Remarks:            Determines whether or not the birds will be put into group mode
						during data collection.  This affects the speed at which data can 
						be collected, and whether or not measurement cycle reporting can 
						be enabled.  "nGroupID" is the group identifier that was passed 
						to birdWakeUp().
*/
BOOL DLLEXPORT birdRS232GroupModeEnabled(int nGroupID);

// Retained for reverse-compatability; returns the negation of birdRS232GroupModeEnabled().
BOOL DLLEXPORT birdRS232NonGroupModeAllowed(int nGroupID);

/*
	birdISASendCommand  Send command, ISA mode

	Parameters Passed:  int nGroupID
						int nDeviceNum
						void *pbuffer
						WORD wNumBytes

	Return Value:       TRUE if exited OK
						FALSE otherwise

    Remarks:            Sends a generic command in ISA mode.  "nGroupID" is
						the group identifier that was passed to birdWakeUp().
						The bird number is passed in "nDeviceNum" (ignored
						for stand-alone mode), the command bytes are passed 
						in "pbuffer", and the number of bytes is passed in 
						"wNumBytes".

						NOTE: This routine will automatically add the
							  FBB-address prefix for devices that are not on 
							  the ISA-bus, so do not put this prefix in your 
							  command string.
*/
BOOL DLLEXPORT birdISASendCommand(int nGroupID, int nDeviceNum, void *pbuffer, 
								  WORD wNumBytes);

/*
	birdISAGetResponse  Get response, ISA mode

	Parameters Passed:  int nGroupID
						int nDeviceNum
						void *pbuffer
						WORD wNumBytes

	Return Value:       TRUE if exited OK
						FALSE otherwise

    Remarks:            Gets a generic response in ISA mode.  "nGroupID" is
						the group identifier that was passed to birdWakeUp().
						The bird number is passed in "nDeviceNum" (ignored
						for stand-alone mode), the response bytes are passed
						in "pbuffer", and the number of bytes is passed in 
						"wNumBytes".
*/
BOOL DLLEXPORT birdISAGetResponse(int nGroupID, int nDeviceNum, void *pbuffer, 
								  WORD wNumBytes);

/*
	birdISAClearBuffer  Clear buffer, ISA mode

	Parameters Passed:  int nGroupID
						int nDeviceNum

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Clears the ISA receiver buffer.  "nGroupID" is
						the group identifier that was passed to birdWakeUp().
						The bird number is passed in "nDeviceNum" (ignored
						for stand-alone mode).
*/
BOOL DLLEXPORT birdISAClearBuffer(int nGroupID, int nDeviceNum);

/*
	birdISAResynch		Resynchronize, ISA mode

	Parameters Passed:  int nGroupID

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Resynchronizes the ISA data stream during streamed
						frame acquisition.  "nGroupID" is the group 
						identifier that was passed to birdWakeUp().
*/
BOOL DLLEXPORT birdISAResynch(int nGroupID);

/*
	birdISAReset		Reset, ISA mode

	Parameters Passed:  int nGroupID

	Return Value:       TRUE if exited OK
						FALSE otherwise

	Remarks:            Resets a group of birds by toggling the ISA RESET 
						line.  "nGroupID" is the group identifier that was 
						passed to birdWakeUp().
*/
BOOL DLLEXPORT birdISAReset(int nGroupID);

/*
	birdDisplayErrorDialogs		Display error dialogs

	Parameters Passed:  BOOL bEnable

	Return Value:       void

	Remarks:            Enables or disables the display of error dialogs.

*/
void DLLEXPORT birdDisplayErrorDialogs(BOOL bEnable);

/*
	birdGetErrorCode	Get error code

	Parameters Passed:  void

	Return Value:       BE_NOERROR if no error occurred
						<bird error> otherwise (see bird error definitions, above)

	Remarks:            Gets the current error code, and resets it to BE_NOERROR.

*/
int DLLEXPORT birdGetErrorCode();

/*
	birdGetDllVersion	Get Bird DLL software version string

	Parameters Passed:  char *szRev  version string

	Return Value:       void

	Remarks:            Gets the current Bird DLL version string.

*/
void DLLEXPORT birdGetDllVersion(char *szRev);

#if defined(__cplusplus)
}	// extern "C"
#endif

#endif	// __BIRD_H__
