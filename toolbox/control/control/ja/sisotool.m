% SISOTOOL   SISO Design Tool
%
% SISOTOOL �́ASISO Design Tool ���J���܂��B
% ���̃O���t�B�J�����[�U�C���^�t�F�[�X(GUI)�́A���O�Ր}��J���[�v�� Bode ���}��
% �g���āA�P����/�P�o��(SISO)�̕⏞���݌v���邱�Ƃ��ł��܂��B�v�����g���f��
% �� SISODesign Tool �ɓǂݍ��ނɂ�File ���j���[����Import Model �A�C�e����
% �f�t�H���g�ł́A�t�B�[�h�o�b�N�R���t�B�M�����[�V�����͂��̂悤�ɂȂ�܂��B
%
%              r -->[ F ]-->O--->[ C ]--->[ G ]----+---> y
%                         - |                      |
%                           +-------[ H ]----------+
%
% SISOTOOL(G) �́ASISO Tool �̒��Ńv�����g���f�� G ��ݒ肵�܂��B
% G �́ATF, ZPK, SS �̂����ꂩ���g���č쐬�����C�ӂ̐��`���f���ł��B
%
% SISOTOOL(G,C) �́A�X�ɕ⏞�� C �ɑ΂��鏉���l���w�肵�܂��B
% ���l�ɁASISOTOOL(G,C,H,F) �́A�Z���T H �ƃv���t�B���^ F �ɑ΂���t���I��
% ���f����^���܂��B
%
% SISOTOOL(VIEWS) �܂��́ASISOTOOL(VIEWS,G,...) �́ASISO Tool �̏����R���t�B�M��
% ���[�V������ݒ肵�܂��BVIEWS �́A���̕�����̂����ꂩ(�܂��́A������
% ���킹������)�ł��B
%   'rlocus'      ���O�Ր}
%   'bode'        �J���[�v������ Bode���}
%   'nichols'     �J���[�v������ Nichols�v���b�g
%   'filter'      �v���t�B���^ F �� Bode���}
% ���Ƃ��΁A
%   sisotool({'nichols','bode'}) 
% �́ANichols�v���b�g�ƊJ���[�v��Bode���}������ SISO Design Tool ���J���܂��B
%
% �f�t�H���g�̕⏞��̈ʒu�ƃt�B�[�h�o�b�N�̕�����ύX����ɂ́A����  
% �t�B�[���h�����ʂ̓��͈��� OPTIONS (�\����) ���g���Ă��������B
%    OPTIONS.Location   C�̈ʒu (�t�H���[�h���[�v   'forward'
%                                �t�B�[�h�o�b�N���[�v 'feedback')
%    OPTIONS.Sign       �t�B�[�h�o�b�N���� (���ɑ΂��� -1, ���ɑ΂��� +1)
%
% �Q�l : LTIVIEW, RLOCUS, BODE, NICHOLS.


% Copyright 1986-2002 The MathWorks, Inc.
