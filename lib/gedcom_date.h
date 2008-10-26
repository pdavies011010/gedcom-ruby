/* -------------------------------------------------------------------------
 * gedcom_date.h -- Defines the interface for the GEDCOM date parser.
 * Copyright (C) 2003 Jamis Buck (jgb3@email.byu.edu)
 * -------------------------------------------------------------------------
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * ------------------------------------------------------------------------- */

#ifndef __GEDDATE_H__
#define __GEDDATE_H__

#ifdef __cplusplus
extern "C" {
#endif

#include "gedcom_types.h"

/* calendar types */

#define gctGREGORIAN   ( 0 )
#define gctJULIAN      ( 1 )
#define gctHEBREW      ( 2 )
#define gctFRENCH      ( 3 )
#define gctFUTURE      ( 4 )
#define gctUNKNOWN     ( 99 )

#define gctDEFAULT     gctGREGORIAN

/* date constants */

  #define gcNONE        ( 0 )

  /* approximated date constants */

  #define gcABOUT       ( 1 )
  #define gcCALCULATED  ( 2 )
  #define gcESTIMATED   ( 3 )

  /* date range constants */

  #define gcBEFORE      ( 4 )
  #define gcAFTER       ( 5 )
  #define gcBETWEEN     ( 6 )

  /* date period constants */

  #define gcFROM        ( 7 )
  #define gcTO          ( 8 )
  #define gcFROMTO      ( 9 )

  /* other date constants */

  #define gcINTERPRETED ( 10 )

  /* LDS ordinance constants */

  #define gcCHILD       ( 11 )
  #define gcCLEARED     ( 12 )
  #define gcCOMPLETED   ( 13 )
  #define gcINFANT      ( 14 )
  #define gcPRE1970     ( 15 )
  #define gcQUALIFIED   ( 16 )
  #define gcSTILLBORN   ( 17 )
  #define gcSUBMITTED   ( 18 )
  #define gcUNCLEARED   ( 19 )
  #define gcBIC         ( 20 ) /* Born In the Covenant */
  #define gcDNS         ( 21 ) /* Do Not Submit */
  #define gcDNSCAN      ( 22 ) /* Do Not Submit / Cancelled */
  #define gcDEAD        ( 23 )

/* date flags */

  #define gfNONE        (  0 )
  #define gfPHRASE      (  1 )
  #define gfNONSTANDARD (  2 )

/* date bit flags */

  #define gfNOFLAG      ( 0x00 )
  #define gfNODAY       ( 0x01 )
  #define gfNOMONTH     ( 0x02 )
  #define gfNOYEAR      ( 0x04 )
  #define gfYEARSPAN    ( 0x08 )

/* data type constants */

  #define gcMAXPHRASEBUFFERSIZE  ( 35 )

/* types */

typedef enum {
  gedadbcBC = 0,
  gedadbcAD
} gedADBC_t;

typedef struct {
  ofUI8_t   flags;
  ofUI8_t   day;
  ofUI8_t   month;
  ofUI16_t  year;
  ofUI8_t   year2;
  gedADBC_t adbc;
} gedDATEGREG_t;

typedef struct {
  ofUI8_t   flags;
  ofUI8_t   day;
  ofUI8_t   month;
  ofUI16_t  year;
} gedDATEGENERAL_t;

typedef ofCHAR_t  gedDATEPHRASE_t[ gcMAXPHRASEBUFFERSIZE ];

typedef struct {
  ofUI8_t type;
  ofUI8_t flags;
  union {
    gedDATEPHRASE_t  phrase;
    gedDATEGREG_t    dateGregorian;
    gedDATEGENERAL_t dateOther;
  } data;
} gedDATE_t;

typedef struct {
  ofUI8_t flags;
  gedDATE_t date1;
  gedDATE_t date2;
} gedDATEVALUE_t;


int parseGEDCOMDate( ofCHAR_t* dateString, gedDATEVALUE_t* date, int type );

void buildGEDCOMDateString( gedDATEVALUE_t *date, ofCHAR_t *buffer );

void buildGEDCOMDatePartString( gedDATE_t *date, ofCHAR_t *buffer );

#ifdef __cplusplus
} // extern "C"
#endif

#endif // __GEDDATE_H__
