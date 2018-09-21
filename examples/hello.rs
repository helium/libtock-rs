#![feature(alloc)]
#![no_std]

extern crate alloc;
extern crate tock;

use tock::console::Console;
use tock::timer;
use tock::timer::Duration;

// TODO: Make format!/alloc::string::ToString work
fn main() {
    let mut console = Console::new();

    for i in 0.. {
        console.write(tock::fmt::u32_as_decimal(i));
        timer::sleep(Duration::from_ms(500))
    }
}
