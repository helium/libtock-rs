#![feature(alloc)]
#![no_std]
extern crate alloc;
extern crate tock;

use alloc::string::String;
use tock::console::Console;
use tock::uart;



// Prevents the compiler from dropping the subscription too early.
#[allow(unreachable_code)]
fn main() {

    let mut console = Console::new();
    console.write(String::from("Started Nextnode UART\r\n"));
    let mut _with_callback = uart::receive_byte(|byte: isize| {
        let mut output = String::new();
        output.push(byte as u8 as char);
        console.write(output);
    });


    loop {
        tock::syscalls::yieldk();
    }
}
