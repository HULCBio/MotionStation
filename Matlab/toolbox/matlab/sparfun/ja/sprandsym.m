% SPRANDSYM   �X�p�[�X�����Ώ̍s��
% 
% R = SPRANDSYM(S) �́A���O�p�����ƑΊp������ S �Ɠ����\���̑Ώ̂ȗ���
% �s����o�͂��܂��BR �̗v�f�́A����0�A���U1�Ő��K���z���܂��B
%
% R = SPRANDSYM(n,density) �́An �s n ��̃X�p�[�X�Ώ̗����s��ɂȂ�܂��B
% ���̍s��́A�ق� density*n*n �̔�[���v�f�������A�e�v�f�́A1�ȏ�
% �̐��K���z����T���v���̘a�ł��B
%
% R = SPRANDSYM(n,density,rc) �́A�������̋t���� rc �Ɠ������s����o��
% ���܂��B�v�f�̕��z�͈�l�ł͂Ȃ��A�قڃ[���𒆐S�ɑΏ̂ŁA���ׂĂ̗v�f
% �� [-1,1] �͈̔͂ɓ���܂��B
%
% rc ������ n �̃x�N�g���̏ꍇ�AR �͌ŗL�l rc �������܂��B���������āA
% rc ����(���łȂ�)�x�N�g���ł���΁AR �͐���s��ƂȂ�܂��B�ǂ����
% �ꍇ�ɂ��AR �͗^����ꂽ�ŗL�l�܂��͏����������Ίp�s��ɁA�����_����
% ���R�r�A����]��K�p���č���܂��BR �́A�����̈ʑ��I�\����A�㐔�I
% �\���������Ă��܂��B
% 
% R = SPRANDSYM(n�Adensity�Arc�Akind) �͐���s����o�͂��܂��B
%
% kind = 1 �̏ꍇ�AR �͐���Ίp�s��̃����_���ȃ��R�r�A����]�ō���܂��B
% R �̏������́A���m�Ɋ�]����l�ɂȂ�܂��B
%
% kind = 2 �̏ꍇ�AR �͊O�ς̈ړ��a(shifted sum)�ɂȂ�܂��BR �̏������́A
% ��]����l�̊T�Z�l�ƂȂ�܂����AR �͂�菬���ȍ\���ɂȂ�܂��B
%
% R = SPRANDSYM(S,[],rc,3) �́A�s�� S �Ɠ����\���ŁA�������̋ߎ��l��
% 1/rc �ɂȂ�܂��B
% 
% �Q�l�FSPRANDN, SPRAND.


%   Rob Schreiber, RIACS, and Cleve Moler, MathWorks, 2/5/91.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:03:35 $
