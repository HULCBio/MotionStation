% XSLT   XSLT�G���W�����g����XML�h�L�������g��ϊ�
%
% RESULT = XSLT(SOURCE,STYLE,DEST) �́A�X�^�C���V�[�g���g����XML
% �h�L�������g��ϊ����A���ʂ̃h�L�������g��URL���o�͂��܂��B�֐��́A
% �ȉ��̓��͂��g���A�ŏ��̂��͕̂K�{�ł��B
%   SOURCE �́A�\�[�XXML�t�@�C���̃t�@�C�����܂���URL�ł��BSOURCE �́A
%     DOM node�ł����܂��܂���B
%   STYLE �́AXSL�X�^�C���V�[�g�̃t�@�C�����܂���URL�ł��B
%   DEST �́A��]����o�̓h�L�������g�̃t�@�C�����܂���URL�ł��B
%     DEST �����w��܂��͋�̏ꍇ�́A�֐��̓e���|�����t�@�C�����𗘗p
%     ���܂��BDEST ��'-tostring' �̏ꍇ�́A�o�̓h�L�������g�́AMATLAB
%     ������Ƃ��ďo�͂���܂��B
%
% [RESULT,STYLE] = XSLT(...) �́A��ɑ���XLSR�̌Ăяo���ɓn�����߂ɓK��
% �������ς̃X�^�C���V�[�g��STYLE�Ƃ��ďo�͂��܂��B����ɂ��A�X�^�C��
% �V�[�g�̏����̏d��������邱�Ƃ��ł��܂��B
%
% XSLT(...,'-web') �́A���ʂ̃h�L�������g���w���v�u���E�U�ɕ\�����܂��B
%
% ���:
% �ȉ��́A�X�^�C���V�[�g "info.xsl"���g���ăt�@�C��"info.xml" ���e���|
% �����t�@�C���ɕϊ����A���ʂ��w���v�u���E�U�ɕ\�����܂��BMATLAB�́A
% Launch Pad�ŗ��p����镡����info.xml�t�@�C�����܂݂܂��B
%
%   xslt info.xml info.xsl -web
%    
% �Q�l �F XMLREAD, XMLWRITE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2004/04/28 01:58:39 $
