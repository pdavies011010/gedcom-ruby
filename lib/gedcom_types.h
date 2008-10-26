/* -------------------------------------------------------------------------
 * gedcom_types.h -- Defines the types used for the GEDCOM date parser.
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

#ifndef __OFTYPES_H__
#define __OFTYPES_H__

typedef enum {
  ofFALSE = 0,
  ofTRUE
} ofBOOL_t;

typedef signed char ofI8_t;
typedef unsigned char ofUI8_t;
typedef signed short int ofI16_t;
typedef unsigned short int ofUI16_t;
typedef signed long int ofI32_t;
typedef unsigned long int ofUI32_t;

typedef unsigned char ofCHAR_t;

#endif // __OFTYPES_H__
