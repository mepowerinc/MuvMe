#import <dlfcn.h>
#import <sys/types.h>
#import "AppDelegate.h"
#import "AGParser.h"
#import "AGFileManager.h"

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif

#ifndef DEBUG
static void disable_gdb() {
    void *handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}

#endif

int main(int argc, char *argv[]){
    // disable debugger
#ifndef DEBUG
    disable_gdb();
#endif

    // disable logs
#ifndef DEBUG
    fclose(stderr);
#endif

    @autoreleasepool {
        // main
        UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
