% GET   �I�u�W�F�N�g�̃v���p�e�B�̎擾
% 
% V = GET(H,'PropertyName') �́A�n���h���ԍ� H �����O���t�B�b�N�X�I�u
% �W�F�N�g�̎w�肵���v���p�e�B�̒l���o�͂��܂��BH �́A�n���h���ԍ�����
% �Ȃ�x�N�g���ŁAget �� M �� length(H) �ł���AM�s1��̃Z���z����o��
% ���܂��B'PropertyName' ���A�v���p�e�B�����܂ޕ����񂩂�Ȃ�1�sN��
% �܂���N�s1��̃Z���z��Œu����������ꍇ�́AGET �́A�l��v�f�ɂ���
% M�sN��̃Z���z����o�͂��܂��B
%
% GET(H) �́A�n���h���ԍ��� H �̃O���t�B�b�N�X�I�u�W�F�N�g�̂��ׂẴv���p
% �e�B���ƃJ�����g�̒l��\�����܂��B
%
% V = GET(H) �́AH ���X�J���̂Ƃ��A�e�t�B�[���h���� H �̃v���p�e�B���ŁA
% �e�t�B�[���h���v���p�e�B�̒l���܂ލ\���̂��o�͂��܂��B
%
%   V = GET(0�A'Factory') 
%   V = GET(0�A'Factory<ObjectType>')
%   V = GET(0�A'Factory<ObjectType><PropertyName>') 
% 
% �́A���ׂẴI�u�W�F�N�g�^�C�v�ɑ΂��āA���[�U�ݒ肪�\�ȃf�t�H���g�l
% �����A���ׂẴv���p�e�B�̏o�׎��ɒ�`����Ă���l���o�͂��܂��B
%
%   V = GET(H�A'Default') 
%   V = GET(H�A'Default<ObjectType>') 
%   V = GET(H�A'Default<ObjectType><PropertyName>') 
% 
% �́A�f�t�H���g�̃v���p�e�B�l�ɂ��Ă̏����o�͂��܂�(H �́A�X�J���ł�
% ����΂Ȃ�܂���)�B 'Default' �́A�J�����g�� H �ɐݒ肳��Ă��邷�ׂĂ�
% �f�t�H���g�̃v���p�e�B�l�̃��X�g���o�͂��܂��B'Default<ObjectType>' �́A
% H �ɐݒ肳��Ă���<ObjectType>�̃v���p�e�B�̃f�t�H���g�݂̂��o�͂��܂��B
% 'Default<ObjectType><PropertyName>' �́AH �ɐݒ肳��Ă���f�t�H���g��
% �f�t�H���g��������܂ł��̐e���������邱�Ƃɂ��A�w�肵���v���p�e�B
% �̃f�t�H���g�l���o�͂��܂��B���̃v���p�e�B�ɑ΂���f�t�H���g�l���AH 
% �܂��̓��[�g�ȉ��� H �̐e�ɐݒ肳��Ă��Ȃ��ꍇ�́A�o�׎��ɒ�`�����
% ����v���p�e�B�̒l���o�͂��܂��B
% 
% �f�t�H���g�́A�I�u�W�F�N�g�̎q�A�܂��̓I�u�W�F�N�g���g����Q�Ƃ����
% ����B���Ƃ��΁A'DefaultAxesColor' �̒l�́Aaxes �܂��� axes �̎q�I�u
% �W�F�N�g����Q�Ƃ���܂��񂪁Afigure�⃋�[�g�ł͎Q�Ƃ���܂��B
%
% 'Factory' �܂��� 'Default' �� GET ���g�p����Ƃ��APropertyName ���ȗ�
% ����Ă���΁A�o�͒l�̓t�B�[���h�����v���p�e�B���ŁA�Ή�����l���v��
% �p�e�B�l�ł���\���̂̌`�����Ƃ�܂��BPropertyName ���w�肳���΁A
% �s��܂��͕�����̒l���o�͂���܂��B
%   
%
% �Q�l�FSET, RESET, DELETE, GCF, GCA, FIGURE, AXES.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:48 $
%   Built-in function.
