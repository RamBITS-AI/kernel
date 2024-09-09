# Build an OS Kernel from the scratch

To install WSL2 (Windows Subsystem for Linux 2) on a Windows Home PC and then install Ubuntu 22.04, follow the detailed steps below.

### Step 1: Enable WSL on Windows Home

1. **Open PowerShell as Administrator**:
   - Press `Windows Key + X` and select "Windows PowerShell (Admin)" or search for PowerShell in the Start menu, then right-click and select "Run as administrator."

2. **Install WSL**:
   - Run the following command in PowerShell to enable the necessary WSL feature and install WSL2:

   ```bash
   wsl --install
   ```

   This command installs WSL and sets WSL 2 as the default version. It also installs the default Linux distribution (typically Ubuntu) unless you specify otherwise.

   - After the installation completes, **restart your PC** as prompted.

3. **Check if WSL 2 is Installed**:
   - After restarting, open PowerShell again (no need for admin privileges this time) and run:

   ```bash
   wsl --list --verbose
   ```

   This will list all installed distributions and confirm if WSL 2 is installed.

   If `wsl --install` doesn’t automatically set WSL 2 as the default, you can set it manually by running:

   ```bash
   wsl --set-default-version 2
   ```

4. **Ensure Virtual Machine Platform is Enabled**:
   - In case the virtual machine platform is not enabled, run the following command in PowerShell (Administrator mode) to ensure it's enabled:

   ```bash
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```

   Afterward, restart your PC to ensure the changes take effect.

### Step 2: Install Ubuntu 22.04 in WSL2

1. **Open Microsoft Store**:
   - Search for "Microsoft Store" in the Start menu and open it.

2. **Search for Ubuntu 22.04**:
   - In the Store, search for "Ubuntu 22.04" and click on the **Ubuntu 22.04 LTS** distribution.

3. **Install Ubuntu 22.04**:
   - Click the **Install** button to download and install Ubuntu 22.04.

4. **Launch Ubuntu 22.04**:
   - Once installed, click **Launch** in the Store, or you can open it anytime by typing "Ubuntu 22.04" in the Start menu.
   - On first launch, it will take a few minutes to set up your Ubuntu environment.

5. **Create a Username and Password**:
   - You’ll be asked to create a UNIX username and password. This user will have sudo privileges for administrative tasks.

6. **Verify Installation**:
   - After the setup is complete, you can verify that you are using Ubuntu 22.04 by running the following command inside the Ubuntu terminal:

   ```bash
   lsb_release -a
   ```

   This will display the version of Ubuntu that you have installed.

### Step 3: Update and Upgrade Ubuntu 22.04

After installation, it's recommended to update the package list and upgrade any outdated packages:

```bash
sudo apt update
sudo apt upgrade
```

This will ensure that your Ubuntu 22.04 installation is up-to-date with the latest security patches and software.

### Step 4: Set WSL 2 as Default for Ubuntu (if needed)

To check the version of WSL that Ubuntu 22.04 is running on, run:

```bash
wsl --list --verbose
```

If it shows Ubuntu is running WSL 1 and you want to switch to WSL 2, you can manually set it using the following command:

```bash
wsl --set-version Ubuntu-22.04 2
```

This command ensures that Ubuntu 22.04 runs on WSL 2.

### Step 5: (Optional) Set WSL 2 as the Default for All Future Distros

To set WSL 2 as the default version for all Linux distributions going forward, run this command in PowerShell:

```bash
wsl --set-default-version 2
```

### Step 6: Verify WSL Version

You can check the WSL version and the status of installed distributions with the following command:

```bash
wsl --list --verbose
```

This will show the list of installed distributions and the version of WSL each one is using (WSL 1 or WSL 2).

### Step 7: Launch Ubuntu 22.04 in WSL2

```bash
wsl -d Ubuntu-22.04
```

Now, let's install `i386-elf-gcc` and `i386-elf-ld` on WSL2 (Windows Subsystem for Linux 2).

### Step 8: Update and Install Required Dependencies

Install the dependencies required for building GCC and Binutils:

```bash
sudo apt install build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo
```

### Step 9: Download Binutils and GCC Source Code

You need to download the source code for `binutils` and `gcc`:

```bash
mkdir -p ~/cross-compiler/src
cd ~/cross-compiler/src

# Download binutils
wget https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.gz
tar -xf binutils-2.40.tar.gz

# Download GCC
wget https://ftp.gnu.org/gnu/gcc/gcc-12.2.0/gcc-12.2.0.tar.gz
tar -xf gcc-12.2.0.tar.gz
```

### Step 10: Build and Install Binutils

Now, build and install `binutils`:

```bash
mkdir -p ~/cross-compiler/build-binutils
cd ~/cross-compiler/build-binutils

# Configure binutils
../src/binutils-2.40/configure --target=i386-elf --prefix=/usr/local/cross --disable-nls --disable-werror

# Build and install
make
sudo make install
```

### Step 11: Build and Install GCC

GCC requires that you have already installed the i386 cross-compiler libraries, so you need to build it with minimal features first and then complete the installation after.

1. **Build a minimal GCC (without libraries)**:

```bash
mkdir -p ~/cross-compiler/build-gcc
cd ~/cross-compiler/build-gcc

# Configure GCC
../src/gcc-12.2.0/configure --target=i386-elf --prefix=/usr/local/cross --disable-nls --enable-languages=c --without-headers

# Build and install GCC
make all-gcc
sudo make install-gcc
```

2. **Finish GCC installation (with full libraries)**:

```bash
make all-target-libgcc
sudo make install-target-libgcc
```

### Step 12: Add the Cross-Compiler to Your Path

To make sure you can use the `i386-elf-gcc` and `i386-elf-ld` commands from anywhere, add the cross-compiler binary directory to your `PATH`:

```bash
echo 'export PATH=$PATH:/usr/local/cross/bin' >> ~/.bashrc
source ~/.bashrc
```

### Step 13: Verify Installation

Check if `i386-elf-gcc` and `i386-elf-ld` are installed and working:

```bash
i386-elf-gcc --version
i386-elf-ld --version
```

If everything was done correctly, this should display the version information for both tools.

Now, install `qemu-system-i386` in WSL2 after setting up the `i386-elf-gcc` and `i386-elf-ld` cross-compiler.

### Step 14: Install QEMU

Now, you can install the QEMU emulator. Specifically, for i386, you'll need `qemu-system-i386`:

```bash
sudo apt install qemu-system-i386
```

### Step 15: Verify Installation
Once the installation is complete, verify that QEMU is installed by checking its version:

```bash
qemu-system-i386 --version
```

This should display the installed version of QEMU, confirming that the installation was successful.

### Step 16: Write Code for Minimal Kernel (in C and Assembly)

Here's a minimal kernel written in C (in combination with assembly for bootstrapping):

1. **Bootloader (Assembly - `boot.asm`)**: This small piece of assembly code loads the kernel into memory and starts it.

```asm
[BITS 16]
[ORG 0x7C00]

start:
    mov ax, 0x07C0      ; Set up 16-bit stack
    add ax, 288         ; Move beyond the bootloader space
    mov ss, ax
    mov sp, 4096

    mov ax, 0x0         ; Set video mode
    mov ds, ax
    mov es, ax

    call load_kernel

load_kernel:
    ; Load kernel
    mov bx, 0x1000      ; Kernel load address
    mov dh, 2           ; Number of sectors to read
    mov dl, 0x00        ; First floppy
    mov ah, 0x02        ; Read sector function
    mov al, dh          ; Number of sectors
    mov ch, 0x00        ; Cylinder number
    mov cl, 0x02        ; Sector number
    mov dh, 0x00        ; Head number
    int 0x13            ; BIOS interrupt to read disk
    jc load_kernel      ; Retry if failed

    jmp 0x1000          ; Jump to the loaded kernel

times 510 - ($ - $$) db 0  ; Fill to 510 bytes
dw 0xAA55                 ; Boot signature
```

2. **Kernel (C - `ramz_kernel.c`)**: A simple C program to display a message on the screen.

```c
void print_string(char* str) {
    unsigned short* VideoMemory = (unsigned short*)0xB8000; // Video memory address for text mode
    int i = 0;
    while (str[i] != '\0') {
        VideoMemory[i] = (VideoMemory[i] & 0xFF00) | str[i];
        i++;
    }
}

void kernel_main() {
    print_string("Hello, World! This is Ramz kernel.");
    while (1); // Infinite loop to prevent the kernel from exiting
}
```

3. **Linker Script (`link.ld`)**: This file tells the linker where to place the kernel in memory.

```ld
OUTPUT_FORMAT(elf32-i386)
ENTRY(kernel_main)

SECTIONS {
    . = 0x1000;
    .text : { *(.text) }
    .data : { *(.data) }
    .bss  : { *(.bss)  }
}
```

### Step 17: Build and Run

1. Assemble the bootloader:
   ```bash
   nasm -f bin boot.asm -o boot.bin
   ```

2. Compile the kernel:
   ```bash
   i386-elf-gcc -ffreestanding -c ramz_kernel.c -o ramz_kernel.o
   ```

3. Link the kernel:
   ```bash
   i386-elf-ld -o ramz_kernel.bin -Ttext 0x1000 ramz_kernel.o --oformat binary
   ```

4. Combine the bootloader and kernel:
   ```bash
   cat boot.bin ramz_kernel.bin > os-image
   ```

5. Run the kernel in an emulator (e.g., QEMU):
   ```bash
   qemu-system-i386 -drive format=raw,file=os-image
   ```

### What this does:

- The `boot.asm` file is a basic bootloader that loads the kernel from disk into memory and jumps to its entry point.
- The kernel itself is written in C and prints "Hello, World!" to the screen using direct memory access to video memory.
- This example is extremely minimal and just demonstrates some basics of how kernels operate. It doesn't include any advanced features like memory management, process scheduling, or device drivers.
