
#[ctor::ctor]
fn pre() {
    println!("Fuck you");
}
/*
#[no_mangle]
unsafe extern "C" fn write(fd: libc::c_int, buf: *const libc::c_void, len: libc::size_t) -> libc::ssize_t {
    println!("hook'd!");
    libc::write(fd, buf, len)
}
*/
#[cfg(test)]
mod test;
