#include <efi.h>
#include <efilib.h>

#include <console.h>

EFI_STATUS
efi_main (EFI_HANDLE image, EFI_SYSTEM_TABLE *systab)
{
	InitializeLib(image, systab);

	console_alertbox((CHAR16 *[]) {
			L"BOOTSY UEFI TEST",
			L"",
			L"This file is used to prove you have managed",
			L"to execute an unsigned binary in UEFI",
			NULL,
		});

	return EFI_SUCCESS;
}
