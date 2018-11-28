#if defined(__linux__)
    #error "Cross-compiler required!"
#elif !defined(__i386__)
    #error "Requires an i686-elf cross-compiler!"
#endif

/**
 * Entry point of our OS in C
 */
void kernel_main(void) 
{
	/* Does nothing */
}