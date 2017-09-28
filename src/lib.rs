#![feature(asm,alloc,allocator_api,compiler_builtins_lib,const_fn,global_allocator,lang_items,naked_functions)]
#![no_std]

pub mod syscalls;
pub mod ipc;
pub mod sensors;
pub mod console;
pub mod timer;
pub mod led;

extern crate alloc;
extern crate compiler_builtins;
extern crate linked_list_allocator;

mod lang_items;

use core::ptr;
use core::mem::align_of;
use linked_list_allocator::{align_up, LockedHeap, Heap};

#[global_allocator]
static ALLOCATOR: LockedHeap = LockedHeap::empty();

static mut FOOBAR: [usize; 386] = [543; 386];

/// Tock programs' entry point
#[doc(hidden)]
#[no_mangle]
#[naked]
pub extern "C" fn _start(mem_start: *mut u8, _app_heap_break: usize,
                         _kernel_memory_break: usize) -> ! {

    extern "C" {
        // NOTE `rustc` forces this signature on us. See `src/lang_items.rs`
        fn main(argc: isize, argv: *const *const u8) -> isize;
        static _data: isize;
        static _edata: isize;
        static _estack: isize;
    }

    unsafe {
        asm!("mov r9, $0" : : "r"(mem_start) : : "volatile");

        // Setup stack
        let new_stack = mem_start.offset(_estack);
        syscalls::memop(0, new_stack as usize);
        asm!("mov sp, $0" : : "r"(new_stack) : : "volatile");
        syscalls::memop(10, new_stack as usize);

        // Copy data segment
        let mut cur_seg = &_data as *const _ as *const usize;
        let mut cur_mem = mem_start as *mut usize;
        while cur_seg < (&_edata as *const _ as *const usize) {
            ::core::ptr::write(cur_mem, ::core::ptr::read(cur_seg));
            cur_mem = cur_mem.offset(1);
            cur_seg = cur_seg.offset(1);
        }

        let x = ::core::ptr::read_volatile(&FOOBAR[12]);

        // Setup heap
        let heap_start = align_up(new_stack as usize, align_of::<Heap>());
        let heap_size = 1024 + x;
        let heap_end = heap_start + heap_size;
        syscalls::memop(0, heap_end);

        // arguments are not used in Tock applications
        main(0, ptr::null());
    }

    loop {
        ::syscalls::yieldk();
    }
}
