% FITTYPE  fit type �I�u�W�F�N�g���쐬
% FITTYPE(EXPR) �́A������ EXPR �̒��Ɋ܂܂�� MATLAB �\������ FITTYPE 
% �֐��I�u�W�F�N�g���쐬���܂��B���͈����́A�ϐ����ɑ΂��āAEXPR ������
% ���邱�ƂŁA�����I�Ɍ��肳��܂�(SYMVAR ���Q��)�B���̏ꍇ�A'x'�́A�Ɨ�
% �ϐ��ŁA'y'�́A�]���ϐ��ŁA���ׂĂ̑��̕ϐ��́A���f���̌W���Ɖ��肵��
% ���܂��B�ϐ������݂��Ȃ��ꍇ�A'x' ���g���܂��B���ׂĂ̌W���̓X�J����
% ���BEXPR �́A����`���f���Ƃ��Ď�舵���܂��B
%
% ���`���f���A����́A���̌^���������f���ł��B
% 
%    coeff1 * term1 + coeff2 * term2 + coeff3 * term3 + ...
% 
% (�����ŁA�W���́Aterm1, term2, ���X�̒��ɂ͕\��܂���)
% 
% ���̃��f���́A�Z���z��Ƃ��āAEXPR ��ݒ肷�邱�ƂŁA�K�肳��A�W����
% �܂܂Ȃ����`���f���̊e���́AEXPR �̃Z���ɐݒ肳��܂��B���Ƃ��΁A���f
% �� 'a*x + b*sin(x) + c' �́A'a', 'b', 'c' ���܂񂾌^�Ő��`�ł��B3��
% ���A'x', 'sin(x)', '1' (since c=c*1) �������AEXPR �́A3�̃Z�������
% �ɂ܂Ƃ߂��Z�� {'x','sin(x)','1'} �ɂȂ�܂��B
%
% FITTYPE(TYPE) �́A�^�C�v TYPE �� FITTYPE �I�u�W�F�N�g���쐬���܂��B
% 
% TYPE �ɑ΂���I���F
%              TYPE                   �ڍ�       
% Splines:     
%              'smoothingspline'      �������X�v���C��
%              'cubicspline'          �L���[�r�b�N(���}���ꂽ)�X�v���C��
% Interpolants:
%              'linearinterp'         ���`���}
%              'nearestinterp'        �ŋߖT���}
%              'splineinterp'         �L���[�r�b�N�X�v���C�����}
%              'pchipinterp'          �^��ۑ�����(pchip)���}
%
% �܂��́ACFLIBHELP �ɋL�q����郉�C�u�������f���̖��O��ݒ�ł��܂�
% (���C�u�������f���̖��O�A�ڍׂ́Atype CFLIBHELP ���Q�Ƃ��Ă�������)�B
%
% FITTYPE(EXPR,PARAM1,VALUE1,PARAM2,VALUE2,....) �́APARAM-VALUE �̑g��
% �g���āA�f�t�H���g�l�����������܂��B
% 
%   'independent'    �Ɨ��ϐ������w��
%   'dependent'      �]���ϐ������w��
%   'coefficients'   �W�������w��(2�ȏ�̏ꍇ�́A�Z���z��)
%   'problem'        ���Ɉˑ�����(�萔)�����w��
%                    (2�ȏ�̏ꍇ�́A�Z���z��)
%   'options'        ���̕������ɑ΂��ẮA�f�t�H���g�� 'fitoptions' ��
%                    �ݒ�
%   �f�t�H���g�F�Ɨ��ϐ��́Ax �ł��B
%               �]���ϐ��́Ay �ł��B
%               ���ɏ]������ϐ��͂���܂���B
%               ���̑��́A���ׂČW�����ł��B
%
% �}���`�L�����N�^�V���{�������g�����Ƃ��ł��܂��B
%
%   ���F
%     g = fittype('a*x^2+b*x+c')
%     g = fittype('a*x^2+b*x+c','coeff',{'a','b','c'})
%     g = fittype('a*time^2+b*time+c','indep','time')
%     g = fittype('a*time^2+b*time+c','indep','time','depen','height')
%     g = fittype('a*x+n*b','problem','n')
%     g = fittype({'cos(x)','1'})                            % ���`
%     g = fittype({'cos(x)','1'}, 'coefficients', {'a','b'}) % ���`
%
% �Q�l   CFLIBHELP, FIT.

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
