% SET   timer �I�u�W�F�N�g�v���p�e�B�̐ݒ�܂��͕\��
% 
% SET(OBJ) �́Atimer �I�u�W�F�N�g OBJ �̐ݒ�\�Ȃ��ׂẴv���p�e�B��
% �΂��ĉ\�Ȓl�ƃv���p�e�B����\�����܂��BOBJ �́A�P��� timer �I�u
% �W�F�N�g�łȂ���΂Ȃ�܂���B
%
% PROP_STRUCT = SET(OBJ) �́Atimer �I�u�W�F�N�g OBJ �̐ݒ�\�Ȃ��ׂĂ�
% �v���p�e�B�ɑ΂��Đݒ�\�Ȓl�ƃv���p�e�B�����o�͂��܂��BOBJ �́A
% �P��� timer �I�u�W�F�N�g�łȂ���΂Ȃ�܂���B�o�͒l PROP_STRUCT �́A
% �t�B�[���h���� OBJ �̃v���p�e�B���ł���\���̂ł��B�܂��A�v���p�e�B��
% �L���ȕ�����̒l�̐ݒ肪����Ă��Ȃ��ꍇ�A�l�͉\�ȃv���p�e�B�l��
% �Z���z�񂩁A�܂��͋�̃Z���z��ł���\���̂ɂȂ�܂��B
%
% SET(OBJ,'PropertyName') �́Atimer �I�u�W�F�N�g OBJ �Ɏw�肳�ꂽ�v��
% �p�e�B PropertyName �ɑ΂��Đݒ�\�Ȓl��\�����܂��BOBJ �́A�P��� 
% timer �I�u�W�F�N�g�łȂ���΂Ȃ�܂���B
%
% PROP_CELL = SET(OBJ,'PropertyName') �́Atimer �I�u�W�F�N�g OBJ ��
% �w�肳�ꂽ�v���p�e�B PropertyName �ɑ΂���ݒ�\�Ȓl���o�͂��܂��B
% OBJ �́A�P��� timer �I�u�W�F�N�g�łȂ���΂Ȃ�܂���B�o�͒l PROP_CELL
% �́A�v���p�e�B���L���ȕ�����̒l�̐ݒ肪����Ă��Ȃ��ꍇ�A�ݒ�\��
% ������̃Z���z�񂩁A��̃Z���z��ł��B
%
% SET(OBJ,'PropertyName',PropertyValue,...) �́Atimer �I�u�W�F�N�g OBJ
% �ɑ΂���v���p�e�B PropertyName �ɁA�w�肳�ꂽ�l PropertyValue ��
% �ݒ肵�܂��B���[�U�́A�P��̃X�e�[�g�����g���� ���O/�v���p�e�B�l��
% �g�ݍ��킹�ŕ����̃v���p�e�B���w�肷�邱�Ƃ��ł��܂��BOBJ �́A�P���
% timer �I�u�W�F�N�g���Atimer �I�u�W�F�N�g�̃x�N�g���ł��B�x�N�g����
% �ꍇ�ASET �́A���ׂĂ̎w�肳�ꂽ timer �I�u�W�F�N�g�ɑ΂��ăv���p�e�B
% �l��ݒ肵�܂��B
%
% SET(OBJ,S) �́A�\���̂̒��Ɋ܂܂��l���g���āA�e�t�B�[���h���ɖ��t��
% ��ꂽ�v���p�e�B��ݒ肵�܂��B�����ŁAS �́A�I�u�W�F�N�g�v���p�e�B��
% �ł���\���̂̃t�B�[���h���ł��B
%
% SET(OBJ,PN,PV) �́A������̃Z���z�� PN �Ɏw�肵���v���p�e�B���Atimer 
% �I�u�W�F�N�g OBJ �̒��Ɏw�肵�����ׂẴI�u�W�F�N�g�ɑ΂��āA�Z���z�� 
% PV �̒��̑Ή�����l�ɐݒ肵�܂��BPN �̓x�N�g���łȂ���΂Ȃ�܂���B
% OBJ �� timer �I�u�W�F�N�g�̃Z���z��ł���ꍇ�APV �́AM �s N ��̃Z��
% �z��ł��B�����ŁA M �́Alength(OBJ)�ŁAN �́Alength(PN) �ł��B����
% �ꍇ�A�e timer �I�u�W�F�N�g�́APN �̒��Ɋ܂܂��v���p�e�B���̃��X�g
% �ɑ΂��āA��X�̒l�ōX�V����܂��B
%
% �p�����[�^-�l �̕�����̑g�ݍ��킹�̍\���̂ƁA�p�����[�^-�l�̃Z���z��
% �̑g�ݍ��킹�́ASET �Ɠ����Ăяo�����g�p���܂��B
%
% ���:
%     t = timer;
%     set(t) % ���ׂĂ̐ݒ�\�ȃv���p�e�B�ƒl��\��
%     set(t, 'ExecutionMode') % �v���p�e�B�̂��ׂĂ̐ݒ�\�Ȓl��\��
%     set(t, 'TimerFcn', 'callbk', 'ExecutionMode', 'FixedRate')
%     set(t, {'StartDelay', 'Period'}, {30, 30})
%     set(t, 'Name', 'MyTimerObject')
%
% �Q�l : TIMER, TIMER/GET.


%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:57:44 $
