% CONV2  2�����̃R���{�����[�V����
%
% C = CONV2(A, B) �́A�s��A��B��2�����̃R���{�����[�V�������s���܂��B
% [ma,na] = size(A) �ŁA[mb,nb] = size(B)�̏ꍇ�Asize(C) = [ma+mb-1,
% na+nb-1]�ɂȂ�܂��B
% C = CONV2(H1, H2, A) �́A�܂��x�N�g��H1���g���čs�̕����ɁA���Ƀx�N�g��
% H2���g���ė�̕�����A�̃R���{�����[�V�������s���܂��B 
% 
% C = CONV2( ... ,'shape') �́A�ȉ���'shape'�ɂ���Ďw�肳���T�C�Y������
% 2�����R���{�����[�V�����̃T�u�Z�N�V�������o�͂��܂��B
%     'full'  - (�f�t�H���g) ���S��2�����R���{�����[�V�������o�͂��܂��B
%     'same'  - A�Ɠ����T�C�Y�ŁA�R���{�����[�V�����̒��������o�͂��܂��B
%     'valid' - �G�b�W�Ƀ[�����������Ɍv�Z���ꂽ�R���{�����[�V�����̕���
%               �݂̂��o�͂��܂��Ball(size(A) >= size(B))�̂Ƃ��A
%               size(C) =[ma-mb+1,na-nb+1]�ŁA�����łȂ��ꍇ��C�͋�ł��B
%
% �Q�l �F CONV, CONVN, FILTER2, XCORR2(Signal Processing Toolbox)


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:46:30 $
%   Built-in function.
