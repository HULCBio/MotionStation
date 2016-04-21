'================================================================================== GFXT_PRO.INC

'module: Graphics Tools Pro declarations needed for use of GfxT_Pro.DLL
'
'This file Copyright (C) 2002, Perfect Sync, Inc. All Rights Reserved.
'Graphics Tools Copyright (C) 1999-2002, Perfect Sync, Inc. All Rights Reserved.

'----------------------------------------------------------------------------
'TODO: BEFORE YOU CAN USE GRAPHICS TOOLS FOR THE FIRST TIME YOU WILL NEED TO
'ENTER YOUR GRAPHICS TOOLS AUTHORIZATION CODE WHERE YOU SEE THE 8 DOTS:
%MY_GFXT_AUTHCODE = &hCA1BE934
'----------------------------------------------------------------------------

TYPE GRADIENT_PARAMETERS
     lGradientType AS LONG
     lFillType     AS LONG
     lAngle        AS LONG
     lTexture      AS LONG
     lTextureStart AS LONG
     lReserved5    AS LONG
     lReserved6    AS LONG
     lReserved7    AS LONG
     lReserved8    AS LONG
     lReserved9    AS LONG
     lReservedA    AS LONG
     lReservedB    AS LONG
     lReservedC    AS LONG
     lReservedD    AS LONG
     lReservedE    AS LONG
     lReservedF    AS LONG
END TYPE

TYPE GRADIENT_ELEMENT
     lMin          AS LONG
     lMax          AS LONG
     lStart        AS LONG
     lRate         AS LONG
     lOptions      AS LONG
     lOffset       AS LONG
     lTexture      AS LONG
     lCutOff       AS LONG
     lReserved8    AS LONG
     lReserved9    AS LONG
     lReservedA    AS LONG
     lReservedB    AS LONG
     lReservedC    AS LONG
     lReservedD    AS LONG
     lReservedE    AS LONG
     lReservedF    AS LONG
END TYPE

TYPE GT_HSW_GRADIENT
     Gradient       AS GRADIENT_PARAMETERS
     Hue            AS GRADIENT_ELEMENT
     Saturation     AS GRADIENT_ELEMENT
     Whiteness      AS GRADIENT_ELEMENT
END TYPE

TYPE GT_RGB_GRADIENT
     Gradient       AS GRADIENT_PARAMETERS
     Red            AS GRADIENT_ELEMENT
     Green          AS GRADIENT_ELEMENT
     Blue           AS GRADIENT_ELEMENT
END TYPE

TYPE GT_XYZ_GRADIENT
     Gradient      AS GRADIENT_PARAMETERS
     X             AS GRADIENT_ELEMENT
     Y             AS GRADIENT_ELEMENT
     Z             AS GRADIENT_ELEMENT
END TYPE

UNION GT_GRADIENT
     HSWGradient   AS GT_HSW_GRADIENT
     RGBGradient   AS GT_RGB_GRADIENT
     XYZGradient   AS GT_XYZ_GRADIENT
END UNION

DECLARE FUNCTION ActualColor              LIB "GfxT_Pro.DLL"            ALIAS "ActualColor"           (BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION ActualColorEx            LIB "GfxT_Pro.DLL"            ALIAS "ActualColorEx"         (BYVAL lWindowNumber AS LONG, BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION AnimateCursor            LIB "GfxT_Pro.DLL"            ALIAS "AnimateCursor"         (BYVAL sCursor AS STRING, BYVAL lFrame AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION AnimateCursorEx          LIB "GfxT_Pro.DLL"            ALIAS "AnimateCursorEx"       (BYVAL lWindowNumber AS LONG, BYVAL sCursor AS STRING, BYVAL lFrame AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION AnimateIcon              LIB "GfxT_Pro.DLL"            ALIAS "AnimateIcon"           (BYVAL sIcon AS STRING, BYVAL lFrame AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION AnimateIconEx            LIB "GfxT_Pro.DLL"            ALIAS "AnimateIconEx"         (BYVAL lWindowNumber AS LONG, BYVAL sIcon AS STRING, BYVAL lFrame AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION AutoPlayControl          LIB "GfxT_Pro.DLL"            ALIAS "AutoPlayControl"       (BYVAL lNumber AS LONG, BYVAL lAction AS LONG) AS LONG
DECLARE FUNCTION AutoPlayControlEx        LIB "GfxT_Pro.DLL"            ALIAS "AutoPlayControlEx"     (BYVAL lWindowNumber AS LONG, BYVAL lNumber AS LONG, BYVAL lAction AS LONG) AS LONG
DECLARE FUNCTION AutoPlayCursor           LIB "GfxT_Pro.DLL"            ALIAS "AutoPlayCursor"        (BYVAL lNumber AS LONG, BYVAL sCursor AS STRING, BYVAL lFrame AS LONG, _
                                                                                                       BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lInitState AS LONG) AS LONG
DECLARE FUNCTION AutoPlayCursorEx         LIB "GfxT_Pro.DLL"            ALIAS "AutoPlayCursorEx"      (BYVAL lWindowNumber AS LONG, BYVAL lNumber AS LONG, BYVAL sCursor AS STRING, BYVAL lFrame AS LONG, _
                                                                                                       BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lInitState AS LONG) AS LONG
DECLARE FUNCTION AutoPlayIcon             LIB "GfxT_Pro.DLL"            ALIAS "AutoPlayIcon"          (BYVAL lNumber AS LONG, BYVAL sIcon AS STRING, BYVAL lFrame AS LONG, _
                                                                                                       BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lInitState AS LONG) AS LONG
DECLARE FUNCTION AutoPlayIconEx           LIB "GfxT_Pro.DLL"            ALIAS "AutoPlayIconEx"        (BYVAL lWindowNumber AS LONG, BYVAL lNumber AS LONG, BYVAL sIcon AS STRING, BYVAL lFrame AS LONG, _
                                                                                                       BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lInitState AS LONG) AS LONG
DECLARE FUNCTION BitmapParam              LIB "GfxT_Pro.DLL"            ALIAS "BitmapParam"           (BYVAL sBitmap AS STRING, BYVAL lInfoType AS LONG) AS LONG
DECLARE FUNCTION BlueValue                LIB "GfxT_Pro.DLL"            ALIAS "BlueValue"             (BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION Brush                    LIB "GfxT_Pro.DLL"            ALIAS "Brush"                 (BYVAL lColor AS LONG, BYVAL lStyle AS LONG, BYVAL lHatch AS LONG) AS LONG
DECLARE FUNCTION BrushEx                  LIB "GfxT_Pro.DLL"            ALIAS "BrushEx"               (BYVAL lWindowNumber AS LONG, BYVAL lColor AS LONG, BYVAL lStyle AS LONG, BYVAL lHatch AS LONG) AS LONG
DECLARE FUNCTION BrushBitmap              LIB "GfxT_Pro.DLL"            ALIAS "BrushBitmap"           (BYVAL sBitmap AS STRING) AS LONG
DECLARE FUNCTION BrushBitmapEx            LIB "GfxT_Pro.DLL"            ALIAS "BrushBitmapEx"         (BYVAL lWindowNumber AS LONG, BYVAL sBitmap AS STRING) AS LONG
DECLARE FUNCTION BrushColor               LIB "GfxT_Pro.DLL"            ALIAS "BrushColor"            (BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION BrushColorEx             LIB "GfxT_Pro.DLL"            ALIAS "BrushColorEx"          (BYVAL lWindowNumber AS LONG, BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION BrushHatch               LIB "GfxT_Pro.DLL"            ALIAS "BrushHatch"            (BYVAL lHatch AS LONG) AS LONG
DECLARE FUNCTION BrushHatchEx             LIB "GfxT_Pro.DLL"            ALIAS "BrushHatchEx"          (BYVAL lWindowNumber AS LONG, BYVAL lHatch AS LONG) AS LONG
DECLARE FUNCTION BrushStyle               LIB "GfxT_Pro.DLL"            ALIAS "BrushStyle"            (BYVAL lStyle AS LONG) AS LONG
DECLARE FUNCTION BrushStyleEx             LIB "GfxT_Pro.DLL"            ALIAS "BrushStyleEx"          (BYVAL lWindowNumber AS LONG, BYVAL lStyle AS LONG) AS LONG
DECLARE FUNCTION CalcPoint                LIB "GfxT_Pro.DLL"            ALIAS "CalcPoint"             (BYREF lXPos AS LONG, BYREF lYPos AS LONG, BYVAL dpAngle AS DOUBLE, BYVAL lDistance AS LONG) AS LONG
DECLARE FUNCTION CalcPointEx              LIB "GfxT_Pro.DLL"            ALIAS "CalcPointEx"           (BYVAL lWindowNumber AS LONG, BYREF lXPos AS LONG, BYREF lYPos AS LONG, BYVAL dpAngle AS DOUBLE, BYVAL lDistance AS LONG) AS LONG
DECLARE FUNCTION CropBitmap               LIB "GfxT_Pro.DLL"            ALIAS "CropBitmap"            (BYVAL sBitmap AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, _
                                                                                                       BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION CropBitmapEx             LIB "GfxT_Pro.DLL"            ALIAS "CropBitmapEx"          (BYVAL lWindowNumber AS LONG, BYVAL sBitmap AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, _
                                                                                                       BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION CropJpeg                 LIB "GfxT_Pro.DLL"            ALIAS "CropJpeg"              (BYVAL sFileName AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, _
                                                                                                       BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION CropJpegEx               LIB "GfxT_Pro.DLL"            ALIAS "CropJpegEx"            (BYVAL lWindowNumber AS LONG, BYVAL sFileName AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, _
                                                                                                       BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION CropWindow               LIB "GfxT_Pro.DLL"            ALIAS "CropWindow"            (BYVAL lSourceWindow AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, _
                                                                                                       BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION CropWindowEx             LIB "GfxT_Pro.DLL"            ALIAS "CropWindowEx"          (BYVAL lWindowNumber AS LONG, BYVAL lSourceWindow AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, _
                                                                                                       BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION CursorParam              LIB "GfxT_Pro.DLL"            ALIAS "CursorParam"           (BYVAL sCursor AS STRING, BYVAL lInfoType AS LONG) AS LONG
DECLARE FUNCTION CustomColor              LIB "GfxT_Pro.DLL"            ALIAS "CustomColor"           (BYVAL lNumber AS LONG, BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION DisplayBitmap            LIB "GfxT_Pro.DLL"            ALIAS "DisplayBitmap"         (BYVAL sBitmap AS STRING) AS LONG
DECLARE FUNCTION DisplayBitmapEx          LIB "GfxT_Pro.DLL"            ALIAS "DisplayBitmapEx"       (BYVAL lWindowNumber AS LONG, BYVAL sBitmap AS STRING) AS LONG
DECLARE FUNCTION DisplayCursor            LIB "GfxT_Pro.DLL"            ALIAS "DisplayCursor"         (BYVAL sCursor AS STRING) AS LONG
DECLARE FUNCTION DisplayCursorEx          LIB "GfxT_Pro.DLL"            ALIAS "DisplayCursorEx"       (BYVAL lWindowNumber AS LONG, BYVAL sCursor AS STRING) AS LONG
DECLARE FUNCTION DisplayIcon              LIB "GfxT_Pro.DLL"            ALIAS "DisplayIcon"           (BYVAL sIcon AS STRING) AS LONG
DECLARE FUNCTION DisplayIconEx            LIB "GfxT_Pro.DLL"            ALIAS "DisplayIconEx"         (BYVAL lWindowNumber AS LONG, BYVAL sIcon AS STRING) AS LONG
DECLARE FUNCTION DisplayImage             LIB "GfxT_Pro.DLL"            ALIAS "DisplayImage"          (BYVAL sFileName AS STRING) AS LONG
DECLARE FUNCTION DisplayImageEx           LIB "GfxT_Pro.DLL"            ALIAS "DisplayImageEx"        (BYVAL lWindowNumber AS LONG, BYVAL sFileName AS STRING) AS LONG
DECLARE FUNCTION DisplayJpeg              LIB "GfxT_Pro.DLL"            ALIAS "DisplayJpeg"           (BYVAL sFileName AS STRING) AS LONG
DECLARE FUNCTION DisplayJpegEx            LIB "GfxT_Pro.DLL"            ALIAS "DisplayJpegEx"         (BYVAL lWindowNumber AS LONG, BYVAL sFileName AS STRING) AS LONG
DECLARE FUNCTION DisplayWindow            LIB "GfxT_Pro.DLL"            ALIAS "DisplayWindow"         (BYVAL lSourceWindow AS LONG) AS LONG
DECLARE FUNCTION DisplayWindowEx          LIB "GfxT_Pro.DLL"            ALIAS "DisplayWindowEx"       (BYVAL lWindowNumber AS LONG, BYVAL lSourceWindow AS LONG) AS LONG
DECLARE FUNCTION DrawAngle                LIB "GfxT_Pro.DLL"            ALIAS "DrawAngle"             (BYVAL dpAngle AS DOUBLE, BYVAL lDistance AS LONG) AS LONG
DECLARE FUNCTION DrawAngleEx              LIB "GfxT_Pro.DLL"            ALIAS "DrawAngleEx"           (BYVAL lWindowNumber AS LONG, BYVAL dpAngle AS DOUBLE, BYVAL lDistance AS LONG) AS LONG
DECLARE FUNCTION DrawArc                  LIB "GfxT_Pro.DLL"            ALIAS "DrawArc"               (BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL dpStartAngle AS DOUBLE, BYVAL dpEndAngle AS DOUBLE) AS LONG
DECLARE FUNCTION DrawArcEx                LIB "GfxT_Pro.DLL"            ALIAS "DrawArcEx"             (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL dpStartAngle AS DOUBLE, BYVAL dpEndAngle AS DOUBLE) AS LONG
DECLARE FUNCTION DrawArea                 LIB "GfxT_Pro.DLL"            ALIAS "DrawArea"              (BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION DrawAreaEx               LIB "GfxT_Pro.DLL"            ALIAS "DrawAreaEx"            (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION DrawBezier               LIB "GfxT_Pro.DLL"            ALIAS "DrawBezier"            (BYREF lFirstX AS LONG, BYVAL lCount AS LONG) AS LONG
DECLARE FUNCTION DrawBezierEx             LIB "GfxT_Pro.DLL"            ALIAS "DrawBezierEx"          (BYVAL lWindowNumber AS LONG, BYREF lFirstX AS LONG, BYVAL lCount AS LONG) AS LONG
DECLARE FUNCTION DrawButton               LIB "GfxT_Pro.DLL"            ALIAS "DrawButton"            (BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lButtonType AS LONG) AS LONG
DECLARE FUNCTION DrawButtonEx             LIB "GfxT_Pro.DLL"            ALIAS "DrawButtonEx"          (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lType AS LONG) AS LONG
DECLARE FUNCTION DrawChord                LIB "GfxT_Pro.DLL"            ALIAS "DrawChord"             (BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL dpStartAngle AS DOUBLE, BYVAL dpEndAngle AS DOUBLE) AS LONG
DECLARE FUNCTION DrawChordEx              LIB "GfxT_Pro.DLL"            ALIAS "DrawChordEx"           (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL dpStartAngle AS DOUBLE, BYVAL dpEndAngle AS DOUBLE) AS LONG
DECLARE FUNCTION DrawCircle               LIB "GfxT_Pro.DLL"            ALIAS "DrawCircle"            (BYVAL lRadius AS LONG) AS LONG
DECLARE FUNCTION DrawCircleEx             LIB "GfxT_Pro.DLL"            ALIAS "DrawCircleEx"          (BYVAL lWindowNumber AS LONG, BYVAL lRadius AS LONG) AS LONG
DECLARE FUNCTION DrawCube                 LIB "GfxT_Pro.DLL"            ALIAS "DrawCube"              (BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lDepth AS LONG, BYVAL dpEdgeAngle AS DOUBLE) AS LONG
DECLARE FUNCTION DrawCubeEx               LIB "GfxT_Pro.DLL"            ALIAS "DrawCubeEx"            (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lDepth AS LONG, BYVAL dpEdgeAngle AS DOUBLE) AS LONG
DECLARE FUNCTION DrawCylinder             LIB "GfxT_Pro.DLL"            ALIAS "DrawCylinder"          (BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lThickness AS LONG, BYVAL dpRotation AS DOUBLE) AS LONG
DECLARE FUNCTION DrawCylinderEx           LIB "GfxT_Pro.DLL"            ALIAS "DrawCylinderEx"        (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lThickness AS LONG, BYVAL dpRotation AS DOUBLE) AS LONG
DECLARE FUNCTION DrawEllipse              LIB "GfxT_Pro.DLL"            ALIAS "DrawEllipse"           (BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION DrawEllipseEx            LIB "GfxT_Pro.DLL"            ALIAS "DrawEllipseEx"         (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION DrawEllipseRotated       LIB "GfxT_Pro.DLL"            ALIAS "DrawEllipseRotated"    (BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL dpAngle AS DOUBLE) AS LONG
DECLARE FUNCTION DrawEllipseRotatedEx     LIB "GfxT_Pro.DLL"            ALIAS "DrawEllipseRotatedEx"  (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL dpAngle AS DOUBLE) AS LONG
DECLARE FUNCTION DrawFlood                LIB "GfxT_Pro.DLL"            ALIAS "DrawFlood"             (BYVAL lMode AS LONG, BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION DrawFloodEx              LIB "GfxT_Pro.DLL"            ALIAS "DrawFloodEx"           (BYVAL lWindowNumber AS LONG, BYVAL lMode AS LONG, BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION DrawFocus                LIB "GfxT_Pro.DLL"            ALIAS "DrawFocus"             (BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION DrawFocusEx              LIB "GfxT_Pro.DLL"            ALIAS "DrawFocusEx"           (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION DrawFrame                LIB "GfxT_Pro.DLL"            ALIAS "DrawFrame"             (BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lFrameType AS LONG, BYVAL lFrameOptions AS LONG) AS LONG
DECLARE FUNCTION DrawFrameEx              LIB "GfxT_Pro.DLL"            ALIAS "DrawFrameEx"           (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lType AS LONG, BYVAL lOptions AS LONG) AS LONG
DECLARE FUNCTION DrawFrom                 LIB "GfxT_Pro.DLL"            ALIAS "DrawFrom"              (BYVAL lXPos AS LONG, BYVAL lYPos AS LONG) AS LONG
DECLARE FUNCTION DrawFromEx               LIB "GfxT_Pro.DLL"            ALIAS "DrawFromEx"            (BYVAL lWindowNumber AS LONG, BYVAL lXPos AS LONG, BYVAL lYPos AS LONG) AS LONG
DECLARE FUNCTION DrawHole                 LIB "GfxT_Pro.DLL"            ALIAS "DrawHole"              (BYVAL lNumber AS LONG, BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION DrawLine                 LIB "GfxT_Pro.DLL"            ALIAS "DrawLine"              (BYVAL lStartX AS LONG, BYVAL lStartY AS LONG, BYVAL lEndX AS LONG, BYVAL lEndY AS LONG) AS LONG
DECLARE FUNCTION DrawLineEx               LIB "GfxT_Pro.DLL"            ALIAS "DrawLineEx"            (BYVAL lWindowNumber AS LONG, BYVAL lStartX AS LONG, BYVAL lStartY AS LONG, BYVAL lEndX AS LONG, BYVAL lEndY AS LONG) AS LONG
DECLARE FUNCTION DrawMultiLine            LIB "GfxT_Pro.DLL"            ALIAS "DrawMultiLine"         (BYREF lFirstX AS LONG, BYVAL lCount AS LONG) AS LONG
DECLARE FUNCTION DrawMultiLineEx          LIB "GfxT_Pro.DLL"            ALIAS "DrawMultiLineEx"       (BYVAL lWindowNumber AS LONG, BYREF lFirstX AS LONG, BYVAL lCount AS LONG) AS LONG
DECLARE FUNCTION DrawPgram                LIB "GfxT_Pro.DLL"            ALIAS "DrawPgram"             (BYVAL dpAngle1 AS DOUBLE, BYVAL lDistance1 AS LONG, BYVAL dpAngle2 AS DOUBLE, BYVAL lDistance2 AS LONG) AS LONG
DECLARE FUNCTION DrawPgramEx              LIB "GfxT_Pro.DLL"            ALIAS "DrawPgramEx"           (BYVAL lWindowNumber AS LONG, BYVAL dpAngle1 AS DOUBLE, BYVAL lDistance1 AS LONG, BYVAL dpAngle2 AS DOUBLE, BYVAL lDistance2 AS LONG) AS LONG
DECLARE FUNCTION DrawPie                  LIB "GfxT_Pro.DLL"            ALIAS "DrawPie"               (BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL dpStartAngle AS DOUBLE, BYVAL dpEndAngle AS DOUBLE) AS LONG
DECLARE FUNCTION DrawPieEx                LIB "GfxT_Pro.DLL"            ALIAS "DrawPieEx"             (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL dpStartAngle AS DOUBLE, BYVAL dpEndAngle AS DOUBLE) AS LONG
DECLARE FUNCTION DrawPixel                LIB "GfxT_Pro.DLL"            ALIAS "DrawPixel"             (BYVAL lXPos AS LONG, BYVAL lYPos AS LONG, BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION DrawPixelEx              LIB "GfxT_Pro.DLL"            ALIAS "DrawPixelEx"           (BYVAL lWindowNumber AS LONG, BYVAL lXPos AS LONG, BYVAL lYPos AS LONG, BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION DrawPolygon              LIB "GfxT_Pro.DLL"            ALIAS "DrawPolygon"           (BYREF lFirstX AS LONG, BYVAL lCount AS LONG) AS LONG
DECLARE FUNCTION DrawPolygonEx            LIB "GfxT_Pro.DLL"            ALIAS "DrawPolygonEx"         (BYVAL lWindowNumber AS LONG, BYREF lFirstX AS LONG, BYVAL lCount AS LONG) AS LONG
DECLARE FUNCTION DrawRect                 LIB "GfxT_Pro.DLL"            ALIAS "DrawRect"              (BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION DrawRectEx               LIB "GfxT_Pro.DLL"            ALIAS "DrawRectEx"            (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION DrawSoftRect             LIB "GfxT_Pro.DLL"            ALIAS "DrawSoftRect"          (BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lCornerWidth AS LONG, BYVAL lCornerHeight AS LONG) AS LONG
DECLARE FUNCTION DrawSoftRectEx           LIB "GfxT_Pro.DLL"            ALIAS "DrawSoftRectEx"        (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lCornerWidth AS LONG, BYVAL lCornerHeight AS LONG) AS LONG
DECLARE FUNCTION DrawTextBox              LIB "GfxT_Pro.DLL"            ALIAS "DrawTextBox"           (BYVAL sText AS STRING, BYVAL lOptions AS LONG, BYREF lWidth AS LONG, BYREF lHeight AS LONG) AS LONG
DECLARE FUNCTION DrawTextBoxEx            LIB "GfxT_Pro.DLL"            ALIAS "DrawTextBoxEx"         (BYVAL lWindowNumber AS LONG, BYVAL sText AS STRING, BYVAL lOptions AS LONG, BYREF lWidth AS LONG, BYREF lHeight AS LONG) AS LONG
DECLARE FUNCTION DrawTextRow              LIB "GfxT_Pro.DLL"            ALIAS "DrawTextRow"           (BYVAL sText AS STRING, BYVAL lOptions AS LONG) AS LONG
DECLARE FUNCTION DrawTextRowEx            LIB "GfxT_Pro.DLL"            ALIAS "DrawTextRowEx"         (BYVAL lWindowNumber AS LONG, BYVAL sText AS STRING, BYVAL lOptions AS LONG) AS LONG
DECLARE FUNCTION DrawTo                   LIB "GfxT_Pro.DLL"            ALIAS "DrawTo"                (BYVAL lXPos AS LONG, BYVAL lYPos AS LONG) AS LONG
DECLARE FUNCTION DrawToEx                 LIB "GfxT_Pro.DLL"            ALIAS "DrawToEx"              (BYVAL lWindowNumber AS LONG, BYVAL lXPos AS LONG, BYVAL lYPos AS LONG) AS LONG
DECLARE FUNCTION DrawTube                 LIB "GfxT_Pro.DLL"            ALIAS "DrawTube"              (BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lThickness AS LONG, BYVAL dpRotation AS DOUBLE) AS LONG
DECLARE FUNCTION DrawTubeEx               LIB "GfxT_Pro.DLL"            ALIAS "DrawTubeEx"            (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lThickness AS LONG, BYVAL dpRotation AS DOUBLE) AS LONG
DECLARE FUNCTION DrawWedge                LIB "GfxT_Pro.DLL"            ALIAS "DrawWedge"             (BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lThickNess AS LONG, BYVAL dpStartAngle AS DOUBLE, BYVAL dpEndAngle AS DOUBLE) AS LONG
DECLARE FUNCTION DrawWedgeEx              LIB "GfxT_Pro.DLL"            ALIAS "DrawWedgeEx"           (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lThickNess AS LONG, _
                                                                                                       BYVAL dpStartAngle AS DOUBLE, BYVAL dpEndAngle AS DOUBLE) AS LONG
DECLARE FUNCTION DrawXagon                LIB "GfxT_Pro.DLL"            ALIAS "DrawXagon"             (BYVAL lSides AS LONG, BYVAL lRadius AS LONG, BYVAL dpRotation AS DOUBLE, BYVAL lEffect AS LONG) AS LONG
DECLARE FUNCTION DrawXagonEx              LIB "GfxT_Pro.DLL"            ALIAS "DrawXagonEx"           (BYVAL lWindowNumber AS LONG, BYVAL lSides AS LONG, BYVAL lRadius AS LONG, BYVAL dpRotation AS DOUBLE, BYVAL lEffect AS LONG) AS LONG
DECLARE FUNCTION FillHole                 LIB "GfxT_Pro.DLL"            ALIAS "FillHole"              (BYVAL lNumber AS LONG) AS LONG
DECLARE FUNCTION GfxAllocBuffer           LIB "GfxT_Pro.DLL"            ALIAS "GfxAllocBuffer"        (BYVAL lState AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION GfxAllocBufferEx         LIB "GfxT_Pro.DLL"            ALIAS "GfxAllocBufferEx"      (BYVAL lWindowNumber AS LONG, BYVAL lState AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION GfxBkgdColor             LIB "GfxT_Pro.DLL"            ALIAS "GfxBkgdColor"          (BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION GfxBkgdColorEx           LIB "GfxT_Pro.DLL"            ALIAS "GfxBkgdColorEx"        (BYVAL lWindowNumber AS LONG, BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION GfxBkgdMode              LIB "GfxT_Pro.DLL"            ALIAS "GfxBkgdMode"           (BYVAL lTransparent AS LONG) AS LONG
DECLARE FUNCTION GfxBkgdModeEx            LIB "GfxT_Pro.DLL"            ALIAS "GfxBkgdModeEx"         (BYVAL lWindowNumber AS LONG, BYVAL lTransparent AS LONG) AS LONG
DECLARE FUNCTION GfxCLS                   LIB "GfxT_Pro.DLL"            ALIAS "GfxCLS"                AS LONG
DECLARE FUNCTION GfxCLSEx                 LIB "GfxT_Pro.DLL"            ALIAS "GfxCLSEx"              (BYVAL lWindowNumber AS LONG) AS LONG
DECLARE FUNCTION GfxCaption               LIB "GfxT_Pro.DLL"            ALIAS "GfxCaption"            (BYVAL sCaption AS STRING, BYVAL lActive AS LONG) AS LONG
DECLARE FUNCTION GfxCaptionEx             LIB "GfxT_Pro.DLL"            ALIAS "GfxCaptionEx"          (BYVAL lWindowNumber AS LONG, BYVAL sCaption AS STRING, BYVAL lActive AS LONG) AS LONG
DECLARE FUNCTION GfxClipArea              LIB "GfxT_Pro.DLL"            ALIAS "GfxClipArea"           (BYVAL lOperation AS LONG) AS LONG
DECLARE FUNCTION GfxClipAreaEx            LIB "GfxT_Pro.DLL"            ALIAS "GfxClipAreaEx"         (BYVAL lWindowNumber AS LONG, BYVAL lOperation AS LONG) AS LONG
DECLARE FUNCTION GfxConvert               LIB "GfxT_Pro.DLL"            ALIAS "GfxConvert"            (BYVAL lConversionType AS LONG, BYVAL lUnits AS LONG) AS LONG
DECLARE FUNCTION GfxConvertEx             LIB "GfxT_Pro.DLL"            ALIAS "GfxConvertEx"          (BYVAL lWindowNumber AS LONG, BYVAL lConversionType AS LONG, BYVAL lUnits AS LONG) AS LONG
DECLARE FUNCTION GfxCursor                LIB "GfxT_Pro.DLL"            ALIAS "GfxCursor"             (BYVAL lCursor AS LONG) AS LONG
DECLARE FUNCTION GfxCursorEx              LIB "GfxT_Pro.DLL"            ALIAS "GfxCursorEx"           (BYVAL lWindowNumber AS LONG, BYVAL lCursor AS LONG) AS LONG
DECLARE FUNCTION GfxDrawMode              LIB "GfxT_Pro.DLL"            ALIAS "GfxDrawMode"           (BYVAL lMode AS LONG) AS LONG
DECLARE FUNCTION GfxDrawModeEx            LIB "GfxT_Pro.DLL"            ALIAS "GfxDrawModeEx"         (BYVAL lWindowNumber AS LONG, BYVAL lMode AS LONG) AS LONG
DECLARE FUNCTION GfxDroppedFiles          LIB "GfxT_Pro.DLL"            ALIAS "GfxDroppedFiles"       AS STRING
DECLARE FUNCTION GfxDroppedFilesEx        LIB "GfxT_Pro.DLL"            ALIAS "GfxDroppedFilesEx"     (BYVAL lWindowNumber AS LONG) AS STRING
DECLARE FUNCTION GfxFont                  LIB "GfxT_Pro.DLL"            ALIAS "GfxFont"               (BYVAL sFontName AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lWeight AS LONG, BYVAL lColor AS LONG, _
                                                                                                       BYVAL lEffects AS LONG, BYVAL dpAngle AS DOUBLE) AS LONG
DECLARE FUNCTION GfxFontEx                LIB "GfxT_Pro.DLL"            ALIAS "GfxFontEx"             (BYVAL lWindowNumber AS LONG, BYVAL sFontName AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, _
                                                                                                       BYVAL lWeight AS LONG, BYVAL lColor AS LONG, BYVAL lEffects AS LONG, BYVAL dpAngle AS DOUBLE) AS LONG
DECLARE FUNCTION GfxFontAngle             LIB "GfxT_Pro.DLL"            ALIAS "GfxFontAngle"          (BYVAL dpAngle AS DOUBLE) AS LONG
DECLARE FUNCTION GfxFontAngleEx           LIB "GfxT_Pro.DLL"            ALIAS "GfxFontAngleEx"        (BYVAL lWindowNumber AS LONG, BYVAL dpAngle AS DOUBLE) AS LONG
DECLARE FUNCTION GfxFontColor             LIB "GfxT_Pro.DLL"            ALIAS "GfxFontColor"          (BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION GfxFontColorEx           LIB "GfxT_Pro.DLL"            ALIAS "GfxFontColorEx"        (BYVAL lWindowNumber AS LONG, BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION GfxFontEffects           LIB "GfxT_Pro.DLL"            ALIAS "GfxFontEffects"        (BYVAL lEffects AS LONG) AS LONG
DECLARE FUNCTION GfxFontEffectsEx         LIB "GfxT_Pro.DLL"            ALIAS "GfxFontEffectsEx"      (BYVAL lWindowNumber AS LONG, BYVAL lEffects AS LONG) AS LONG
DECLARE FUNCTION GfxFontHeight            LIB "GfxT_Pro.DLL"            ALIAS "GfxFontHeight"         (BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION GfxFontHeightEx          LIB "GfxT_Pro.DLL"            ALIAS "GfxFontHeightEx"       (BYVAL lWindowNumber AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION GfxFontName              LIB "GfxT_Pro.DLL"            ALIAS "GfxFontName"           (BYVAL sName AS STRING) AS STRING
DECLARE FUNCTION GfxFontNameEx            LIB "GfxT_Pro.DLL"            ALIAS "GfxFontNameEx"         (BYVAL lWindowNumber AS LONG, BYVAL sName AS STRING) AS STRING
DECLARE FUNCTION GfxFontSize              LIB "GfxT_Pro.DLL"            ALIAS "GfxFontSize"           (BYVAL lSize AS LONG) AS LONG
DECLARE FUNCTION GfxFontSizeEx            LIB "GfxT_Pro.DLL"            ALIAS "GfxFontSizeEx"         (BYVAL lWindowNumber AS LONG, BYVAL lSize AS LONG) AS LONG
DECLARE FUNCTION GfxFontWeight            LIB "GfxT_Pro.DLL"            ALIAS "GfxFontWeight"         (BYVAL lWeight AS LONG) AS LONG
DECLARE FUNCTION GfxFontWeightEx          LIB "GfxT_Pro.DLL"            ALIAS "GfxFontWeightEx"       (BYVAL lWindowNumber AS LONG, BYVAL lWeight AS LONG) AS LONG
DECLARE FUNCTION GfxFontWidth             LIB "GfxT_Pro.DLL"            ALIAS "GfxFontWidth"          (BYVAL lWidth AS LONG) AS LONG
DECLARE FUNCTION GfxFontWidthEx           LIB "GfxT_Pro.DLL"            ALIAS "GfxFontWidthEx"        (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG) AS LONG
DECLARE FUNCTION GfxIsOpen                LIB "GfxT_Pro.DLL"            ALIAS "GfxIsOpen"             (BYVAL lWindowNumber AS LONG) AS LONG
DECLARE FUNCTION GfxLPR                   LIB "GfxT_Pro.DLL"            ALIAS "GfxLPR"                (BYREF lXPos AS LONG, BYREF lYPos AS LONG) AS LONG
DECLARE FUNCTION GfxLPREx                 LIB "GfxT_Pro.DLL"            ALIAS "GfxLPREx"              (BYVAL lWindowNumber AS LONG, BYREF lXPos AS LONG, BYREF lYPos AS LONG) AS LONG
DECLARE FUNCTION GfxLoc                   LIB "GfxT_Pro.DLL"            ALIAS "GfxLoc"                (BYVAL lAction AS LONG, BYVAL lWhich AS LONG) AS LONG
DECLARE FUNCTION GfxLocEx                 LIB "GfxT_Pro.DLL"            ALIAS "GfxLocEx"              (BYVAL lWindowNumber AS LONG, BYVAL lAction AS LONG, BYVAL lWhich AS LONG) AS LONG
DECLARE FUNCTION GfxMetrics               LIB "GfxT_Pro.DLL"            ALIAS "GfxMetrics"            (BYVAL lWhich AS LONG) AS LONG
DECLARE FUNCTION GfxMetricsEx             LIB "GfxT_Pro.DLL"            ALIAS "GfxMetricsEx"          (BYVAL lWindowNumber AS LONG, BYVAL lWhich AS LONG) AS LONG
DECLARE FUNCTION GfxMove                  LIB "GfxT_Pro.DLL"            ALIAS "GfxMove"               (BYVAL lLeft AS LONG, BYVAL lTop AS LONG) AS LONG
DECLARE FUNCTION GfxMoveEx                LIB "GfxT_Pro.DLL"            ALIAS "GfxMoveEx"             (BYVAL lWindowNumber AS LONG, BYVAL lLeft AS LONG, BYVAL lTop AS LONG) AS LONG
DECLARE FUNCTION GfxOption                LIB "GfxT_Pro.DLL"            ALIAS "GfxOption"             (BYVAL lOptionType AS LONG, BYVAL lValue AS LONG) AS LONG
DECLARE FUNCTION GfxOptionEx              LIB "GfxT_Pro.DLL"            ALIAS "GfxOptionEx"           (BYVAL lWindowNumber AS LONG, BYVAL lOptionType AS LONG, BYVAL lValue AS LONG) AS LONG
DECLARE FUNCTION GfxPrintArea             LIB "GfxT_Pro.DLL"            ALIAS "GfxPrintArea"          (BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG, BYVAL sDocName AS STRING, BYVAL sCaption AS STRING) AS LONG
DECLARE FUNCTION GfxPrintAreaEx           LIB "GfxT_Pro.DLL"            ALIAS "GfxPrintAreaEx"        (BYVAL lWindowNumber AS LONG, _
                                                                                                       BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG, BYVAL sDocName AS STRING, BYVAL sCaption AS STRING) AS LONG
DECLARE FUNCTION GfxPrintDefaults         LIB "GfxT_Pro.DLL"            ALIAS "GfxPrintDefaults"      AS LONG
DECLARE FUNCTION GfxPrintDefaultsEx       LIB "GfxT_Pro.DLL"            ALIAS "GfxPrintDefaultsEx"    (BYVAL lWindowNumber AS LONG) AS LONG
DECLARE FUNCTION GfxPrintPageSetup        LIB "GfxT_Pro.DLL"            ALIAS "GfxPrintPageSetup"     (BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION GfxPrintPageSetupEx      LIB "GfxT_Pro.DLL"            ALIAS "GfxPrintPageSetupEx"   (BYVAL lWindowNumber AS LONG, BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION GfxPrintParam            LIB "GfxT_Pro.DLL"            ALIAS "GfxPrintParam"         (BYVAL lParameter AS LONG, BYVAL lValue AS LONG) AS LONG
DECLARE FUNCTION GfxPrintParamEx          LIB "GfxT_Pro.DLL"            ALIAS "GfxPrintParamEx"       (BYVAL lWindowNumber AS LONG, BYVAL lParameter AS LONG, BYVAL lValue AS LONG) AS LONG
DECLARE FUNCTION GfxPrintSetup            LIB "GfxT_Pro.DLL"            ALIAS "GfxPrintSetup"         AS LONG
DECLARE FUNCTION GfxPrintSetupEx          LIB "GfxT_Pro.DLL"            ALIAS "GfxPrintSetupEx"       (BYVAL lWindowNumber AS LONG) AS LONG
DECLARE FUNCTION GfxPrintStatus           LIB "GfxT_Pro.DLL"            ALIAS "GfxPrintStatus"        (BYVAL lWhich AS LONG) AS STRING
DECLARE FUNCTION GfxPrintStatusEx         LIB "GfxT_Pro.DLL"            ALIAS "GfxPrintStatusEx"      (BYVAL lWindowNumber AS LONG, BYVAL lWhich AS LONG) AS STRING
DECLARE FUNCTION GfxPrintWindow           LIB "GfxT_Pro.DLL"            ALIAS "GfxPrintWindow"        (BYVAL sDocName AS STRING, BYVAL sCaption AS STRING) AS LONG
DECLARE FUNCTION GfxPrintWindowEx         LIB "GfxT_Pro.DLL"            ALIAS "GfxPrintWindowEx"      (BYVAL lWindowNumber AS LONG, BYVAL sDocName AS STRING, BYVAL sCaption AS STRING) AS LONG
DECLARE FUNCTION GfxRefresh               LIB "GfxT_Pro.DLL"            ALIAS "GfxRefresh"            (BYVAL lForce AS LONG) AS LONG
DECLARE FUNCTION GfxRefreshEx             LIB "GfxT_Pro.DLL"            ALIAS "GfxRefreshEx"          (BYVAL lWindowNumber AS LONG, BYVAL lForce AS LONG) AS LONG
DECLARE FUNCTION GfxResize                LIB "GfxT_Pro.DLL"            ALIAS "GfxResize"             (BYVAL lWhich AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION GfxResizeEx              LIB "GfxT_Pro.DLL"            ALIAS "GfxResizeEx"           (BYVAL lWindowNumber AS LONG, BYVAL lWhich AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION GfxResponse              LIB "GfxT_Pro.DLL"            ALIAS "GfxResponse"           (BYVAL hWnd AS LONG, BYVAL lResponse AS LONG) AS LONG
DECLARE FUNCTION GfxScroll                LIB "GfxT_Pro.DLL"            ALIAS "GfxScroll"             (BYVAL lDirection AS LONG, BYVAL lDistance AS LONG) AS LONG
DECLARE FUNCTION GfxScrollEx              LIB "GfxT_Pro.DLL"            ALIAS "GfxScrollEx"           (BYVAL lWindowNumber AS LONG, BYVAL lDirection AS LONG, BYVAL lDistance AS LONG) AS LONG
DECLARE FUNCTION GfxSquareness            LIB "GfxT_Pro.DLL"            ALIAS "GfxSquareness"         AS DOUBLE
DECLARE FUNCTION GfxSquarenessEx          LIB "GfxT_Pro.DLL"            ALIAS "GfxSquarenessEx"       (BYVAL lWindowNumber AS LONG) AS DOUBLE
DECLARE FUNCTION GfxSyncCursor            LIB "GfxT_Pro.DLL"            ALIAS "GfxSyncCursor"         AS LONG
DECLARE FUNCTION GfxSyncCursorEx          LIB "GfxT_Pro.DLL"            ALIAS "GfxSyncCursorEx"       (BYVAL lWindowNumber AS LONG) AS LONG
DECLARE FUNCTION GfxToolsVersion          LIB "GfxT_Pro.DLL"            ALIAS "GfxToolsVersion"       AS LONG
DECLARE FUNCTION GfxUpdate                LIB "GfxT_Pro.DLL"            ALIAS "GfxUpdate"             (BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION GfxUpdateEx              LIB "GfxT_Pro.DLL"            ALIAS "GfxUpdateEx"           (BYVAL lWindowNumber AS LONG, BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION GfxWindow                LIB "GfxT_Pro.DLL"            ALIAS "GfxWindow"             (BYVAL lAction AS LONG) AS LONG
DECLARE FUNCTION GfxWindowEx              LIB "GfxT_Pro.DLL"            ALIAS "GfxWindowEx"           (BYVAL lWindowNumber AS LONG, BYVAL lAction AS LONG) AS LONG
DECLARE FUNCTION GfxWorld                 LIB "GfxT_Pro.DLL"            ALIAS "GfxWorld"              (BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION GfxWorldEx               LIB "GfxT_Pro.DLL"            ALIAS "GfxWorldEx"            (BYVAL lWindowNumber AS LONG, BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION GfxX                     LIB "GfxT_Pro.DLL"            ALIAS "GfxX"                  AS LONG
DECLARE FUNCTION GfxXEx                   LIB "GfxT_Pro.DLL"            ALIAS "GfxXEx"                (BYVAL lWindowNumber AS LONG) AS LONG
DECLARE FUNCTION GfxY                     LIB "GfxT_Pro.DLL"            ALIAS "GfxY"                  AS LONG
DECLARE FUNCTION GfxYEx                   LIB "GfxT_Pro.DLL"            ALIAS "GfxYEx"                (BYVAL lWindowNumber AS LONG) AS LONG
DECLARE FUNCTION GradientBrush            LIB "GfxT_Pro.DLL"            ALIAS "GradientBrush"         (BYVAL lFigures AS LONG) AS LONG
DECLARE FUNCTION GradientBrushEx          LIB "GfxT_Pro.DLL"            ALIAS "GradientBrushEx"       (BYVAL lWindowNumber AS LONG, BYVAL lFigures AS LONG) AS LONG
DECLARE FUNCTION GradientColor            LIB "GfxT_Pro.DLL"            ALIAS "GradientColor"         (BYVAL lIndex AS LONG) AS LONG
DECLARE FUNCTION GradientColorEx          LIB "GfxT_Pro.DLL"            ALIAS "GradientColorEx"       (BYVAL lWindowNumber AS LONG, BYVAL lIndex AS LONG) AS LONG
DECLARE FUNCTION GradientLoad             LIB "GfxT_Pro.DLL"            ALIAS "GradientLoad"          (BYVAL sFileName AS STRING) AS LONG
DECLARE FUNCTION GradientLoadEx           LIB "GfxT_Pro.DLL"            ALIAS "GradientLoadEx"        (BYVAL lWindowNumber AS LONG, BYVAL sFileName AS STRING) AS LONG
DECLARE FUNCTION GradientSave             LIB "GfxT_Pro.DLL"            ALIAS "GradientSave"          (BYVAL sFileName AS STRING) AS LONG
DECLARE FUNCTION GradientSaveEx           LIB "GfxT_Pro.DLL"            ALIAS "GradientSaveEx"        (BYVAL lWindowNumber AS LONG, BYVAL sFileName AS STRING) AS LONG
DECLARE FUNCTION GradientValue            LIB "GfxT_Pro.DLL"            ALIAS "GradientValue"         (BYVAL lWhich AS LONG, BYVAL lValue AS LONG) AS LONG
DECLARE FUNCTION GradientValueEx          LIB "GfxT_Pro.DLL"            ALIAS "GradientValueEx"       (BYVAL lWindowNumber AS LONG, BYVAL lWhich AS LONG, BYVAL lValue AS LONG) AS LONG
DECLARE FUNCTION GraphicsToolsAuthorize   LIB "GfxT_Pro.DLL"            ALIAS "GraphicsToolsAuthorize"(BYVAL dwAuthCode AS DWORD) AS LONG
DECLARE FUNCTION GreenValue               LIB "GfxT_Pro.DLL"            ALIAS "GreenValue"            (BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION hGfx                     LIB "GfxT_Pro.DLL"            ALIAS "hGfx"                  (BYVAL lWhich AS LONG) AS LONG
DECLARE FUNCTION hGfxEx                   LIB "GfxT_Pro.DLL"            ALIAS "hGfxEx"                (BYVAL lWindowNumber AS LONG, BYVAL lWhich AS LONG) AS LONG
DECLARE FUNCTION hGfxFont                 LIB "GfxT_Pro.DLL"            ALIAS "hGfxFont"              AS LONG
DECLARE FUNCTION hGfxFontEx               LIB "GfxT_Pro.DLL"            ALIAS "hGfxFontEx"            (BYVAL lWindowNumber AS LONG) AS LONG
DECLARE FUNCTION HSW                      LIB "GfxT_Pro.DLL"            ALIAS "Hsw"                   (BYVAL lHue AS LONG, BYVAL lSaturation AS LONG, BYVAL lWhiteness AS LONG) AS LONG
DECLARE FUNCTION HSWtoRGB                 LIB "GfxT_Pro.DLL"            ALIAS "HSWtoRGB"              (BYREF X AS LONG, BYREF Y AS LONG, BYREF Z AS LONG) AS LONG
DECLARE FUNCTION HighlightColor           LIB "GfxT_Pro.DLL"            ALIAS "HighlightColor"        (BYVAL lColor AS LONG,BYVAL lPercentage AS LONG) AS LONG
DECLARE FUNCTION HueValue                 LIB "GfxT_Pro.DLL"            ALIAS "HueValue"              (BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION IconParam                LIB "GfxT_Pro.DLL"            ALIAS "IconParam"             (BYVAL sIcon AS STRING, BYVAL lInfoType AS LONG) AS LONG
DECLARE FUNCTION ImageParam               LIB "GfxT_Pro.DLL"            ALIAS "ImageParam"            (BYVAL sFileName AS STRING, BYVAL lInfoType AS LONG) AS LONG
DECLARE FUNCTION InitGradientHSW          LIB "GfxT_Pro.DLL"            ALIAS "InitGradientHSW"       (tGradient AS GT_HSW_GRADIENT) AS LONG
DECLARE FUNCTION InitGradientRGB          LIB "GfxT_Pro.DLL"            ALIAS "InitGradientRGB"       (tGradient AS GT_RGB_GRADIENT) AS LONG
DECLARE FUNCTION InitGraphicsTools        LIB "GfxT_Pro.DLL"            ALIAS "InitGraphicsTools"     (BYVAL lMaxWindow AS LONG, BYVAL lToolSet AS LONG) AS LONG
DECLARE FUNCTION JpegParam                LIB "GfxT_Pro.DLL"            ALIAS "JpegParam"             (BYVAL sFileName AS STRING, BYVAL lInfoType AS LONG) AS LONG
DECLARE FUNCTION MouseOver                LIB "GfxT_Pro.DLL"            ALIAS "MouseOver"             (BYVAL lWhich AS LONG) AS LONG
DECLARE FUNCTION MouseOverEx              LIB "GfxT_Pro.DLL"            ALIAS "MouseOverEx"           (BYVAL lWindowNumber AS LONG, BYVAL lWhich AS LONG) AS LONG
DECLARE FUNCTION MouseOverX               LIB "GfxT_Pro.DLL"            ALIAS "MouseOverX"            AS LONG
DECLARE FUNCTION MouseOverXEx             LIB "GfxT_Pro.DLL"            ALIAS "MouseOverXEx"          (BYVAL lWindowNumber AS LONG) AS LONG
DECLARE FUNCTION MouseOverY               LIB "GfxT_Pro.DLL"            ALIAS "MouseOverY"            AS LONG
DECLARE FUNCTION MouseOverYEx             LIB "GfxT_Pro.DLL"            ALIAS "MouseOverYEx"          (BYVAL lWindowNumber AS LONG) AS LONG
DECLARE FUNCTION MoveLPR                  LIB "GfxT_Pro.DLL"            ALIAS "MoveLPR"               (BYVAL lDistanceX AS LONG, BYVAL lDistanceY AS LONG) AS LONG
DECLARE FUNCTION MoveLPREx                LIB "GfxT_Pro.DLL"            ALIAS "MoveLPREx"             (BYVAL lWindowNumber AS LONG, BYVAL lDistanceX AS LONG, BYVAL lDistanceY AS LONG) AS LONG
DECLARE FUNCTION OpenGfx                  LIB "GfxT_Pro.DLL"            ALIAS "OpenGfx"               (BYVAL hParentWindow AS LONG, BYVAL lLeft AS LONG, BYVAL lTop AS LONG, _
                                                                                                       BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lStyles AS LONG) AS LONG
DECLARE FUNCTION OpenGfxEx                LIB "GfxT_Pro.DLL"            ALIAS "OpenGfxEx"             (BYVAL lWindowNumber AS LONG, BYVAL hParentWindow AS LONG, BYVAL lLeft AS LONG, BYVAL lTop AS LONG, _
                                                                                                       BYVAL lWidth AS LONG, BYVAL lHeight AS LONG, BYVAL lStyles AS LONG) AS LONG
DECLARE FUNCTION OverlayWindow            LIB "GfxT_Pro.DLL"            ALIAS "OverlayWindow"         (BYVAL lSourceWindow AS LONG, BYVAL lTransparentColor AS LONG) AS LONG
DECLARE FUNCTION OverlayWindowEx          LIB "GfxT_Pro.DLL"            ALIAS "OverlayWindowEx"       (BYVAL lWindowNumber AS LONG, BYVAL lSourceWindow AS LONG, BYVAL lTransparentColor AS LONG) AS LONG
DECLARE FUNCTION Pen                      LIB "GfxT_Pro.DLL"            ALIAS "Pen"                   (BYVAL lColor AS LONG, BYVAL lStyle AS LONG, BYVAL lWidth AS LONG) AS LONG
DECLARE FUNCTION PenEx                    LIB "GfxT_Pro.DLL"            ALIAS "PenEx"                 (BYVAL lWindowNumber AS LONG, BYVAL lColor AS LONG, BYVAL lStyle AS LONG, BYVAL lWidth AS LONG) AS LONG
DECLARE FUNCTION PenColor                 LIB "GfxT_Pro.DLL"            ALIAS "PenColor"              (BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION PenColorEx               LIB "GfxT_Pro.DLL"            ALIAS "PenColorEx"            (BYVAL lWindowNumber AS LONG, BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION PenStyle                 LIB "GfxT_Pro.DLL"            ALIAS "PenStyle"              (BYVAL lStyle AS LONG) AS LONG
DECLARE FUNCTION PenStyleEx               LIB "GfxT_Pro.DLL"            ALIAS "PenStyleEx"            (BYVAL lWindowNumber AS LONG, BYVAL lStyle AS LONG) AS LONG
DECLARE FUNCTION PenWidth                 LIB "GfxT_Pro.DLL"            ALIAS "PenWidth"              (BYVAL lWidth AS LONG) AS LONG
DECLARE FUNCTION PenWidthEx               LIB "GfxT_Pro.DLL"            ALIAS "PenWidthEx"            (BYVAL lWindowNumber AS LONG, BYVAL lWidth AS LONG) AS LONG
DECLARE FUNCTION PixelColor               LIB "GfxT_Pro.DLL"            ALIAS "PixelColor"            (BYVAL lXPos AS LONG, BYVAL lYPos AS LONG) AS LONG
DECLARE FUNCTION PixelColorEx             LIB "GfxT_Pro.DLL"            ALIAS "PixelColorEx"          (BYVAL lWindowNumber AS LONG, BYVAL lXPos AS LONG, BYVAL lYPos AS LONG) AS LONG
DECLARE FUNCTION PolyFillMode             LIB "GfxT_Pro.DLL"            ALIAS "PolyFillMode"          (BYVAL lMode AS LONG) AS LONG
DECLARE FUNCTION PolyFillModeEx           LIB "GfxT_Pro.DLL"            ALIAS "PolyFillModeEx"        (BYVAL lWindowNumber AS LONG, BYVAL lMode AS LONG) AS LONG
DECLARE FUNCTION RGBtoHSW                 LIB "GfxT_Pro.DLL"            ALIAS "RGBtoHSW"              (BYREF X AS LONG, BYREF Y AS LONG, BYREF Z AS LONG) AS LONG
DECLARE FUNCTION RedValue                 LIB "GfxT_Pro.DLL"            ALIAS "RedValue"              (BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION SaturationValue          LIB "GfxT_Pro.DLL"            ALIAS "SaturationValue"       (BYVAL lColor AS LONG) AS LONG
DECLARE FUNCTION SaveGfxArea              LIB "GfxT_Pro.DLL"            ALIAS "SaveGfxArea"           (BYVAL sBitmapName AS STRING, BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION SaveGfxAreaEx            LIB "GfxT_Pro.DLL"            ALIAS "SaveGfxAreaEx"         (BYVAL lWindowNumber AS LONG, BYVAL sBitmapName AS STRING, _
                                                                                                       BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION SaveGfxMode              LIB "GfxT_Pro.DLL"            ALIAS "SaveGfxMode"           (BYVAL lMode AS LONG) AS LONG
DECLARE FUNCTION SaveGfxModeEx                  LIB "GfxT_Pro.DLL"            ALIAS "SaveGfxModeEx"         (BYVAL lWindowNumber AS LONG, BYVAL lMode AS LONG) AS LONG
DECLARE FUNCTION SaveGfxWindow            LIB "GfxT_Pro.DLL"            ALIAS "SaveGfxWindow"         (BYVAL sBitmapName AS STRING) AS LONG
DECLARE FUNCTION SaveGfxWindowEx          LIB "GfxT_Pro.DLL"            ALIAS "SaveGfxWindowEx"       (BYVAL lWindowNumber AS LONG, BYVAL sBitmapName AS STRING) AS LONG
DECLARE FUNCTION SelectGfxColor           LIB "GfxT_Pro.DLL"            ALIAS "SelectGfxColor"        (BYVAL lStartColor AS LONG, BYVAL lStyleOption AS LONG) AS LONG
DECLARE FUNCTION SelectGfxColorEx         LIB "GfxT_Pro.DLL"            ALIAS "SelectGfxColorEx"      (BYVAL lWindowNumber AS LONG, BYVAL lStartColor AS LONG, BYVAL lStyleOption AS LONG) AS LONG
DECLARE FUNCTION SelectGfxFile            LIB "GfxT_Pro.DLL"            ALIAS "SelectGfxFile"         (BYVAL sTitle AS STRING, BYVAL sFileSpec AS STRING, BYVAL sInitialDir AS STRING, _
                                                                                                       BYVAL sFilter AS STRING, BYVAL sDefExtension AS STRING, BYREF lFlags AS LONG) AS STRING
DECLARE FUNCTION SelectGfxFileEx          LIB "GfxT_Pro.DLL"            ALIAS "SelectGfxFileEx"       (BYVAL lWindowNumber AS LONG, BYVAL sTitle AS STRING, BYVAL sFileSpec AS STRING, _
                                                                                                       BYVAL sInitialDir AS STRING, BYVAL sFilter AS STRING, BYVAL sDefExtension AS STRING, BYREF lFlags AS LONG) AS STRING
DECLARE FUNCTION StretchBitmap            LIB "GfxT_Pro.DLL"            ALIAS "StretchBitmap"         (BYVAL sBitmap AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION StretchBitmapEx          LIB "GfxT_Pro.DLL"            ALIAS "StretchBitmapEx"       (BYVAL lWindowNumber AS LONG, BYVAL sBitmap AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION StretchCursor            LIB "GfxT_Pro.DLL"            ALIAS "StretchCursor"         (BYVAL sCursor AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION StretchCursorEx          LIB "GfxT_Pro.DLL"            ALIAS "StretchCursorEx"       (BYVAL lWindowNumber AS LONG, BYVAL sCursor AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION StretchIcon              LIB "GfxT_Pro.DLL"            ALIAS "StretchIcon"           (BYVAL sIcon AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION StretchIconEx            LIB "GfxT_Pro.DLL"            ALIAS "StretchIconEx"         (BYVAL lWindowNumber AS LONG, BYVAL sIcon AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION StretchImage             LIB "GfxT_Pro.DLL"            ALIAS "StretchImage"          (BYVAL sFileName AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION StretchImageEx           LIB "GfxT_Pro.DLL"            ALIAS "StretchImageEx"        (BYVAL lWindowNumber AS LONG, BYVAL sFileName AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION StretchJpeg              LIB "GfxT_Pro.DLL"            ALIAS "StretchJpeg"           (BYVAL sFileName AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION StretchJpegEx            LIB "GfxT_Pro.DLL"            ALIAS "StretchJpegEx"         (BYVAL lWindowNumber AS LONG, BYVAL sFileName AS STRING, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION StretchWindow            LIB "GfxT_Pro.DLL"            ALIAS "StretchWindow"         (BYVAL lSourceWindow AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION StretchWindowEx          LIB "GfxT_Pro.DLL"            ALIAS "StretchWindowEx"       (BYVAL lWindowNumber AS LONG, BYVAL lSourceWindow AS LONG, BYVAL lWidth AS LONG, BYVAL lHeight AS LONG) AS LONG
DECLARE FUNCTION SystemColor              LIB "GfxT_Pro.DLL"            ALIAS "SystemColor"           (BYVAL lWhich AS LONG) AS LONG
DECLARE FUNCTION TempDraw                 LIB "GfxT_Pro.DLL"            ALIAS "TempDraw"              (BYVAL lAction AS LONG) AS LONG
DECLARE FUNCTION TempDrawEx               LIB "GfxT_Pro.DLL"            ALIAS "TempDrawEx"            (BYVAL lWindowNumber AS LONG, BYVAL lAction AS LONG) AS LONG
DECLARE FUNCTION TempErase                LIB "GfxT_Pro.DLL"            ALIAS "TempErase"             (BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION TempEraseEx              LIB "GfxT_Pro.DLL"            ALIAS "TempEraseEx"           (BYVAL lWindowNumber AS LONG, BYVAL lLeft AS LONG, BYVAL lTop AS LONG, BYVAL lRight AS LONG, BYVAL lBottom AS LONG) AS LONG
DECLARE FUNCTION UseGfxWindow             LIB "GfxT_Pro.DLL"            ALIAS "UseGfxWindow"          (BYVAL lNewWindowNumber AS LONG) AS LONG
DECLARE FUNCTION UseGradient              LIB "GfxT_Pro.DLL"            ALIAS "UseGradient"           (tGradient AS GT_XYZ_GRADIENT) AS LONG
DECLARE FUNCTION UseGradientEx            LIB "GfxT_Pro.DLL"            ALIAS "UseGradientEx"         (BYVAL lWindowNumber AS LONG, tGradient AS GT_XYZ_GRADIENT) AS LONG
DECLARE FUNCTION UserDraw                 LIB "GfxT_Pro.DLL"            ALIAS "UserDraw"              AS LONG
DECLARE FUNCTION UserDrawEx               LIB "GfxT_Pro.DLL"            ALIAS "UserDrawEx"            (BYVAL lWindowNumber AS LONG) AS LONG
DECLARE FUNCTION WedgeOrder               LIB "GfxT_Pro.DLL"            ALIAS "WedgeOrder"            (BYVAL dpStartAngle AS DOUBLE, BYVAL dpEndAngle AS DOUBLE) AS LONG
DECLARE FUNCTION WhitenessValue           LIB "GfxT_Pro.DLL"            ALIAS "WhitenessValue"        (BYVAL lColor AS LONG) AS LONG

'=========================== EQUATES (CONSTANTS) ===========================

      'If you are using a version of PowerBASIC that supports string equates,
      'you can remove the apostrophes and use these.  If your version of
      'PowerBASIC does not support string equates, you will need to use the
      'literal strings instead of the equates.
      '$GFX_TOOLS_CLASS       = "GFXTOOLS2"
      '$CLIPBOARD             = "CLIPBOARD"

      %GFXTOOLS_PRO                    = -1
      %GFXTOOLS_STD                    = 0

'Error Codes for all functions...
      %SUCCESS                         = 0
      %ERROR_FIRST_GFXT_ERROR          = 999000000&
      %ERROR_DLL_NOT_AUTHORIZED        = 999000000&
      %ERROR_IMAGE_NOT_FOUND           = 999000020&
      %ERROR_LIBRARY_NOT_FOUND         = 999000022&
      %ERROR_BAD_PARAM_VALUE           = 999000030&
      %ERROR_USER_CANCEL               = 999000045&
      %ERROR_CANT_BE_DONE              = 999000048&
      %ERROR_SIZE_LIMIT                = 999000081&
      %ERROR_NO_WINDOW                 = 999000090&
      %ERROR_FIRST_BAS_ERROR           = 999001000&
      %ERROR_LAST_BAS_ERROR            = 999001999&
      %ERROR_FIRST_PRINTER_ERROR       = 999002000&
      %ERROR_LAST_PRINTER_ERROR        = 999002999&
      %ERROR_FIRST_ARRAY_ERROR         = 999003000&
      %ERROR_LAST_ARRAY_ERROR          = 999003999&
      %ERROR_FIRST_IMAGE_ERROR         = 999004000&
      %ERROR_LAST_IMAGE_ERROR          = 999004999&
      %ERROR_UNKNOWN_ERROR             = 999999999&
      %ERROR_LAST_GFXT_ERROR           = 999999999&

'Generic values...
      %GFX_NONE                        = &h7FFFFF00&
      %GFX_AUTO                        = &h7FFFFF0A&
      %GFX_SAME                        = &h7FFFFF0C&
      %GFX_QUERY                       = &h7FFFFF0E&
      %GFX_ALL                         = &h7FFFFF0F&
      %GFX_WINDOW_CENTER               = &h7FFFFF1C&
      %GFX_WINDOW_EDGE                 = &h7FFFFF1E&
      %GFX_BORDER_LEFT                 = &h7FFFFF21&
      %GFX_BORDER_TOP                  = &h7FFFFF22&
      %GFX_BORDER_RIGHT                = &h7FFFFF23&
      %GFX_BORDER_BOTTOM               = &h7FFFFF24&
      %GFX_SCROLLBAR_RIGHT             = &h7FFFFF33&
      %GFX_SCROLLBAR_BOTTOM            = &h7FFFFF34&
      %GFX_SCROLLBUTTON_UP             = &h7FFFFF35&
      %GFX_SCROLLBUTTON_DOWN           = &h7FFFFF36&
      %GFX_SCROLLBUTTON_LEFT           = &h7FFFFF37&
      %GFX_SCROLLBUTTON_RIGHT          = &h7FFFFF38&
      %GFX_SIZE_HANDLE                 = &h7FFFFF39&

'Graphics Window Styles, for the OpenGfx function...

      'Basic Window styles.
      %GFX_STYLE_PLAIN                 = &h00000000& 'default
      %GFX_STYLE_BORDER_LINE           = &h00800000& 'basic style
      %GFX_STYLE_RAISED                = &h00400000& 'basic style
      %GFX_STYLE_BUMP                  = &h00400200&
      %GFX_STYLE_SUNKEN                = &h00000200& 'basic style
      %GFX_STYLE_SUNKEN_SHALLOW        = &h00020000& 'basic style
      %GFX_STYLE_SUNKEN_DEEP           = &h00020200&
      %GFX_STYLE_SUNKEN_LINE           = &h00820000&
      %GFX_STYLE_SUNKEN_DOUBLE         = &h00820200&
      %GFX_STYLE_CAPTION               = &h00C00000&
      %GFX_STYLE_CAPTION_BUMP          = &h00C00200&
      %GFX_STYLE_CAPTION_SUNKEN        = &h00C60000&
      %GFX_STYLE_CAPTION_SMALL         = &h00C00080&
      'This style can be added to any style
      %GFX_STYLE_RAISED_DRAG_SIZE      = &h00040000& 'basic style
      'Combination styles are also supported, such
      'as %GFX_STYLE_CAPTION OR %GFX_STYLE_SUNKEN_DOUBLE

      'Scrollbar options
      %GFX_STYLE_SCROLLBARS_AUTO       = &h00000000& 'default
      %GFX_STYLE_SCROLLBARS_ALWAYS     = &h00000001&
      %GFX_STYLE_SCROLLBARS_NEVER      = &h00000002&

      'Options that affect sizing/moving
      %GFX_STYLE_STRETCHABLE           = &h00000100&
      %GFX_STYLE_MOVABLE               = &h00000400&
      %GFX_STYLE_SIZABLE               = &h00000800&
      %GFX_STYLE_DRAG_MOVE             = &h00008000&
      '(also see %GFX_STYLE_DRAG_SIZE above)

      'Common options
      %GFX_STYLE_TABSTOP               = &h00010000&
      %GFX_STYLE_DROP_FILES            = &h00000010&

      'Rarely-needed options
      %GFX_STYLE_CLIP_CHILDREN         = &h02000000&
      %GFX_STYLE_CLIP_SIBLINGS         = &h04000000&
      %GFX_STYLE_DISABLED              = &h08000000&
      %GFX_STYLE_NO_PARENT_NOTIFY      = &h00000004&
      %GFX_STYLE_TRANSPARENT           = &h00000020&
      %GFX_STYLE_TOPMOST               = &h00000008&
      %GFX_STYLE_RIGHT_ALIGN           = &h00001000&
      %GFX_STYLE_RTL_READING           = &h00002000&
      %GFX_STYLE_LEFT_SCROLLBAR        = &h00004000&

'Other OpenGfx values...
      %GFX_TOOLSET_WINDOWS             = 0
      %GFX_TOOLSET_PRINTER             = 1
      %GFX_TOOLSET_CONSOLE             = 2

'For the GfxResize function...
      %GFX_DRAWING_SIZE                = &h7FFFFFD0&
      %GFX_VISIBLE_SIZE                = &h7FFFFFD1&

'For the GradientFillMode function...
      %GRADIENT_FILL_ROUND_FIGURES     = &h1
      %GRADIENT_FILL_SQUARE_FIGURES    = &h2
      %GRADIENT_FILL_TEXT_BODY         = &h4
      %GRADIENT_FILL_TEXT_EFFECTS      = &h8

'For the GradientValue function...
      %GRADIENT_BASIC_TYPE             = 601
            %HSW_GRADIENT    = 1
            %RGB_GRADIENT    = 2
      %GRADIENT_FILL_TYPE              = 602
      %GRADIENT_ANGLE                  = 603
      %GRADIENT_TEXTURE                = 604
      %GRADIENT_TEXTURE_START          = 605

      %HSW_GRADIENT_HUE_MIN            = 617
      %RGB_GRADIENT_RED_MIN            = 617

      %HSW_GRADIENT_HUE_MAX            = 618
      %RGB_GRADIENT_RED_MAX            = 618

      %HSW_GRADIENT_HUE_START          = 619
      %RGB_GRADIENT_RED_START          = 619
      %HSW_GRADIENT_HUE_RATE           = 620
      %RGB_GRADIENT_RED_RATE           = 620
      %HSW_GRADIENT_HUE_OPTIONS        = 621
      %RGB_GRADIENT_RED_OPTIONS        = 621
      %HSW_GRADIENT_HUE_OFFSET         = 622
      %RGB_GRADIENT_RED_OFFSET         = 622
      %HSW_GRADIENT_HUE_TEXTURE        = 623
      %RGB_GRADIENT_RED_TEXTURE        = 623
      %HSW_GRADIENT_HUE_CUTOFF         = 624
      %RGB_GRADIENT_RED_CUTOFF         = 624

      %HSW_GRADIENT_SATURATION_MIN     = 633
      %RGB_GRADIENT_GREEN_MIN          = 633
      %HSW_GRADIENT_SATURATION_MAX     = 634
      %RGB_GRADIENT_GREEN_MAX          = 634
      %HSW_GRADIENT_SATURATION_START   = 635
      %RGB_GRADIENT_GREEN_START        = 635
      %HSW_GRADIENT_SATURATION_RATE    = 636
      %RGB_GRADIENT_GREEN_RATE         = 636
      %HSW_GRADIENT_SATURATION_OPTIONS = 637
      %RGB_GRADIENT_GREEN_OPTIONS      = 637
      %HSW_GRADIENT_SATURATION_OFFSET  = 638
      %RGB_GRADIENT_GREEN_OFFSET       = 638
      %HSW_GRADIENT_SATURATION_TEXTURE = 639
      %RGB_GRADIENT_GREEN_TEXTURE      = 639
      %HSW_GRADIENT_GREEN_CUTOFF       = 640
      %RGB_GRADIENT_SATURATION_CUTOFF  = 640

      %HSW_GRADIENT_WHITENESS_MIN      = 649
      %RGB_GRADIENT_BLUE_MIN           = 649
      %HSW_GRADIENT_WHITENESS_MAX      = 650
      %RGB_GRADIENT_BLUE_MAX           = 650
      %HSW_GRADIENT_WHITENESS_START    = 651
      %RGB_GRADIENT_BLUE_START         = 651
      %HSW_GRADIENT_WHITENESS_RATE     = 652
      %RGB_GRADIENT_BLUE_RATE          = 652
      %HSW_GRADIENT_WHITENESS_OPTIONS  = 653
      %RGB_GRADIENT_BLUE_OPTIONS       = 653
      %HSW_GRADIENT_WHITENESS_OFFSET   = 654
      %RGB_GRADIENT_BLUE_OFFSET        = 654
      %HSW_GRADIENT_WHITENESS_TEXTURE  = 655
      %RGB_GRADIENT_BLUE_TEXTURE       = 655
      %HSW_GRADIENT_WHITENESS_CUTOFF   = 656
      %RGB_GRADIENT_BLUE_CUTOFF        = 656

      %GRADIENT_SINGLE                 = &h00000001&
      %GRADIENT_SAWTOOTH               = &h00000002&
      %GRADIENT_BINARY                 = &h00000004&

      %GRADIENT_SOFTEN                 = &h10100000&
      %GRADIENT_SOFTEN_x2              = &h20100000&
      %GRADIENT_SOFTEN_x3              = &h30100000&
      %GRADIENT_SOFTEN_x4              = &h40100000&
      %GRADIENT_SOFTEN_x5              = &h50100000&
      %GRADIENT_SOFTEN_x6              = &h60100000&
      %GRADIENT_SOFTEN_x7              = &h70100000&
      %GRADIENT_SHARPEN                = &h11100000&
      %GRADIENT_SHARPEN_x2             = &h21100000&
      %GRADIENT_SHARPEN_x3             = &h31100000&
      %GRADIENT_SHARPEN_x4             = &h41100000&
      %GRADIENT_SHARPEN_x5             = &h51100000&
      %GRADIENT_SHARPEN_x6             = &h61100000&
      %GRADIENT_SHARPEN_x7             = &h71100000&

'For the GfxDrawMode function...

      'DEFAULT DRAW MODE...
      %GFX_OPAQUE_COLORS               = 13
      %GFX_NORMAL_DRAW_MODE            = %GFX_OPAQUE_COLORS

      %GFX_INVERSE_COLORS              = 4
      %GFX_INVERSE_SCREEN              = 6

      'SINGLE COLOR OPERATIONS
      %GFX_BLACK_ONLY                  = 1
      %GFX_WHITE_ONLY                  = 16

      'DRAW AND UN-DRAW...
      %GFX_XOR_DRAW                    = 7
      %GFX_XOR_DRAW_INVERSE            = 10

      'COLOR-MERGE OPERATIONS...
      %GFX_MERGE_COLORS                = 15
      %GFX_MERGE_COLORS_INVERSE        = 2
      %GFX_MERGE_COLORS_INV_PEN        = 14
      %GFX_MERGE_COLORS_INV_SCRN       = 12

      'MASK OPERATIONS...
      %GFX_MASK_COLORS                 = 9
      %GFX_MASK_COLORS_INVERSE         = 8
      %GFX_MASK_COLORS_INV_PEN         = 3
      %GFX_MASK_COLORS_INV_SCRN        = 5

      'The "No Operation" mode...
      %GFX_NO_DRAW                     = 11

'For the TempDraw function...
      %TEMPDRAW_BEGIN                  = 1
      %TEMPDRAW_CLEAR                  = 99
      %TEMPDRAW_END                    = 0
      %TEMPDRAW_DISABLE                = -1

'For the GfxWindow function...
      %GFX_HIDE                        = 0
      %GFX_CLOSE                       = 1
      %GFX_FREEZE                      = 2
      %GFX_UNFREEZE                    = 3
      %GFX_SHOW                        = 5
      %SET_FOCUS                       = 6
      %GFX_MOUSE_CAPTURE               = 10
      %GFX_MOUSE_RELEASE               = 11

'For the GfxPrintParam function...
      %PRINTER_SETUP_OPTIONS           = 1
            %PAGE_SETUP_DISABLE_MARGINS   = &h00000010&
            %PAGE_SETUP_DISABLE_PRINTER   = &h00000020&
            %PAGE_SETUP_DISABLE_ORIENTATION=&h00000100&
            %PAGE_SETUP_DISABLE_PAPER     = &h00000200&
            %PAGE_SETUP_NO_NETWORK_BUTTON = &h00200000&
            %PRINT_ACTUAL_SIZE            = &h20000000&
            %PRINT_FILL_SPECIFIED_AREA    = &h10000000&
            %PRINT_HEADER                 = &h40000000&

      %PRINTER_SETUP_UNITS             = 2
      %PRINTER_MARGIN_LEFT             = 3
      %PRINTER_MARGIN_TOP              = 4
      %PRINTER_MARGIN_RIGHT            = 5
      %PRINTER_MARGIN_BOTTOM           = 6
      %PRINTER_ORIENTATION             = 7
      %PRINTER_PAPER_SIZE              = 8
      %PRINTER_COPIES                  = 9
      %PRINTER_TRANSFER_MODE           = 10

'For the GfxPrintStatus function...
      %PRINTER_JOB_NUMBER              = 100
      %PRINTER_NAME                    = 101
      %PRINTER_MACHINE                 = 102
      %PRINTER_USER                    = 103
      %PRINTER_JOB_NAME                = 104
      %PRINTER_DATATYPE                = 105
      %PRINTER_JOB_STATUS              = 106
      %PRINTER_JOB_PRIORITY            = 107
      %PRINTER_JOB_POSITION            = 108
      %PRINTER_PAGES_TOTAL             = 109
      %PRINTER_PAGES_DONE              = 110
      %PRINTER_JOB_START_TIME          = 111

'For the SaveGfxMode function...
      %BMP_MONOCHROME                  = -1
      %BMP_16_COLORS                   = 4
      %BMP_256_COLORS                  = 8
      %BMP_32K_COLORS                  = 16
      %BMP_TRUECOLOR                   = 24
      %BMP_TRUECOLOR32                 = 32
      %JPEG_QUALITY                    = 1000
      %JPEG_TYPICAL                    = %JPEG_QUALITY + 75
      %JPEG_BEST                       = %JPEG_QUALITY + 100

'For the AutoPlay functions...
      %AUTOPLAY_START                  = 1
      %AUTOPLAY_PAUSE                  = 5
      %AUTOPLAY_ERASE                  = 7
      %AUTOPLAY_END                    = 9

'For the GfxScroll function...
      %SCROLL_HOME                     = &h7FFFFF01&
      %SCROLL_END                      = &h7FFFFF02&
      %SCROLL_HORIZ_POS                = &h7FFFFF03&
      %SCROLL_VERT_POS                 = &h7FFFFF04&
      %SCROLL_HORIZ                    = &h00000000&
      %SCROLL_VERT                    = &h00000001&
            %SCROLL_PAGE_UP   = &h7FFFFF10&
            %SCROLL_PAGE_DOWN = &h7FFFFF1F&

'For the MouseOver function...
      %HORIZONTAL_AXIS                 = 1
      %VERTICAL_AXIS                   = 2
      %MOUSE_LOCATION                  = 3
      %WINDOW_NUMBER                   = 10
      %RELATIVE_TO_WINDOW              = 20
      %RELATIVE_TO_PARENT              = 21
      %RELATIVE_TO_SCREEN              = 22

'For the BitmapParam, IconParam, CursorParam, and JpegParam functions...
      %IMAGE_WIDTH_HEIGHT              = 0
      %IMAGE_WIDTH                     = 1
      %IMAGE_HEIGHT                    = 2
      %IMAGE_BYTES_PER_LINE            = 3
      %IMAGE_PLANES                    = 4
      %IMAGE_BITS_PER_PIXEL            = 5

'For the DrawButton function...
      %GFX_CHECKBOX                    = &h0
      %GFX_RADIOBUTTON                 = &h4
      %GFX_THREESTATE                  = &h8
      %GFX_PUSHBUTTON                  = &h10
      %GFX_INACTIVE                    = &h100
      %GFX_PUSHED                      = &h200
      %GFX_CHECKED                     = &h400
      %GFX_ADJUST_RECT                 = &h2000&
      %GFX_FLAT_BORDER                 = &h4000&
      %GFX_MONO_BORDER                 = &h8000&

'For the GfxClipArea function...
      %AREA_DEFINE                     = 1
      %AREA_USE                        = 2
      %AREA_ADD                        = 3
      %AREA_XOR                        = 4
      %AREA_DIFFERENCE                 = 5
      %AREA_OVERLAP                    = 6
      %AREA_INACTIVE                   = 20
      %AREA_ACTIVE                     = 21
      %AREA_RESET                      = 99

'For the GfxFontEffects and GfxFont functions...
      %FONT_ITALIC                     = 1
      %FONT_UNDERLINE                  = 2
      %FONT_STRIKEOUT                  = 4

'For the DrawTextBox and DrawTextRow functions...
      %TEXT_ALIGN_TOP                  = &h00000000&
      %TEXT_ALIGN_LEFT                 = &h00000000&
      %TEXT_ALIGN_RIGHT                = &h00000002&
      %TEXT_ALIGN_BOTTOM               = &h00000008&
      %TEXT_CENTER                     = &h00000001&
      %TEXT_V_CENTER                   = &h00000004&
      %TEXT_WORD_BREAK                 = &h00000010&
      %TEXT_SINGLE_LINE                = &h00000020&
      %TEXT_EXPAND_TABS                = &h00000040&
      %TEXT_NO_CLIP                    = &h00000100&
      %TEXT_CALC_SIZE                  = &h00000400&
      %TEXT_NO_PREFIX                  = &h00000800&
      %TEXT_NO_PARTIALS                = &h00002000&
      %TEXT_PATH_ELLIPSIS              = &h00004000&
      %TEXT_END_ELLIPSIS               = &h00008000&
      %TEXT_WORD_ELLIPSIS              = &h00040000&
      %TEXT_MODIFY_STRING              = &h00010000&
      %TEXT_EXTERNAL_LEADING           = &h00000200&
      %TEXT_RTL_READING                = &h00020000&
      %TEXT_MOVE_X                     = &h00100000&
      %TEXT_MOVE_Y                     = &h00200000&
      %TEXT_SHADOW                     = &h01000000&
      %TEXT_OUTLINE                    = &h02000000&
      %TEXT_REVERSE                    = &h04000000&
      %TEXT_ANIMATE                    = &h08000000&
      %TEXT_B_EDGES                    = &h10000000&
      %TEXT_W_EDGES                    = &h20000000&
      %TEXT_C_EDGES                    = &h30000000&
      %TEXT_RAISED                     = &h40000000&
      %TEXT_ETCHED                     = &h80000000&

'For the GfxLoc function...
      %LOC_SAVE                        = 1
      %LOC_RESTORE                     = 2
      %LOC_X_RESTORE                   = 3
      %LOC_Y_RESTORE                   = 4
      %LOC_X_VALUE                     = 5
      %LOC_Y_VALUE                     = 6
      %LOC_CLEAR                       = 99

'For the hGfx function...
      %GFX_WINDOW_HANDLE               = 0
      %GFX_DC_HANDLE                   = 1
      %GFX_COMPAT_DC_HANDLE            = 2
      %GFX_BITMAP_HANDLE               = 3
      %GFX_PARENT_HANDLE               = 4
      %GFX_PEN_HANDLE                  = 10
      %GFX_BRUSH_HANDLE                = 11
      %GFX_FONT_HANDLE                 = 12
      %GFX_INSTANCE_HANDLE             = 20

'For the PolyFillMode function...
      %GFX_ALTERNATE_FILL              = 1
      %GFX_WINDING_FILL                = 2     'default setting

'Pen Styles
      %GFX_SOLID                       = 0
      %GFX_DASHED                      = 1     '  -------
      %GFX_DOTTED                      = 2     '  .......
      %GFX_DASHDOT                     = 3     '  _._._._
      %GFX_DASHDOTDOT                  = 4     '  _.._.._
      %GFX_CLEAR                       = 99

'Brush Styles
      '%GFX_SOLID                      = 0     'defined above
      %GFX_HATCHED                     = 2
      '%GFX_CLEAR                      = 99    'defined above

'Brush Hatch Styles
      %GFX_HLINE                       = 0     '  -----
      %GFX_VLINE                       = 1     '  |||||
      %GFX_DIAGBACK                    = 2     '  \\\\\
      %GFX_DIAGFWD                     = 3     '  /////
      %GFX_HVLINES                     = 4     '  +++++
      %GFX_DIAGBOTH                    = 5     '  xxxxx

'Frame Styles (specify one only)
      %FRAME_RAISED                    = &h5&  '(default)
      %FRAME_ETCHED                    = &h6&
      %FRAME_BUMP                      = &h9&
      %FRAME_SUNKEN                    = &hA&

'Frame Options
      %FRAME_OPT_LEFT                  = &h0001&
      %FRAME_OPT_TOP                   = &h0002&
      %FRAME_OPT_RIGHT                 = &h0004&
      %FRAME_OPT_BOTTOM                = &h0008&
      %FRAME_OPT_NORMAL                = &h000F&  '(default)
      %FRAME_OPT_SE_NW                 = &h0013&
      %FRAME_OPT_SW_NE                 = &h0016&
      %FRAME_OPT_NE_SW                 = &h0019&
      %FRAME_OPT_NW_SE                 = &h001C&
      %FRAME_OPT_FILL                  = &h0800&
      %FRAME_OPT_SOFT                  = &h1000&
      %FRAME_OPT_FLAT                  = &h4000&
      %FRAME_OPT_MONO                  = &h8000&

'For the DrawFlood function...

      %FLOOD_TO_BORDER                 = 0
      %FLOOD_SURFACE                   = 1

'For the GfxConvert function...
      %X_PIXELS_TO_UNITS               = 1
      %Y_PIXELS_TO_UNITS               = 2
      %X_UNITS_TO_PIXELS               = 3
      %Y_UNITS_TO_PIXELS               = 4
      %X_PIXELS_TO_DLG_UNITS           = 11
      %Y_PIXELS_TO_DLG_UNITS           = 12
      %X_DLG_UNITS_TO_PIXELS           = 13
      %Y_DLG_UNITS_TO_PIXELS           = 14

'Predefined colors
      %MINCOLOR                        = &h000000???
      %BLACK                           = &h000000???
      %LOBLUE                          = &h800000???
      %LOGREEN                         = &h008000???
      %LOCYAN                          = &h808000???
      %LORED                           = &h000080???
      %LOMAGENTA                       = &h800080???
      %LOYELLOW                        = &h008080???
      %LOWHITE                         = &hC0C0C0???
      %GRAY                            = &h808080???
      %HIBLUE                          = &hFF0000???
      %HIGREEN                         = &h00FF00???
      %HICYAN                          = &hFFFF00???
      %HIRED                           = &h0000FF???
      %HIMAGENTA                       = &hFF00FF???
      %HIYELLOW                        = &h00FFFF???
      %HIWHITE                         = &hFFFFFF???
      %MAXCOLOR                        = &hFFFFFF???

'Alternate color names...
      %BROWN                           = &h008080???
      %BRWN                            = &h008080???
      %BLCK                            = &h000000???
      %LOBL                            = &h800000???
      %LOGR                            = &h008000???
      %LOCY                            = &h808000???
      %LORD                            = &h000080???
      %LOMG                            = &h800080???
      %LOYL                            = &h008080???
      %LOWH                            = &hC0C0C0???
      %GRAY                            = &h808080???
      %HIBL                            = &hFF0000???
      %HIGR                            = &h00FF00???
      %HICY                            = &hFFFF00???
      %HIRD                            = &h0000FF???
      %HIMG                            = &hFF00FF???
      %HIYL                            = &h00FFFF???
      %HIWH                            = &hFFFFFF???

      'NOTE: If your program uses the PowerBASIC WIN32API.INC file you MAY see
      'a "duplicate equate definition" error (or another error) when you include
      'this file in your program.  If that happens, you can remove the following
      'lines from this file (or comment them out) because the necessary values
      'have already been defined in the WIN32API.INC file.

'For various keyboard/mouse operations...
      %MK_LBUTTON                      = &h0001
      %MK_RBUTTON                      = &h0002
      %MK_SHIFT                        = &h0004
      %MK_CONTROL                      = &h0008
      %MK_MBUTTON                      = &h0010
      %MK_XBUTTON1                     = &h0020
      %MK_XBUTTON2                     = &h0040

'For the SystemColor function...
      %COLOR_SCROLLBAR                 = 0  '(see note just above)
      %COLOR_BACKGROUND                = 1
      %COLOR_ACTIVECAPTION             = 2
      %COLOR_INACTIVECAPTION           = 3
      %COLOR_MENU                      = 4
      %COLOR_MSGBOX                    = 4
      %COLOR_WINDOW                    = 5
      %COLOR_WINDOWFRAME               = 6
      %COLOR_MENUTEXT                  = 7
      %COLOR_MSGBOXTEXT                = 7
      %COLOR_WINDOWTEXT                = 8
      %COLOR_CAPTIONTEXT               = 9
      %COLOR_ACTIVEBORDER              = 10
      %COLOR_INACTIVEBORDER            = 11
      %COLOR_APPWORKSPACE              = 12
      %COLOR_HIGHLIGHT                 = 13
      %COLOR_HIGHLIGHTTEXT             = 14
      %COLOR_BTNFACE                   = 15
      %COLOR_BTNSHADOW                 = 16
      %COLOR_GRAYTEXT                  = 17
      %COLOR_BTNTEXT                   = 18
      %COLOR_INACTIVECAPTIONTEXT       = 19
      %COLOR_BTNHIGHLIGHT              = 20
      %COLOR_3DDKSHADOW                = 21
      %COLOR_3DLIGHT                   = 22
      %COLOR_INFOTEXT                  = 23
      %COLOR_INFOBK                    = 24

      'NOTE: If your program uses the PowerBASIC WIN32API.INC file you MAY see
      'a "duplicate equate definition" error (or another error) when you include
      'this file in your program.  If that happens, you can remove the following
      'lines from this file (or comment them out) because the necessary values
      'have already been defined in the WIN32API.INC file.

'For the SelectGfxFile function...
      %OFN_ALLOWMULTISELECT            = &h000200 '(see note just above)
      %OFN_CREATEPROMPT                = &h002000
      %OFN_FILEMUSTEXIST               = &h001000
      %OFN_HIDEREADONLY                = &h000004
      %OFN_NOCHANGEDIR                 = &h000008
      %OFN_NODEREFERENCELINKS          = &h100000
      %OFN_NONETWORKBUTTON             = &h020000
      %OFN_NOTESTFILECREATE            = &h010000
      %OFN_NOVALIDATE                  = &h000100
      %OFN_PATHMUSTEXIST               = &h000800
      %OFN_READONLY                    = &h000001
      'Output flags
      %OFN_EXTENSIONDIFFERENT          = &h000400
      %OFN_NOREADONLYRETURN            = &h008000

'For the GfxMetrics function...
      %GFX_SCALE_MODE                  = 0  'always returns True in Graphics Tools Version 2.
      %GFX_HORIZ_SCALE                 = 1
      %GFX_DRAWING_WIDTH               = 2
      %GFX_HORIZ_LOC                   = 3
      %GFX_VERT_SCALE                  = 6
      %GFX_DRAWING_HEIGHT              = 7
      %GFX_VERT_LOC                    = 8
      %GFX_WINDOW_NUMBER               = 10
      %GFX_AUTOSHOW                    = 99
      %GFX_BKGD_COLOR                  = 100
      %GFX_BKGD_MODE                   = 101
      %GFX_WINDOW_STATE                = 111
      %GFX_WINDOW_STYLE                = 121
      %GFX_WINDOW_EX_STYLE             = 122
      %GFX_NONCLIENT_WIDTH             = 131
      %GFX_NONCLIENT_HEIGHT            = 132
      %GFX_NONCLIENT_LEFT              = 133
      %GFX_NONCLIENT_TOP               = 134
      %GFX_VISIBLE_WIDTH               = 141
      %GFX_VISIBLE_HEIGHT              = 142
      %GFX_SCROLL_POS_H                = 151
      %GFX_SCROLL_POS_V                = 152
      %GFX_SCROLL_LIMIT_H              = 153
      %GFX_SCROLL_LIMIT_V              = 154
      %GFX_BRUSH_STYLE                 = 201
      %GFX_BRUSH_HATCH                 = 202
      %GFX_BRUSH_COLOR                 = 203

      %GFX_PEN_STYLE                   = 301
      %GFX_PEN_WIDTH                   = 302
      %GFX_PEN_COLOR                   = 303

      %GFX_FONT_HEIGHT                 = 401
      %GFX_FONT_WIDTH                  = 402
      %GFX_FONT_WEIGHT                 = 403
      %GFX_FONT_EFFECTS                = 404
      %GFX_FONT_ANGLE                  = 405
      %GFX_FONT_COLOR                  = 406

      %GFX_FONT_ACTUAL_HEIGHT          = 500
      %GFX_FONT_AVE_WIDTH              = 501
      %GFX_FONT_MAX_WIDTH              = 502
      %GFX_FONT_ACTUAL_WEIGHT          = 503
      %GFX_FONT_ASCENT                 = 504
      %GFX_FONT_DESCENT                = 505
      %GFX_FONT_INT_LEADING            = 506
      %GFX_FONT_EXT_LEADING            = 507
      %GFX_FONT_ASPECT_X               = 508
      %GFX_FONT_ASPECT_Y               = 509
      %GFX_FONT_CHAR_FIRST             = 510
      %GFX_FONT_CHAR_LAST              = 511
      %GFX_FONT_CHAR_DEFAULT           = 512
      %GFX_FONT_CHAR_BREAK             = 513
      %GFX_FONT_ITALIC                 = 514
      %GFX_FONT_UNDERLINED             = 515
      %GFX_FONT_STRIKEOUT              = 516
      %GFX_FONT_PITCH_FAMILY           = 517
      %GFX_FONT_OVERHANG               = 518
      %GFX_FONT_CHARSET                = 519

'For the GfxOption function...

      %GFX_USE_RADIANS                 = 10
      %GFX_BASE_ANGLE                  = 11
      %GFX_REVERSE_ANGLES              = 12
      %GFX_USE_DLG_UNITS               = 14

      %GFX_ANIMATE_BKGD                = 16

      %GFX_PEN_SCALE_DISABLE           = 20
      %GFX_FONT_SCALE_DISABLE          = 21

      %GFX_FOCUS_RECT_COLOR            = 30
      %GFX_NO_FOCUS_RECT_COLOR         = 31

      %GFX_FAST_POLYDRAW               = 40

      %GFX_TEXT_ANIMATE_SPEED          = 50
      %GFX_TEXT_EDGE_COLOR             = 51
      %GFX_TEXT_ROW_ORIGIN             = 54
            %ORIGIN_TOP       = &h0
            %ORIGIN_LEFT      = &h0
            %ORIGIN_RIGHT     = &h1
            %ORIGIN_BOTTOM    = &h2
            %ORIGIN_H_CENTER  = &h4
            %ORIGIN_V_CENTER  = &h8
            %ORIGIN_CENTER    = &hC
      %GFX_TEXT_SHADOW_ANGLE           = 55
      %GFX_TEXT_SHADOW_SIZE            = 56
      %GFX_TEXT_SHADOW_COLOR           = 57
      %GFX_TEXT_OUTLINE_SIZE           = 58
      %GFX_TEXT_OUTLINE_COLOR          = 59

      %GFX_MAX_SAVED_LOCS              = 60
      %GFX_MAX_HOLES                   = 61
      %GFX_HOLE_MARGIN                 = 62

      %GFX_TRANSFER_MODE               = 70
      %GFX_QUICK_DRAW                  = 71

      %GFX_IMAGE_LOAD_MODE             = 73
            %LOAD_MONOCHROME = &h0001&
            %LOAD_TRANSPARENT= &h0020&
            %LOAD_MAP3DCOLORS= &h1000&

      %GFX_IMAGE_SAVE_MODE             = 74

      %GFX_OVERLAY_MODE                = 75
            %OVERLAY_TRANSPARENT = 1
            %OVERLAY_BLEND25     = 2
            %OVERLAY_BLEND50     = 4

      %GFX_IMAGE_DRAW_MODE             = 76
      %GFX_IMAGE_FLIP_H                = 77
      %GFX_IMAGE_FLIP_V                = 78

      %GFX_JPEG_LIB_VERSION            = 80
        %GFXT_JPEG       = 0
        %INTEL_JPEG      = 15

      %GFX_JPEG_SUBSAMPLING            = 81

      %GFX_WINDOW_NUMBER_OFFSET        = 90
      %GFX_WINDOW_DEFAULT_STYLE        = 91
      %GFX_EVENT_MESSAGE               = 92
            %WM_GFX_EVENT = &h4000
            %WM_GFX_EVENT_MAX = &h4FFF
      %GFX_CONFINE_TO_PARENT           = 93
      %GFX_H_SCROLL_BAR_SPEED          = 95
      %GFX_V_SCROLL_BAR_SPEED          = 96

      %GFX_CURSOR_TYPE                 = 97
      %GFX_MODULE_INSTANCE             = 98
      %GFX_SET_CALLBACK                = 99

      %GFX_3D_HIGHLIGHT                = 101
      %GFX_CYLINDER_CAP_COLOR          = 121
      %GFX_CYLINDER_SHADING_LEVEL      = 129
      %GFX_TUBE_SHADING_LEVEL          = 139
      %GFX_WEDGE_CAP_COLOR             = 141
      %GFX_WEDGE_SHADING_LEVEL         = 149
      %GFX_CUBE_CAP_COLOR              = 151
      %GFX_CUBE_SIDE_COLOR             = 152
      %GFX_CUBE_FRONT_COLOR            = 153
      %GFX_CUBE_DEPTH_SCALING          = 155
      %GFX_CUBE_SHADING_LEVEL          = 159
      %GFX_PIE_EXPLOSION_DISTANCE      = 161
      %GFX_PIE_EXPLOSION_OFFSET        = 162

      %GFX_HSW_POINTS                  = 180

      %GFX_OLE_STRINGS                 = 199

'----------------------------------------------------------------------------

'This function should be included in all PowerBASIC programs that use Graphics
'Tools.  (Other languages that support OLE strings should also include it.)
'
'If you want to eliminate this exported function, you should either...
'
'   1) use the alternative method: GfxOption %GFX_OLE_STRINGS, %TRUE
'OR 2) use ASCIIZ strings for all Graphics Tools string parameters.
'
'Failure to use one of these methods will result in OLE string memory leaks.

FUNCTION Gfx_OleStringParams ALIAS "Gfx_OleStringParams" EXPORT AS LONG
    ASM nop
END FUNCTION

'=========================================================================== end of GFXT_PRO.INC
