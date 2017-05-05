cmake_minimum_required(VERSION 2.4)
PROJECT (LVvtkwrap)

INCLUDE (${CMAKE_ROOT}/Modules/FindVTK.cmake)
IF (USE_VTK_FILE)
  INCLUDE(${USE_VTK_FILE})
ENDIF (USE_VTK_FILE)

ADD_LIBRARY(lvvtkwrap2 SHARED lvvtkwrap.cxx)
TARGET_LINK_LIBRARIES(lvvtkwrap2 vtkRendering vtkAtamaiTracking vtkHybrid)
