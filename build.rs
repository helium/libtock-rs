extern crate gcc;

fn main() {
    gcc::Build::new()
        .compiler("clang")
        .pic(false)
        .flag("-I/usr/arm-none-eabi/include")
        .flag("-fropi")
        .flag("-frwpi")
        .flag("-DUSE_LOCKS=0")
        .flag("-DHAVE_MMAP=0")
        .file("malloc.c")
        .compile("libmalloc.a");
}
