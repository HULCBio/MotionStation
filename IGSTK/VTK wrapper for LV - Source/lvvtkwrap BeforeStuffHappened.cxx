//Note from Utsav, this is not the original lvvtkwrap.cxx.  
//I've totally broke compatibility for the reasoning that this 
//Source code got very big.
//I've tried to follow a naming system of LVvtkClassFunction for all functions here.
//New objects are created with LVCreateVtkClass
//It was getting kinda hard to navigate through all the functions in Labview, 
//hence the new naming scheme.  The end result of this, is that the old VIs will likely not work.
//Apologies if this move is dumb and annoying
//For backwards compatibility, I suggest that you use both DLLs in your labview code.  (It should not conflict!)

/***************************************
*  VTK wrapper for Lab View            *
***************************************/


#include "string.h"
#include "stdafx.h"					//for apientry
#include "vtkCubeSource.h"
#include "vtkPolyDataMapper.h"
#include "vtkActor.h"
#include "vtkRenderer.h"
#include "vtkRenderWindow.h"
#include "vtkRenderWindowInteractor.h"
#include "vtkRendererCollection.h"
#include "vtkRenderWindowCollection.h"
#include "vtkActorCollection.h"
#include "vtkProperty.h"
#include "vtkLight.h"
#include "vtkLightCollection.h"
#include "vtkCamera.h"
#include "vtkAbstractPicker.h"
#include "vtkTransform.h"
#include "vtk3DSImporter.h"
#include "vtkWin32OpenGLRenderWindow.h"
#include "vtkVRMLimporter.h"
#include "vtkPolyDataMapper.h"
#include "vtkCylinderSource.h"
#include "vtkConeSource.h"
#include "vtkAxes.h"
#include "vtkTubeFilter.h"
#include "vtkCaptionActor2D.h"
#include "vtkTextProperty.h"
#include "vtkTextSource.h"
#include "vtkCursor3D.h"
#include "vtkAssembly.h"
#include "vtkPropPicker.h"
#include "vtkMath.h"
#include "vtkProp3d.h"
#include "vtkPoints.h"
#include "vtkPolyData.h"
#include "vtkSphereSource.h"
#include "vtkGlyph3D.h"
#include "vtkPolyDataMapper.h"
#include "vtkPolyLine.h"
#include "vtkPolyVertex.h"
#include "vtkFlockTracker.h"
#include "vtkNDITracker.h"
#include "vtkTracker.h"
#include "vtkTrackerTool.h"
#include "vtkTrackerBuffer.h"
#include "vtkMultiThreader.h"
#include "vtkMutexLock.h"
#include "vtkCommand.h"
#include "vtkRenderWindowInteractor.h"
#include "vtkWin32RenderWindowInteractor.h"
//#include "vtkWin32RenderWindowInteractor.cxx"
#include "C:\Program Files\Microsoft Visual Studio\VC98\Include\GL\GL.H"
#include <process.h>
#include <stdlib.h>
#include <time.h>
//#include "vtkInteractorStyleHULC.h"
#include "vtkPolyDataReader.h"
#include "vtkInteractorStyleTrackballCamera.h"
#include "vtkAssemblyPath.h"
#include "vtkAssemblyNode.h"
//maybe just needed for calling win32api from dll?
BOOL APIENTRY DllMain( HANDLE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved )
{
   return TRUE;
}



//VTK_RENDERING_EXPORT LRESULT CALLBACK vtkHandleMessage(HWND,UINT,WPARAM,LPARAM);
//VTK_RENDERING_EXPORT LRESULT CALLBACK vtkHandleMessage2(HWND,UINT,WPARAM,LPARAM,class vtkWin32RenderWindowInteractor*);
void vtkRenderingThread(void *arglist);


extern "C" {
_declspec(dllexport) void LVSuchAFunction();
}
_declspec(dllexport) void LVSuchAFunction()
{
	while (1)
	{
	}

}

void vtkTrackerUpdateThread(void *arglist);
extern "C" {
_declspec(dllexport) void LVvtkStartTrackerUpdateThread(vtkTracker *Tracker, int *Period, unsigned int *PerID, unsigned int arg[]);
}
_declspec(dllexport) void LVvtkStartTrackerUpdateThread(vtkTracker *Tracker, int *Period, unsigned int *PerID, unsigned int arg[])
{
	//Beginthread not platform independant
	arg[0] = (unsigned int) Period;
	arg[1] = (unsigned int) Tracker;
	*PerID = (unsigned int) Period;
	_beginthread(vtkTrackerUpdateThread, 0, (void *) arg);
}

void vtkTrackerUpdateThread(void *arglist)
{
	unsigned int *arg = (unsigned int *) arglist;
	vtkTracker *tracker = (vtkTracker *)  arg[1];
	tracker->Update();
	int period;
	while (tracker->IsTracking())
	{
		
		
		//Warning, Sleep used here, not platform independant
		period = *((int *)  arg[0]);
		if (period > 0)
			tracker->Update();
		Sleep((period!=0)?period:100);
	}
}

extern "C" {
_declspec(dllexport) void LVvtkStartRenderWindow(vtkRenderWindow *RenderWindow,int *Period, unsigned int *PerID, unsigned int arg[]);
}
_declspec(dllexport) void LVvtkStartRenderWindow(vtkRenderWindow *RenderWindow,int *Period, unsigned int *PerID, unsigned int arg[])
{
	arg[0] = (unsigned int) Period;
	arg[1] = (unsigned int) RenderWindow;
	*PerID= (unsigned int) Period;
	_beginthread(vtkRenderingThread, 0, (void *) arg);
}

void vtkRenderingThread(void *arglist)
{	

//	FILE *file = fopen("C:\\Utsav\\DebugLog.txt","w");
	unsigned int *arg = (unsigned int *) arglist;
	vtkRenderWindowInteractor *iren = vtkRenderWindowInteractor::New();
	vtkInteractorStyleTrackballCamera *style = vtkInteractorStyleTrackballCamera::New();
	style->AutoAdjustCameraClippingRangeOff();
	iren->SetInteractorStyle(style);
	vtkRenderWindow *rw = (vtkRenderWindow *)  arg[1];
	int period = *((int *)  arg[0]);
	int timer=0;
	iren->SetRenderWindow(rw);
	rw->Render();
	MSG msg;
	clock_t c0;
	HANDLE h = (HANDLE)CreateEvent( 0, false, false, 0 );
	int ismessage;
	while(1)
	{
		period = (*(int *)  arg[0]);
		if (period >0)
		{
		c0 = clock();
		ismessage=PeekMessage(&msg,NULL,0,0,PM_REMOVE);
		if (!ismessage)
			rw->Render();
		while (ismessage) 
		{
			if (msg.message != (WM_MBUTTONDOWN || WM_LBUTTONDOWN ||WM_RBUTTONDOWN))
				rw->Render();

			TranslateMessage(&msg);
			DispatchMessage(&msg);
			ismessage=PeekMessage(&msg,NULL,0,0,PM_REMOVE);
		}
		timer = period - (int) ((clock() -c0)/(CLOCKS_PER_SEC*0.001));
		if (timer > 0)
		{
			MsgWaitForMultipleObjectsEx( 1, &h, timer, QS_ALLEVENTS, 
				MWMO_ALERTABLE|MWMO_INPUTAVAILABLE );  
		}
//		fprintf(file, "clock 1 %i   period here %i Timer Here %i Clocks per sec %i \n", (int) c0, period, timer, CLOCKS_PER_SEC);
		}
/*		else if (period < 0)
		{
//			fprintf(file, "Hello I'm Paused\n");
			GetMessage(&msg,NULL,0,0);
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}*/
		else
			break;
	}
//	fclose(file);
	CloseHandle( h );
	iren->Delete();  
}


extern "C" {
_declspec(dllexport) void LVvtkRenderingThreadResetCamera(vtkWin32OpenGLRenderWindow *rw);
}
_declspec(dllexport) void LVvtkRenderingThreadResetCamera(vtkWin32OpenGLRenderWindow *rw)
{
	PostMessage(rw->GetWindowId(),WM_CHAR,0x52,0);
}


extern "C" {
_declspec(dllexport) void LVvtkSetThreadUpdateRate(unsigned int PerID, int rate);
}
_declspec(dllexport) void LVvtkSetThreadUpdateRate(unsigned int PerID,int rate)
{
	*((int *)(PerID)) = rate;
}



extern "C" {
_declspec(dllexport) void LVvtkRenderingThreadPause(unsigned int PerID);
}
_declspec(dllexport) void LVvtkRenderingThreadPause(unsigned int PerID)
{
	*((int *)(PerID))  = abs(*((int *)(PerID)))*-1;
}

extern "C" {
_declspec(dllexport) void LVvtkRenderingThreadUnPause(unsigned int PerID);
}
_declspec(dllexport) void LVvtkRenderingThreadUnPause(unsigned int PerID)
{
	*((int *)(PerID))  = abs(*((int *)(PerID)));
}


extern "C" {
_declspec(dllexport) void LVvtkTrackerThreadPause(vtkTracker *Tracker);
}
_declspec(dllexport) void LVvtkTrackerThreadPause(vtkTracker *Tracker)
{
	Tracker->UpdateMutex->Lock();
}


extern "C" {
_declspec(dllexport) void LVvtkTrackerThreadUnPause(vtkTracker *Tracker);
}
_declspec(dllexport) void LVvtkTrackerThreadUnPause(vtkTracker *Tracker)
{
	Tracker->UpdateMutex->Unlock();
}

extern "C" {
_declspec(dllexport) void LVvtkStopRenderWindow(unsigned int PerID);
}
_declspec(dllexport) void LVvtkStopRenderWindow(unsigned int PerID)
{
	*((int *)(PerID)) = 0;
}
extern "C" {
_declspec(dllexport) void LVvtkKillRenderThread(unsigned int PerID);
}
_declspec(dllexport) void LVvtkKillRenderThread(unsigned int PerID)
{
	*((int *)(PerID)) = 0;
}

// Get the number of actors in a specified renderer
extern "C" {
_declspec(dllexport) long LVvtkRendererGetNumberOfActors(vtkRenderer *Renderer, int *N);
}

_declspec(dllexport) long LVvtkRendererGetNumberOfActors(vtkRenderer *Renderer, int *N)
{
	vtkActorCollection *Actors;
	Actors = Renderer->GetActors();
	Actors->InitTraversal();
	*N = Actors->GetNumberOfItems();

	return (1);
}

extern "C" {
_declspec(dllexport) void LVvtkRendererRender(vtkRenderer *Renderer);
}

_declspec(dllexport) void LVvtkRendererRender(vtkRenderer *Renderer)
{
	Renderer->Render();
}

// Get the last actor in the renderer
extern "C" {
_declspec(dllexport) long LVvtkRendererGetLastActor(vtkRenderer *Renderer, vtkActor **Actor);
}

_declspec(dllexport) long LVvtkRendererGetLastActor(vtkRenderer *Renderer, vtkActor **Actor)
{


	vtkActorCollection *Actors = vtkActorCollection::New();
	Actors = Renderer->GetActors();

	Actors->InitTraversal();

	*Actor = Actors->GetLastActor();

	return(1);
}

// Initialize Window
extern "C" {
_declspec(dllexport) long LVvtkNewRenderWindow(vtkRenderWindow **renWinPTR, vtkRenderer **Renderer, vtkRenderWindowInteractor **InteractorPTR, vtk3DSImporter **DSI);
}

_declspec(dllexport) long LVvtkNewRenderWindow(vtkRenderWindow **renWinPTR, vtkRenderer **Renderer, vtkRenderWindowInteractor **InteractorPTR, vtk3DSImporter **DSI)
{
  vtkRenderWindow *renWin = vtkRenderWindow::New();
   *renWinPTR = renWin;
   
  *Renderer = vtkRenderer::New();

//  vtkRenderWindowInteractor *Interactor = vtkRenderWindowInteractor::New();
	vtkObject *Interactor = vtkObject::New();
	*InteractorPTR = (vtkRenderWindowInteractor *) Interactor;

  *DSI = vtk3DSImporter::New();

    renWin->AddRenderer(*Renderer);
	renWin->SetSize(500, 500);

	Interactor = vtkObject::New();
//  Interactor = vtkRenderWindowInteractor::New();
  //Interactor->SetRenderWindow(renWin);

  return (1);
}

// Import 3D Assembly
extern "C" {
_declspec(dllexport) long LVvtk3DSImportAssembly(vtkAssembly **NewAssembly, char *filepath, int ComputeNormals, vtk3DSImporter **DSI);
}

_declspec(dllexport) long LVvtk3DSImportAssembly(vtkAssembly **NewAssembly, char *filepath, int ComputeNormals, vtk3DSImporter **DSI)
{
  *DSI = vtk3DSImporter::New();
  (*DSI)->SetFileName(filepath); 

  if (ComputeNormals)
  {
	  (*DSI)->ComputeNormalsOn();  
  }

  (*DSI)->Read();
  *NewAssembly = vtkAssembly::New();
  (*DSI)->GetRenderer()->GetActors()->InitTraversal();
  for(int i=0; i<(*DSI)->GetRenderer()->GetActors()->GetNumberOfItems(); (*NewAssembly)->AddPart(static_cast<vtkActor *>((*DSI)->GetRenderer()->GetActors()->GetItemAsObject(i++))));
	  (static_cast<vtkActor *>((*DSI)->GetRenderer()->GetActors()->GetItemAsObject(i)))->Delete();
  return (1);
}

// Import 3D Assembly
extern "C" {
_declspec(dllexport) long LVvtkVRMLImportAssembly(vtkAssembly **NewAssembly, char *filepath, vtkVRMLImporter **vrmli);
}

_declspec(dllexport) long LVvtkVRMLImportAssembly(vtkAssembly **NewAssembly, char *filepath, vtkVRMLImporter  **vrmli)
{
  *vrmli = vtkVRMLImporter::New();
  (*vrmli)->SetFileName(filepath); 
  (*vrmli)->Read();
  *NewAssembly = vtkAssembly::New();
  (*vrmli)->GetRenderer()->GetActors()->InitTraversal();
  for(int i=0; i<(*vrmli)->GetRenderer()->GetActors()->GetNumberOfItems(); (*NewAssembly)->AddPart(static_cast<vtkActor *>((*vrmli)->GetRenderer()->GetActors()->GetItemAsObject(i++))))
	  (static_cast<vtkActor *>((*vrmli)->GetRenderer()->GetActors()->GetItemAsObject(i)))->Delete();
  return (1);
}

// Import 3D model
extern "C" {
_declspec(dllexport) long LVvtk3DSImportActor(vtkProp3D **Actor, char *filepath, int ComputeNormals, vtk3DSImporter **DSI);
}

_declspec(dllexport) long LVvtk3DSImportActor(vtkProp3D **Actor, char *filepath, int ComputeNormals, vtk3DSImporter **DSI)
{
  vtkAssembly *NewAssembly;
  *DSI = vtk3DSImporter::New();
  (*DSI)->SetFileName(filepath); 

  if (ComputeNormals)
  {
	  (*DSI)->ComputeNormalsOn();  
  }

  (*DSI)->Read();
  if((*DSI)->GetRenderer()->GetActors()->GetNumberOfItems()==1)
	  *Actor = (*DSI)->GetRenderer()->GetActors()->GetLastActor();
  else if((*DSI)->GetRenderer()->GetActors()->GetNumberOfItems() > 1)
  {
	  NewAssembly = vtkAssembly::New();
	  (*DSI)->GetRenderer()->GetActors()->InitTraversal();
	   for(int i=0; i<(*DSI)->GetRenderer()->GetActors()->GetNumberOfItems(); NewAssembly->AddPart(static_cast<vtkActor *>((*DSI)->GetRenderer()->GetActors()->GetItemAsObject(i++))))
		   (static_cast<vtkActor *>((*DSI)->GetRenderer()->GetActors()->GetItemAsObject(i)))->Delete();
	  *Actor=NewAssembly;
  }
  return (1);
}

// Import 3D model
extern "C" {
_declspec(dllexport) long LVvtkVRMLImportActor(vtkProp3D **Actor, char *filepath,  vtkVRMLImporter **vrmli);
}

_declspec(dllexport) long LVvtkVRMLImportActor(vtkProp3D **Actor, char *filepath, vtkVRMLImporter **vrmli)
{
  vtkAssembly *NewAssembly;
  *vrmli = vtkVRMLImporter::New();
  (*vrmli)->SetFileName(filepath); 

  (*vrmli)->Read();
  if((*vrmli)->GetRenderer()->GetActors()->GetNumberOfItems()==1)
	  *Actor = (*vrmli)->GetRenderer()->GetActors()->GetLastActor();
  else if((*vrmli)->GetRenderer()->GetActors()->GetNumberOfItems() > 1)
  {
	  NewAssembly = vtkAssembly::New();
	  (*vrmli)->GetRenderer()->GetActors()->InitTraversal();
	   for(int i=0; i<(*vrmli)->GetRenderer()->GetActors()->GetNumberOfItems(); NewAssembly->AddPart(static_cast<vtkActor *>((*vrmli)->GetRenderer()->GetActors()->GetItemAsObject(i++))))
		   (static_cast<vtkActor *>((*vrmli)->GetRenderer()->GetActors()->GetItemAsObject(i)))->Delete();
	  *Actor=NewAssembly;
  }
  return (1);
}


// Import 3D model
extern "C" {
_declspec(dllexport) void LVvtkPolyDataReaderReadFile(vtkPolyData **Polydata, char *filepath, vtkPolyDataReader **reader);
}

_declspec(dllexport) void LVvtkPolyDataReaderReadFile(vtkPolyData **Polydata, char *filepath, vtkPolyDataReader **reader)
{
	*reader = vtkPolyDataReader::New();
	(*reader)->SetFileName(filepath);
	*Polydata = (*reader)->GetOutput();
}

extern "C" {
_declspec(dllexport) long LVvtk3DSImport(vtkRenderWindow *renWin, char *filepath, int ComputeNormals);
}

_declspec(dllexport) long LVvtk3DSImport(vtkRenderWindow *renWin, char *filepath, int ComputeNormals)
{
  vtk3DSImporter *DSI = vtk3DSImporter::New();
  DSI->SetRenderWindow(renWin);
  DSI->SetFileName(filepath); 

  if (ComputeNormals)
  {
	  DSI->ComputeNormalsOn();  
  }

  DSI->Read();
  DSI->Delete();

  return (1);
}
extern "C" {
_declspec(dllexport) long LVvtkProp3DSetPosition(vtkProp3D *Prop, int x, int y, int z);
}

_declspec(dllexport) long LVvtkProp3DSetPosition(vtkProp3D *Prop, int x, int y, int z)
{
  Prop->SetPosition(x,y,z);
  return (1);
}

// Import VRML model
extern "C" {
_declspec(dllexport) long LVvtkVRMLImport(vtkRenderWindow *renWin, char *filepath);
}

_declspec(dllexport) long LVvtkVRMLImport(vtkRenderWindow *renWin, char *filepath)
{
  vtkVRMLImporter *VRML = vtkVRMLImporter::New();
  VRML->SetRenderWindow(renWin);
  VRML->SetFileName(filepath); 

  VRML->Read();
  VRML->Delete();

  return (1);
}



// Set user matrix function that creates the user matrix only once
// redefines using LVvtkSetUserMatrix for every transformation
extern "C" {
_declspec(dllexport) long LVCreateVtkMatrix4x4(vtkMatrix4x4 **UserMatrix);
}

_declspec(dllexport) long LVCreateVtkMatrix4x4(vtkMatrix4x4 **UserMatrix)
{
	*UserMatrix = vtkMatrix4x4::New();

	return (1);
}

double Matrix3x3[3][3];

extern "C" {
_declspec(dllexport) long LVvtkProp3DSetQuaternion(vtkProp3D *Actor, vtkMatrix4x4 *UserMatrix, double Quaternion[], double Position[]);
}

_declspec(dllexport) long LVvtkProp3DSetQuaternion(vtkProp3D *Actor, vtkMatrix4x4 *UserMatrix, double Quaternion[], double Position[])
{
	
	vtkMath::QuaternionToMatrix3x3(Quaternion, Matrix3x3);
	UserMatrix->SetElement(0,0,Matrix3x3[0][0]);
	UserMatrix->SetElement(0,1,Matrix3x3[0][1]);
	UserMatrix->SetElement(0,2,Matrix3x3[0][2]);
	UserMatrix->SetElement(1,0,Matrix3x3[1][0]);
	UserMatrix->SetElement(1,1,Matrix3x3[1][1]);
	UserMatrix->SetElement(1,2,Matrix3x3[1][2]);
	UserMatrix->SetElement(2,0,Matrix3x3[2][0]);
	UserMatrix->SetElement(2,1,Matrix3x3[2][1]);
	UserMatrix->SetElement(2,2,Matrix3x3[2][2]);
	UserMatrix->SetElement(0,3,Position[0]);
	UserMatrix->SetElement(1,3,Position[1]);
	UserMatrix->SetElement(2,3,Position[2]);
    Actor->SetUserMatrix(UserMatrix);
	return (1);
}

// Apply a transformation matrix to an actor
extern "C" {
_declspec(dllexport) long LVvtkProp3DSetUserMatrix(vtkProp3D *Actor, vtkMatrix4x4 *UserMatrix, double TMatrix[]);
}

_declspec(dllexport) long LVvtkProp3DSetUserMatrix(vtkProp3D *Actor, vtkMatrix4x4 *UserMatrix, double TMatrix[])
{
    UserMatrix->DeepCopy(TMatrix);

    Actor->SetUserMatrix(UserMatrix);

	return (1);
}

extern "C" {
_declspec(dllexport) long LVvtkProp3DPokeMatrix(vtkProp3D *Actor, vtkMatrix4x4 *PokeMatrix, double TMatrix[]);
}

_declspec(dllexport) long LVvtkProp3DPokeMatrix(vtkProp3D *Actor, vtkMatrix4x4 *PokeMatrix, double TMatrix[])
{
    PokeMatrix->DeepCopy(TMatrix);

    Actor->PokeMatrix(PokeMatrix);

	return (1);
}


extern "C" {
_declspec(dllexport) LVvtkProp3DResetPokeMatrix(vtkProp3D *Actor);
}

_declspec(dllexport) LVvtkProp3DResetPokeMatrix(vtkProp3D *Actor)
{
    Actor->PokeMatrix(NULL);
}

// Original set user matrix function
// Creates and deletes a new matrix every time -> not very efficient
extern "C" {
_declspec(dllexport) long LVvtkSetUserMatrixO(vtkActor *Actor, vtkMatrix4x4 *UserMatrix, double TMatrix[]);
}

_declspec(dllexport) long LVvtkSetUserMatrixO(vtkActor *Actor, vtkMatrix4x4 *UserMatrix, double TMatrix[])
{
  vtkMatrix4x4 *aM = vtkMatrix4x4::New();
    aM->DeepCopy(TMatrix);

  Actor->SetUserMatrix(aM);
	aM->Delete();

	return (1);
}

// resets camera to view all actors in a renderer  (Does not work with a threaded renderer)
extern "C" {
_declspec(dllexport) long  LVvtkRendererResetCamera (vtkRenderer *renderer); 
}

_declspec(dllexport) long  LVvtkRendererResetCamera (vtkRenderer *renderer) 
{
	renderer->ResetCamera();

	return (1);
}
extern "C" {
_declspec(dllexport) long  LVvtkRendererResetCameraClippingRange (vtkRenderer *renderer); 
}

_declspec(dllexport) long  LVvtkRendererResetCameraClippingRange(vtkRenderer *renderer) 
{
	renderer->InvokeEvent(vtkCommand::ResetCameraClippingRangeEvent,renderer);

	return (1);
}

// Add an actor to a renderer
extern "C" {
_declspec(dllexport) void  LVvtkRendererAddActor (vtkRenderer *renderer, vtkProp *prop); 
}

_declspec(dllexport) void  LVvtkRendererAddActor (vtkRenderer *renderer, vtkProp *prop) 
{
	renderer->AddProp(prop);
}

// Remove an actor from a renderer
extern "C" {
_declspec(dllexport) void  LVvtkRendererRemoveActor (vtkRenderer *renderer, vtkProp *prop); 
}

_declspec(dllexport) void  LVvtkRendererRemoveActor (vtkRenderer *renderer, vtkProp *prop) 
{
	renderer->RemoveActor(prop);
}

// Get all the actros in a renderer and place them in a collection
extern "C" {
_declspec(dllexport) long LVvtkRendererGetActors (vtkRenderer *renderer, vtkActorCollection **actCollection); 
}

_declspec(dllexport) long LVvtkRendererGetActors (vtkRenderer *renderer, vtkActorCollection **actCollection) 
{
	*actCollection = renderer->GetActors();

	return (1);
}


////////////////////
//vtkRenderWindow
//Public Member Functions

// Set borders on a render window [0 = no borders, 1 = borders]
extern "C" {
_declspec(dllexport) void  LVvtkRenderWindowSetBorders (vtkRenderWindow *renWin, int onOff); 
}

_declspec(dllexport) void  LVvtkRenderWindowSetBorders (vtkRenderWindow *renWin, int onOff) 
{
	renWin->SetBorders(onOff);
}

extern "C" {
_declspec(dllexport) long LVvtkRenderWindowGetRenderers (vtkRenderWindow *renWin, vtkRendererCollection *renCollection); 
}

_declspec(dllexport) long LVvtkRenderWindowGetRenderers (vtkRenderWindow *renWin, vtkRendererCollection *renCollection) 
{
	renCollection = renWin->GetRenderers();

	return (1);
}
/*
extern "C" {
_declspec(dllexport) long LVvtkGetRendererfromCol (vtkRendererCollection *renCollection, vtkRenderer *ren); 
}

_declspec(dllexport) long LVvtkGetRendererfromCol (vtkRendererCollection *renCollection, vtkRenderer *ren) 
{
	ren = renCollection->GetFirstRenderer();

	return (1);
}
*/
extern "C" {
_declspec(dllexport) unsigned long LVvtkRenderWindowRender(vtkRenderWindow *renWin);
}

_declspec(dllexport) unsigned long LVvtkRenderWindowRender(vtkRenderWindow *renWin)
{
	renWin->Render();

	return (1);
}

// Hides the cursor.. vtk says a 3D cursor is placed instead... doesn't work / screws up cursor for all of windows --> don't use
extern "C" {
_declspec(dllexport) long LVvtkRenderWindowHideCursor(vtkRenderWindow *renWin);
}

_declspec(dllexport) long LVvtkRenderWindowHideCursor(vtkRenderWindow *renWin)
{
	renWin->HideCursor();

	return (1);
}

extern "C" {
_declspec(dllexport) void LVvtkRenderWindowShowCursor(vtkRenderWindow *renWin);
}

_declspec(dllexport) void LVvtkRenderWindowShowCursor(vtkRenderWindow *renWin)
{
	renWin->ShowCursor();
}

// sets window to full screen.  Cannot get interactor to work after this operation even rerendering it
extern "C" {
_declspec(dllexport) void LVvtkRenderWindowSetFullScreen(vtkRenderWindow *renWin, int value);
}

_declspec(dllexport) void LVvtkRenderWindowSetFullScreen(vtkRenderWindow *renWin, int value)
{
	renWin->SetFullScreen(value);
}

extern "C" {
_declspec(dllexport) void LVvtkRenderWindowSetPointSmoothing(vtkRenderWindow *renWin, int value);
}

_declspec(dllexport) void LVvtkRenderWindowSetPointSmoothing(vtkRenderWindow *renWin, int value)
{
	renWin->SetPointSmoothing(value);
}

extern "C" {
_declspec(dllexport) void LVvtkRenderWindowSetLineSmoothing(vtkRenderWindow *renWin, int value);
}

_declspec(dllexport) void LVvtkRenderWindowSetLineSmoothing(vtkRenderWindow *renWin, int value)
{
	renWin->SetLineSmoothing(value);
}

extern "C" {
_declspec(dllexport) void LVvtkRenderWindowSetPolygonSmoothing(vtkRenderWindow *renWin, int value);
}

_declspec(dllexport) void LVvtkRenderWindowSetPolygonSmoothing(vtkRenderWindow *renWin, int value)
{
	renWin->SetPolygonSmoothing(value);
}

extern "C" {
_declspec(dllexport) long LVvtkRenderWindowGetInteractor(vtkRenderWindow *renWin, vtkRenderWindowInteractor *renWinInteractor);
}

_declspec(dllexport) long LVvtkRenderWindowGetInteractor(vtkRenderWindow *renWin, vtkRenderWindowInteractor *renWinInteractor)
{
	renWinInteractor = renWin->GetInteractor();

	return (1);
}

extern "C" {
_declspec(dllexport) void LVvtkRenderWindowSetInteractor(vtkRenderWindow *renWin, vtkRenderWindowInteractor *Interactor);
}

_declspec(dllexport) void LVvtkRenderWindowSetInteractor(vtkRenderWindow *renWin, vtkRenderWindowInteractor *Interactor)
{
	renWin->SetInteractor(Interactor);
}

extern "C" {
_declspec(dllexport) void LVvtkRenderWindowMakeCurrent(vtkRenderWindow *renWin);
}

_declspec(dllexport) void LVvtkRenderWindowMakeCurrent(vtkRenderWindow *renWin)
{
	renWin->MakeCurrent();
}

////////////////////
//vtkRenderWindowInteractor
//Public Member Functions

// initialized the interactor and starts it. this is done by default? need to test this more with while loops
extern "C" {
_declspec(dllexport) void LVvtkRenderWindowInteractorInitialize(vtkRenderWindowInteractor *Interactor);
}

_declspec(dllexport) void LVvtkRenderWindowInteractorInitialize(vtkRenderWindowInteractor *Interactor)
{
	Interactor->Initialize();
	
}

extern "C" {
_declspec(dllexport) void LVvtkRenderWindowInteractorStart(vtkRenderWindowInteractor *Interactor);
}

_declspec(dllexport) void LVvtkRenderWindowInteractorStart(vtkRenderWindowInteractor *Interactor)
{
	Interactor->Start();
	
}



extern "C" {
_declspec(dllexport) void LVvtkRenderWindowInteractorSetDesiredUpdateRate(vtkRenderWindowInteractor *Interactor, double update_rate);
}

_declspec(dllexport) void LVvtkRenderWindowInteractorSetDesiredUpdateRate(vtkRenderWindowInteractor *Interactor, double update_rate)
{
	Interactor->SetDesiredUpdateRate(update_rate);
}

extern "C" {
_declspec(dllexport) void LVvtkRenderWindowInteractorSetStillUpdateRate(vtkRenderWindowInteractor *Interactor, double update_rate);
}

_declspec(dllexport) void LVvtkRenderWindowInteractorSetStillUpdateRate(vtkRenderWindowInteractor *Interactor, double update_rate)
{
	Interactor->SetStillUpdateRate(update_rate);
}

////////////////////
//vtkMatrix4x4
//Public Member Functions

extern "C" {
_declspec(dllexport) void LVvtkMatrix4x4ZeroMatrix(vtkMatrix4x4 *matrix);
}

_declspec(dllexport) void LVvtkMatrix4x4ZeroMatrix(vtkMatrix4x4 *matrix)
{
	matrix->Zero();
}

extern "C" {
_declspec(dllexport) void LVvtkMatrix4x4InvertMatrix(vtkMatrix4x4 *matrix);
}

_declspec(dllexport) void LVvtkMatrix4x4InvertMatrix(vtkMatrix4x4 *matrix)
{
	matrix->Invert();
}

extern "C" {
_declspec(dllexport) void LVvtkMatrix4x4TransposeMatrix(vtkMatrix4x4 *matrix);
}

_declspec(dllexport) void LVvtkMatrix4x4TransposeMatrix(vtkMatrix4x4 *matrix)
{
	matrix->Transpose();
}

////////////////////
//vtkProp
//Public Member Functions

extern "C" {
_declspec(dllexport) void LVvtkPropVisibilityOn(vtkProp *prop);
}

_declspec(dllexport) void LVvtkPropVisibilityOn(vtkProp *prop)
{
	prop->VisibilityOn();
}

extern "C" {
_declspec(dllexport) void LVvtkPropVisibilityOff(vtkProp *prop);
}

_declspec(dllexport) void LVvtkPropVisibilityOff(vtkProp *prop)
{
	prop->VisibilityOff();
}

// Not certain what this does but I believe it gives the current
// position matrix of a specified prop --> need to test this
extern "C" {
_declspec(dllexport) long LVvtkPropGetMatrix(vtkProp *prop, vtkMatrix4x4 *matrix);
}

_declspec(dllexport) long LVvtkPropGetMatrix(vtkProp *prop, vtkMatrix4x4 *matrix)
{
	matrix = prop->GetMatrix();

	return (1);
}

////////////////////
//vtkActor
//Public Member Functions


extern "C" {
_declspec(dllexport) long LVvtkActorSetColor(vtkActor *actor, double R, double G, double B, double R1, double G1, double B1,
										   double R2, double G2, double B2);
}

_declspec(dllexport) long LVvtkActorSetColor(vtkActor *actor, double R, double G, double B, double R1, double G1, double B1,
										   double R2, double G2, double B2)
{
	
	actor->GetProperty()->SetColor(R, G, B);

	actor->GetProperty()->SetDiffuseColor(R1, G1, B1);

	actor->GetProperty()->SetSpecularColor(R2, G2, B2);


	return (1);
}

extern "C" {
_declspec(dllexport) long LVvtkActorSetSpecularPower(vtkActor *actor, double power);
}

_declspec(dllexport) long LVvtkActorSetSpecularPower(vtkActor *actor, double power)
{
	
	actor->GetProperty()->SetSpecularPower(power);

	return (1);
}

extern "C" {
_declspec(dllexport) long LVvtkActorSetEdgeColour(vtkActor *actor, double R, double G, double B);
}

_declspec(dllexport) long LVvtkActorSetEdgeColour(vtkActor *actor, double R, double G, double B)
{
	
	actor->GetProperty()->SetEdgeVisibility(1);
	actor->GetProperty()->SetEdgeColor(R, G, B);

	return (1);
}

extern "C" {
_declspec(dllexport) long LVvtkActorSetOpacity(vtkActor *actor, double opacity);
}

_declspec(dllexport) long LVvtkActorSetOpacity(vtkActor *actor, double opacity)
{
	
	actor->GetProperty()->SetOpacity(opacity);

	return (1);
}

////////////////////
//vtkAbstractPicker
//Public Member Functions

extern "C" {
_declspec(dllexport) void LVvtkAbstractPickerGetSelectionPoint(vtkAbstractPicker *abspick, double data[3]);
}

_declspec(dllexport) void LVvtkAbstractPickerGetSelectionPoint(vtkAbstractPicker *abspick, double data[3])
{
	abspick->GetSelectionPoint(data);
}

////////////////////
//vtkLight
//Public Member Functions

extern "C" {
_declspec(dllexport) long LVvtkLightSetColorAndIntensity(vtkLight *light, double R, double G, double B, double intensity);
}

_declspec(dllexport) long LVvtkLightSetColorAndIntensity(vtkLight *light, double R, double G, double B, double intensity)
{
	light->SetColor(R, G, B);
	light->SetIntensity(intensity);

	return (1);
}

extern "C" {
_declspec(dllexport) long LVvtkRendererGetLight(vtkRenderer *ren, vtkLight *light);
}

_declspec(dllexport) long LVvtkRendererGetLight(vtkRenderer *ren, vtkLight *light)
{
	vtkLightCollection *Lights = vtkLightCollection::New();

	Lights = ren->GetLights();
	Lights->InitTraversal();
	light = Lights->GetNextItem();

	Lights->Delete();

	return (1);
}

/*
////////////////////
//vtkCylinder
//Public Member Functions


extern "C" {
_declspec(dllexport) long LVvtkCreateCylinderActor(vtkRenderer *ren, double R, double G, double B, double height, double radius, double x, double y, double z);
}

_declspec(dllexport) long LVvtkCreateCylinderActor(vtkRenderer *ren, double R, double G, double B, double height, double radius, double x, double y, double z)
{
	vtkCylinderSource *Cylinder = vtkCylinderSource::New();
	Cylinder->SetHeight(height);
	Cylinder->SetRadius(radius);
	Cylinder->SetCenter(x, y, z);
	
	vtkPolyDataMapper *CylinderMapper = vtkPolyDataMapper::New();
	CylinderMapper->SetInput(Cylinder->GetOutput());

	vtkActor *CylinderActor = vtkActor::New();
	CylinderActor->SetMapper(CylinderMapper);
	CylinderActor->GetProperty()->SetColor(R, G, B);

	ren->AddActor(CylinderActor);

	Cylinder->Delete();
	CylinderMapper->Delete();  //Well, Laa Tee Daaa  Utsav is surprised this works.
	CylinderActor->Delete();

	return (1);
}



extern "C" {
_declspec(dllexport) long LVvtkCreateCone(vtkRenderer *ren, double R, double G, double B, double dX, double dY, double dZ, double x, double y, double z);
}

_declspec(dllexport) long LVvtkCreateCone(vtkRenderer *ren, double R, double G, double B, double dX, double dY, double dZ, double x, double y, double z)
{
	vtkConeSource *Cone = vtkConeSource::New();
	Cone->SetCenter(x, y, z);
	Cone->SetDirection(dX, dY, dZ);
	
	vtkPolyDataMapper *ConeMapper = vtkPolyDataMapper::New();
	ConeMapper->SetInput(Cone->GetOutput());

	vtkActor *ConeActor = vtkActor::New();
	ConeActor->SetMapper(ConeMapper);
	ConeActor->GetProperty()->SetColor(R, G, B);

	ren->AddActor(ConeActor);

	Cone->Delete();
	ConeMapper->Delete();
	ConeActor->Delete();

	return (1);
}

extern "C" {
_declspec(dllexport) long LVvtkCreateAxes(vtkRenderer *ren, double scale, double x, double y, double z);
}

_declspec(dllexport) long LVvtkCreateAxes(vtkRenderer *ren, double scale, double x, double y, double z) 
{
	vtkAxes *Axes = vtkAxes::New();
	Axes->SetScaleFactor(scale);
	Axes->SetOrigin(x, y, z);

	vtkTubeFilter *TubeFilter = vtkTubeFilter::New();
	TubeFilter->SetInput(Axes->GetOutput());
	TubeFilter->SetRadius(Axes->GetScaleFactor()/30.0);
	TubeFilter->SetNumberOfSides(8);
	TubeFilter->SetCapping(1);
	
	vtkPolyDataMapper *AxesMapper = vtkPolyDataMapper::New();
	AxesMapper->SetInput(TubeFilter->GetOutput());

	vtkActor *AxesActor = vtkActor::New();
	AxesActor->SetMapper(AxesMapper);
	AxesActor->GetProperty()->SetLineWidth(1.5);


	vtkCaptionActor2D *XCaption = vtkCaptionActor2D::New();
	XCaption->SetCaption("X Axis");
	XCaption->SetAttachmentPoint(Axes->GetScaleFactor(), 0, 0);
	XCaption->GetCaptionTextProperty()->SetFontSize(6);
	XCaption->SetBorder(0);
	XCaption->GetCaptionTextProperty()->SetFontFamilyToTimes();

	vtkCaptionActor2D *YCaption = vtkCaptionActor2D::New();
	YCaption->SetCaption("Y Axis");
	YCaption->SetAttachmentPoint(0, Axes->GetScaleFactor(), 0);
	YCaption->GetCaptionTextProperty()->SetFontSize(6);
	YCaption->SetBorder(0);
	YCaption->GetCaptionTextProperty()->SetFontFamilyToTimes();

	vtkCaptionActor2D *ZCaption = vtkCaptionActor2D::New();
	ZCaption->SetCaption("Z Axis");
	ZCaption->SetAttachmentPoint(0, 0, Axes->GetScaleFactor());
	ZCaption->GetCaptionTextProperty()->SetFontSize(6);
	ZCaption->SetBorder(0);
	ZCaption->GetCaptionTextProperty()->SetFontFamilyToTimes();

	ren->AddActor(AxesActor);
	ren->AddActor(XCaption);
	ren->AddActor(YCaption);
	ren->AddActor(ZCaption);
	
	ren->SetBackground(0.5, 0.5, 0.5);

	Axes->Delete();
	TubeFilter->Delete();
	AxesMapper->Delete();
	AxesActor->Delete();
	XCaption->Delete();
	YCaption->Delete();
	ZCaption->Delete();

	return (1);
}
*/
extern "C" {
_declspec(dllexport) LVCreatevtkAssembly(vtkAssembly **Assembly);
}

_declspec(dllexport) LVCreatevtkAssembly(vtkAssembly **Assembly)
{
	*Assembly = vtkAssembly::New();
}

extern "C" {
_declspec(dllexport) long LVvtkAssemblyAddPart(vtkAssembly *Assembly, vtkActor *Root);
}

_declspec(dllexport) long LVvtkAssemblyAddPart(vtkAssembly *Assembly, vtkActor *Root)
{
	Assembly->AddPart(Root);

	return (1);
}

extern "C" {
_declspec(dllexport) long LVvtkCursor3D(vtkRenderer *Ren);
}

_declspec(dllexport) long LVvtkCursor3D(vtkRenderer *Ren)
{
	vtkCursor3D *Cursor3D = vtkCursor3D::New();
	Cursor3D->AxesOn();
	Cursor3D->SetModelBounds(-100, 100, -100, 100, -100, 100);

	vtkPolyDataMapper *CursorMap = vtkPolyDataMapper::New();
	CursorMap->SetInput(Cursor3D->GetOutput());

	vtkActor *CursorActor = vtkActor::New();
	CursorActor->SetMapper(CursorMap);
	CursorActor->GetProperty()->SetColor(1, 0, 0);

	Ren->AddActor(CursorActor);

	Cursor3D->Delete();
	CursorMap->Delete();
	CursorActor->Delete();
	
	return (1);
}

extern "C" {
_declspec(dllexport) long LVvtkActorPicker(vtkRenderWindowInteractor *RenWinInt, vtkRenderer *Ren, vtkActor *Actor, double x, double y);
}

_declspec(dllexport) long LVvtkActorPicker(vtkRenderWindowInteractor *RenWinInt, vtkRenderer *Ren, vtkActor *Actor, double x, double y)
{
	vtkPropPicker *PropPicker = vtkPropPicker::New();
	RenWinInt->SetPicker(PropPicker);

	PropPicker->PickProp(x, y, Ren);
	Actor = PropPicker->GetActor();
	
	return (1);
}

//Delete stuff using this function!!

extern "C" {
_declspec(dllexport) int LVvtkDeleteObject(vtkObject *DeleteMe);
}

_declspec(dllexport) int LVvtkDeleteObject(vtkObject *DeleteMe)
{	
	DeleteMe->Delete();
	return (0);
}

extern "C" {
_declspec(dllexport) int LVvtkKillWindow(vtkWin32OpenGLRenderWindow *RenWin, vtkRenderWindowInteractor *Interactor, vtkRenderer *Renderer);
}

_declspec(dllexport) int LVvtkKillWindow(vtkWin32OpenGLRenderWindow *RenWin, vtkRenderWindowInteractor *Interactor, vtkRenderer *Renderer)
{	
	Renderer->Delete();
	Interactor->Delete();
	RenWin->Clean();
	RenWin->Finalize();
	RenWin->Delete();
	
	return (0);
}

extern "C" {
_declspec(dllexport) long LVvtkInitWindowtoDelete(vtkWin32OpenGLRenderWindow **renWinPTR, vtkRenderer **Renderer, vtkRenderWindowInteractor **InteractorPTR);
}

_declspec(dllexport) long LVvtkInitWindowtoDelete(vtkWin32OpenGLRenderWindow **renWinPTR, vtkRenderer **Renderer, vtkRenderWindowInteractor **InteractorPTR)
{
  vtkWin32OpenGLRenderWindow *renWin = vtkWin32OpenGLRenderWindow::New();
  
  *renWinPTR = renWin;

  *Renderer = vtkRenderer::New();

  vtkRenderWindowInteractor *Interactor = vtkRenderWindowInteractor::New();
	*InteractorPTR = Interactor;

    renWin->AddRenderer(*Renderer);
	renWin->SetSize(500, 500);

  Interactor = vtkRenderWindowInteractor::New();
  int x = renWin->GetReferenceCount();
//  Interactor->SetRenderWindow(renWin);
//  Interactor->SetStillUpdateRate(30);
//  Interactor->Start

  return (x);
}
extern "C" {
_declspec(dllexport) void LVCreateVtkPoints(vtkPoints **newPoint);
}

_declspec(dllexport) void LVCreateVtkPoints(vtkPoints **newPoint)
{
	*newPoint = vtkPoints::New();
}
extern "C" {
_declspec(dllexport) void LVvtkPointsInsertNextPoint(vtkPoints *Point, double x, double y, double z);
}

_declspec(dllexport) void LVvtkPointsInsertNextPoint(vtkPoints *Point, double x, double y, double z)
{
	Point->InsertNextPoint(x,y,z);
}
extern "C" {
_declspec(dllexport) void LVCreateVtkPolyData(vtkPolyData **NewPolyData);
}

_declspec(dllexport) void LVCreateVtkPolyData(vtkPolyData **NewPolyData)
{
	*NewPolyData= vtkPolyData::New();
}

extern "C" {
_declspec(dllexport) void LVvtkPolyDataSetPoints(vtkPolyData **PolyData, vtkPoints *Points);
}

_declspec(dllexport) void LVvtkPolyDataSetPoints(vtkPolyData **PolyData, vtkPoints *Points)
{
	(*PolyData)->SetPoints(Points);
}

extern "C" {
_declspec(dllexport) void LVCreateVtkSphereSource(vtkSphereSource **SphereSrc, vtkPolyData **PolyData, double Radius, double ThetaResolution, double PhiResolution);
}

_declspec(dllexport) void LVCreateVtkSphereSource(vtkSphereSource **SphereSrc, vtkPolyData **PolyData, double Radius, double ThetaResolution, double PhiResolution)
{
	*SphereSrc= vtkSphereSource::New();
	(*SphereSrc)->SetRadius(Radius);
	(*SphereSrc)->SetPhiResolution(PhiResolution);
	(*SphereSrc)->SetThetaResolution(ThetaResolution);
	*PolyData = (*SphereSrc)->GetOutput();
}


extern "C" {
_declspec(dllexport) void LVCreateVtkGlyph3D(vtkGlyph3D **Glyph3D, vtkPolyData **Output, vtkPolyData *Point, vtkPolyData *Points);
}

_declspec(dllexport) void LVCreateVtkGlyph3D(vtkGlyph3D **Glyph3D, vtkPolyData **Output, vtkPolyData *Point, vtkPolyData *Points)
{
	*Glyph3D = vtkGlyph3D::New();
	(*Glyph3D)->SetSource(Point);
	(*Glyph3D)->SetInput(Points);
	*Output = (*Glyph3D)->GetOutput();
}

extern "C" {
_declspec(dllexport) void LVCreateVtkActor(vtkActor **Actor, vtkPolyData *PolyData);
}

_declspec(dllexport) void LVCreateVtkActor(vtkActor **Actor, vtkPolyData *PolyData)
{
	vtkPolyDataMapper *Mapper = vtkPolyDataMapper::New();
	*Actor = vtkActor::New();
	Mapper->SetInput(PolyData);
	(*Actor)->SetMapper(Mapper);
}
extern "C" {
_declspec(dllexport) void LVvtkPolyDataUpdate(vtkPolyData *polydata);
}

_declspec(dllexport) void LVvtkPolyDataUpdate(vtkPolyData *polydata)
{
	(*polydata).Update();
}
extern "C" {
_declspec(dllexport) void LVvtkGlyph3DUpdate(vtkGlyph3D *Glyph3D);
}

_declspec(dllexport) void LVvtkGlyph3DUpdate(vtkGlyph3D *Glyph3D)
{
	(*Glyph3D).Update();
}


extern "C" {
_declspec(dllexport) void LVvtkObjectModified(vtkObject *Object);
}

_declspec(dllexport) void LVvtkObjectModified(vtkObject *Object)
{
	(*Object).Modified();
}

extern "C" {
_declspec(dllexport) void LVCreateVtkPolyLine(vtkPolyLine **Pline, vtkPolyData **PData, vtkPoints *Points);
}

_declspec(dllexport) void LVCreateVtkPolyLine(vtkPolyLine **PLine, vtkPolyData **PData, vtkPoints *Points)
{
	int size = Points->GetNumberOfPoints();
	*PLine = vtkPolyLine::New();
	*PData = vtkPolyData::New();
	(*PLine)->GetPointIds()->SetNumberOfIds(size);
	for(int i =0; i<size;i++)
		(*PLine)->GetPointIds()->SetId(i,i);
	(*PData)->Allocate(1,1);
	(*PData)->InsertNextCell((*PLine)->GetCellType(), (*PLine)->GetPointIds());
	(*PData)->SetPoints(Points);

}

extern "C" {
_declspec(dllexport) void LVvtkPolyLineUpdate(vtkPolyLine *Pline, vtkPolyData *PData, vtkPoints *Points);
}

_declspec(dllexport) void LVvtkPolyLineUpdate(vtkPolyLine *PLine, vtkPolyData *PData, vtkPoints *Points)
{
	int size = Points->GetNumberOfPoints();
	(PLine)->GetPointIds()->SetNumberOfIds(size);
	for(int i =0; i<size;i++)
		(PLine)->GetPointIds()->SetId(i,i);
	(PData)->Allocate(1,1);
	(PData)->InsertNextCell((PLine)->GetCellType(), (PLine)->GetPointIds());
	(PData)->SetPoints(Points);

}

extern "C" {
_declspec(dllexport) void LVvtkPolyVertexUpdate(vtkPolyVertex *Pvert, vtkPolyData *PData, vtkPoints *Points);
}

_declspec(dllexport) void LVvtkPolyVertexUpdate(vtkPolyVertex *Pvert, vtkPolyData *PData, vtkPoints *Points)
{
	int size = Points->GetNumberOfPoints();
	(Pvert)->GetPointIds()->SetNumberOfIds(size);
	for(int i =0; i<size;i++)
		(Pvert)->GetPointIds()->SetId(i,i);
	(PData)->Allocate(1,1);
	(PData)->InsertNextCell((Pvert)->GetCellType(), (Pvert)->GetPointIds());
	(PData)->SetPoints(Points);

}

extern "C" {
_declspec(dllexport) void LVvtkActorCollectionGetItem(vtkActorCollection *Collection, vtkActor **Actors, int index);
}

_declspec(dllexport) void LVvtkActorCollectionGetItem(vtkActorCollection *Collection, vtkActor **Actors, int index)
{
	*Actors = static_cast<vtkActor *>(Collection->GetItemAsObject(index));
}


extern "C" {
	_declspec(dllexport) void LVCreateVtkPolyVertex(vtkPolyVertex **Pvertex, vtkPolyData **PData, vtkPoints *Points);
}

_declspec(dllexport) void LVCreateVtkPolyVertex(vtkPolyVertex **Pvertex, vtkPolyData **PData, vtkPoints *Points)
{
	int size = Points->GetNumberOfPoints();
	*Pvertex = vtkPolyVertex::New();
	*PData = vtkPolyData::New();
	(*Pvertex)->GetPointIds()->SetNumberOfIds(size);
	for(int i =0; i<size;i++)
		(*Pvertex)->GetPointIds()->SetId(i,i);
	(*PData)->Allocate(1,1);
	(*PData)->InsertNextCell((*Pvertex)->GetCellType(), (*Pvertex)->GetPointIds());
	(*PData)->SetPoints(Points);

}


extern "C" {
_declspec(dllexport) void LVCreateVtkNDITracker(vtkNDITracker **NDITracker);
}

_declspec(dllexport) void LVCreateVtkNDITracker(vtkNDITracker **NDITracker)
{
	*NDITracker = vtkNDITracker::New();

}
extern "C" {
_declspec(dllexport) void LVCreateVtkFlockTracker(vtkFlockTracker **FlockTracker);
}

_declspec(dllexport) void LVCreateVtkFlockTracker(vtkFlockTracker **FlockTracker)
{
	*FlockTracker = vtkFlockTracker::New();

}

extern "C" {
_declspec(dllexport) void LVvtkTrackerGetTool(vtkTracker *Tracker, int tool, vtkTrackerTool **Tool);
}

_declspec(dllexport) void LVvtkTrackerGetTool(vtkTracker *Tracker, int tool, vtkTrackerTool **Tool)
{
	*Tool = Tracker->GetTool(tool);
}

extern "C" {
_declspec(dllexport) void LVvtkTrackerToolSetLED(vtkTrackerTool *Tool, int LED, int state);
}

_declspec(dllexport) void LVvtkTrackerToolSetLED(vtkTrackerTool *Tool, int LED, int state)
{
	//0 is off, 1 is on, 2 is flashing
	switch (LED)
	{
	case 1:
		Tool->SetLED1(state);
		break;
	case 2:
		Tool->SetLED2(state);
		break;
	case 3:
		Tool->SetLED3(state);
		break;
	}
}


extern "C" {
_declspec(dllexport) void LVvtkTrackerToolGetTransform(vtkTrackerTool *Tool, vtkTransform **Transform);
}

_declspec(dllexport) void LVvtkTrackerToolGetTransform(vtkTrackerTool *Tool, vtkTransform **Transform)
{
	*Transform = Tool->GetTransform();
}

extern "C" {
_declspec(dllexport) void LVvtkTrackerToolGetData(vtkTrackerTool *Tool, vtkMatrix4x4 **matrix, int *isMissing, int *isOutOfView, int *isOutOfVolume, int *isSwitch1On, int *isSwitch2On, int *isSwitch3On, int *LED1, int *LED2, int *LED3, double *TimeStamp);
}

_declspec(dllexport) void LVvtkTrackerToolGetData(vtkTrackerTool *Tool, vtkMatrix4x4 **matrix, int *isMissing, int *isOutOfView, int *isOutOfVolume, int *isSwitch1On, int *isSwitch2On, int *isSwitch3On, int *LED1, int *LED2, int *LED3, double *TimeStamp)
{
	*matrix = Tool->GetTransform()->GetMatrix();
	*isMissing = Tool->IsMissing();
	*isOutOfView = Tool->IsOutOfView();
	*isOutOfVolume = Tool->IsOutOfVolume();
	*isSwitch1On = Tool->IsSwitch1On();
	*isSwitch2On = Tool->IsSwitch2On();
	*isSwitch3On = Tool->IsSwitch3On();
	*LED1 = Tool->GetLED1();
	*LED2 = Tool->GetLED2();
	*LED3 = Tool->GetLED3();
	*TimeStamp = Tool->GetTimeStamp();
}

extern "C" {
_declspec(dllexport) void LVvtkTrackerProbe(vtkTracker *Tracker);
}

_declspec(dllexport) void LVvtkTrackerProbe(vtkTracker *Tracker)
{
	Tracker->Probe();
}

extern "C" {
_declspec(dllexport) void LVvtkTrackerStartTracking(vtkTracker *Tracker);
}

_declspec(dllexport) void LVvtkTrackerStartTracking(vtkTracker *Tracker)
{
	Tracker->StartTracking();
}


extern "C" {
_declspec(dllexport) void LVvtkTrackerStopTracking(vtkTracker *Tracker);
}

_declspec(dllexport) void LVvtkTrackerStopTracking(vtkTracker *Tracker)
{
	Tracker->StopTracking();
}


extern "C" {
_declspec(dllexport) void LVvtkTrackerUpdate(vtkTracker *Tracker); 
}

_declspec(dllexport) void LVvtkTrackerUpdate(vtkTracker *Tracker)
{
	Tracker->Update();
}

extern "C" {
_declspec(dllexport) void LVvtkTrackerSetReferenceTool(vtkTracker *Tracker, int tool); 
}

_declspec(dllexport) void LVvtkTrackerSetReferenceTool(vtkTracker *Tracker, int tool)
{
	Tracker->SetReferenceTool(tool);
}

extern "C" {
_declspec(dllexport) void LVvtkProp3DSetUserTransform(vtkProp3D *Prop, vtkTransform *Transform);
}

_declspec(dllexport) void LVvtkProp3DSetUserTransform(vtkProp3D *Prop, vtkTransform *Transform)
{
	Prop->SetUserTransform(Transform);
}

extern "C" {
_declspec(dllexport) void LVvtkProp3DSetUserTransformInput(vtkProp3D *Prop, vtkTransform *TrackerTransform);
}

_declspec(dllexport) void LVvtkProp3DSetUserTransformInput(vtkProp3D *Prop, vtkTransform *TrackerTransform)
{
	
	if (Prop->GetUserMatrix())
	{
		vtkTransform *xform = vtkTransform::New();
		xform->SetMatrix(Prop->GetUserMatrix());
		xform->SetInput(TrackerTransform);
		Prop->SetUserTransform(xform);
	}
	else
	Prop->SetUserTransform(TrackerTransform);
}


extern "C" {
_declspec(dllexport) void LVvtkTrackerToolGetTrackerBuffer(vtkTrackerTool *TrackerTool, vtkTrackerBuffer **Buffer);
}

_declspec(dllexport) void LVvtkTrackerToolGetTrackerBuffer(vtkTrackerTool *TrackerTool, vtkTrackerBuffer **Buffer)
{
	*Buffer = TrackerTool->GetBuffer();
}
/*
extern "C"{

}*/

extern "C" {
_declspec(dllexport) void LVCreateVtkTrackerBuffer(vtkTrackerBuffer **Buffer);
}

_declspec(dllexport) void LVCreateVtkTrackerBuffer(vtkTrackerBuffer **Buffer)
{
	*Buffer= vtkTrackerBuffer::New();
}

extern "C" {
_declspec(dllexport) void LVvtkTrackerBufferGetMatrix(vtkTrackerBuffer *Buffer, int frame, vtkMatrix4x4 **Matrix);
}

_declspec(dllexport) void LVvtkTrackerBufferGetMatrix(vtkTrackerBuffer *Buffer, int frame, vtkMatrix4x4 **Matrix)
{
	Buffer->GetMatrix(*Matrix, frame);
}

extern "C" {
_declspec(dllexport) void LVvtkTrackerBufferGetFlags(vtkTrackerBuffer *Buffer, int frame, int *isMissing, int *isOutOfView, int *isOutOfVolume);
}

_declspec(dllexport) void LVvtkTrackerBufferGetFlags(vtkTrackerBuffer *Buffer, int frame, int *isMissing, int *isOutOfView, int *isOutOfVolume)
{
	*isMissing=Buffer->IsMissing(frame);
	*isOutOfView=Buffer->IsOutOfView(frame);
	*isOutOfVolume=Buffer->IsOutOfVolume(frame);
}




extern "C" {
_declspec(dllexport) void LVvtkTrackerBufferGetTimeStamp(vtkTrackerBuffer *Buffer, int frame, double *Time);
}

_declspec(dllexport) void LVvtkTrackerBufferGetTimeStamp(vtkTrackerBuffer *Buffer, int frame, double *Time)
{
	*Time = Buffer->GetTimeStamp(frame);
}

extern "C" {
_declspec(dllexport) void LVvtkTrackerBufferWriteToFile(vtkTrackerBuffer *Buffer, char *FilePath);
}

_declspec(dllexport) void LVvtkTrackerBufferWriteToFile(vtkTrackerBuffer *Buffer, char *FilePath)
{
	Buffer->WriteToFile(FilePath);
}


extern "C" {
_declspec(dllexport) void LVvtkTrackerBufferReadFromFile(vtkTrackerBuffer *Buffer, char *FilePath);
}

_declspec(dllexport) void LVvtkTrackerBufferReadFromFile(vtkTrackerBuffer *Buffer, char *FilePath)
{
	Buffer->ReadFromFile(FilePath);
}

extern "C" {
_declspec(dllexport) void LVvtkConvertFromMatrix4x4(vtkMatrix4x4 *Matrix, double *frame);
}

_declspec(dllexport) void LVvtkConvertFromMatrix4x4(vtkMatrix4x4 *Matrix, double *frame)
{
	frame[0] = Matrix->GetElement(0,0);
	frame[1] = Matrix->GetElement(0,1);
	frame[2] = Matrix->GetElement(0,2);
	frame[3] = Matrix->GetElement(0,3);
	frame[4] = Matrix->GetElement(1,0);
	frame[5] = Matrix->GetElement(1,1);
	frame[6] = Matrix->GetElement(1,2);
	frame[7] = Matrix->GetElement(1,3);
	frame[8] = Matrix->GetElement(2,0);
	frame[9] = Matrix->GetElement(2,1);
	frame[10] = Matrix->GetElement(2,2);
	frame[11] = Matrix->GetElement(2,3);
	frame[12] = Matrix->GetElement(3,0);
	frame[13] = Matrix->GetElement(3,1);
	frame[14] = Matrix->GetElement(3,2);
	frame[15] = Matrix->GetElement(3,3);
}
extern "C" {
_declspec(dllexport) int LVvtkTrackerBufferGetNumberOfItems(vtkTrackerBuffer *Buffer);
}

_declspec(dllexport) int LVvtkTrackerBufferGetNumberOfItems(vtkTrackerBuffer *Buffer)
{
	return Buffer->GetNumberOfItems();
}

extern "C" {
_declspec(dllexport) void LVvtkTrackerBufferSetBufferSize(vtkTrackerBuffer *Buffer, int Num);
}

_declspec(dllexport) void LVvtkTrackerBufferSetBufferSize(vtkTrackerBuffer *Buffer, int Num)
{
	Buffer->SetBufferSize(Num);
}


extern "C" {
_declspec(dllexport) void LVvtkNDITrackerSetBaudRate(vtkNDITracker *Tracker, int number);
}

_declspec(dllexport) void LVvtkNDITrackerSetBaudRate(vtkNDITracker *Tracker,int number)
{
	Tracker->SetBaudRate(number);
}


extern "C" {
_declspec(dllexport) void LVvtkNDITrackerSetSerialPort(vtkNDITracker *Tracker, int number);
}

_declspec(dllexport) void LVvtkNDITrackerSetSerialPort(vtkNDITracker *Tracker,int number)
{
	Tracker->SetSerialPort(number);
}

extern "C" {
_declspec(dllexport) int LVvtkNDITrackerGetBaudRate(vtkNDITracker *Tracker);
}

_declspec(dllexport) int LVvtkNDITrackerGetBaudRate(vtkNDITracker *Tracker)
{
	return Tracker->GetBaudRate();
}


extern "C" {
_declspec(dllexport) int LVvtkNDITrackerGetSerialPort(vtkNDITracker *Tracker);
}

_declspec(dllexport) int LVvtkNDITrackerGetSerialPort(vtkNDITracker *Tracker)
{
	return Tracker->GetSerialPort();
}


extern "C" {
_declspec(dllexport) void LVvtkNDITrackerLoadSROM(vtkNDITracker *Tracker, int tool, char *filepath);
}

_declspec(dllexport) void LVvtkNDITrackerLoadSROM(vtkNDITracker *Tracker, int tool, char *filepath)
{
	Tracker->LoadVirtualSROM(tool, filepath);
}

extern "C" {
_declspec(dllexport) void LVvtkNDITrackerRemoveSROM(vtkNDITracker *Tracker, int tool);
}

_declspec(dllexport) void LVvtkNDITrackerRemoveSROM(vtkNDITracker *Tracker, int tool)
{
	Tracker->ClearVirtualSROM(tool);
}

extern "C" {
_declspec(dllexport) void LVvtkNDIEnableDisablePort(vtkNDITracker *Tracker, int tool, int state);
}

_declspec(dllexport) void LVvtkNDIEnableDisablePort(vtkNDITracker *Tracker, int tool, int state)
{
	Tracker->EnableDisable(tool,state);
}

extern "C" {
_declspec(dllexport) void LVvtkFlockTrackerSetQuaternions(vtkFlockTracker *Tracker, int onoff);
}

_declspec(dllexport) void LVvtkFlockTrackerSetQuaternions(vtkFlockTracker *Tracker,int onoff)
{
	Tracker->SetQuaternions(onoff);
}


extern "C" {
_declspec(dllexport) void LVvtkFlockTrackerSetBaudRate(vtkFlockTracker *Tracker, int number);
}

_declspec(dllexport) void LVvtkFlockTrackerSetBaudRate(vtkFlockTracker *Tracker,int number)
{
	Tracker->SetBaudRate(number);
}

extern "C" {
_declspec(dllexport) void LVvtkFlockTrackerSetSerialPort(vtkFlockTracker *Tracker, int portnum);
}

_declspec(dllexport) void LVvtkFlockTrackerSetSerialPort(vtkFlockTracker *Tracker,int portnum)
{
	Tracker->SetSerialPort(portnum);
}


extern "C" {
_declspec(dllexport) int LVvtkFlockTrackerGetBaudRate(vtkFlockTracker *Tracker);
}

_declspec(dllexport) int LVvtkFlockTrackerGetBaudRate(vtkFlockTracker *Tracker)
{
	return Tracker->GetBaudRate();
}

extern "C" {
_declspec(dllexport) int LVvtkFlockTrackerGetSerialPort(vtkFlockTracker *Tracker);
}

_declspec(dllexport) int LVvtkFlockTrackerGetSerialPort(vtkFlockTracker *Tracker)
{
	return Tracker->GetSerialPort();
}

extern "C" {
_declspec(dllexport) void LVvtkFlockTrackerAutoDetectNumberOfBirds(vtkFlockTracker *Tracker, int yesno);
}

_declspec(dllexport) void LVvtkFlockTrackerAutoDetectNumberOfBirds(vtkFlockTracker *Tracker, int yesno)
{
	Tracker->SetAutoDetectNumberOfBirds(yesno);
}

extern "C" {
_declspec(dllexport) void LVvtkFlockTrackerSetNumberOfBirds(vtkFlockTracker *Tracker, int Number);
}

_declspec(dllexport) void LVvtkFlockTrackerSetNumberOfBirds(vtkFlockTracker *Tracker, int Number)
{
	Tracker->SetAutoDetectNumberOfBirds(0);
	Tracker->SetNumberOfBirds(Number);
}

extern "C" {
_declspec(dllexport) int LVvtkFlockTrackerGetNumberOfBirds(vtkFlockTracker *Tracker);
}

_declspec(dllexport) int  LVvtkFlockTrackerGetNumberOfBirds(vtkFlockTracker *Tracker)
{
	return Tracker->GetNumberOfBirds();
}

extern "C" {
_declspec(dllexport) void LVvtkTrackerToolGetPosition(vtkTrackerTool *TrackerTool, double *xyz);
}

_declspec(dllexport) void LVvtkTrackerToolGetPosition(vtkTrackerTool *TrackerTool, double *xyz)
{
	TrackerTool->GetTransform()->GetPosition(xyz);
}


extern "C" {
_declspec(dllexport) void LVvtkTrackerToolSetTransformationMatrix(vtkTrackerTool *tool, vtkMatrix4x4 *UserMatrix, double TMatrix[]);
}

_declspec(dllexport) void LVvtkTrackerToolSetTransformationMatrix(vtkTrackerTool *tool, vtkMatrix4x4 *UserMatrix, double TMatrix[])
{
    UserMatrix->DeepCopy(TMatrix);
    tool->SetCalibrationMatrix(UserMatrix);
}

extern "C" {
_declspec(dllexport) void LVvtkTrackerSetWorldCalibrationMatrix(vtkTracker *Tracker, vtkMatrix4x4 *Matrix, double TMatrix[]);
}

_declspec(dllexport) void LVvtkTrackerSetWorldCalibrationMatrix(vtkTracker *Tracker, vtkMatrix4x4 *Matrix, double TMatrix[])
{
    Matrix->DeepCopy(TMatrix);
    Tracker->SetWorldCalibrationMatrix(Matrix);
}

//Return 0 if flock, returns 1 if NDI Tracker, returns 2 if it's something else;
extern "C" {
_declspec(dllexport) LVvtkTrackerWhatsIt(vtkTracker *Tracker, char *classname);
}

_declspec(dllexport) LVvtkTrackerWhatsIt(vtkTracker *Tracker, char *classname)
{
	memcpy(classname,Tracker->GetClassName(),strlen(Tracker->GetClassName())*sizeof(char));
}

extern "C" {
_declspec(dllexport) int LVvtkTrackerGetNumberOfTools(vtkTracker *Tracker);
}

_declspec(dllexport) int LVvtkTrackerGetNumberOfTools(vtkTracker *Tracker)
{
	return Tracker->GetNumberOfTools();
}

extern "C" {
_declspec(dllexport) void LVvtkCameraSetClippingRange(vtkRenderer *ren, double close, double away);
}

_declspec(dllexport) void LVvtkCameraSetClippingRange(vtkRenderer *ren, double close, double away)
{
	ren->GetActiveCamera()->SetClippingRange(close,away);  
}

extern "C" {
_declspec(dllexport) void LVvtkCameraSetFocalPoint(vtkRenderer *ren, int focalx, int focaly, int focalz);
}

_declspec(dllexport) void LVvtkCameraSetFocalPoint(vtkRenderer *ren, int focalx, int focaly, int focalz)
{
	ren->GetActiveCamera()->SetFocalPoint(focalx,focaly,focalz);
}


extern "C" {
_declspec(dllexport) void LVvtkCameraSetViewUp(vtkRenderer *ren, int x, int y, int z);
}

_declspec(dllexport) void LVvtkCameraSetViewUp(vtkRenderer *ren, int x, int y, int z)
{
	ren->GetActiveCamera()->SetViewUp(x,y,z);
}



extern "C" {
_declspec(dllexport) void LVvtkCameraSetUserTransform(vtkRenderer *ren, vtkTransform *Transform);
}

_declspec(dllexport) void LVvtkCameraSetUserTransform(vtkRenderer *ren, vtkTransform *Transform)
{
/*	vtkMatrix4x4 *matrix = vtkMatrix4x4::New();
	matrix->Identity();
	ren->GetRenderWindow()->GetInteractor()->Disable();
	ren->GetActiveCamera()->GetViewTransformObject()->SetMatrix(matrix);		
	ren->GetActiveCamera()->GetViewTransformObject()->SetInput(Transform);
	matrix->Delete();*/
	ren->GetActiveCamera()->SetPosition(0,0,0);
//	ren->GetActiveCamera()->SetPosition(0,0,0);
	ren->GetActiveCamera()->SetUserTransform(Transform);
}


extern "C" {
_declspec(dllexport) vtkProp *LVvtkRenderWindowGetPickedActor(vtkRenderWindow *rw);
}

_declspec(dllexport) vtkProp *LVvtkRenderWindowGetPickedActor(vtkRenderWindow *rw)
{	
	vtkRenderWindowInteractor *iren = rw->GetInteractor();
	vtkAssemblyPath *path=NULL;
	vtkAbstractPropPicker *picker;
	//Blatantly copied from vtkInteractorStyle.cxx
	if ( (picker=vtkAbstractPropPicker::SafeDownCast(iren->GetPicker())) )
          {
          path = picker->GetPath();
          }
	if ( path == NULL )
          {
          return 0;
          }
        else
          {
          return (path->GetFirstNode()->GetProp());
          }
}