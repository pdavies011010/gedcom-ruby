/* -------------------------------------------------------------------------
 * gedcom.c -- the glue code between the GEDCOM::Date class and the C code.
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

#include <ruby.h>

#include "gedcom_types.h"
#include "gedcom_date.h"


static VALUE mGEDCOM;
static VALUE cDate;
static VALUE cDatePart;
static VALUE eDateFormatException;


static VALUE static_gedcom_date_new( int    argc,
                                     VALUE *argv,
                                     VALUE  klass );

static VALUE static_gedcom_date_get_format( VALUE self );
static VALUE static_gedcom_date_get_date1( VALUE self );
static VALUE static_gedcom_date_get_date2( VALUE self );
static VALUE static_gedcom_date_to_s( VALUE self );
static VALUE static_gedcom_date_is_date( VALUE self );
static VALUE static_gedcom_date_is_range( VALUE self );

static VALUE static_gedcom_date_get_type( VALUE self );
static VALUE static_gedcom_date_get_flags( VALUE self );
static VALUE static_gedcom_date_get_phrase( VALUE self );
static VALUE static_gedcom_date_has_day( VALUE self );
static VALUE static_gedcom_date_has_month( VALUE self );
static VALUE static_gedcom_date_has_year( VALUE self );
static VALUE static_gedcom_date_has_year_span( VALUE self );
static VALUE static_gedcom_date_day( VALUE self );
static VALUE static_gedcom_date_month( VALUE self );
static VALUE static_gedcom_date_year( VALUE self );
static VALUE static_gedcom_date_to_year( VALUE self );
static VALUE static_gedcom_date_epoch( VALUE self );
static VALUE static_gedcom_datepart_to_s( VALUE self );


static VALUE static_gedcom_date_new( int    argc,
                                     VALUE *argv,
                                     VALUE  klass )
{
  char *s_date;
  int   i_type;
  int   rc;
  VALUE date;
  VALUE type;
  VALUE new_date;
  gedDATEVALUE_t parsed_date;
  gedDATEVALUE_t *temp;

  if( rb_scan_args( argc, argv, "11", &date, &type ) == 1 )
  {
    i_type = gctDEFAULT;
  }
  else
  {
    i_type = FIX2INT( type );
  }
    
  s_date = STR2CSTR( date );

  rc = parseGEDCOMDate( s_date, &parsed_date, i_type );

  if( rc != 0 )
  {
    VALUE err_msg;

    err_msg = rb_str_new2( "format error at '" );

    if( parsed_date.date1.flags & gfNONSTANDARD )
      rb_str_cat( err_msg, parsed_date.date1.data.phrase, strlen( parsed_date.date1.data.phrase ) );
    else
      rb_str_cat( err_msg, parsed_date.date2.data.phrase, strlen( parsed_date.date2.data.phrase ) );

    rb_str_cat( err_msg, "'", 1 );

    if( rb_block_given_p() )
    {
      rb_yield( err_msg );
    }
    else
    {
      rb_raise( eDateFormatException, STR2CSTR( err_msg ) );
    }
  }

  new_date = Data_Make_Struct( klass, gedDATEVALUE_t, 0, 0, temp );
  memcpy( temp, &parsed_date, sizeof( parsed_date ) );

  return new_date;
}


static VALUE static_gedcom_date_get_format( VALUE self )
{
  gedDATEVALUE_t *date;

  Data_Get_Struct( self, gedDATEVALUE_t, date );

  return FIX2INT( date->flags );
}


static VALUE static_gedcom_date_get_date1( VALUE self )
{
  gedDATEVALUE_t *date;
  gedDATE_t      *date_part;
  VALUE           date1;

  Data_Get_Struct( self, gedDATEVALUE_t, date );

  date1 = Data_Make_Struct( cDatePart, gedDATE_t, 0, 0, date_part );
  memcpy( date_part, &date->date1, sizeof( gedDATE_t ) );

  return date1;
}


static VALUE static_gedcom_date_get_date2( VALUE self )
{
  gedDATEVALUE_t *date;
  gedDATE_t      *date_part;
  VALUE           date2;

  Data_Get_Struct( self, gedDATEVALUE_t, date );

  date2 = Data_Make_Struct( cDatePart, gedDATE_t, 0, 0, date_part );
  memcpy( date_part, &date->date2, sizeof( gedDATE_t ) );

  return date2;
}


static VALUE static_gedcom_date_get_type( VALUE self )
{
  gedDATE_t *date_part;

  Data_Get_Struct( self, gedDATE_t, date_part );

  return INT2FIX( date_part->type );
}


static VALUE static_gedcom_date_get_flags( VALUE self )
{
  gedDATE_t *date_part;

  Data_Get_Struct( self, gedDATE_t, date_part );

  return INT2FIX( date_part->flags );
}


static VALUE static_gedcom_date_get_phrase( VALUE self )
{
  gedDATE_t *date_part;

  Data_Get_Struct( self, gedDATE_t, date_part );

  if( date_part->flags != gfPHRASE )
    rb_raise( eDateFormatException, "date does not contain a phrase" );

  return rb_str_new2( date_part->data.phrase );
}


static VALUE static_gedcom_date_has_day( VALUE self )
{
  gedDATE_t *date_part;

  Data_Get_Struct( self, gedDATE_t, date_part );

  if( date_part->flags == gfPHRASE )
    return Qfalse;

  return ( ( date_part->data.dateOther.flags & gfNODAY ) ? Qfalse : Qtrue );
}


static VALUE static_gedcom_date_has_month( VALUE self )
{
  gedDATE_t *date_part;

  Data_Get_Struct( self, gedDATE_t, date_part );

  if( date_part->flags == gfPHRASE )
    return Qfalse;

  return ( ( date_part->data.dateOther.flags & gfNOMONTH ) ? Qfalse : Qtrue );
}


static VALUE static_gedcom_date_has_year( VALUE self )
{
  gedDATE_t *date_part;

  Data_Get_Struct( self, gedDATE_t, date_part );

  if( date_part->flags == gfPHRASE )
    return Qfalse;

  return ( ( date_part->data.dateOther.flags & gfNOYEAR ) ? Qfalse : Qtrue );
}


static VALUE static_gedcom_date_has_year_span( VALUE self )
{
  gedDATE_t *date_part;

  Data_Get_Struct( self, gedDATE_t, date_part );

  if( date_part->flags == gfPHRASE )
    return Qfalse;

  return ( ( date_part->data.dateOther.flags & gfYEARSPAN ) ? Qtrue : Qfalse );
}


static VALUE static_gedcom_date_day( VALUE self )
{
  gedDATE_t *date_part;

  Data_Get_Struct( self, gedDATE_t, date_part );

  if( date_part->flags == gfPHRASE || date_part->data.dateOther.flags & gfNODAY )
    rb_raise( eDateFormatException, "date has no day" );

  return INT2FIX( date_part->data.dateOther.day );
}


static VALUE static_gedcom_date_month( VALUE self )
{
  gedDATE_t *date_part;

  Data_Get_Struct( self, gedDATE_t, date_part );

  if( date_part->flags == gfPHRASE || date_part->data.dateOther.flags & gfNOMONTH )
    rb_raise( eDateFormatException, "date has no month" );

  return INT2FIX( date_part->data.dateOther.month );
}


static VALUE static_gedcom_date_year( VALUE self )
{
  gedDATE_t *date_part;

  Data_Get_Struct( self, gedDATE_t, date_part );

  if( date_part->flags == gfPHRASE || date_part->data.dateOther.flags & gfNOYEAR )
    rb_raise( eDateFormatException, "date has no year" );

  return INT2FIX( date_part->data.dateOther.year );
}


static VALUE static_gedcom_date_to_year( VALUE self )
{
  gedDATE_t *date_part;

  Data_Get_Struct( self, gedDATE_t, date_part );

  if( date_part->flags == gfPHRASE || ( date_part->data.dateOther.flags & gfYEARSPAN == 0 ) )
    rb_raise( eDateFormatException, "date has no year span" );

  return INT2FIX( date_part->data.dateGregorian.year2 );
}


static VALUE static_gedcom_date_epoch( VALUE self )
{
  gedDATE_t *date_part;

  Data_Get_Struct( self, gedDATE_t, date_part );

  if( date_part->flags == gfPHRASE || date_part->type != gctGREGORIAN )
    rb_raise( eDateFormatException, "only gregorian dates have epoch" );

  return rb_str_new2( ( date_part->data.dateGregorian.adbc == gedadbcBC ) ? "BC" : "AD" );
}


static VALUE static_gedcom_date_to_s( VALUE self )
{
  gedDATEVALUE_t *date;
  char text[ 512 ];

  Data_Get_Struct( self, gedDATEVALUE_t, date );

  buildGEDCOMDateString( date, text );

  return rb_str_new2( text );
}


static VALUE static_gedcom_datepart_to_s( VALUE self )
{
  gedDATE_t *date_part;
  char       text[ 512 ];

  Data_Get_Struct( self, gedDATE_t, date_part );

  buildGEDCOMDatePartString( date_part, text );

  return rb_str_new2( text );
}


static VALUE static_gedcom_date_is_date( VALUE self )
{
  gedDATEVALUE_t *date;

  Data_Get_Struct( self, gedDATEVALUE_t, date );

  switch( date->flags )
  {
    case gcNONE:
    case gcABOUT:
    case gcCALCULATED:
    case gcESTIMATED:
    case gcBEFORE:
    case gcAFTER:
    case gcBETWEEN:
    case gcFROM:
    case gcTO:
    case gcFROMTO:
    case gcINTERPRETED:
      return Qtrue;
  }

  return Qfalse;
}


static VALUE static_gedcom_date_is_range( VALUE self )
{
  gedDATEVALUE_t *date;

  Data_Get_Struct( self, gedDATEVALUE_t, date );

  switch( date->flags )
  {
    case gcBETWEEN:
    case gcFROMTO:
      return Qtrue;
  }

  return Qfalse;
}


void Init__gedcom()
{
  VALUE cDateType;

  mGEDCOM   = rb_define_module( "GEDCOM" );
  cDate     = rb_define_class_under( mGEDCOM, "Date", rb_cObject );
  cDatePart = rb_define_class_under( mGEDCOM, "DatePart", rb_cObject );

  eDateFormatException = rb_define_class_under( mGEDCOM, "DateFormatException", rb_eException );

  rb_define_const( cDate, "NONE",  INT2FIX( gcNONE ) );

  rb_define_const( cDate, "ABOUT",       INT2FIX( gcABOUT ) );
  rb_define_const( cDate, "CALCULATED",  INT2FIX( gcCALCULATED ) );
  rb_define_const( cDate, "ESTIMATED",   INT2FIX( gcESTIMATED ) );
  rb_define_const( cDate, "BEFORE",      INT2FIX( gcBEFORE ) );
  rb_define_const( cDate, "AFTER",       INT2FIX( gcAFTER ) );
  rb_define_const( cDate, "BETWEEN",     INT2FIX( gcBETWEEN ) );
  rb_define_const( cDate, "FROM",        INT2FIX( gcFROM ) );
  rb_define_const( cDate, "TO",          INT2FIX( gcTO ) );
  rb_define_const( cDate, "FROMTO",      INT2FIX( gcFROMTO ) );
  rb_define_const( cDate, "INTERPRETED", INT2FIX( gcINTERPRETED ) );

  rb_define_const( cDate, "CHILD",       INT2FIX( gcCHILD ) );
  rb_define_const( cDate, "CLEARED",     INT2FIX( gcCLEARED ) );
  rb_define_const( cDate, "COMPLETED",   INT2FIX( gcCOMPLETED ) );
  rb_define_const( cDate, "INFANT",      INT2FIX( gcINFANT ) );
  rb_define_const( cDate, "PRE1970",     INT2FIX( gcPRE1970 ) );
  rb_define_const( cDate, "QUALIFIED",   INT2FIX( gcQUALIFIED ) );
  rb_define_const( cDate, "STILLBORN",   INT2FIX( gcSTILLBORN ) );
  rb_define_const( cDate, "SUBMITTED",   INT2FIX( gcSUBMITTED ) );
  rb_define_const( cDate, "UNCLEARED",   INT2FIX( gcUNCLEARED ) );
  rb_define_const( cDate, "BIC",         INT2FIX( gcBIC ) );
  rb_define_const( cDate, "DNS",         INT2FIX( gcDNS ) );
  rb_define_const( cDate, "DNSCAN",      INT2FIX( gcDNSCAN ) );
  rb_define_const( cDate, "DEAD",        INT2FIX( gcDEAD ) );

  rb_define_singleton_method( cDate, "new", static_gedcom_date_new, -1 );
  
  rb_define_method( cDate, "format", static_gedcom_date_get_format, 0 );
  rb_define_method( cDate, "first", static_gedcom_date_get_date1, 0 );
  rb_define_method( cDate, "last", static_gedcom_date_get_date2, 0 );
  rb_define_method( cDate, "to_s", static_gedcom_date_to_s, 0 );
  rb_define_method( cDate, "is_date?", static_gedcom_date_is_date, 0 );
  rb_define_method( cDate, "is_range?", static_gedcom_date_is_range, 0 );

  rb_define_const( cDatePart, "NONE",        INT2FIX( gfNONE ) );
  rb_define_const( cDatePart, "PHRASE",      INT2FIX( gfPHRASE ) );
  rb_define_const( cDatePart, "NONSTANDARD", INT2FIX( gfNONSTANDARD ) );

  rb_define_const( cDatePart, "NOFLAG",      INT2FIX( gfNOFLAG ) );
  rb_define_const( cDatePart, "NODAY",       INT2FIX( gfNODAY ) );
  rb_define_const( cDatePart, "NOMONTH",     INT2FIX( gfNOMONTH ) );
  rb_define_const( cDatePart, "NOYEAR",      INT2FIX( gfNOYEAR ) );
  rb_define_const( cDatePart, "YEARSPAN",    INT2FIX( gfYEARSPAN ) );

  rb_define_method( cDatePart, "calendar",        static_gedcom_date_get_type, 0 );
  rb_define_method( cDatePart, "compliance",      static_gedcom_date_get_flags, 0 );
  rb_define_method( cDatePart, "phrase",          static_gedcom_date_get_phrase, 0 );
  rb_define_method( cDatePart, "has_day?",        static_gedcom_date_has_day, 0 );
  rb_define_method( cDatePart, "has_month?",      static_gedcom_date_has_month, 0 );
  rb_define_method( cDatePart, "has_year?",       static_gedcom_date_has_year, 0 );
  rb_define_method( cDatePart, "has_year_span?",  static_gedcom_date_has_year_span, 0 );
  rb_define_method( cDatePart, "day",             static_gedcom_date_day, 0 );
  rb_define_method( cDatePart, "month",           static_gedcom_date_month, 0 );
  rb_define_method( cDatePart, "year",            static_gedcom_date_year, 0 );
  rb_define_method( cDatePart, "to_year",         static_gedcom_date_to_year, 0 );
  rb_define_method( cDatePart, "epoch",           static_gedcom_date_epoch, 0 );
  rb_define_method( cDatePart, "to_s",            static_gedcom_datepart_to_s, 0 );

  cDateType = rb_define_class_under( mGEDCOM, "DateType", rb_cObject );

  rb_define_const( cDateType, "GREGORIAN", INT2FIX( gctGREGORIAN ) );
  rb_define_const( cDateType, "JULIAN",    INT2FIX( gctJULIAN ) );
  rb_define_const( cDateType, "HEBREW",    INT2FIX( gctHEBREW ) );
  rb_define_const( cDateType, "FRENCH",    INT2FIX( gctFRENCH ) );
  rb_define_const( cDateType, "FUTURE",    INT2FIX( gctFUTURE ) );
  rb_define_const( cDateType, "UNKNOWN",   INT2FIX( gctUNKNOWN ) );
  rb_define_const( cDateType, "DEFAULT",   INT2FIX( gctDEFAULT ) );
}
