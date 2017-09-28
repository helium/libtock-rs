/* Userland Generic Layout
 *
 * This linker script is designed for Tock apps where the end microcontroller
 * is not known. Therefore, this script over provisions space on some platforms.
 */

ENTRY(_start)

SECTIONS {
/* Text section, Code! */
    .text :
    {
        LONG(_data);
        LONG(_bss);
        LONG(_sram_end);
        _text = .;
        KEEP (*(.text._start))
        *(.text*)
        *(.rodata*)

        /* C++ exception unwinding information */
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    }

/* ARM Exception support
 *
 * This contains compiler-generated support for unwinding the stack,
 * consisting of key-value pairs of function addresses and information on
 * how to unwind stack frames.
 * https://wiki.linaro.org/KenWerner/Sandbox/libunwind?action=AttachFile&do=get&target=libunwind-LDS.pdf
 *
 * .ARM.exidx is sorted, so has to go in its own output section.
 */
    PROVIDE_HIDDEN (__exidx_start = .);
    .ARM.exidx :
    {
      /* (C++) Index entries for section unwinding */
      *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    }
    PROVIDE_HIDDEN (__exidx_end = .);

/* Global Offset Table */
    .got :
    {
        _data = .;
        _got = .;
        *(.got*)
        _egot = .;
        _plt = .;
        *(.got.plt*)
        _eplt = .;
    }

/* Data section, static initialized variables
 *  Note: This is placed in Flash after the text section, but needs to be
 *  moved to SRAM at runtime
 */
    .data :
    {
        KEEP(*(.data*))
    }
    _edata = .;

/* BSS section, static uninitialized variables */
    .bss :
    {
      _bss = .;
        KEEP(*(.bss*))
        *(COMMON)
    }

/*
 * __NOTE__: The following symbols are used only to pass information
 * through the elf -> tbf -> Tock kernel.
 *
 * The kernel will place the stack at the beginning of the SRAM section so
 * that stack overflows run off the end of the memory segment and trigger an
 * MPU violation instead of overwriting data/got/bss information. This means
 * the actual location of symbols in those sections in memory will be offset
 * by STACK_SIZE.
 */
    .stack :
    {
        _stack = .;
        . += 1024;
        _estack = .;
    }

    _sram_end = .;
}
