% RLTOOL   SISO Design Tool ���I�[�v�����A���O�Ր݌v�̂��߂̐ݒ���s���܂��B
% 
% RLTOOL �́ARoot Locus �r���[���I���ɂ��� SISO Design Tool ���I�[�v��
% ���܂��B���� GUI ���g���āARoot Locus ��@���g���āA�P����/�P�o��(SISO)
% �⏞���Θb�^�Ő݌v���邱�Ƃ��ł��܂��B�v�����g���f����SISO Design Tool
% �Ɏ�荞�ނ��߁AFile ���j���[���� Import Model �A�C�e����I�����܂��B
% �f�t�H���g�ł́A���̃t�B�[�h�o�b�N�R���t�B�M�����[�V�������ݒ肳��
% �Ă��܂��B
% 
%          u --->O--->[ COMP ]--->[ PLANT ]----+---> y
%              - |                             |
%                +-----------------------------+
% 
% RLTOOL(PLANT) �́ASISO Tool ���Ŏg�p�����v�����g���f�� PLANT ���w��
% ���܂��BPLANT �́ATF, ZPK, SS �̂����ꂩ���g���č쐬�������`���f���ł��B
% 
% RLTOOL(PLANT,COMP) �́A�⏞��(������ATF, ZPK, SS �̂����ꂩ���g����
% �쐬�������`���f���ł�)�ɑ΂��鏉���l COMP ���ݒ肵�܂��B
% 
% RLTOOL(PLANT,COMP,LocationFlag,FeedbackSign) �́A���̂悤�ɂ��āA
% �⏞��̈ʒu�ƃt�B�[�h�o�b�N�̕�����ύX���܂��B
%
%    LocationFlag = 1: �⏞����t�H���[�h���[�v�ɒu��
%    LocationFlag = 2: �⏞����t�B�[�h�o�b�N���[�v�ɒu��
%    
%    FeedbackSign = -1: ���̃t�B�[�h�o�b�N
%    FeedbackSign =  1: ���̃t�B�[�h�o�b�N
% 
% �Q�l�F   SISOTOOL.


%   Karen D. Gondoly
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2003/06/26 16:04:46 $
