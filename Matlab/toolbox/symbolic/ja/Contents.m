% Symbolic Math Toolbox
% Version 3.1 (R14) 05-May-2004
%
% �v�Z
%   diff        - ����
%   int         - �ϕ�
%   limit       - �Ɍ��l
%   taylor      - Taylor����
%   jacobian    - Jacobian�s��
%   symsum      - �����̑��a 
%
% ���`�㐔
%   diag        - �Ίp�s��̍쐬�A�܂��́A�Ίp�����̒��o
%   triu        - ��O�p�s��
%   tril        - ���O�p�s��
%   inv         - �t�s��
%   det         - �s��
%   rank        - �����N
%   rref        - �s�̊K�i�^
%   null        - �k����Ԃɑ΂�����
%   colspace    - ���Ԃɑ΂�����
%   eig         - �ŗL�l�ƌŗL�x�N�g��
%   svd         - ���ْl�Ɠ��كx�N�g��
%   jordan      - Jordan�����^
%   poly        - ����������
%   expm        - �s��w��
%
% �ȗ���
%   simplify    - �ȗ���
%   expand      - �W�J
%   factor      - ��������
%   collect     - �W�����܂Ƃ߂�
%   simple      - �ł��Z���\���̌���
%   numden      - ���q�ƕ���
%   horner      - ����q�̑������\��
%   subexpr     - ���ʂ��镔�����ɂ�鎮�̏�������
%   subs        - �V���{���b�N�ȑ��
%
% �������̉�@
%   solve       - �㐔�������̃V���{���b�N�ȉ�
%   dsolve      - �����������̃V���{���b�N�ȉ�
%   finverse    - �t�֐�
%   compose     - �֐��̍���
%
% �ϐ��x�̉��Z
%   vpa         - �ϐ��x�̉��Z
%   digits      - �ϐ��x�̐ݒ�
%
% �ϕ��ϊ�
%   fourier     - �t�[���G�ϊ�
%   laplace     - ���v���X�ϊ�
%   ztrans      - Z-�ϊ�
%   ifourier    - �t�t�[���G�ϊ�
%   ilaplace    - �t���v���X�ϊ�
%   iztrans     - �tZ-�ϊ�
%
% �ϊ�
%   double      - �V���{���b�N�s���{���x�ɕϊ�
%   poly2sym    - �W���x�N�g�����V���{���b�N�������ɕϊ�
%   sym2poly    - �V���{���b�N���������W���x�N�g���ɕϊ�
%   char        - �V���{���b�N�I�u�W�F�N�g�𕶎���ɕϊ�
%
% ��{���Z
%   sym         - �V���{���b�N�I�u�W�F�N�g�̍쐬
%   syms        - �V���{���b�N�I�u�W�F�N�g�쐬�̃V���[�g�J�b�g
%   findsym     - �V���{���b�N�ϐ��̌���
%   pretty      - �V���{���b�N���̃v���e�B�v�����g
%   latex       - �V���{���b�N����LaTeX�\��
%   ccode       - �V���{���b�N����C�R�[�h�\��
%   fortran     - �V���{���b�N����Fortran�\��
%
% ����֐�
%   sinint      - �����ϕ��֐�
%   cosint      - �]���ϕ��֐�
%   zeta        - Riemann��zeta�֐�
%   lambertw    - Lambert��W�֐�
%
% ������̎�舵���̃��[�e�B���e�B
%   isvarname   - �L���ȕϐ����̃`�F�b�N(MATLAB TOOLBOX)
%   vectorize   - �V���{���b�N���̃x�N�g����
%
% ����I�ȃO���t�B�J���A�v���P�[�V����
%   rsums       - Riemann�a
%   ezcontour   - �ȒP�ȃR���^�[�v���b�g
%   ezcontourf  - �ȒP�ȓh��Ԃ��R���^�[�v���b�g
%   ezmesh      - �ȒP�ȃ��b�V��(�T�[�t�F�X)�v���b�g
%   ezmeshc     - ���b�V���ƃR���^�[�̊ȒP�ȑg�ݍ��킹�v���b�g
%   ezplot      - �֐��̊ȒP�ȃv���b�g
%   ezplot3     - 3�����p�����g���b�N�Ȑ��̊ȒP�ȃv���b�g
%   ezpolar     - �ȒP�ȋɍ��W�v���b�g
%   ezsurf      - �ȒP�ȃT�[�t�F�X�v���b�g
%   ezsurfc     - �T�[�t�F�X�ƃR���^�[�̊ȒP�ȑg�ݍ��킹�v���b�g
%   funtool     - �֐��v�Z�@
%   taylortool  - Taylor�����v�Z�@
%
% �f��
%   symintro    - Symbolic Toolbox�̏Љ�
%   symcalcdemo - �v�Z�̃f�����X�g���[�V����
%   symlindemo  - �V���{���b�N�Ȑ��`�㐔�̃f��
%   symvpademo  - �ϐ��x�̉��Z�̃f��
%   symrotdemo  - ���ʉ�]�̖��
%   symeqndemo  - �V���{���b�N�Ȏ��̉�@�̃f��
%
% Maple�ւ̃A�N�Z�X(Student Edition�ł͎g�p�ł��܂���)
%   maple       - Maple�̃J�[�l���ւ̃A�N�Z�X
%   mfun        - Maple�֐��̐��l�]��
%   mfunlist    - MFUN�̊֐��̃��X�g
%   mhelp       - Maple�̃w���v
%   procread    - Maple�̃v���V�[�W���̑}��(Extended Toolbox���K�v�ł�)

%   Copyright 1993-2004 The MathWorks, Inc. 
%   Generated from Contents.m_template revision 1.1.6.1  $Date: 2003/09/14 14:00:58 $
