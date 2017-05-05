# MotionStation
Repo for all of Motionstation. The main VI is MotionStation3/ MotionStation.llb/ MotionStation

## DIR
* MotionStation3
	* **MotionStation.llb**
	* GOLPIsource
		* GOLPI
			* Contains the VIs and files for the GOLPI math library
* MotionStation2
	* Contains all the old code for MotionStation before it was cleaned. Mostly kept incase something breaks. 
	* dont download unless you have to this is a big file
* IGSTK
	* Documentation
	* Downloads
		* Contains all the uncompiled code used for IGSTK, along with CMake and Visual Studio 2010 (compiler)
	* fltk-1.1
		* Contains compiled code for FLTK
	* IGSTK-5.2
		* Bin
			* Conatins all the compiled code for IGSTK including the VS solution
		* Certus_Init
			* Contains Source code for the C++ Certus initialize program. Useful for debugging. Is included in IGSTK VS solution
		* Flock_Init
			* Contains Source code for the C++ Flock initialize program. Useful for debugging. Is included in IGSTK VS solution
		* Examples
			* Contains IGSTK examples. Is included in IGSTK VS solution
	* ITK
		* Bin
			* Contains all the compiled code for ITK including VS solution
	* lvvtkwrapBin3
		* Conatins the compiled code for the VTK/IGSTK wrapper used in LabVIEW.
	* VTK
		* Bin
			* Contains all the compiled code for VTK including VS solution
	* VTK wrapper for LV - Source
		* Contains the source code for the LabVIEW wrapper. Is included in the IGSTK VS solution. Compiles to lvvtkwrapBin3

## Compiling IGSTK
If IGSTK ever needs to be recompiled, the steps that I followed are below. All of the uncompiled code, Cmake 2.8 and Visual 
Studio 2010 are in IGSTK/Downloads

1. Run Cmake for VTK, FLTK, and ITK. Use VS10 for the generator
2. Open the Visual Studio solution for VTK, FLTK, and ITK and compile. 
3. Run CMake for IGSTK with VS10 set for the generator
4. Set FLTK_DIR to /FLTK/Fl
5. Set FLTK_INCLUDE_DIR to /FLTK/
6. Open the Visual Studio solution for IGSTK and compile.


  
   
