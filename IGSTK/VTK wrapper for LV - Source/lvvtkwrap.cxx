////////////////////////////////////////////////////////////////////////////////////////////////
// Filename: lvvtkwrap.cxx
// Author:   Utsav Pardasani
// Date:     Unknown
//
// Description: This file is the source for a LabView/VTK dll wrapper mainly used for "Return of 
//				the MotionStation"
//
// Modified: 
//
// Name				Date				Description
// ---------------------------------------------------------------------------------------------
// Matthew Pan		May 14, 2008		Added Stereo3D functions for 3D viewing with various 
//										glasses
// Matthew Pan		June 9, 2008		Added functionality for RemoteView RenderWindow (see
//										rendering thread)
//
// Notes:
// 
// [UTSAV]: This is not the original lvvtkwrap.cxx.  I've totally broke compatibility for 
// the reasoning that this source code got very big.  I've tried to follow a naming system of 
// LVvtkClassFunction for all functions here.  New objects are created with LVCreateVtkClass
// It was getting kinda hard to navigate through all the functions in Labview, hence the new 
// naming scheme.  The end result of this, is that the old VIs will likely not work. Apologies if 
// this move is dumb and annoying. Fortunately, this DLL is named lvvtkwrap2.dll, so you can load 
// this one where you want to use my newer VIs, and you can use lvvtkwrap.dll where you want to 
// use the old ones.  There should be no problem using both dlls in the same Labview code.
//
// [UTSAV]:
//									--Rendering Threads!--
// So, we need a seperate thread to issue rendering commands/update trackers/do digitizations.  
// This is because Labview's normal behaviour is to wait until a DLL function call finishes
// before doing anything else.  You'll see the function 
// LVvtkStartRenderWindow
// which starts the vtkRenderWindow.  The function which defines the thread is vtkRenderingThread
// Threads bring a fair bit of complexity to our code.  It means we have to look at locking, and 
// threads, and stuff.  I use software locks in order to arbitrate access to complex vtk data
// structures such as vtkPolyData.
// 
//										--DoPreRender()--
// I wish I had called this something else.  It's just for digitizations.  It's called in 
// vtkRenderingThread before things render.  It modifies the polydata contained in the 
// pointmessage structure passed in.
//
//										--Pointmessage--
// This is a data structure consisting of information required to do digitizations.
// You'll see 
//		vtkTransform *Probe
//		vtkTransform *Reference
//		vtkPolyData  *PolyData
//
// PolyData gets modified in order to do digitizations.  Probe is the vtkTransform object from 
// the tracker tool you want to follow.  Reference is a vtkTransform object which you want the 
// digitizations to be with reference to.
//
//											--PerID--
// PerID is a pointer to an integer, holding the period which the rendering thread refreshes at.  
//If that integer is a negative number or zero, the thread will pause.  In order to use it, you'll 
//have to cast it to be a pointer to an integer. This is 
// done with:
//		(int *)(PerID)
// To read/modify it's value, you have to dereference that pointer with:
//		*(int *)(PerID)
// (you'll actually see that fairly often.)

//						--Why do some things have two pointers in front??--
// OK, well labview doesn't see VTK objects, it sees unsigned ints.  When you create a vtk object 
// here, you're actually creating a pointer to a vtkObject.  So if you want Labview to have a 
// pointer to a vtk object which you create, you can pass that pointer in by reference.  A 
// pointer to a pointer.  

////////////////////////////////////////////////////////////////////////////////////////////////////////
//[Jordan][April 2017] Added IGSTK compatability. New functions to the VTK equivalent are named the same, 
//just with IGSTK unstead of VTK. This souldn't break compatability as the original functions are still
//here. However, IGSTK functions cannot accept VTK objects as this causes an error. This means that if
//you are using igstk functions, you must always use igstk functions, and the same with vtk functions. 
//All IGSTK functions are loacted at the bottom of this file and are commented.   
//
//Things to do:
//This is still being compiled using VS 2010. Who knows how long this will continue working for newer systems
//and might be worth porting to a newer compiler. This is especially troubling as it is built for 32 built systems
//which are quickly falling out of favour for 64 bit systems. (writen in 2017)
//
//This DLL probably has links to libraries that are not needed, since the additional libraries and directories were 
//copied directly from an IGSTK example while I was trying to get it compile Many of the VTK functions here are also
//depreciated to use IGSTK instead. I didn't have time before i left to test which ones are no longer needed. If 
//someone is comming back to this, it may be a worthwhile exercise to figure out what functions are no longer called 
//from LabVIEW. 
////////////////////////////////////////////////////////////////////////////////////////////////

/***************************************
*  VTK wrapper for Lab View            *
***************************************/

//IGSTK items
#include <iostream>
#include <fstream>
#include "igstkConfigure.h"
#include "igstkStateMachine.h"
#include "igstkMacros.h"
#include "igstkObject.h"
#include "igstkEvents.h"
#include "igstkTracker.h"
#include "igstkTrackerTool.h"
#include "igstkNDICertusTracker.h"
#include "igstkNDICertusTrackerTool.h"
#include "igstkAscensionTracker.h"
#include "igstkAscensionTrackerTool.h"
#include "igstkPolarisTracker.h"
#include "igstkPolarisTrackerTool.h"
#include "itkCommand.h"
#include "itkStdStreamLogOutput.h"
#include "igstkTransform.h"
#include "igstkTransformObserver.h"

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
#include "vtkNDICertusTracker.h"
#include "vtkTracker.h"
#include "vtkTrackerTool.h"
#include "vtkTrackerBuffer.h"
#include "vtkMultiThreader.h"
#include "vtkMutexLock.h"
#include "vtkCommand.h"
#include "vtkRenderWindowInteractor.h"
//#include "vtkWin32RenderWindowInteractor.h"
#include "vtkCellArray.h"
//#include "vtkWin32RenderWindowInteractor.cxx"
#include "GL\GL.H"
#include <process.h>
#include <stdlib.h>
#include <time.h>
//#include "vtkInteractorStyleHULC.h"
#include "vtkPolyDataReader.h"
#include "vtkInteractorStyle.h"
#include "vtkInteractorStyleTrackballCamera.h"
#include "vtkAssemblyPath.h"
#include "vtkAssemblyNode.h"
#include "vtkOpenGLRenderWindow.h"
#include "windows.h"
#include "vtkOutputWindow.h"
#include "vtkObjectFactory.h"
#include "vtkVersion.h"
#include "vtkFileOutputWindow.h"
#include "vtkLandmarkTransform.h"
#include "vtkLookupTable.h"
#include "vtkPolyDataWriter.h"


BOOL APIENTRY DllMain( HANDLE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved )
{
   return TRUE;
}

typedef struct {
	vtkTransform *Probe;
	vtkTransform *Reference;
	vtkPolyData *PolyData;
} pointmessagetype;

pointmessagetype pointmessage;


vtkFlockTracker *FlockTracker;
vtkNDITracker *PolarisTracker;
vtkNDICertusTracker *CertusTracker;

//IGTSK tracker pointers (probably not the best way to do this)
igstk::NDICertusTracker::Pointer NDICertusTracker;

igstk::NDICertusTrackerTool::Pointer NDICertusTrackerTool[100];
igstk::TransformObserver::Pointer coordSystemObserver[100];
vtkTransform *vtkTransHolder[100];

int lock =0;
int debug_check =0;

//Begin InteractorStyle Subclass
enum LVMessage { NOTHING, PICK};


//Class for igstk observer
class NDICertusTrackerTestCommand : public itk::Command 
{
public:
  typedef  NDICertusTrackerTestCommand   Self;
  typedef  itk::Command                Superclass;
  typedef itk::SmartPointer<Self>      Pointer;
  itkNewMacro( Self );
protected:
  NDICertusTrackerTestCommand() {};

public:
  void Execute(itk::Object *caller, const itk::EventObject & event)
    {
    Execute( (const itk::Object *)caller, event);
    }

  void Execute(const itk::Object * object, const itk::EventObject & event)
    {
    // don't print "CompletedEvent", only print interesting events
    if (!igstk::CompletedEvent().CheckEvent(&event) &&
        !itk::DeleteEvent().CheckEvent(&event) )
      {
      std::cout << event.GetEventName() << std::endl;
      }
    }
};

class  vtkHULCInteractorStyle: public vtkInteractorStyle {
public:
  static vtkHULCInteractorStyle *New();
  // vtkTypeRevisionMacro(vtkHULCInteractorStyle ,vtkInteractorStyle);   //Do I need this??
  virtual void PrintSelf(ostream& os, vtkIndent indent);
	
  // Description:
  // Event bindings controlling the effects of pressing mouse buttons
  // or moving the mouse.
  virtual void OnMouseMove();
  virtual void OnLeftButtonDown();
  virtual void OnLeftButtonUp();
  virtual void OnMiddleButtonDown();
  virtual void OnMiddleButtonUp();
  virtual void OnRightButtonDown();
  virtual void OnRightButtonUp();
  virtual void OnMouseWheelForward();
  virtual void OnMouseWheelBackward();

  // These methods for the different interactions in different modes
  // are overridden in subclasses to perform the correct motion. Since
  // they are called by OnTimer, they do not have mouse coord parameters
  // (use interactor's GetEventPosition and GetLastEventPosition)
  virtual void Rotate();
  virtual void Spin();
  virtual void Pan();
  virtual void Dolly();

  enum LVMessage lvVTKMessage;
  vtkSetMacro(lvVTKMessage, LVMessage);
protected:
  vtkHULCInteractorStyle();
  ~vtkHULCInteractorStyle();

  double MotionFactor;

  virtual void Dolly(double factor);

private:
  vtkHULCInteractorStyle(const vtkHULCInteractorStyle&);  // Not implemented.
  void operator=(const vtkHULCInteractorStyle&);  // Not implemented.

};
vtkStandardNewMacro(vtkHULCInteractorStyle);

vtkHULCInteractorStyle::vtkHULCInteractorStyle() 
{
  this->MotionFactor   = 10.0;
  this->lvVTKMessage = NOTHING;
}

//----------------------------------------------------------------------------
vtkHULCInteractorStyle::~vtkHULCInteractorStyle() 
{
}

//----------------------------------------------------------------------------
void vtkHULCInteractorStyle::OnMouseMove() 
{ 
  int x = this->Interactor->GetEventPosition()[0];
  int y = this->Interactor->GetEventPosition()[1];

  switch (this->State) 
    {
    case VTKIS_ROTATE:
      this->FindPokedRenderer(x, y);
      this->Rotate();
      this->InvokeEvent(vtkCommand::InteractionEvent, NULL);
      break;

    case VTKIS_PAN:
      this->FindPokedRenderer(x, y);
      this->Pan();
      this->InvokeEvent(vtkCommand::InteractionEvent, NULL);
      break;

    case VTKIS_DOLLY:
      this->FindPokedRenderer(x, y);
      this->Dolly();
      this->InvokeEvent(vtkCommand::InteractionEvent, NULL);
      break;

    case VTKIS_SPIN:
      this->FindPokedRenderer(x, y);
      this->Spin();
      this->InvokeEvent(vtkCommand::InteractionEvent, NULL);
      break;
    }
}

//----------------------------------------------------------------------------
void vtkHULCInteractorStyle::OnLeftButtonDown() 
{ 
  this->FindPokedRenderer(this->Interactor->GetEventPosition()[0], 
                          this->Interactor->GetEventPosition()[1]);
  if (this->CurrentRenderer == NULL)
    {
    return;
    }
  
  if (this->Interactor->GetShiftKey()) 
    {
    if (this->Interactor->GetControlKey()) 
      {
      this->StartDolly();
      }
    else 
      {
      this->StartPan();
      }
    } 
  else 
    {
    if (this->Interactor->GetControlKey()) 
      {
      this->StartSpin();
      }
    else 
      {
      this->StartRotate();
      }
    }
}

//----------------------------------------------------------------------------
void vtkHULCInteractorStyle::OnLeftButtonUp()
{
  switch (this->State) 
    {
    case VTKIS_DOLLY:
      this->EndDolly();
      break;

    case VTKIS_PAN:
      this->EndPan();
      break;

    case VTKIS_SPIN:
      this->EndSpin();
      break;

    case VTKIS_ROTATE:
      this->EndRotate();
      break;
    }
  if (this->lvVTKMessage == PICK)
  {
	if (this->State == VTKIS_NONE) 
        {
        vtkAssemblyPath *path = NULL;
        int *eventPos = this->Interactor->GetEventPosition();
        this->FindPokedRenderer(eventPos[0], eventPos[1]);
        this->Interactor->StartPickCallback();
        vtkAbstractPropPicker *picker = 
          vtkAbstractPropPicker::SafeDownCast(this->Interactor->GetPicker());
        if ( picker != NULL )
          {
          picker->Pick(eventPos[0], eventPos[1], 
                       0.0, this->CurrentRenderer);
          path = picker->GetPath();
          }
        if ( path == NULL )
          {
          this->HighlightProp(NULL);
          this->PropPicked = 0;
          }
        else
          {
          this->HighlightProp(path->GetFirstNode()->GetViewProp());
          this->PropPicked = 1;
          }
        this->Interactor->EndPickCallback();
        }
	this->lvVTKMessage = NOTHING;
	}
}

//----------------------------------------------------------------------------
void vtkHULCInteractorStyle::OnMiddleButtonDown() 
{
  this->FindPokedRenderer(this->Interactor->GetEventPosition()[0], 
                          this->Interactor->GetEventPosition()[1]);
  if (this->CurrentRenderer == NULL)
    {
    return;
    }
  
  this->StartPan();
}

//----------------------------------------------------------------------------
void vtkHULCInteractorStyle::OnMiddleButtonUp()
{
  switch (this->State) 
    {
    case VTKIS_PAN:
      this->EndPan();
      break;
    }
}

//----------------------------------------------------------------------------
void vtkHULCInteractorStyle::OnRightButtonDown() 
{
  this->FindPokedRenderer(this->Interactor->GetEventPosition()[0], 
                          this->Interactor->GetEventPosition()[1]);
  if (this->CurrentRenderer == NULL)
    {
    return;
    }
  
  this->StartDolly();
}

//----------------------------------------------------------------------------
void vtkHULCInteractorStyle::OnRightButtonUp()
{
  switch (this->State) 
    {
    case VTKIS_DOLLY:
      this->EndDolly();
      break;
    }
}

//----------------------------------------------------------------------------
void vtkHULCInteractorStyle::OnMouseWheelForward() 
{
  this->FindPokedRenderer(this->Interactor->GetEventPosition()[0], 
                          this->Interactor->GetEventPosition()[1]);
  if (this->CurrentRenderer == NULL)
    {
    return;
    }
  
  this->StartDolly();
  double factor = this->MotionFactor * 0.2 * this->MouseWheelMotionFactor;
  this->Dolly(pow((double)1.1, factor));
  this->EndDolly();
}

//----------------------------------------------------------------------------
void vtkHULCInteractorStyle::OnMouseWheelBackward()
{
  this->FindPokedRenderer(this->Interactor->GetEventPosition()[0], 
                          this->Interactor->GetEventPosition()[1]);
  if (this->CurrentRenderer == NULL)
    {
    return;
    }
  
  this->StartDolly();
  double factor = this->MotionFactor * -0.2 * this->MouseWheelMotionFactor;
  this->Dolly(pow((double)1.1, factor));
  this->EndDolly();
}

//----------------------------------------------------------------------------
void vtkHULCInteractorStyle::Rotate()
{
  if (this->CurrentRenderer == NULL)
    {
    return;
    }
  
  vtkRenderWindowInteractor *rwi = this->Interactor;

  int dx = rwi->GetEventPosition()[0] - rwi->GetLastEventPosition()[0];
  int dy = rwi->GetEventPosition()[1] - rwi->GetLastEventPosition()[1];
  
  int *size = this->CurrentRenderer->GetRenderWindow()->GetSize();

  double delta_elevation = -20.0 / size[1];
  double delta_azimuth = -20.0 / size[0];
  
  double rxf = (double)dx * delta_azimuth * this->MotionFactor;
  double ryf = (double)dy * delta_elevation * this->MotionFactor;
  
  vtkCamera *camera = this->CurrentRenderer->GetActiveCamera();
  camera->Azimuth(rxf);
  camera->Elevation(ryf);
  camera->OrthogonalizeViewUp();

  if (this->AutoAdjustCameraClippingRange)
    {
    this->CurrentRenderer->ResetCameraClippingRange();
    }

  if (rwi->GetLightFollowCamera()) 
    {
    this->CurrentRenderer->UpdateLightsGeometryToFollowCamera();
    }

  rwi->Render();
}

//----------------------------------------------------------------------------
void vtkHULCInteractorStyle::Spin()
{
  if (this->CurrentRenderer == NULL)
    {
    return;
    }

  vtkRenderWindowInteractor *rwi = this->Interactor;

  double *center = this->CurrentRenderer->GetCenter();

  double newAngle = 
    atan2((double)rwi->GetEventPosition()[1] - (double)center[1],
          (double)rwi->GetEventPosition()[0] - (double)center[0]);

  double oldAngle = 
    atan2((double)rwi->GetLastEventPosition()[1] - (double)center[1],
          (double)rwi->GetLastEventPosition()[0] - (double)center[0]);
  
  newAngle *= vtkMath::DegreesFromRadians(newAngle);
  oldAngle *= vtkMath::DegreesFromRadians(oldAngle);

  vtkCamera *camera = this->CurrentRenderer->GetActiveCamera();
  camera->Roll(newAngle - oldAngle);
  camera->OrthogonalizeViewUp();
      
  rwi->Render();
}

//----------------------------------------------------------------------------
void vtkHULCInteractorStyle::Pan()
{
  if (this->CurrentRenderer == NULL)
    {
    return;
    }

  vtkRenderWindowInteractor *rwi = this->Interactor;

  double viewFocus[4], focalDepth, viewPoint[3];
  double newPickPoint[4], oldPickPoint[4], motionVector[3];
  
  // Calculate the focal depth since we'll be using it a lot

  vtkCamera *camera = this->CurrentRenderer->GetActiveCamera();
  camera->GetFocalPoint(viewFocus);
  this->ComputeWorldToDisplay(viewFocus[0], viewFocus[1], viewFocus[2], 
                              viewFocus);
  focalDepth = viewFocus[2];

  this->ComputeDisplayToWorld((double)rwi->GetEventPosition()[0], 
                              (double)rwi->GetEventPosition()[1],
                              focalDepth, 
                              newPickPoint);
    
  // Has to recalc old mouse point since the viewport has moved,
  // so can't move it outside the loop

  this->ComputeDisplayToWorld((double)rwi->GetLastEventPosition()[0],
                              (double)rwi->GetLastEventPosition()[1],
                              focalDepth, 
                              oldPickPoint);
  
  // Camera motion is reversed

  motionVector[0] = oldPickPoint[0] - newPickPoint[0];
  motionVector[1] = oldPickPoint[1] - newPickPoint[1];
  motionVector[2] = oldPickPoint[2] - newPickPoint[2];
  
  camera->GetFocalPoint(viewFocus);
  camera->GetPosition(viewPoint);
  camera->SetFocalPoint(motionVector[0] + viewFocus[0],
                        motionVector[1] + viewFocus[1],
                        motionVector[2] + viewFocus[2]);

  camera->SetPosition(motionVector[0] + viewPoint[0],
                      motionVector[1] + viewPoint[1],
                      motionVector[2] + viewPoint[2]);
      
  if (rwi->GetLightFollowCamera()) 
    {
    this->CurrentRenderer->UpdateLightsGeometryToFollowCamera();
    }
    
  rwi->Render();
}

//----------------------------------------------------------------------------
void vtkHULCInteractorStyle::Dolly()
{
  if (this->CurrentRenderer == NULL)
    {
    return;
    }
  
  vtkRenderWindowInteractor *rwi = this->Interactor;
  double *center = this->CurrentRenderer->GetCenter();
  int dy = rwi->GetEventPosition()[1] - rwi->GetLastEventPosition()[1];
  double dyf = this->MotionFactor * (double)(dy) / (double)(center[1]);
  this->Dolly(pow((double)1.1, dyf));
}

//----------------------------------------------------------------------------
void vtkHULCInteractorStyle::Dolly(double factor)
{
  if (this->CurrentRenderer == NULL)
    {
    return;
    }
  
  vtkCamera *camera = this->CurrentRenderer->GetActiveCamera();
  if (camera->GetParallelProjection())
    {
    camera->SetParallelScale(camera->GetParallelScale() / factor);
    }
  else
    {
    camera->Dolly(factor);
    if (this->AutoAdjustCameraClippingRange)
      {
      this->CurrentRenderer->ResetCameraClippingRange();
      }
    }
  
  if (this->Interactor->GetLightFollowCamera()) 
    {
    this->CurrentRenderer->UpdateLightsGeometryToFollowCamera();
    }
  
  this->Interactor->Render();
}

//----------------------------------------------------------------------------
void vtkHULCInteractorStyle::PrintSelf(ostream& os, vtkIndent indent)
{
  this->Superclass::PrintSelf(os,indent);

}

int iterations;

//Digitizations happen here.  If we are tracking, pointmessage will direct this function to do 
//digitizations.  This is called from the rendering thread.  (vtkRenderingThread)
//JOB 2017: We think that this is for digitizations ONLY. if this is the case it is not a good name for this Function
void doPreRender()
{
	iterations++;
	vtkMatrix4x4 *MatrixOut, *MatrixInvert;
	//Potential for race condition here, be sure to pause trackers and rendering thread before 
	//removing trackers.
	if (PolarisTracker)
		PolarisTracker->Update();
	if (FlockTracker)
		FlockTracker->Update();
	if (CertusTracker)
		CertusTracker->Update();
	if (pointmessage.PolyData)
	{
		double x,y,z;
		vtkPolyData *PData;
		PData = pointmessage.PolyData;
		if (pointmessage.Reference==0)
		{
			MatrixOut=pointmessage.Probe->GetMatrix();
			x = MatrixOut->GetElement(0,3);
			y = MatrixOut->GetElement(1,3);
			z = MatrixOut->GetElement(2,3);
		}
		else
		{
			MatrixOut= vtkMatrix4x4::New();
			MatrixInvert = vtkMatrix4x4::New();
			vtkMatrix4x4::Invert(pointmessage.Reference->GetMatrix(),MatrixInvert);
			vtkMatrix4x4::Multiply4x4(MatrixInvert, pointmessage.Probe->GetMatrix(), MatrixOut);
			MatrixInvert->Delete();
			x = MatrixOut->GetElement(0,3);
			y = MatrixOut->GetElement(1,3);
			z = MatrixOut->GetElement(2,3);
			MatrixOut->Delete();
		}

		PData->GetPoints()->InsertNextPoint(x,y,z);
		PData->GetVerts()->GetData()->InsertNextValue(PData->GetPoints()->GetNumberOfPoints()-1);
		PData->GetVerts()->GetData()->SetValue(0,PData->GetVerts()->GetData()->GetValue(0)+1);
		PData->Modified();
	}
	else
		iterations=0;
}

void vtkRenderingThread(void *arglist);

extern "C" {
_declspec(dllexport) void LVvtkStartRenderWindow(vtkRenderWindow *RenderWindow,int *Period, unsigned int *PerID, unsigned int arg[]);
}
_declspec(dllexport) void LVvtkStartRenderWindow(vtkRenderWindow *RenderWindow,int *Period, unsigned int *PerID, unsigned int arg[])
{
	arg[0] = (unsigned int) Period;
	arg[1] = (unsigned int) RenderWindow;
	*PerID= (unsigned int) Period;
	//The best way I could think of to pass information to the new thread is to put them all into an array.
	_beginthread(vtkRenderingThread, 0, (void *) arg);
}


void vtkRenderingThread(void *arglist)
{	

	iterations=0;
	PolarisTracker=0;
	FlockTracker=0;
	CertusTracker=0;
	pointmessage.PolyData =0;
	pointmessage.Probe=0;
	pointmessage.Reference=0;
	unsigned int *arg = (unsigned int *) arglist;
	vtkRenderWindowInteractor *iren = vtkRenderWindowInteractor::New();
	vtkHULCInteractorStyle *style = vtkHULCInteractorStyle::New();  //Use our custom Interactor Style for getting messages from Labview to the interactor! 

	//Vtk Has an annoying pop up window which gives error output.
	//Instead I have it redirect it to a file. 
	vtkFileOutputWindow *fileout = vtkFileOutputWindow::New();
	fileout->SetFileName ("C:\\Users\\HMMS\\Desktop\\MotionStation Tests\\vtkLabviewFileOutputWindow.log");
	fileout->SetInstance(fileout);

	style->AutoAdjustCameraClippingRangeOff();
	iren->SetInteractorStyle(style);
	vtkRenderWindow *rw = (vtkRenderWindow *)  arg[1];
	int period = *((int *)  arg[0]);
	int timer=0;
	iren->SetRenderWindow(rw);
	rw->Render();
	/*MSG msg;
	clock_t c0;
	HANDLE h = (HANDLE)CreateEvent( 0, false, false, 0 );
	int ismessage;
	while(1)
	{
		period = (*(int *)  arg[0]);
		if (period >0)
		{
			c0 = clock();
			//This is a win32 api function call
			ismessage=PeekMessage(&msg,NULL,0,0,PM_REMOVE);

			if (!ismessage)
			{
				doPreRender();
				rw->Render();
			}
			else while (ismessage) 
			{
				doPreRender();
				if (msg.message != (WM_MBUTTONDOWN || WM_LBUTTONDOWN ||WM_RBUTTONDOWN))
					rw->Render();

				TranslateMessage(&msg);
				DispatchMessage(&msg);
				ismessage=PeekMessage(&msg,NULL,0,0,PM_REMOVE);
			}
			timer = abs(period) - (int) ((clock() -c0)/(CLOCKS_PER_SEC*0.001));
			if (timer > 0)
			{
				//Tells Windows to give us messages at regular intervals.
				MsgWaitForMultipleObjectsEx( 1, &h, timer, QS_ALLEVENTS, 
					MWMO_ALERTABLE|MWMO_INPUTAVAILABLE );  
			}
		}
		else if (period < 0)
		{
			PeekMessage(&msg,NULL,0,0,PM_REMOVE);
			//The above line pauses all rendering, if you want interaction, comment out the top line and uncomment the ones below.
//			GetMessage(&msg,NULL,0,0);
//			TranslateMessage(&msg);
//			DispatchMessage(&msg);
		}
		else
		{
			_endthread();
			break;
		}
	}
//	fclose(file);
	CloseHandle( h );
	iren->Delete();  */
}

//MATT'S CONSTRUCTION ZONE************************************************************************************************************************************************************

void vtkRenderingThread2(void *arglist);

extern "C" {
_declspec(dllexport) void LVvtkStart2RenderWindows(vtkRenderWindow *RenderWindow, vtkRenderWindow *RenderWindow2, int *Period, unsigned int *PerID, unsigned int arg[]);
}
_declspec(dllexport) void LVvtkStart2RenderWindows(vtkRenderWindow *RenderWindow, vtkRenderWindow *RenderWindow2, int *Period, unsigned int *PerID, unsigned int arg[])
{
	arg[0] = (unsigned int) Period;
	arg[1] = (unsigned int) RenderWindow;
	arg[2] = (unsigned int) RenderWindow2;
	*PerID= (unsigned int) Period;
	//The best way I could think of to pass information to the new thread is to put them all 
	//into an array.
	_beginthread(vtkRenderingThread2, 0, (void *) arg);
}


void vtkRenderingThread2(void *arglist)
{	

	iterations=0;
	PolarisTracker=0;
	FlockTracker=0;
	CertusTracker=0;
	pointmessage.PolyData =0;
	pointmessage.Probe=0;
	pointmessage.Reference=0;
	unsigned int *arg = (unsigned int *) arglist;
	//double rw1focX,rw1focY,rw1focZ;
	//double *rw1focXp = &rw1focX;
	//double *rw1focYp = &rw1focY;
	//double *rw1focZp = &rw1focZ;

	vtkRenderWindowInteractor *iren = vtkRenderWindowInteractor::New();
	vtkHULCInteractorStyle *style = vtkHULCInteractorStyle::New();  //Use our custom Interactor Style for getting messages from Labview to the interactor! 
	//VTK Has an annoying pop up window which gives error output.
	//Instead I have it redirect it to a file. 
	vtkFileOutputWindow *fileout = vtkFileOutputWindow::New();
	fileout->SetFileName ("C:\\Users\\HMMS\\Desktop\\MotionStation Tests\\vtkLabviewFileOutputWindow.log");
	fileout->SetInstance(fileout);

	style->AutoAdjustCameraClippingRangeOff();
	iren->SetInteractorStyle(style);

	vtkRenderWindow *rw1 = (vtkRenderWindow *)  arg[1];
	vtkRenderWindow *rw2 = (vtkRenderWindow *)  arg[2];

	vtkRendererCollection *rw1Renderers = rw1->GetRenderers();
	vtkRendererCollection *rw2Renderers = rw2->GetRenderers();

    vtkCamera *rw1Camera = rw1Renderers->GetFirstRenderer()->GetActiveCamera();
	vtkCamera *rw2Camera = rw2Renderers->GetFirstRenderer()->GetActiveCamera();

	vtkLight *rw2Light = vtkLight::New();
	rw2Renderers->GetFirstRenderer()->AddLight(rw2Light);
	
	vtkTransform *rw2CamTrans = rw2Camera->GetViewTransformObject();

	int period = *((int *)  arg[0]);
	int timer=0;
	iren->SetRenderWindow(rw1);
	//rw2Renderers->GetFirstRenderer()->UpdateLightsGeometryToFollowCamera();
	rw1->Render();
	rw2->Render();

	MSG msg;
	clock_t c0;
	HANDLE h = (HANDLE)CreateEvent( 0, false, false, 0 );
	int ismessage;
	while(1)
	{
		rw2Camera->SetDistance(rw1Camera->GetDistance()); 
		period = (*(int *)  arg[0]); //frequency
		if (period >0)
		{
			c0 = clock();
			//This is a win32 api function call
			ismessage=PeekMessage(&msg,NULL,0,0,PM_REMOVE);

			if (!ismessage)
			{
				doPreRender();
				//rw1Camera->GetFocalPoint(*rw1focXp,*rw1focYp,*rw1focZp);
				//rw2Camera->SetFocalPoint(rw1focX,rw1focY,rw1focZ);
				rw2Light->SetTransformMatrix(rw1Camera->GetCameraLightTransformMatrix());
				//rw2Camera->SetDistance(rw1Camera->GetDistance()); 
				rw2->Render();
				rw1->Render();
			}
			else while (ismessage) 
			{
				doPreRender();
				if (msg.message != (WM_MBUTTONDOWN || WM_LBUTTONDOWN ||WM_RBUTTONDOWN))
				{
					rw2CamTrans->SetMatrix(rw1Camera->GetViewTransformMatrix());
					rw2Light->SetTransformMatrix(rw1Camera->GetCameraLightTransformMatrix()); 
					//rw2Camera->SetDistance(rw1Camera->GetDistance()); 
					
					rw2->Render();
					rw1->Render();
					//rw1Camera->GetFocalPoint(*rw1focXp,*rw1focYp,*rw1focZp);
					//rw2Camera->SetFocalPoint(rw1focX,rw1focY,rw1focZ);
				}	
				
				TranslateMessage(&msg);
				DispatchMessage(&msg);
				ismessage=PeekMessage(&msg,NULL,0,0,PM_REMOVE);
			}
			timer = abs(period) - (int) ((clock() -c0)/(CLOCKS_PER_SEC*0.001));
			if (timer > 0)
			{
				//Tells Windows to give us messages at regular intervals.
				MsgWaitForMultipleObjectsEx( 1, &h, timer, QS_ALLEVENTS, 
					MWMO_ALERTABLE|MWMO_INPUTAVAILABLE );  
			}
		}
		else if (period < 0)
		{
			PeekMessage(&msg,NULL,0,0,PM_REMOVE);
			//The above line pauses all rendering, if you want interaction, comment out the 
			//top line and uncomment the ones below.
//			GetMessage(&msg,NULL,0,0);
//			TranslateMessage(&msg);
//			DispatchMessage(&msg);
		}
		else
		{
			_endthread();
			break;
		}
	}
//	fclose(file);
	CloseHandle( h );
	iren->Delete();
}

//Telling the rendering thread to reset the camera.
//This is done by sending a "message" to the thread.
//The resseting of the camera is taken care of 
//in vtkHULCRenderWindowInteractorStyle
extern "C" {
_declspec(dllexport) void LVvtkRenderingThreadResetCamera(vtkWin32OpenGLRenderWindow *rw);
}
_declspec(dllexport) void LVvtkRenderingThreadResetCamera(vtkWin32OpenGLRenderWindow *rw)
{
	PostMessage(rw->GetWindowId(),WM_CHAR,0x52,0);
}

extern "C" {
_declspec(dllexport) void LVvtkEnableParallelProjection(vtkWin32OpenGLRenderWindow *rw);
}
_declspec(dllexport) void LVvtkEnableParallelProjection(vtkWin32OpenGLRenderWindow *rw)
{
	rw->GetRenderers()->GetFirstRenderer()->GetActiveCamera()->ParallelProjectionOn();
}

extern "C" {
_declspec(dllexport) void LVvtkDisableParallelProjection(vtkWin32OpenGLRenderWindow *rw);
}
_declspec(dllexport) void LVvtkDisableParallelProjection(vtkWin32OpenGLRenderWindow *rw)
{
	rw->GetRenderers()->GetFirstRenderer()->GetActiveCamera()->ParallelProjectionOff();
}

//This enables Red/Blue Anaglyph Stereo 3D rendering which enables the user to use a pair of
//red/blue 3D glasses they can get in a box of cereal or in an IMAX3D movie to view objects 
//in the renderWindow.
extern "C" {
_declspec(dllexport) void LVvtkEnableStereo3DRedBlue(vtkWin32OpenGLRenderWindow *rw);
}
_declspec(dllexport) void LVvtkEnableStereo3DRedBlue(vtkWin32OpenGLRenderWindow *rw)
{
  rw->SetStereoTypeToRedBlue();
  rw->StereoRenderOn();
}

//This enables Frame Sequential 3D rendering which enables the user to use a pair of
//more expensive 3D glasses to view objects in the renderWindow.
extern "C" {
_declspec(dllexport) void LVvtkEnableStereo3DCrystalEyes(vtkWin32OpenGLRenderWindow *rw);
}
_declspec(dllexport) void LVvtkEnableStereo3DCrystalEyes(vtkWin32OpenGLRenderWindow *rw)
{
  rw->SetStereoTypeToCrystalEyes();
  rw->StereoRenderOn();
  rw->StereoUpdate();
}

//This enables Left/Right Interlaced 3D rendering which enables the user to use a pair of
//more expensive 3D glasses to view objects in the renderWindow.
extern "C" {
_declspec(dllexport) void LVvtkEnableStereo3DInterlaced(vtkWin32OpenGLRenderWindow *rw);
}
_declspec(dllexport) void LVvtkEnableStereo3DInterlaced(vtkWin32OpenGLRenderWindow *rw)
{
  rw->SetStereoTypeToInterlaced();
  rw->StereoRenderOn();
}

//This disables eyepopping 3D effects.  
extern "C" {
_declspec(dllexport) void LVvtkDisableStereo3D(vtkWin32OpenGLRenderWindow *rw);
}
_declspec(dllexport) void LVvtkDisableStereo3D(vtkWin32OpenGLRenderWindow *rw)
{
  rw->StereoRenderOff();
}

//Sends messages to the vtkHULCRenderWindowInteractor with characters.
//In a normal RenderWindow, (Like in a normal C++ program you'd write.) you can send
//keystrokes to have it do things like resetting camera, and toggling wireframe mode, 
//etc.  So with this function you can do all these things.  These keystrokes should
//be documented in rederwindowinteractorstyle classes.
extern "C" {
_declspec(dllexport) void LVvtkRenderWindowSendChar(vtkWin32OpenGLRenderWindow *rw, char character);
}
_declspec(dllexport) void LVvtkRenderWindowSendChar(vtkWin32OpenGLRenderWindow *rw, char character)
{
	PostMessage(rw->GetWindowId(),WM_CHAR,character,0);
}

extern "C" {
_declspec(dllexport) vtkRendererCollection *LVvtkRenderWindowGetRenderers(vtkWin32OpenGLRenderWindow *rw);
}
_declspec(dllexport) vtkRendererCollection *LVvtkRenderWindowGetRenderers(vtkWin32OpenGLRenderWindow *rw)
{
	return rw->GetRenderers();
}

extern "C" {
_declspec(dllexport) int LVvtkCollectionGetNumberofItems(vtkCollection *collection);
}
_declspec(dllexport) int LVvtkCollectionGetNumberofItems(vtkCollection *collection)
{
	return collection->GetNumberOfItems();
}



extern "C" {
_declspec(dllexport) vtkRendererCollection *LVvtkRendererCollectionGetItem(vtkRendererCollection *Collection, int index);
}

_declspec(dllexport) vtkRendererCollection *LVvtkRendererCollectionGetItem(vtkRendererCollection *Collection, int index)
{
	return static_cast<vtkRendererCollection *>(Collection->GetItemAsObject(index));
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
	//Robin:  Jumping Jack-O-Lanterns in a Monkey Bag Batman?  What's this do??  
	//Batman: Read the note at the top of the file regarding PerID.
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

//Replaces the old seperate thread per tracker.  Passes tracker info to the rendering thread
extern "C" {
_declspec(dllexport) void LVvtkTrackerStartUpdating(vtkTracker *Tracker);
}
_declspec(dllexport) void LVvtkTrackerStartUpdating(vtkTracker *Tracker)
{
	//Detects whether this is a flock or Polaris tracker.
	if (strcmp(Tracker->GetClassName(),"vtkFlockTracker")==0)
		FlockTracker =(vtkFlockTracker*) Tracker;
	else if (strcmp(Tracker->GetClassName(),"vtkNDITracker")==0)
		PolarisTracker = (vtkNDITracker*)Tracker;
	else if (strcmp(Tracker->GetClassName(),"vtkNDICertusTracker")==0)
		CertusTracker = (vtkNDICertusTracker*)Tracker;
}
//
////IGSTK function for start updating tracker(not sure if it will work)
//extern "C" {
//_declspec(dllexport) void LVigstkTrackerStartUpdating(igstk::Tracker *Tracker);
//}
//_declspec(dllexport) void LVigstkTrackerStartUpdating(igstk::Tracker *Tracker)
//{
//	//Detects whether this is a flock or Certus tracker. 
//	if (strcmp(Tracker->GetNameOfClass(),"igstk::AscensionTracker")==0)
//		FlockTrackerNew =(igstk::AscensionTracker*) Tracker;
//	else if (strcmp(Tracker->GetNameOfClass(),"igstk::NDITracker")==0)
//		PolarisTrackerNew = (igstk::PolarisTracker*)Tracker;
//	else if (strcmp(Tracker->GetNameOfClass(),"igstk::NDICertusTracker")==0)
//		CertusTrackerNew = (igstk::NDICertusTracker*)Tracker;
//}

//Removes the old Tracker from the list.  I hope this works, I haven't tried this for many cases.
extern "C" {
_declspec(dllexport) void LVvtkTrackerStopUpdating(vtkTracker *Tracker);
}
_declspec(dllexport) void LVvtkTrackerStopUpdating(vtkTracker *Tracker)
{
if (strcmp(Tracker->GetClassName(),"vtkFlockTracker")==0)
		FlockTracker = 0;
	else if (strcmp(Tracker->GetClassName(),"vtkNDITracker")==0)
		PolarisTracker = 0;
	else if (strcmp(Tracker->GetClassName(),"vtkNDICertusTracker")==0)
		CertusTracker = 0;
}

////Removes the old Tracker from the list.  I hope this works, I haven't tried this for many cases.
//extern "C" {
//_declspec(dllexport) void LVigstkTrackerStopUpdating(igstk::Tracker *Tracker);
//}
//_declspec(dllexport) void LVigstkTrackerStopUpdating(igstk::Tracker *Tracker)
//{
//if (strcmp(Tracker->GetNameOfClass(),"igstk::AscensionTracker")==0)
//		FlockTracker = 0;
//	else if (strcmp(Tracker->GetNameOfClass(),"igstk::NDITracker")==0)
//		PolarisTracker = 0;
//	else if (strcmp(Tracker->GetNameOfClass(),"igstk::NDICertusTracker")==0)
//		CertusTracker = 0;
//}

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

extern "C" {
_declspec(dllexport) void LVvtkRendererSetViewport(vtkRenderer *Renderer, double xmin, double ymin, double xmax, double ymax);
}

_declspec(dllexport) void LVvtkRendererSetViewport(vtkRenderer *Renderer, double xmin, double ymin, double xmax, double ymax)
{
	Renderer->SetViewport(xmin, ymin, xmax, ymax);
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
  int i=0;
  for(; i<(*DSI)->GetRenderer()->GetActors()->GetNumberOfItems(); (*NewAssembly)->AddPart(static_cast<vtkActor *>((*DSI)->GetRenderer()->GetActors()->GetItemAsObject(i++))));
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
/*
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
*/

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
	   for(int i=0; i<(*DSI)->GetRenderer()->GetActors()->GetNumberOfItems(); NewAssembly->AddPart(static_cast<vtkActor *>((*DSI)->GetRenderer()->GetActors()->GetItemAsObject(i++))));
//		   (static_cast<vtkActor *>((*DSI)->GetRenderer()->GetActors()->GetItemAsObject(i)))->Delete();
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
	   for(int i=0; i<(*vrmli)->GetRenderer()->GetActors()->GetNumberOfItems(); NewAssembly->AddPart(static_cast<vtkActor *>((*vrmli)->GetRenderer()->GetActors()->GetItemAsObject(i++))));		   
	  *Actor=NewAssembly;
  }
  return 1;// ((*vrmli)->GetRenderer()->GetActors()->GetItemAsObject(i))->GetReferenceCount();
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
_declspec(dllexport) void LVvtkPolyDataWriter(vtkPolyData *Polydata, char *filepath);
}

_declspec(dllexport) void LVvtkPolyDataWriter(vtkPolyData *Polydata, char *filepath)
{
	
	vtkPolyDataWriter *writer = vtkPolyDataWriter::New();
	writer->SetInput(Polydata);
	writer->SetFileName(filepath);
	writer->Write();
//	writer->Delete();
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
_declspec(dllexport) long LVvtkProp3DSetPosition(vtkProp3D *Prop, double  x, double  y, double  z);
}

_declspec(dllexport) long LVvtkProp3DSetPosition(vtkProp3D *Prop, double  x, double  y, double  z)
{
  Prop->SetPosition(x,y,z);
  return (1);
}

extern "C" {
_declspec(dllexport) void LVvtkActorSetFlatShading(vtkActor *Prop);
}

_declspec(dllexport) void LVvtkActorSetFlatShading(vtkActor  *Prop)
{
  Prop->GetProperty()->SetInterpolationToFlat();
  static_cast<vtkLookupTable *>(Prop->GetMapper()->GetLookupTable())->SetNumberOfColors(1);
  static_cast<vtkLookupTable *>(Prop->GetMapper()->GetLookupTable())->SetNumberOfTableValues(1);
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

//Set the user matrix 
//If there is a transformation chain, replace the first vtktransform's matrix,
//else, just set the user matrix
extern "C" {
_declspec(dllexport) long LVvtkProp3DSetUserMatrix(vtkProp3D *Prop, vtkMatrix4x4 *UserMatrix, double TMatrix[]);
}

_declspec(dllexport) long LVvtkProp3DSetUserMatrix(vtkProp3D *Prop, vtkMatrix4x4 *UserMatrix, double TMatrix[])
{
//
	if ((Prop->GetUserTransform()) && (strcmp(Prop->GetUserTransform()->GetClassName(), "vtkTransform")==0) && (((vtkTransform*)Prop->GetUserTransform())->GetInput()))
	{
		UserMatrix->DeepCopy(TMatrix);
		((vtkTransform*)Prop->GetUserTransform()) ->SetMatrix(UserMatrix);
		return (1);
	}
    else
	{
			UserMatrix->DeepCopy(TMatrix);
			Prop->SetUserMatrix(UserMatrix);
	}

	return (0);
}
extern "C" {
_declspec(dllexport) vtkPolyData *LVvtkActorGetPolyData(vtkActor *Prop);
}

_declspec(dllexport) vtkPolyData *LVvtkActorGetPolyData(vtkActor *Prop)
{
	if (Prop->GetMapper()->IsA("vtkPolyDataMapper"))
		return static_cast<vtkPolyData*> (Prop->GetMapper()->GetInput());

	return 0;
}

extern "C" {
_declspec(dllexport) void LVvtkMatrix4x4DeepCopy(vtkMatrix4x4 *Matrix, double TMatrix[]);
}

_declspec(dllexport) void LVvtkMatrix4x4DeepCopy(vtkMatrix4x4 *Matrix, double TMatrix[])
{
	Matrix->DeepCopy(TMatrix);
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
_declspec(dllexport) void LVvtkProp3DResetPokeMatrix(vtkProp3D *Actor);
}

_declspec(dllexport) void LVvtkProp3DResetPokeMatrix(vtkProp3D *Actor)
{
    Actor->PokeMatrix(NULL);
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
	renderer->AddViewProp(prop);
	// renderer->AddProp(prop); use this line for VTK 4.2.1 and lower
}

// Remove an actor from a renderer
extern "C" {
_declspec(dllexport) void  LVvtkRendererRemoveActor (vtkRenderer *renderer, vtkProp *prop); 
}

_declspec(dllexport) void  LVvtkRendererRemoveActor (vtkRenderer *renderer, vtkProp *prop) 
{
	renderer->RemoveActor(prop);
}

// Get all the actors in a renderer and place them in a collection
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
_declspec(dllexport) vtkRenderWindowInteractor *LVvtkRenderWindowGetInteractor(vtkRenderWindow *renWin);
}

_declspec(dllexport) vtkRenderWindowInteractor *LVvtkRenderWindowGetInteractor(vtkRenderWindow *renWin)
{
	return renWin->GetInteractor();
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

extern "C" {
_declspec(dllexport) void LVvtkRenderWindowSetSize(vtkRenderWindow *renWin, int width, int height);
}

_declspec(dllexport) void LVvtkRenderWindowSetSize(vtkRenderWindow *renWin, int width, int height)
{
	renWin->SetSize(width,height);
}

////////////////////
//vtkRenderWindowInteractor
//Public Member Functions

// Not quite sure if this is used anymore.
extern "C" {
_declspec(dllexport) void LVvtkRenderWindowInteractorInitialize(vtkRenderWindowInteractor *Interactor);
}

_declspec(dllexport) void LVvtkRenderWindowInteractorInitialize(vtkRenderWindowInteractor *Interactor)
{
	Interactor->Initialize();
	
}

//Not quite sure if I'm actually using this.
extern "C" {
_declspec(dllexport) void LVvtkRenderWindowInteractorStart(vtkRenderWindowInteractor *Interactor);
}

_declspec(dllexport) void LVvtkRenderWindowInteractorStart(vtkRenderWindowInteractor *Interactor)
{
	Interactor->Start();
	
}


//Pretty sure I'm not actually using this.
extern "C" {
_declspec(dllexport) void LVvtkRenderWindowInteractorSetDesiredUpdateRate(vtkRenderWindowInteractor *Interactor, double update_rate);
}

_declspec(dllexport) void LVvtkRenderWindowInteractorSetDesiredUpdateRate(vtkRenderWindowInteractor *Interactor, double update_rate)
{
	Interactor->SetDesiredUpdateRate(update_rate);
}

//Pretty sure I'm not actually using this.
extern "C" {
_declspec(dllexport) void LVvtkRenderWindowInteractorSetStillUpdateRate(vtkRenderWindowInteractor *Interactor, double update_rate);
}

_declspec(dllexport) void LVvtkRenderWindowInteractorSetStillUpdateRate(vtkRenderWindowInteractor *Interactor, double update_rate)
{
	Interactor->SetStillUpdateRate(update_rate);
}

//Highlights a Prop3D
extern "C" {
_declspec(dllexport) void LVvtkRenderWindowInteractorHighlightProp3D(vtkRenderWindowInteractor *Interactor, vtkProp3D *Prop);
}

_declspec(dllexport) void LVvtkRenderWindowInteractorHighlightProp3D(vtkRenderWindowInteractor *Interactor, vtkProp3D *Prop)
{
	//static_cast<vtkHULCInteractorStyle *>(Interactor->GetInteractorStyle()) Is how you cast pointers to vtk Object pointers.
	static_cast<vtkHULCInteractorStyle *>(Interactor->GetInteractorStyle())->HighlightProp3D(Prop);
	
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
_declspec(dllexport) void LVvtkActorGetProperties(vtkActor *actor, double *Color, double *Opacity);
}

_declspec(dllexport) void LVvtkActorGetProperties(vtkActor *actor, double *Color, double *Opacity)
{
	vtkProperty *prop = actor->GetProperty();
	
	prop->GetColor(Color);

	*Opacity=prop->GetOpacity();

}


extern "C" {
_declspec(dllexport) void LVvtkActorSetColor(vtkActor *actor, double R, double G, double B);
}

_declspec(dllexport) void LVvtkActorSetColor(vtkActor *actor, double R, double G, double B)
{
	actor->GetProperty()->SetColor(R, G, B);

}


extern "C" {
_declspec(dllexport) void LVvtkActorSetPointSize(vtkActor *actor, float size);
}

_declspec(dllexport) void LVvtkActorSetPointSize(vtkActor *actor, float size)
{
	actor->GetProperty()->SetPointSize(size);

}

extern "C" {
_declspec(dllexport) void LVvtkActorSetDiffuseColor(vtkActor *actor, double R, double G, double B);
}

_declspec(dllexport) void LVvtkActorSetDiffuseColor(vtkActor *actor, double R, double G, double B)
{
	
	actor->GetProperty()->SetDiffuseColor(R, G, B);

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
_declspec(dllexport) void LVvtkActorSetOpacity(vtkActor *actor, double opacity);
}

_declspec(dllexport) void LVvtkActorSetOpacity(vtkActor *actor, double opacity)
{
	
	actor->GetProperty()->SetOpacity(opacity);

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

extern "C" {
_declspec(dllexport) void LVCreatevtkAssembly(vtkAssembly **Assembly);
}

_declspec(dllexport) void LVCreatevtkAssembly(vtkAssembly **Assembly)
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
_declspec(dllexport) long LVvtkAssemblyRemovePart(vtkAssembly *Assembly, vtkActor *Part);
}

_declspec(dllexport) long LVvtkAssemblyRemovePart(vtkAssembly *Assembly, vtkActor *Part)
{
	Assembly->RemovePart(Part);

	return (1);
}

extern "C" {
_declspec(dllexport) vtkProp3DCollection *LVvtkAssemblyGetParts(vtkAssembly *Assembly);
}

_declspec(dllexport) vtkProp3DCollection *LVvtkAssemblyGetParts(vtkAssembly *Assembly)
{
	return Assembly->GetParts();
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
_declspec(dllexport) void LVvtkRenderWindowAddRenderer(vtkRenderWindow *rw, vtkRenderer *ren);
}

_declspec(dllexport) void LVvtkRenderWindowAddRenderer(vtkRenderWindow *rw, vtkRenderer *ren)
{
	rw->AddRenderer(ren);
}

extern "C" {
_declspec(dllexport) vtkRenderer  *LVCreateVtkRenderer();
}

_declspec(dllexport) vtkRenderer  *LVCreateVtkRenderer()
{
	return vtkRenderer::New();
}

extern "C" {
_declspec(dllexport) vtkRenderWindowInteractor *LVCreateVtkInteractor();
}

_declspec(dllexport) vtkRenderWindowInteractor *LVCreateVtkInteractor()
{
	return vtkRenderWindowInteractor::New();
}

extern "C" {
_declspec(dllexport) vtkWin32OpenGLRenderWindow *LVCreateVtkRenderWindow(HWND window, unsigned int width, unsigned int height);
}

_declspec(dllexport) vtkWin32OpenGLRenderWindow *LVCreateVtkRenderWindow(HWND window, unsigned int width, unsigned int height)
{
  vtkWin32OpenGLRenderWindow *renWin = vtkWin32OpenGLRenderWindow::New();
  renWin->SetSize(width, height);
  renWin->SetParentId(window);
  //Matt Pan: For awesome 3D stuff.
  renWin->StereoCapableWindowOn();

  return renWin;
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
	(*SphereSrc)->Update();
	*PolyData = (*SphereSrc)->GetOutput();
}

extern "C" {
_declspec(dllexport) void LVCreateVtkCylinderSource(vtkCylinderSource **CylSrc, vtkPolyData **PolyData, double height, double radius, double resolution);
}

_declspec(dllexport) void LVCreateVtkCylinderSource(vtkCylinderSource **CylSrc, vtkPolyData **PolyData, double height, double radius, double resolution)
{
	*CylSrc= vtkCylinderSource::New();
	(*CylSrc)->SetRadius(radius);
	(*CylSrc)->SetHeight(height);
	(*CylSrc)->SetResolution(resolution);
	(*CylSrc)->Update();
	*PolyData = (*CylSrc)->GetOutput();
	(*PolyData)->Update();	
}

extern "C" {
_declspec(dllexport) void LVCreateVtkConeSource(vtkConeSource **ConeSrc, vtkPolyData **PolyData, double height, double radius, double centrex, double centrey, double centrez, double directionx, double directiony, double directionz,  int capping, int resolution);
}

_declspec(dllexport) void LVCreateVtkConeSource(vtkConeSource **ConeSrc, vtkPolyData **PolyData, double height, double radius, double centrex, double centrey, double centrez, double directionx, double directiony, double directionz,  int capping, int resolution)
{
	*ConeSrc= vtkConeSource::New();
	(*ConeSrc)->SetRadius(radius);
	(*ConeSrc)->SetHeight(height);
	(*ConeSrc)->SetCenter(centrex, centrey, centrez);
	(*ConeSrc)->SetDirection(directionx, directiony, directionz);
	//(*ConeSrc)->SetAngle(angle);
	(*ConeSrc)->SetCapping(capping);
	(*ConeSrc)->SetResolution(resolution);
	*PolyData = (*ConeSrc)->GetOutput();
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
	Mapper->Delete();
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

//Whoops, broke backward compatibility here with some demos.
extern "C" {
_declspec(dllexport) void LVvtkTrackerToolDigitize(vtkTransform *Probe, vtkTransform *Reference, vtkPolyData *PData);
}

_declspec(dllexport) void LVvtkTrackerToolDigitize(vtkTransform *Probe, vtkTransform *Reference, vtkPolyData *PData)
{
	pointmessage.PolyData=0;
	pointmessage.Probe= Probe;
	pointmessage.Reference=Reference;
	pointmessage.PolyData=PData;
}

extern "C" {
_declspec(dllexport) void LVvtkTrackerToolStartCalibration(vtkTrackerTool *tool);
}

_declspec(dllexport) void LVvtkTrackerToolStartCalibration(vtkTrackerTool *tool)
{
	tool->InitializeToolTipCalibration();
}
extern "C" {
_declspec(dllexport) void LVvtkTrackerToolInsertNextCalibrationPoint(vtkTrackerTool *tool);
}

_declspec(dllexport) void LVvtkTrackerToolInsertNextCalibrationPoint(vtkTrackerTool *tool)
{
	tool->InsertNextCalibrationPoint();
}
extern "C" {
_declspec(dllexport) vtkMatrix4x4 *LVvtkTrackerToolDoneCalibration(vtkTrackerTool *tool);
}

_declspec(dllexport) vtkMatrix4x4 *LVvtkTrackerToolDoneCalibration(vtkTrackerTool *tool)
{
	tool->DoToolTipCalibration();
	return tool->GetCalibrationMatrix();
}
extern "C" {
_declspec(dllexport) void LVvtkTrackerToolStopDigitizing();
}

_declspec(dllexport) void LVvtkTrackerToolStopDigitizing()
{

	pointmessage.PolyData=0;
	pointmessage.Probe=0;
	pointmessage.Reference=0;
}
extern "C" {
_declspec(dllexport) int LVvtkPolyDataGetNumberOfPoints(vtkPolyData *PData);
}

_declspec(dllexport) int LVvtkPolyDataGetNumberOfPoints(vtkPolyData *PData)
{

	return PData->GetPoints()->GetNumberOfPoints();
}

extern "C" {
_declspec(dllexport) int LVvtkPointsGetNumberOfPoints(vtkPoints *Points);
}

_declspec(dllexport) int LVvtkPointsGetNumberOfPoints(vtkPoints *Points)
{

	return Points->GetNumberOfPoints();
}

extern "C" {
_declspec(dllexport) vtkPoints *LVvtkPolyDataGetPoints(vtkPolyData *PData);
}

_declspec(dllexport) vtkPoints *LVvtkPolyDataGetPoints(vtkPolyData *PData)
{

	return PData->GetPoints();
}

extern "C" {
_declspec(dllexport) void LVvtkPointsGetPoint (vtkPoints *Points, int i, double *Point);
}

_declspec(dllexport) void LVvtkPointsGetPoint (vtkPoints *Points, int i, double *Point)
{
	double *points = Points->GetPoint(i);
	Point[0] = points[0];
	Point[1] = points[1];
	Point[2] = points[2];
}

extern "C" {
_declspec(dllexport) void LVvtkPointsSetPoint (vtkPoints *Points, int i, double *Point);
}

_declspec(dllexport) void LVvtkPointsSetPoint (vtkPoints *Points, int i, double *Point)
{
	Points->SetPoint(i, Point);
}

extern "C" {
_declspec(dllexport) void LVvtkPolyVertexUpdate(vtkPolyVertex *Pvert, vtkPolyData *PData, vtkPoints *Points);
}

_declspec(dllexport) void LVvtkPolyVertexUpdate(vtkPolyVertex *Pvert, vtkPolyData *PData, vtkPoints *Points)
{
	int size = Points->GetNumberOfPoints();
	(Pvert)->GetPointIds()->SetNumberOfIds(size);
	(PData)->Allocate(1,1);
	(PData)->InsertNextCell((Pvert)->GetCellType(), (Pvert)->GetPointIds());
	for(int i =0; i<size;i++)
		(Pvert)->GetPointIds()->SetId(i,i);
	
//	(PData)->SetPoints(Points);

}

extern "C" {
_declspec(dllexport) void LVvtkActorCollectionGetItem(vtkActorCollection *Collection, vtkActor **Actors, int index);
}

_declspec(dllexport) void LVvtkActorCollectionGetItem(vtkActorCollection *Collection, vtkActor **Actors, int index)
{
	*Actors = static_cast<vtkActor *>(Collection->GetItemAsObject(index));
}


extern "C" {
	_declspec(dllexport) void LVCreateVtkSizedPolyVertex(vtkPolyData **PData, int size);
}

	_declspec(dllexport) void LVCreateVtkSizedPolyVertex(vtkPolyData **PData, int size)
{
	
	vtkPolyVertex *Pvertex = vtkPolyVertex::New();
	*PData = vtkPolyData::New();
	vtkPoints *Points = vtkPoints::New();
	(*PData)->Allocate(1,1);
	(*PData)->InsertNextCell(Pvertex->GetCellType(), Pvertex->GetPointIds());
	(*PData)->SetPoints(Points);
	(*PData)->GetPoints()->GetData()->Resize(size);
	(*PData)->GetVerts()->GetData()->Resize(size);
	
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
	(*PData)->SetPoints(Points);
	(*PData)->Allocate(1,1);
	(*PData)->InsertNextCell((*Pvertex)->GetCellType(), (*Pvertex)->GetPointIds());
/*	(*PData)->GetPoints()->InsertNextPoint(0,0,0);
	(*PData)->GetVerts()->GetData()->InsertNextValue((*PData)->GetVerts()->GetData()->GetValue(0));
	(*PData)->GetVerts()->GetData()->SetValue(0,(*PData)->GetVerts()->GetData()->GetValue(0)+1);*/
}

extern "C" {
_declspec(dllexport) void LVCreateVtkNDITracker(vtkNDITracker **NDITracker);
}

_declspec(dllexport) void LVCreateVtkNDITracker(vtkNDITracker **NDITracker)
{
	*NDITracker = vtkNDITracker::New();

}

//depreciated
extern "C" {
_declspec(dllexport) void LVCreateVtkNDICertusTracker(vtkNDICertusTracker **NDICertusTracker);
}

_declspec(dllexport) void LVCreateVtkNDICertusTracker(vtkNDICertusTracker **NDICertusTracker)
{
	*NDICertusTracker = vtkNDICertusTracker::New();

}


extern "C" {
_declspec(dllexport) void LVCreateVtkFlockTracker(vtkFlockTracker **FlockTracker);
}

_declspec(dllexport) void LVCreateVtkFlockTracker(vtkFlockTracker **FlockTracker)
{
	*FlockTracker = vtkFlockTracker::New();

}

//depreciated
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


//Depreciated
extern "C" {
_declspec(dllexport) void LVvtkTrackerStartTracking(vtkTracker *Tracker);
}

_declspec(dllexport) void LVvtkTrackerStartTracking(vtkTracker *Tracker)
{
	Tracker->StartTracking();
}

//New Tracker start function for IGSTK
extern "C" {
_declspec(dllexport) void LVigstkTrackerStartTracking(igstk::Tracker *Tracker);
}
_declspec(dllexport) void LVigstkTrackerStartTracking(igstk::Tracker *Tracker)
{
	Tracker->RequestStartTracking();
}

extern "C" {
_declspec(dllexport) void LVvtkTrackerStopTracking(vtkTracker *Tracker);
}

_declspec(dllexport) void LVvtkTrackerStopTracking(vtkTracker *Tracker)
{
	Tracker->StopTracking();
}

extern "C" {
_declspec(dllexport) int LVvtkTrackerIsTracking(vtkTracker *Tracker);
}

_declspec(dllexport) int LVvtkTrackerIsTracking(vtkTracker *Tracker)
{
	return Tracker->IsTracking();
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
_declspec(dllexport) void LVvtkProp3DResetUserTransform(vtkProp3D *Prop);
}

_declspec(dllexport) void LVvtkProp3DResetUserTransform(vtkProp3D *Prop)
{
	vtkTransform *xform = vtkTransform::New();
	Prop->SetUserTransform(xform);
}



extern "C" {
_declspec(dllexport) int LVvtkTransformGetNumberOfConcatenatedTransforms(vtkTransform *xform);
}

_declspec(dllexport) int LVvtkTransformGetNumberOfConcatenatedTransforms(vtkTransform *xform)
{
	return xform->GetNumberOfConcatenatedTransforms();
}
extern "C" {
_declspec(dllexport) void LVvtkTransformGetPosition(vtkTransform *xform, double *x);
}

_declspec(dllexport) void LVvtkTransformGetPosition(vtkTransform *xform, double *x)
{
	xform->GetPosition(x);
}

extern "C" {
_declspec(dllexport) vtkMatrix4x4 *LVvtkTransformGetMatrix(vtkTransform *xform);
}
_declspec(dllexport) vtkMatrix4x4 *LVvtkTransformGetMatrix(vtkTransform *xform)
{
	return xform->GetMatrix();
}

extern "C" {
_declspec(dllexport) vtkLinearTransform *LVvtkTransformGetInput(vtkTransform *xform);
}

_declspec(dllexport) vtkLinearTransform *LVvtkTransformGetInput(vtkTransform *xform)
{
	return xform->GetInput();
}

extern "C" {
_declspec(dllexport) vtkMatrix4x4 *LVvtkTransformGetvtkMatrix4x4(vtkTransform *xform);
}

_declspec(dllexport) vtkMatrix4x4 *LVvtkTransformGetvtkMatrix4x4(vtkTransform *xform)
{
	return xform->GetMatrix();
}
 
extern "C" {
_declspec(dllexport) void LVvtkTransformUpdate(vtkTransform *xform);
}

_declspec(dllexport) void LVvtkTransformUpdate(vtkTransform *xform)
{
	 xform->Update();
}

extern "C" {
_declspec(dllexport) vtkTransform* LVCreatevtkTransform();
}

_declspec(dllexport) vtkTransform* LVCreatevtkTransform()
{
	return vtkTransform::New();
}


extern "C" {
_declspec(dllexport) void LVvtkTransformSetMatrix(vtkTransform *xform, vtkMatrix4x4 *mat);
}

_declspec(dllexport) void LVvtkTransformSetMatrix(vtkTransform *xform, vtkMatrix4x4 *mat)
{
	xform->SetMatrix(mat);
}


//Note: This function does not work
extern "C" {
_declspec(dllexport) void LVvtkTransformGetPoint(vtkTransform *xform, double *x, double *y, double *z);
}
//Note: This function does not work
_declspec(dllexport) void LVvtkTransformGetPoint(vtkTransform *xform, double *x, double *y, double *z)
{
	*x = xform->GetMatrix()->GetElement(0,3);
	*y = xform->GetMatrix()->GetElement(1,3);
	*z = xform->GetMatrix()->GetElement(2,3);
}

extern "C" {
_declspec(dllexport) void LVvtkProp3DCoordinateTransform(vtkProp3D *Prop, vtkTransform *Transform);
}
_declspec(dllexport) void LVvtkProp3DCoordinateTransform(vtkProp3D *Prop, vtkTransform *Transform)
{
if (!( (Prop->GetUserTransform()) && (strcmp(Prop->GetUserTransform()->GetClassName(), "vtkTransform")==0) && (((vtkTransform *)Prop->GetUserTransform())->GetNumberOfConcatenatedTransforms ()==3)))
	{
		ofstream myFile;
			myFile.open("C:\\Users\\HMMS\\Documents\\Coordrxformtest.txt", std::ios::app);
		myFile << 1 << "\n";
		myFile.close();
		vtkTransform *xform = vtkTransform::New();
		vtkTransform *OffsetTransform = vtkTransform::New();
		vtkTransform *TrackerTransform = vtkTransform::New();
		vtkTransform *CoordinateTransform= vtkTransform::New();

	
		CoordinateTransform->SetInverse(Transform);

		xform->Concatenate(CoordinateTransform);		
		xform->Concatenate(TrackerTransform);				
		xform->Concatenate(OffsetTransform);

		Prop->SetUserTransform(xform);
			
	}
	else
	{
		((vtkTransform*)((vtkTransform*)Prop->GetUserTransform())->GetConcatenatedTransform(2))->SetInverse(Transform);
		ofstream myFile;
			myFile.open("C:\\Users\\HMMS\\Documents\\Coordrxformtest.txt", std::ios::app);
		myFile << 2 << "\n";
		myFile.close();
	}
}

extern "C" {
_declspec(dllexport) void LVvtkProp3DSetOffsetTransform(vtkProp3D *Prop, vtkTransform *Transform);
}

_declspec(dllexport) void LVvtkProp3DSetOffsetTransform(vtkProp3D *Prop, vtkTransform *Transform)
{
	if (!( (Prop->GetUserTransform()) && (strcmp(Prop->GetUserTransform()->GetClassName(), "vtkTransform")==0) && (((vtkTransform *)Prop->GetUserTransform())->GetNumberOfConcatenatedTransforms ()==3)))
	{
			ofstream myFile;
			myFile.open("C:\\Users\\HMMS\\Documents\\Offsetxformtest.txt", std::ios::app);
		myFile << 1 << "\n";
		myFile.close();
		vtkTransform *xform = vtkTransform::New();
		vtkTransform *OffsetTransform = vtkTransform::New();
		vtkTransform *TrackerTransform = vtkTransform::New();
		vtkTransform *CoordinateTransform= vtkTransform::New();

		OffsetTransform->SetInput(Transform);

		xform->Concatenate(CoordinateTransform);
		xform->Concatenate(TrackerTransform);		
		xform->Concatenate(OffsetTransform);


		Prop->SetUserTransform(xform);
	
	}
	else
	{
		((vtkTransform*)((vtkTransform*)Prop->GetUserTransform())->GetConcatenatedTransform(0))->SetInput(Transform);
		ofstream myFile;
			myFile.open("C:\\Users\\HMMS\\Documents\\Offsetxformtest.txt", std::ios::app);
		myFile << 2 << "\n";
		myFile.close();
	}
}

extern "C" {
_declspec(dllexport) void LVvtkProp3DSetTrackerTransform(vtkProp3D *Prop, vtkTransform *Transform);
}

_declspec(dllexport) void LVvtkProp3DSetTrackerTransform(vtkProp3D *Prop, vtkTransform *Transform)
{
	if (!( (Prop->GetUserTransform()) && (strcmp(Prop->GetUserTransform()->GetClassName(), "vtkTransform")==0) && (((vtkTransform *)Prop->GetUserTransform())->GetNumberOfConcatenatedTransforms ()==3)))
	{
			ofstream myFile;
		myFile.open("C:\\Users\\HMMS\\Documents\\Trackerxformtest.txt", std::ios::app);
		myFile << 1 << "\n";
		myFile.close();

		vtkTransform *xform = vtkTransform::New();
		vtkTransform *OffsetTransform = vtkTransform::New();
		vtkTransform *TrackerTransform = vtkTransform::New();
		vtkTransform *CoordinateTransform= vtkTransform::New();

	

		xform->Concatenate(OffsetTransform);
		xform->Concatenate(TrackerTransform);
		xform->Concatenate(CoordinateTransform);		

		Prop->SetUserTransform(xform);
	}
	else
	{
		((vtkTransform*)((vtkTransform*)Prop->GetUserTransform())->GetConcatenatedTransform(1))->SetInput(Transform);
		ofstream myFile;
			myFile.open("C:\\Users\\HMMS\\Documents\\Trackerxformtest.txt", std::ios::app);
		myFile << 2 << "\n";
		myFile.close();
	}
	
}

extern "C" {
_declspec(dllexport) vtkTransform *LVvtkProp3DGetTrackerTransform(vtkProp3D *Prop);
}

_declspec(dllexport) vtkTransform *LVvtkProp3DGetTrackerTransform(vtkProp3D *Prop)
{
	if (!( (Prop->GetUserTransform()) && (strcmp(Prop->GetUserTransform()->GetClassName(), "vtkTransform")==0) && (((vtkTransform *)Prop->GetUserTransform())->GetNumberOfConcatenatedTransforms ()==3)))
		return 0;
	return ((vtkTransform*)((vtkTransform*)Prop->GetUserTransform())->GetConcatenatedTransform(1));
}


extern "C" {
_declspec(dllexport) vtkTransform *LVvtkProp3DGetOffsetTransform(vtkProp3D *Prop);
}

_declspec(dllexport) vtkTransform *LVvtkProp3DGetOffsetTransform(vtkProp3D *Prop)
{
	if (!( (Prop->GetUserTransform()) && (strcmp(Prop->GetUserTransform()->GetClassName(), "vtkTransform")==0) && (((vtkTransform *)Prop->GetUserTransform())->GetNumberOfConcatenatedTransforms ()==3)))
		return 0;
	return ((vtkTransform*)((vtkTransform*)Prop->GetUserTransform())->GetConcatenatedTransform(0));
}

extern "C" { 
_declspec(dllexport) vtkTransform *LVvtkProp3DGetCoordinateTransform(vtkProp3D *Prop);
}

_declspec(dllexport) vtkTransform *LVvtkProp3DGetCoordinateTransform(vtkProp3D *Prop)
{
	if (!( (Prop->GetUserTransform()) && (strcmp(Prop->GetUserTransform()->GetClassName(), "vtkTransform")==0) && (((vtkTransform *)Prop->GetUserTransform())->GetNumberOfConcatenatedTransforms ()==3)))
		return 0;
	return ((vtkTransform*)((vtkTransform*)Prop->GetUserTransform())->GetConcatenatedTransform(2));
}

extern "C" {
_declspec(dllexport) vtkMatrix4x4 *LVvtkProp3DGetUserMatrix(vtkProp3D *Prop);
}

_declspec(dllexport) vtkMatrix4x4 *LVvtkProp3DGetUserMatrix(vtkProp3D *Prop)
{
//	return Prop->GetUserTransform()->Pop();
	return Prop->GetUserMatrix();
}

extern "C" {
_declspec(dllexport) vtkLinearTransform *LVvtkProp3DGetUserTransform(vtkProp3D *Prop);
}

_declspec(dllexport) vtkLinearTransform *LVvtkProp3DGetUserTransform(vtkProp3D *Prop)
{
	return Prop->GetUserTransform();
}

extern "C" {
_declspec(dllexport) vtkLandmarkTransform *LVCreateVtkLandmarkTransform();
}

_declspec(dllexport) vtkLandmarkTransform *LVCreateVtkLandmarkTransform()
{
	return vtkLandmarkTransform::New();
}

extern "C" {
_declspec(dllexport) void LVvtkLandmarkTransformSetSourceLandmarks(vtkLandmarkTransform *xform, vtkPoints *source);
}

_declspec(dllexport) void LVvtkLandmarkTransformSetSourceLandmarks(vtkLandmarkTransform *xform, vtkPoints *source)
{
	xform->SetSourceLandmarks(source);
	source->Modified();
}

extern "C" {
_declspec(dllexport) void LVvtkLandmarkTransformSetTargetLandmarks(vtkLandmarkTransform *xform, vtkPoints *target);
}

_declspec(dllexport) void LVvtkLandmarkTransformSetTargetLandmarks(vtkLandmarkTransform *xform, vtkPoints *target)
{
	xform->SetTargetLandmarks(target);
	target->Modified();
}

extern "C" {
_declspec(dllexport) void LVvtkLandmarkTransformSetModeToRigidBody(vtkLandmarkTransform *xform);
}

_declspec(dllexport) void LVvtkLandmarkTransformSetModeToRigidBody(vtkLandmarkTransform *xform)
{
	xform->SetModeToRigidBody();
}

extern "C" {
_declspec(dllexport) void LVvtkLandmarkTransformUpdate(vtkLandmarkTransform *xform);
}

_declspec(dllexport) void LVvtkLandmarkTransformUpdate(vtkLandmarkTransform *xform)
{
	xform->Update();
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
_declspec(dllexport) void LVvtkTrackerLockMutex(vtkTracker *Tracker);
}

_declspec(dllexport) void LVvtkTrackerLockMutex(vtkTracker *Tracker)
{
	Tracker->UpdateMutex->Lock();
}
extern "C" {
_declspec(dllexport) void LVvtkTrackerUnlockMutex(vtkTracker *Tracker);
}

_declspec(dllexport) void LVvtkTrackerUnlockMutex(vtkTracker *Tracker)
{
	Tracker->UpdateMutex->Unlock();
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
_declspec(dllexport) void LVvtkNDITrackerEnableDisablePort(vtkNDITracker *Tracker, int tool, int state);
}

_declspec(dllexport) void LVvtkNDITrackerEnableDisablePort(vtkNDITracker *Tracker, int tool, int state)
{
	Tracker->EnableDisable(tool,state);
}

extern "C" {
_declspec(dllexport) int LVvtkNDITrackerGetEnabled(vtkNDITracker *Tracker, int tool);
}

_declspec(dllexport) int LVvtkNDITrackerGetEnabled(vtkNDITracker *Tracker, int tool)
{
//	Tracker->StartTracking();
//	Sleep(50);
	int enabled = Tracker->GetEnabled(tool);
//	Tracker->StopTracking();
	return enabled;
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
_declspec(dllexport) vtkMatrix4x4 *LVvtkTrackerToolGetCalibrationMatrix(vtkTrackerTool *tool);
}

_declspec(dllexport) vtkMatrix4x4 *LVvtkTrackerToolGetCalibrationMatrix(vtkTrackerTool *tool)
{
    return tool->GetCalibrationMatrix();
}

//Set TMatrix pointer=0 to not deepcopy
extern "C" {
_declspec(dllexport) void LVvtkTrackerSetWorldCalibrationMatrix(vtkTracker *Tracker, vtkMatrix4x4 *Matrix, double TMatrix[]);
}

_declspec(dllexport) void LVvtkTrackerSetWorldCalibrationMatrix(vtkTracker *Tracker, vtkMatrix4x4 *Matrix, double TMatrix[])
{
	if (TMatrix!=0)
	{
		Matrix->DeepCopy(TMatrix);
	}
    Tracker->SetWorldCalibrationMatrix(Matrix);
}

extern "C" {
_declspec(dllexport) vtkMatrix4x4 *LVvtkTrackerGetWorldCalibrationMatrix(vtkTracker *Tracker);
}

_declspec(dllexport) vtkMatrix4x4 *LVvtkTrackerGetWorldCalibrationMatrix(vtkTracker *Tracker)
{
	return Tracker->GetWorldCalibrationMatrix();
}

//Return 0 if flock, returns 1 if NDI Tracker, returns 2 if it's something else;
extern "C" {
_declspec(dllexport) void LVvtkTrackerWhatsIt(vtkTracker *Tracker, char *classname);
}

_declspec(dllexport) void LVvtkTrackerWhatsIt(vtkTracker *Tracker, char *classname)
{
	memcpy(classname,Tracker->GetClassName(),strlen(Tracker->GetClassName())*sizeof(char));
}

extern "C" {
_declspec(dllexport) void LVvtkObjectWhatsIt(vtkObject *Object, char *classname);
}

_declspec(dllexport) void LVvtkObjectWhatsIt(vtkObject *Object, char *classname)
{
	memcpy(classname,Object->GetClassName(),strlen(Object->GetClassName())*sizeof(char));
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
	ren->GetActiveCamera()->SetPosition(0,0,0);
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
          return (path->GetFirstNode()->GetViewProp());
          }
}

extern "C" {
_declspec(dllexport) void LVvtkRenderWindowStartPick(vtkRenderWindow *rw);
}

_declspec(dllexport) void LVvtkRenderWindowStartPick(vtkRenderWindow *rw)
{	
	((vtkHULCInteractorStyle * ) rw->GetInteractor()->GetInteractorStyle())->SetlvVTKMessage(PICK);
}

extern "C" {
_declspec(dllexport) void LVvtkSetFileErrorOutput();
}

_declspec(dllexport) void LVvtkSetFileErrorOutput()
{	
	vtkFileOutputWindow *fileout = vtkFileOutputWindow::New();
	fileout->SetFileName ("C:\\vtkLabviewFileOutputWindow.log");
	fileout->SetInstance(fileout);
}

/* Example of Using vtkObjectFactory inside this DLL to override a class.. **sniffle, it's beautiful

class  vtkFileErrorOutput: public vtkOutputWindow {
public:
  vtkFileErrorOutput();
  virtual void DisplayText(const char*);
  virtual void PrintSelf(ostream& os, vtkIndent indent);
  static vtkFileErrorOutput* New() { return new vtkFileErrorOutput;}
};

class vtkFileErrorOutputFactory : public vtkObjectFactory
{
public:
  vtkFileErrorOutputFactory();
  virtual const char* GetVTKSourceVersion();
  virtual const char* GetDescription();
};
VTK_CREATE_CREATE_FUNCTION(vtkFileErrorOutput);

vtkFileErrorOutputFactory::vtkFileErrorOutputFactory()
{
   this->RegisterOverride("vtkOutputWindow",
			  "vtkFileErrorOutputFactory()",
			  "FileOutput",
			  1,
			  vtkObjectFactoryCreatevtkFileErrorOutput);
}
const char* vtkFileErrorOutputFactory::GetVTKSourceVersion()
{
  return VTK_SOURCE_VERSION;
}

const char* vtkFileErrorOutputFactory::GetDescription()
{
  return "vtk debug output to Word via OLE factory";
}

void vtkFileErrorOutput::PrintSelf(ostream& os, vtkIndent indent)
{
   vtkOutputWindow::PrintSelf(os, indent);
   os << indent <<  "vtkFileErrorOutput" << endl;
}
vtkFileErrorOutput::vtkFileErrorOutput()
{ 

}

void vtkFileErrorOutput::DisplayText(const char* text)
{
   FILE *file = fopen("C:\\Allfile\\Utsav\\DebugLog.txt","a+");
   fprintf(file, text);
   fclose(file);;
}

extern "C" {
_declspec(dllexport) void Test();
}

_declspec(dllexport) void Test()
{	
	vtkFileErrorOutputFactory *a = new vtkFileErrorOutputFactory;
	vtkObjectFactory::RegisterFactory(a);
}
*/
//////////////////////////////////////////////////////////////////////////////////////
////////                                                                      ////////
////////                           IGSTK Functions                            ////////
////////                         Jordan O'Brien 2017                          ////////
////////                                                                      ////////
//////////////////////////////////////////////////////////////////////////////////////

///////CERTUS FUNCTIONS//////


//Initializes the Certus Tracker throiugh the Optotrak ini file and how many rigid bodies will be used
extern "C" {
_declspec(dllexport) void LVigstkNDICertusTrackerInit( char* iniPath, int numberOfRigidBodies);
}

_declspec(dllexport) void LVigstkNDICertusTrackerInit( char* iniPath, int numberOfRigidBodies)
{
	NDICertusTracker = igstk::NDICertusTracker::New();
	NDICertusTracker->SetIniFileName(iniPath);
	NDICertusTracker->rigidBodyStatus.lnRigidBodies = numberOfRigidBodies;

}

//Configures the rigid body by giving the start marker, number of markers and the rigid body file
extern "C" {
_declspec(dllexport) void LVigstkConfigRigidBodiesNDI( int rigidBodyNumber, int startMarker, int numOfMarkers, char* rigidBodyFile);
}

_declspec(dllexport) void LVigstkConfigRigidBodiesNDI( int rigidBodyNumber, int startMarker, int numOfMarkers, char* rigidBodyFile)
{
	NDICertusTracker->rigidBodyDescrArray[rigidBodyNumber].lnStartMarker = startMarker;
	NDICertusTracker->rigidBodyDescrArray[rigidBodyNumber].lnNumberOfMarkers = numOfMarkers;
	strcpy(NDICertusTracker->rigidBodyDescrArray[rigidBodyNumber].szName, rigidBodyFile);
}

//Begind Communication with the Certus. When this function is called the Certus should beep
extern "C" {
_declspec(dllexport) void LVigstkStartCommunicationNDI();
}

_declspec(dllexport) void LVigstkStartCommunicationNDI()
{
	NDICertusTracker->RequestOpen();
}

//Creates however many Certus Tracker Tools that are being used
extern "C" {
_declspec(dllexport) void LVCreateigstkNDITrackerTool(int numberOfTools);
}

_declspec(dllexport) void LVCreateigstkNDITrackerTool(int numberOfTools)
{
	for( int i =1; i < numberOfTools+1; i++)
	{
		NDICertusTrackerTool[i] = igstk::NDICertusTrackerTool::New();
	}
}

//Configures the Certus Traker Tool by setting the rigid body name from the file, and attaching it to the tracker. 
//Also creates a coordante system observer to observe events for the tracker, and creates a new VTK Transform for the tracker.
extern "C" {
_declspec(dllexport) void LVigstkNDITrackerToolConfig(int toolIndex, char* rigidBodyFile);
}

_declspec(dllexport) void LVigstkNDITrackerToolConfig(int toolIndex, char* rigidBodyFile)
{
	NDICertusTrackerTool[toolIndex] = igstk::NDICertusTrackerTool::New();
	NDICertusTrackerTool[toolIndex]->RequestSetRigidBodyName(rigidBodyFile);
	NDICertusTrackerTool[toolIndex]->RequestConfigure();
	NDICertusTrackerTool[toolIndex]->RequestAttachToTracker(NDICertusTracker);

	coordSystemObserver[toolIndex] = igstk::TransformObserver::New();
	coordSystemObserver[toolIndex]->ObserveTransformEventsFrom( NDICertusTrackerTool[toolIndex] );

	vtkTransHolder[toolIndex] = vtkTransform::New();
}

//Begins tracking for the Certus
extern "C" {
_declspec(dllexport) void LVigstkStartTrackingNDI();
}

_declspec(dllexport) void LVigstkStartTrackingNDI()
{
	NDICertusTracker->RequestStartTracking();
}

void igstkTransformThread(void *arglist);

//Gets the position of the Certus tracker and outputs a position array. Also creates a vtk Transform for the renderer
extern "C" {
_declspec(dllexport) void LVigstkStartTransformThread(int *numberOfTools,int *Period, unsigned int *xFormPerID, unsigned int arg[]);
}

_declspec(dllexport) void LVigstkStartTransformThread(int *numberOfTools, int *Period, unsigned int *xFormPerID, unsigned int arg[])
{
	arg[0] = (unsigned int) numberOfTools;
	arg[1] = (unsigned int) Period;
	*xFormPerID = (unsigned int) Period;
	lock =0;
	_beginthread(igstkTransformThread,0,(void *) arg);
}

void igstkTransformThread(void *arglist)
{
	igstk::Transform transform;
	vtkMatrix4x4 *vtkMatrix = vtkMatrix->New();	

	unsigned int *arg = (unsigned int *) arglist;

	int numberOfTools = (*(int *)  arg[0]);
	

	while(1)
	{
		int period = (*(int *) arg[1]);
		if (period > 0)
		{
			for (int i=1; i<numberOfTools+1;i++)
			{
				igstk::PulseGenerator::CheckTimeouts();
				coordSystemObserver[i]->Clear();
				NDICertusTrackerTool[i]->RequestGetTransformToParent();

				if(coordSystemObserver[i]->GotTransform())
				{
					transform = coordSystemObserver[i]->GetTransform();
					if(transform.IsValidNow())
					{
						transform.ExportTransform(*vtkMatrix);
					}
					else 
					{	 
						vtkMatrix->SetElement(0,0,-1);
					}

				}
				else 
				{ 
					vtkMatrix->SetElement(0,0,-2);
				}
				if (lock ==0)
				{
					lock =1;
					vtkTransHolder[i]->SetMatrix(vtkMatrix);
					lock =0;
				}
			}
			Sleep(50);
		}
		else
		{
				_endthread();
				break;
	
		}
	}

}

extern "C" {
_declspec(dllexport) void LVigstkStopTransformThread(unsigned int xFormPerID);
}
_declspec(dllexport) void LVigstkStopTransformThread(unsigned int xFormPerID)
{

	*((int *)(xFormPerID))  = abs(*((int *)(xFormPerID)))*-1;
}

extern "C" {
_declspec(dllexport) void LVigstkGetTrackerLocation(int toolIndex, double *loactionArray);
}

_declspec(dllexport) void LVigstkGetTrackerLocation(int toolIndex, double *locationArray)
{
	ofstream myFile;
	vtkMatrix4x4 *vtkMatrix = vtkMatrix->New();

	//checks if the vtkTransHolder[index] is currently being used in the vtkTransform Thread
	//used to prevent a race condition
	if (lock == 0)
	{
		//if it is not locked then lock it
		lock=1;
		vtkMatrix = vtkTransHolder[toolIndex]->GetMatrix();
		//unlock it once the vtkTransHolder is done being used
		lock=0;
		int k=0;
		for (int i =0; i<4; i++)
		{
			for (int j=0; j<4; j++)
			{
			
				locationArray[k] = vtkMatrix->GetElement(i,j);
				k++;
			}
		}
	}	
}
//Prints a vtkTransform. Was used for testing and may be usefull
extern "C" {
_declspec(dllexport) void printVtkTransform(vtkTransform *vtkTrans);
}

_declspec(dllexport) void printVtkTransform(vtkTransform *vtkTrans)
{
	ofstream myFile;

	myFile.open("C:\\Users\\HMMS\\Documents\\test.txt");
	myFile << *vtkTrans << "\n";
	myFile.close();
}

//Gets the VTK transform for the tracker. Is used for the renderer
extern "C" {
_declspec(dllexport) void LvigstkGetVTKTransform(int toolIndex, vtkTransform **vtkTrans);
}

_declspec(dllexport) void LvigstkGetVTKTransform(int toolIndex, vtkTransform **vtkTrans)
{
	*vtkTrans = vtkTransHolder[toolIndex];

}

//Stops tracking the Certus
extern "C" {
_declspec(dllexport) void LVigstkStopTrackingNDI();
}

_declspec(dllexport) void LVigstkStopTrackingNDI()
{
	NDICertusTracker->RequestStopTracking();
}

//Ends communication. Must be done other wise the next time it tries to connect to the Certus it will error
extern "C" {
_declspec(dllexport) void LVigstkEndCommunicationNDI();
}

_declspec(dllexport) void LVigstkEndCommunicationNDI()
{
	NDICertusTracker->RequestClose();
	//delete vtkTransHolder;
}

extern "C" {
_declspec(dllexport) void LVigstkClear(int numberOfTools);
}

_declspec(dllexport) void LVigstkClear(int numberOfTools)
{
	for (int i =1; i < numberOfTools+1; i++)
	{
		NDICertusTrackerTool[i]->Delete();
		coordSystemObserver[i]->Delete();
		vtkTransHolder[i]->Delete();
	}
}
