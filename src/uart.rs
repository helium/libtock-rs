use callback::CallbackSubscription;
use callback::SubscribableCallback;
use syscalls;

const DRIVER_NUMBER: usize = 0xA3_0000;
const RECEIVE_BYTE: usize = 1;

pub fn receive_byte<CB>(callback: CB) -> ReceiveByte<CB> {
    ReceiveByte { callback }
}

pub struct ReceiveByte<CB> {
    callback: CB,
}

impl<CB: FnMut(isize)> SubscribableCallback for ReceiveByte<CB> {
    fn call_rust(&mut self, arg0: usize, _: usize, _: usize) {
        (self.callback)(arg0 as isize);
    }
}

impl<CB> ReceiveByte<CB>
where
    Self: SubscribableCallback,
{
    pub fn start_measurement(&mut self) -> Result<CallbackSubscription, isize> {
        let subscription = syscalls::subscribe(DRIVER_NUMBER, RECEIVE_BYTE, self)?;
        //unsafe { syscalls::command(DRIVER_NUMBER, START_RECEIVING, 0, 0) };
        Ok(subscription)
    }
}
