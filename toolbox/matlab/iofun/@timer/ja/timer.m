% TIMER   timer �I�u�W�F�N�g�̍쐬
%
% T = TIMER �́A�f�t�H���g�̑������g���� timer �I�u�W�F�N�g���쐬���܂��B
%
% T = TIMER('PropertyName1',PropertyValue1, 'PropertyName2', PropertyValue2,...)
% �́A�^����ꂽ�v���p�e�B�̖��O/�l�̑g�ݍ��킹���I�u�W�F�N�g�ɐݒ肵�� 
% timer �I�u�W�F�N�g���쐬���܂��B
%
% �v���p�e�B���ƒl�̑g�́A�֐� SET �ŃT�|�[�g����Ă���C�ӂ̃t�H�[�}�b�g
% �ŋL�q�ł��邱�Ƃɒ��ӂ��Ă��������B���Ƃ��΁A�p�����[�^-�l�̕������
% �g�A�\���́A�Z���z�񓙂ł��B
% 
% ���:
%       % timer �R�[���o�b�N�� mycallback �Ƃ���10�b�Ԃ� 
%       % timer �I�u�W�F�N�g���쐬���܂��B
%         t = timer('TimerFcn',@mycallback, 'Period', 10.0);
%
%
% �Q�l : TIMER/SET, TIMER/TIMERFIND, TIMER/START, TIMER/STARTAT.


%    RDD 10/23/01
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:57:49 $
