void print_string(char* str) {
    unsigned short* VideoMemory = (unsigned short*)0xB8000; // Video memory address for text mode
    int i = 0;
    while (str[i] != '\0') {
        VideoMemory[i] = (0x0F << 8) | str[i];  // Display text with white foreground on black background
        i++;
    }
}

void _start() {
    print_string("Hello, World! This is Ramz kernel.");
    while (1); // Infinite loop to prevent the kernel from exiting
}
