% [EMSG,NAG1,XSFLAG,TS,O1,...,ON] = MKARGS5X(TYPES,INARGS) �́A�e LTI �I�u
% �W�F�N�g��Ή�����f�[�^�s��Ɋg�����邱�ƂŁA�Z��-�x�N�g���̓��e INARGS
% ={I1,...,IM} ���o�� O1,...ON �ɏ������݂܂��B�Â��Ȃ����V�X�e�� MKSYS ��
% PCK �V�X�e�������݂���ꍇ�A�g������O�� LTI �ɕϊ�����܂��B�Z��-�x�N�g
% �� TYPE �́A�f�[�^�t�H�[�}�b�g���w�肵�܂��B���Ƃ��΁ATYPES = {'ss','tf'
% } �́A���X�g {I1,...,IM} �̒��̍ŏ��� LTI �I�u�W�F�N�g������ɑΉ������
% �ԋ��(a,b,c,d)�s��Ɋg�����A�����āA�e����ɑ��� LTI �I�u�W�F�N�g��(num,
% den)�x�N�g���Ɋg������܂��B�g�p�\�Ȓl�́A���̂��̂ł��B
% 
%       TYPES      �g��                       �g�����ꂽ�I�u�W�F�N�g
%                  �L�q                       ����  & �^�C�v
%       'ss'   --- [a,b,c,d] = ssdata(sys)      4     �s��
%       'des'  --- [a,b,c,d,e] = dssdata(sys)   5     �s�� 
%       'tss'  --- [a,b1,b2,c1,c2,d11,...       9     �s��
%                    d12,d21,d22] state-space
%       'tdes' --- [a,b1,b2,c1,c2,d11,...      10     �s��
%                    d12,d21,d22,e] descriptor
%       'tf'   --- [num,den] (SIMO only)         2     �s��
%       'tfm'  --- [num,den,n,m] (MIMO)          4     ���q�s��A
%                                                      ����x�N�g��
%                                                      n �� m �́A����
%       'lti'  --- LTI (no expansion)            1     LTI  �I�u�W�F�N�g
%               
% NAG1 �́A�L�q�����o�� O1,...,ON �̐���߂��܂��B�����āA����𒴂����
% �̂́ANaN �ŏo�͂���܂��B
% 
% ���� LTI �I�u�W�F�N�g���AINARGS �̒��ɑ��݂���ꍇ�AXSFLAG = 1 �ł��̑�
% �̏ꍇ�́AXSFLAG = 0 �ł��B
% 
% TS �́ALTI �I�u�W�F�N�g�̃T���v�����O����(�f�t�H���g�́ATS = 0 ) ���o��
% ���܂��B
% 
% EMSG �́A�G���[���b�Z�[�W���o�͂��A�G���[���Ȃ��ꍇ�́A��ɂȂ�܂��B

% Copyright 1988-2002 The MathWorks, Inc. 
