% SIM   Simulink���f���̃V�~�����[�V����
%
% SIM('model') �́AWorkspace I/O�I�v�V�������܂ނ��ׂẴV�~�����[�V�����p��
% ���[�^�_�C�A���O�ݒ��p���āASimulink���f�����V�~�����[�V�������܂��B
%
% SIM �R�}���h�́A���̃p�����[�^�������܂��B
% �f�t�H���g�ł́AOPTIONS�ŕύX���Ȃ�����A���ԁA��ԁA�o�͎͂w�肵�����ӈ�����
% �ۑ�����܂��B���ӈ������Ȃ��ꍇ�ɂ́A���M���O����f�[�^���w�肷�邽�߂ɃV�~��
% ���[�V�����p�����[�^�_�C�A���O��Workspace I/O�ݒ�𗘗p���܂��B
%
% [T,X,Y]         = SIM('model',TIMESPAN,OPTIONS,UT) [T,X,Y1,...,
% Yn] = SIM('model',TIMESPAN,OPTIONS,UT)
%
% T            : �o�͂���鎞�ԃx�N�g�� X            :
% X            : �s��܂��͍\���̂̌`���ŏo�͂�����ԍs��B
%  ��ԍs��́A�A����ԂƂ���ɑ������U��Ԃ��܂݂܂��B
% Y            : �s��܂��͍\���̂̌`���̏o�́B
%  �s��܂��͍\���̂̌`���̏o�� �u���b�N���}���f���ɂ��ẮA���ׂẴ��[�g
% ���x����outport�u���b�N���܂܂�܂��B Y1,...,Yn    : �u���b�N���}���f����
% ���Ă̂ݎw��ł��܂��B ���� �ŁAn�̓��[�g���x����outport�u���b�N�̐��łȂ�
% ��΂Ȃ�܂���B�eoutport�́A�ϐ�Y1,...,Yn�ɏo�͂���܂��B
%
% 'model'      : �u���b�N���}���f���̖��O�B
% TIMESPAN     : ���̂����ꂩ��I�����܂��B
%  TFinal, [TStart TFinal], [TStart OutputTimes TFinal].
%  OutputTimes�́AT �ɏo�͂���鎞�ԗ�ł����A�ʏ�AT �͂�葽���̎��ԗ���܂�
% �܂��BOPTIONS      : �I�v�V�����̃V�~�����[�V�����p�����[�^�B
% ����́A ���O�ƒl�̑g��p����SIMSET�ɂ��쐬�����\���̂ł��B
% UT           : �I�v�V�����̊O�����́B
% UT = [T, U1, ... Un] �����ŁAT  =  [t1, ..., tm]'�A�܂��́AUT�͊e���ԃX�e�b
% �v�ŕ]�������֐�u = UT(t)���܂ޕ�����ł��B�e�[�u�����͂ɑ΂��ẮA���f��
% �̓��͂́AUT ����}������܂��B
%
% SIM �̉E�ӈ�������s�� [] �Ƃ��Ďw�肷��ƁA�f�t�H���g�̈��������p����܂��B
%
% 1�Ԗڂ̃p�����[�^�݂̂��K�{�ł��B
% ���ׂẴf�t�H���g�́A�w�肳��Ă��Ȃ��I�v�V�������܂݁A�u���b�N���}���瓾
% ���܂��B�w�肳�ꂽ�I�v�V���������́A�u���b�N���}�̐ݒ��ύX���܂��B
%
% �Q�l : SLDEBUG, SIMSET.


% Copyright 1990-2002 The MathWorks, Inc.
