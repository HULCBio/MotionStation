% TRIM   ������^����ꂽ�V�X�e���ɑ΂������ԃp�����[�^���Z�o
%
%
% TRIM �́A������́A�o�́A��Ԃ̏����𖞂�������ԃp�����[�^�����߂܂��B
%
% [X,U,Y,DX] = TRIM('SYS') �́AS-Function 'SYS' �̏�Ԕ��W�� DX ���[���ɐݒ�
% ���� X,U,Y �̒l�����߂܂��BTRIM �́A�����t���œK����@��p���܂��B
%
% [X,U,Y,DX] = TRIM('SYS',X0,U0) �́AX �� U �ɑ΂��鏉����������ꂼ��X0 ��
% U0 �ɐݒ肵�܂��B
%
% [X,U,Y,DX] = TRIM('SYS',X0,U0,Y0,IX,IU,IY) �́AX, U, Y �� X0(IX),U0(IU),
% Y0(IY) �ɌŒ肵�܂��B�ϐ� IX, IU, IY �́A�C���f�b�N�X�̃x�N�g���ł��B
% ���̖��̉������߂��Ȃ��ꍇ�́ATRIM �́A�Ӑ}����l����̍ő���W�����ŏ�
% �ɂ���l�����߂܂��BIX ����łȂ��A���ׂĂ̏�Ԃ��܂܂Ȃ��ꍇ�́AIX �ŃC���f�b
% �N�X�t������Ȃ���Ԃ�ύX�ł��܂��B���l�ɁAIU ����łȂ��A���ׂĂ̓��͂���
% �܂Ȃ��ꍇ�́AIU �����菜���ꂽ���͂�ύX�ł��܂��B
%
% [X,U,Y,DX] = TRIM('SYS',X0,U0,Y0,IX,IU,IY,DX0,IDX) �́AIDX �ɂ���ăC���f�b
% �N�X�t����ꂽ���W���� DX(IDX) �ɌŒ肵�܂��B�C���f�b�N�X�t�����Ă��Ȃ�
% ���W���́A�ύX�ł��܂��B
%
% [X,U,Y,DX] = TRIM('SYS',X0,U0,Y0,IX,IU,IY,DX,IDX,OPTIONS) �́A�œK���p�����[
% �^��ݒ�ł��܂��B�ڍׂ́AOptimization Toolbox��CONSTR ���Q�Ƃ��Ă��������B
% Optimization Toolbox�ł������łȂ��ꍇ�́A�I�����C���h�L�������g���Q�Ƃ���
% ���������B
%
% [X,U,Y,DX] = TRIM('SYS',X0,U0,Y0,IX,IU,IY,DX0,IDX,OPTIONS,T) �́A���ԂɈ�
% ������V�X�e���ɑ΂��āA���Ԃ� T �ɐݒ肵�܂��B
%
% �ڍׂ́ATYPE TRIM �Ɠ��͂��Ă��������B
% �Q�l  LINMOD.
%
%


% Copyright 1990-2002 The MathWorks, Inc.
