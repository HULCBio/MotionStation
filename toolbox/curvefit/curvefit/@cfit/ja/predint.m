% PREDINT  fit result �I�u�W�F�N�g�A�܂��́A�V�����ϑ��Ɋւ���\�����
% 
% CI = PREDINT(FITRESULT,X,LEVEL) �́A�w�肵�� X �̒l�ŁA�V���� Y �̒l��
% �΂���\����Ԃ��o�͂��܂��BLEVEL �́A�M�����x���ŁA�f�t�H���g�l�́A
% 0.95 �ł��B
%
% CI = PREDINT(FITRESULT,X,LEVEL,'INTOPT','SIMOPT') �́A�v�Z�����Ԃ̃^
% �C�v���w�肵�܂��B'INTOPT' �́A'observation'�A�܂��́A'functional'�̂�
% ���ꂩ��ݒ肷�邱�Ƃ��ł��܂��B'observation' �́A�f�t�H���g�ŁA�V����
% �ϑ��ɑ΂���͈͂��v�Z���A'functional' �́AX �Ōv�Z���ꂽ�J�[�u�ɑ΂���
% �͈͂��v�Z���܂��B'SIMOPT' �́A'on'�̏ꍇ�A����������ĐM����Ԃ��v�Z���A
% 'off'�̏ꍇ�A�񓯊��Ōv�Z���܂�
%
% 'INTOPT' ���A'functional' �̏ꍇ�A�J�[�u�̌v�Z�ŁA�s�m�����̑���ɂȂ�
% �͈͂ł��B�܂��A'observation' �̏ꍇ�A�͈͂́A�V���� Y �l(�J�[�u�l�Ƀ�
% ���_���m�C�Y��t��)��\�����钆�ŁA�t���I�ȕs�m������\�킷���߂ɂ��L
% ���Ȃ�܂��
%
% �M�����x���� 95% �ŁA'INTOPT' �� 'functional' �Ɖ��肵�܂��B
% 'SIMOPT' ���A'off' (�f�t�H���g)�̏ꍇ�A95% �̐M�������O�����Ē�߂� 
% X �l��^����ƁA�^�̃J�[�u�́A�M����Ԃ̊Ԃɓ���܂��B'SIMOPT' �� 'on' 
% �ɂȂ�ꍇ�A(���ׂĂ� X �l�ł�)���ׂẴJ�[�u���A�͈͂̒��ɓ����Ă��� 
% 95% �̐M����Ԃ������܂��B

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
