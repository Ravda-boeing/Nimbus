#include <stdio.h>
#include <string.h>

int main() {
    printf("Nimbus Shell (nsh)\n");

    char input[256];

    while (1) {
        printf("nsh> ");
        fgets(input, sizeof(input), stdin);

        // Remove the newline character from the input
        input[strcspn(input, "\n")] = 0;

        if (strcmp(input, "exit") == 0) {
            break;
        }

        // Here you would normally execute the command entered by the user
        printf("You entered: %s\n", input);
    }
    return 0;
}