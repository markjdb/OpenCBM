/*
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License
 *  as published by the Free Software Foundation; either version
 *  2 of the License, or (at your option) any later version.
 *
 *  Copyright 1999-2004 Michael Klein <michael.klein@puffin.lb.shuttle.de>
 *  Copyright 2001-2004 Spiro Trikaliotis
 */

/*! ************************************************************** 
** \file include/opencbm.h \n
** \author Michael Klein <michael.klein@puffin.lb.shuttle.de> \n
** \version $Id: opencbm.h,v 1.7 2005-01-22 19:50:40 strik Exp $ \n
** \authors With modifications to fit on Windows from
**    Spiro Trikaliotis \n
** \n
** \brief DLL interface for accessing the driver
**
****************************************************************/

#ifndef OPENCBM_H
#define OPENCBM_H

#ifdef __cplusplus
extern "C" {
#endif

#include <sys/types.h>

#ifdef WIN32
  /* we have windows */

#include <windows.h>

# if defined DLL
#  define EXTERN __declspec(dllexport) /*!< we are exporting the functions */
# else
#  define EXTERN __declspec(dllimport) /*!< we are importing the functions */
# endif


#define CBMAPIDECL __cdecl /*!< On Windows, we need c-type function declarations */
# define __u_char unsigned char /*!< __u_char as unsigned char */
# define CBM_FILE HANDLE /*!< The "file descriptor" for an opened driver */

#elif defined(__MSDOS__)

  /* we have MS-DOS */

#include <stdlib.h>
                                                         
# define EXTERN extern /*!< EXTERN is not defined on MS-DOS */
# define CBMAPIDECL /*!< CBMAPIDECL is a dummy on MS-DOS */
# define WINAPI /*!< WINAPI is a dummy on MS-DOS */
# define CBM_FILE int /*!< The "file descriptor" for an opened driver */
# define __u_char unsigned char /*!< __u_char as unsigned char */

extern int vdd_init(void);
extern void vdd_uninit(void);
extern int vdd_install_iohook(CBM_FILE f, int IoBaseAddress, int CableType);
extern int vdd_uninstall_iohook(CBM_FILE f);
extern void vdd_usleep(CBM_FILE f, unsigned int howlong);
#else

  /* we have linux */

# define EXTERN extern /*!< EXTERN is not defined on Linux */
# define CBMAPIDECL /*!< CBMAPIDECL is a dummy on Linux */
# define WINAPI /*!< WINAPI is a dummy on Linux */
# define CBM_FILE int /*!< The "file descriptor" for an opened driver */

#endif

/* specifiers for the lines */
#define IEC_DATA   0x01 /*!< Specify the DATA line */
#define IEC_CLOCK  0x02 /*!< Specify the CLOCK line */
#define IEC_ATN    0x04 /*!< Specify the ATN line */
#define IEC_RESET  0x08 /*!< Specify the RESET line */

/*! Specifies the type of a device for cbm_identify() */
enum cbm_device_type_e 
{
    cbm_dt_unknown = -1, /*!< The device could not be identified */
    cbm_dt_cbm1541,      /*!< The device is a VIC 1541 */
    cbm_dt_cbm1570,      /*!< The device is a VIC 1570 */
    cbm_dt_cbm1571,      /*!< The device is a VIC 1571 */
    cbm_dt_cbm1581       /*!< The device is a VIC 1581 */
};

/*! \todo FIXME: port isn't used yet */
EXTERN int CBMAPIDECL cbm_driver_open(CBM_FILE *f, int port);
EXTERN void CBMAPIDECL cbm_driver_close(CBM_FILE f);

/*! \todo FIXME: port isn't used yet */
EXTERN const char * CBMAPIDECL cbm_get_driver_name(int port);

EXTERN int CBMAPIDECL cbm_listen(CBM_FILE f, __u_char dev, __u_char secadr);
EXTERN int CBMAPIDECL cbm_talk(CBM_FILE f, __u_char dev, __u_char secadr);

EXTERN int CBMAPIDECL cbm_open(CBM_FILE f, __u_char dev, __u_char secadr, const void *fname, size_t len);
EXTERN int CBMAPIDECL cbm_close(CBM_FILE f, __u_char dev, __u_char secadr);

EXTERN int CBMAPIDECL cbm_raw_read(CBM_FILE f, void *buf, size_t size);
EXTERN int CBMAPIDECL cbm_raw_write(CBM_FILE f, const void *buf, size_t size);

EXTERN int CBMAPIDECL cbm_unlisten(CBM_FILE f);
EXTERN int CBMAPIDECL cbm_untalk(CBM_FILE f);

EXTERN int CBMAPIDECL cbm_get_eoi(CBM_FILE f);
EXTERN int CBMAPIDECL cbm_clear_eoi(CBM_FILE f);

EXTERN int CBMAPIDECL cbm_reset(CBM_FILE f);

EXTERN __u_char CBMAPIDECL cbm_pp_read(CBM_FILE f);
EXTERN void CBMAPIDECL cbm_pp_write(CBM_FILE f, __u_char c);

EXTERN int CBMAPIDECL cbm_iec_poll(CBM_FILE f);
EXTERN int CBMAPIDECL cbm_iec_get(CBM_FILE f, int line);
EXTERN void CBMAPIDECL cbm_iec_set(CBM_FILE f, int line);
EXTERN void CBMAPIDECL cbm_iec_release(CBM_FILE f, int line);
EXTERN void CBMAPIDECL cbm_iec_setrelease(CBM_FILE f, int mask, int line);
EXTERN int CBMAPIDECL cbm_iec_wait(CBM_FILE f, int line, int state);

EXTERN int CBMAPIDECL cbm_upload(CBM_FILE f, __u_char dev, int adr, const void *prog, size_t size);

EXTERN int CBMAPIDECL cbm_device_status(CBM_FILE f, __u_char dev, void *buf, size_t bufsize);
EXTERN int CBMAPIDECL cbm_exec_command(CBM_FILE f, __u_char dev, const void *cmd, size_t len);

EXTERN int CBMAPIDECL cbm_identify(CBM_FILE f, __u_char drv,
                                   enum cbm_device_type_e *t,
                                   const char **type_str);


EXTERN char CBMAPIDECL cbm_petscii2ascii_c(char character);
EXTERN char CBMAPIDECL cbm_ascii2petscii_c(char character);
EXTERN char * CBMAPIDECL cbm_petscii2ascii(char *str);
EXTERN char * CBMAPIDECL cbm_ascii2petscii(char *str);

#ifdef __cplusplus
}
#endif

#endif /* OPENCBM_H */
