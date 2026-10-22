#include <stdio.h>
#include <unistd.h>

int main() {
    printf("Nimbus init starting...\n");

    //launching the shell
    execl("../shell/nsh", "nsh", NULL);

    // if execl returns, rav, not only are you stinky but your bum ahh coding skills are bad.
    perror("execl failed");
    return 1;
}