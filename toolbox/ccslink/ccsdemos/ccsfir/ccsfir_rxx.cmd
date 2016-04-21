/* For Generic TMS470 ARM Simulator
 *
 * Assumes you have enabled memory mapping and created a range of RAM from 0x20 for a length of 0x7FFE0.
 * To do this:
 *
 *		Go to the Option menu
 *		Select Memory Map...
 *		Enable Memory Mapping
 *		Enter a Starting Address of 0x20
 *		Enter a Length of 0x7FFE0
 *		Enter Attributes of RAM
 *		Click the Add button
 *		Click Done to leave the dialog
 *
 * You can add additional memory ranges but this linker command file assumes this as a minimum.
 */

-l rts32e.lib
MEMORY
{
    VECS     : org = 0x00000000   len = 0x00000020  /* VECTOR TABLE  */
    RAM      : org = 0x00000020   len = 0x7FFE0     /* SYSTEM RAM    */
}

SECTIONS
{
    .text    : {} > RAM
    .cinit   : {} > RAM
    .bss     : {} > RAM
    .sysmem  : {} > RAM
    .stack   : {} > RAM
    .data    : {} > RAM
}