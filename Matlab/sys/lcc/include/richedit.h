/* $Revision: 1.2 $ */
#ifndef _LCC_RICHEDIT_
#define	_LCC_RICHEDIT_
#ifndef _GNU_H_WIN32Headers
#include <windows.h>
#endif
#define	_PADDING	WORD
#define cchTextLimitDefault 32767
#define	_RICHEDIT_
#define	cchTextLimitDefault 32767
#define	CF_RTFNOOBJS 	TEXT("Rich Text Format Without Objects")
#define	CFE_ALLCAPS	CFM_ALLCAPS
#define	CFE_AUTOBACKCOLOR	CFM_BACKCOLOR
#define	CFE_DISABLED	CFM_DISABLED
#define	CFE_EMBOSS	CFM_EMBOSS
#define	CFE_HIDDEN	CFM_HIDDEN
#define	CFE_IMPRINT	CFM_IMPRINT
#define	CFE_LINK	0x0020
#define	CFE_OUTLINE	CFM_OUTLINE
#define	CFE_REVISED	CFM_REVISED
#define	CFE_SHADOW	CFM_SHADOW
#define	CFE_SMALLCAPS	CFM_SMALLCAPS
#define	CFE_SUBSCRIPT	0x10000
#define	CFE_SUPERSCRIPT	0x00020000
#define	CFM_ALL	0xf800003f
#define	CFM_ALL2	0xfeffffff
#define	CFM_ALLCAPS	0x80
#define	CFM_ANIMATION	0x40000
#define	CFM_BACKCOLOR	0x4000000
#define	CFM_BOLD	1
#define	CFM_CHARSET	0x8000000
#define	CFM_DISABLED	0x2000
#define	CFM_EFFECTS	0x4000003f
#define	CFM_EFFECTS2	0x44037fff
#define	CFM_EMBOSS	0x800
#define	CFM_HIDDEN	0x100
#define	CFM_IMPRINT	0x1000
#define	CFM_KERNING	0x100000
#define	CFM_LCID	0x2000000
#define	CFM_LINK	0x00000020
#define	CFM_OUTLINE	0x200
#define	CFM_REVAUTHOR	0x8000
#define	CFM_REVISED	0x4000
#define	CFM_SHADOW	0x400
#define	CFM_SIZE	0x80000000
#define	CFM_SMALLCAPS	0x40
#define	CFM_SPACING	0x200000
#define	CFM_STYLE	0x80000
#define	CFM_SUBSCRIPT	CFE_SUBSCRIPT | CFE_SUPERSCRIPT
#define	CFM_SUPERSCRIPT	CFM_SUBSCRIPT
#define	CFM_UNDERLINETYPE	0x800000
#define	CFM_WEIGHT	0x400000
#define	CFU_CF1UNDERLINE	0xFF
#define	CFU_INVERT	0xFE
#define	CFU_UNDERLINE	0
#define	CFU_UNDERLINEDOTTED	3
#define	CFU_UNDERLINEDOUBLE	2
#define	CFU_UNDERLINEWORD	1
#define	CHARFORMATDELTA	(sizeof(CHARFORMAT2) - sizeof(CHARFORMAT))
#define	ECO_AUTOWORDSELECTION	1
#define	ECOOP_AND	3
#define	ECOOP_OR	2
#define	ECOOP_SET	1
#define	ECOOP_XOR	4
#define	EM_CANREDO	(WM_USER + 85)
#define	EM_CONVPOSITION (WM_USER + 108)
#define	EM_GETIMECOMPMODE	(WM_USER + 122)
#define	EM_GETIMEOPTION	(WM_USER + 107)
#define	EM_GETLANGOPTIONS	(WM_USER + 121)
#define	EM_GETREDONAME	(WM_USER + 87)
#define	EM_GETTEXTMODE	(WM_USER + 90)
#define	EM_GETUNDONAME	(WM_USER + 86)
#define	EM_REDO	(WM_USER + 84)
#define	EM_SETIMEOPTION	(WM_USER + 106)
#define	EM_SETLANGOPTIONS	(WM_USER + 120)
#define	EM_SETTEXTMODE	(WM_USER + 89)
#define	EM_SETUNDOLIMIT	(WM_USER + 82)
#define	EM_STOPGROUPTYPING	(WM_USER + 88)
#define	EN_LINK	0x70b
#define	EN_OBJECTPOSITIONS	0x70a
#define	EN_REQUESTRESIZ	0x701
#define	ENM_CHANGE	1
#define	ENM_IMECHANGE	0x800000
#define	ENM_LANGCHANGE	0x1000000
#define	ENM_LIN	0x04000000
#define	ENM_NONE	0
#define	ENM_OBJECTPOSITIONS	0x2000000
#define	ENM_SCROLL	4
#define	ENM_UPDATE	2
#define	ICM_LEVEL2	2
#define	ICM_LEVEL2_5	3
#define	ICM_LEVEL2_SUI	4
#define	ICM_LEVEL3	1
#define	ICM_NOTOPEN	0
#define	IMF_AUTOFONT	2
#define	IMF_AUTOKEYBOARD	1
#define	IMF_CLOSESTATUSWINDOW 8
#define	IMF_FORCEACTIVE 0x40
#define	IMF_FORCEDISABLE 4
#define	IMF_FORCEENABLE 2
#define	IMF_FORCEINACTIVE 0x80
#define	IMF_FORCENONE	1
#define	IMF_FORCEREMEMBER 0x100
#define	IMF_MULTIPLEEDIT  0x400
#define	IMF_VERTICAL 0x20
#define	lDefaultTab 720
#define	MAX_TAB_STOPS 32
#define	OLEOP_DOVERB	1
#define	PC_DELIMITER	4
#define	PC_FOLLOWING	1
#define	PC_LEADING	2
#define	PC_OVERFLOW	3
#define	PFA_CENTER	3
#define	PFA_JUSTIFY	4
#define	PFA_LEFT	1
#define	PFA_RIGHT	2
#define	PFE_DONOTHYPHEN	(PFM_DONOTHYPHEN >> 16)
#define	PFE_KEEP	(PFM_KEEP >> 16)
#define	PFE_KEEPNEXT	(PFM_KEEPNEXT >> 16)
#define	PFE_NOLINENUMBER	(PFM_NOLINENUMBER >> 16)
#define	PFE_NOWIDOWCONTROL	(PFM_NOWIDOWCONTROL >> 16)
#define	PFE_PAGEBREAKBEFORE	(PFM_PAGEBREAKBEFORE >> 16)
#define	PFE_RTLPARA	(PFM_RTLPARA >> 16)
#define	PFE_SIDEBYSIDE	(PFM_SIDEBYSIDE	 >> 16)
#define	PFE_TABLECELL	0x4000
#define	PFE_TABLECELLEND	0x8000
#define	PFE_TABLEROW	0xc000
#define	PFM_ALIGNMENT	8
#define PFM_KEEP	0x20000
#define	PFM_ALL	0x8000003f
#define	PFM_ALL2	0xc0fffdff
#define	PFM_BORDER	0x800
#define	PFM_DONOTHYPHEN	0x400000
#define	PFM_EFFECTS	0xc0ff0000
#define	PFM_KEEP	0x20000
#define	PFM_KEEPNEXT	0x40000
#define	PFM_LINESPACING	0x100
#define	PFM_NOLINENUMBER	0x100000
#define	PFM_NOWIDOWCONTROL	0x200000
#define	PFM_NUMBERING	32
#define	PFM_NUMBERINGSTART	0x8000
#define	PFM_NUMBERINGSTYLE	0x2000
#define	PFM_NUMBERINGTAB	0x4000
#define	PFM_OFFSET	4
#define	PFM_OFFSETINDENT	0x80000000
#define	PFM_PAGEBREAKBEFORE	0x80000
#define	PFM_RIGHTINDENT	2
#define	PFM_RTLPARA	0x10000
#define	PFM_SHADING	0x1000
#define	PFM_SIDEBYSIDE	0x800000
#define	PFM_SPACEAFTER	0x80
#define	PFM_SPACEBEFORE	0x40
#define	PFM_STARTINDENT	1
#define	PFM_STYLE	0x400
#define	PFM_TABLE	0xc0000000
#define	PFM_TABSTOPS	16
#define	PFN_BULLET	1
#define	RICHEDIT_CLASS10A	"RICHEDIT"
#define	RICHEDIT_CLASSA		"RichEdit20A"
#define	RICHEDIT_CLASSW		L"RichEdit20W"
#define	SCF_ALL		0x4
#define	SCF_DEFAULT	0
#define	SCF_SELECTION	1
#define	SCF_WORD	2
#define	SEL_EMPTY	0
#define	SEL_MULTICHAR	4
#define	SEL_MULTIOBJECT	8
#define	SEL_OBJECT	2
#define	SEL_TEXT	1
#define	SF_RTFNOOBJS	3
#define	SF_TEXT	1
#define	SF_TEXTIZED	4
#define	SF_UNICODE	0x10
#define	WB_CLASSIFY	3
#define	WB_LEFTBREAK	6
#define	WB_MOVEWORDLEFT	4
#define	WB_MOVEWORDNEXT	5
#define	WB_MOVEWORDPREV	4
#define	WB_MOVEWORDRIGHT	5
#define	WB_NEXTBREAK	7
#define	WB_PREVBREAK	6
#define	WB_RIGHTBREAK	7
#define	WBF_CLASS	((BYTE) 0x0F)
#define	WCH_EMBEDDING (WCHAR)0xFFFC
#define	wEffects	wReserved
#define	yHeightCharPtsMost 1638
#ifndef WM_CONTEXTMENU
#define WM_CONTEXTMENU	0x7B
#endif
#ifndef WM_PRINTCLIENT
#define WM_PRINTCLIENT	0x318
#endif
#ifndef EM_GETLIMITTEXT
#define EM_GETLIMITTEXT	(WM_USER + 37)
#endif
#ifndef EM_POSFROMCHAR
#define EM_POSFROMCHAR	(WM_USER + 38)
#define EM_CHARFROMPOS	(WM_USER + 39)
#endif
#ifndef EM_SCROLLCARET
#define EM_SCROLLCARET	(WM_USER + 49)
#endif
typedef enum tagTextMode { TM_PLAINTEXT	=1, TM_RICHTEXT	=2 } TEXTMODE;
typedef struct _findtextexa { CHARRANGE chrg; LPSTR lpstrText; CHARRANGE chrgText;
} FINDTEXTEXA;
typedef struct _findtextexw { CHARRANGE chrg; LPWSTR lpstrText; CHARRANGE chrgText;
} FINDTEXTEXW;
typedef struct _charformat
{
	UINT		cbSize;
	DWORD		dwMask;
	DWORD		dwEffects;
	LONG		yHeight;
	LONG		yOffset;
	COLORREF	crTextColor;
	BYTE		bCharSet;
	BYTE		bPitchAndFamily;
	char		szFaceName[LF_FACESIZE];
} CHARFORMATA;

typedef struct _charformatw
{
        UINT		cbSize;
        DWORD           dwMask;
        DWORD           dwEffects;
        LONG            yHeight;
        LONG            yOffset;
        COLORREF	crTextColor;
        BYTE		bCharSet;
        BYTE		bPitchAndFamily;
        WCHAR		szFaceName[LF_FACESIZE];
} CHARFORMATW;
typedef struct _charformat2w {
	UINT		cbSize;
	DWORD		dwMask;
	DWORD		dwEffects;
	LONG		yHeight;
	LONG		yOffset;
	COLORREF	crTextColor;
	BYTE		bCharSet;
	BYTE		bPitchAndFamily;
	WCHAR		szFaceName[LF_FACESIZE];
	WORD		wWeight;
	SHORT		sSpacing;
	COLORREF	crBackColor;
	LCID		lcid;
	DWORD		dwReserved;
	SHORT		sStyle;
	WORD		wKerning;
	BYTE		bUnderlineType;
	BYTE		bAnimation;
	BYTE		bRevAuthor;
	BYTE		bReserved1;
} CHARFORMAT2W;
typedef struct _charformat2a {
	UINT		cbSize;
	DWORD		dwMask;
	DWORD		dwEffects;
	LONG		yHeight;
	LONG		yOffset;
	COLORREF	crTextColor;
	BYTE		bCharSet;
	BYTE		bPitchAndFamily;
	char		szFaceName[LF_FACESIZE];
	WORD		wWeight;
	SHORT		sSpacing;
	COLORREF	crBackColor;
	LCID		lcid;
	DWORD		dwReserved;
	SHORT		sStyle;
	WORD		wKerning;
	BYTE		bUnderlineType;
	BYTE		bAnimation;
	BYTE		bRevAuthor;
} CHARFORMAT2A;
typedef struct _paraformat2 {
	UINT	cbSize;
	DWORD	dwMask;
	WORD	wNumbering;
	WORD	wReserved;
	LONG	dxStartIndent;
	LONG	dxRightIndent;
	LONG	dxOffset;
	WORD	wAlignment;
	SHORT	cTabCount;
	LONG	rgxTabs[MAX_TAB_STOPS];
 	LONG	dySpaceBefore;
	LONG	dySpaceAfter;
	LONG	dyLineSpacing;
	SHORT	sStyle;
	BYTE	bLineSpacingRule;
	BYTE	bCRC;
	WORD	wShadingWeight;
	WORD	wShadingStyle;
	WORD	wNumberingStart;
	WORD	wNumberingStyle;
	WORD	wNumberingTab;
	WORD	wBorderSpace;
	WORD	wBorderWidth;
	WORD	wBorders;
} PARAFORMAT2;
#ifndef WM_NOTIFY
#define WM_NOTIFY	0x4E
typedef struct _nmhdr {
	HWND	hwndFrom;
	UINT	idFrom;
	UINT	code;
} NMHDR;
#endif
typedef struct _ensaveclipboard {
	NMHDR nmhdr;
	LONG cObjectCount;
	LONG cch;
} ENSAVECLIPBOARD;
typedef struct _enoleopfailed {
	NMHDR nmhdr;
	LONG iob;
	LONG lOper;
	HRESULT hr;
} ENOLEOPFAILED;
#define	OLEOP_DOVERB	1
typedef struct _objectpositions {
	NMHDR nmhdr;
	LONG cObjectCount;
	LONG *pcpPositions;
} OBJECTPOSITIONS;
typedef struct _enlink {
	NMHDR nmhdr;
	UINT msg;
	WPARAM wParam;
	LPARAM lParam;
	CHARRANGE chrg;
} ENLINK;
typedef struct _compcolor {COLORREF crText;COLORREF crBackground;DWORD dwEffects;
}COMPCOLOR;
typedef enum _undonameid { UID_UNKNOWN=0,UID_TYPING= 1,UID_DELETE= 2,
	UID_DRAGDROP=3,UID_CUT= 4,UID_PASTE= 5 } UNDONAMEID;
#ifndef WCH_EMBEDDING
#define WCH_EMBEDDING (WCHAR)0xFFFC
#endif
#ifdef UNICODE
#define CHARFORMAT2	CHARFORMAT2W
#define CHARFORMAT CHARFORMATW
#define RICHEDIT_CLASS	RICHEDIT_CLASSW
#define TEXTRANGE 	TEXTRANGEW
#define FINDTEXT	FINDTEXTW
#define FINDTEXTEX	FINDTEXTEXW
#else
#define CHARFORMAT CHARFORMATA
#define TEXTRANGE	TEXTRANGEA
#define RICHEDIT_CLASS	RICHEDIT_CLASSA
#define FINDTEXT	FINDTEXTA
#define FINDTEXTEX	FINDTEXTEXA
#define CHARFORMAT2 CHARFORMAT2A
#endif
#undef _PADDING
#endif

