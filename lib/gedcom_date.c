/* -------------------------------------------------------------------------
 * gedcom_date.c -- Defines the GEDCOM date parser.
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

#include <string.h>
#include <ctype.h>

#include "gedcom_types.h"
#include "gedcom_date.h"


/* general token defines */

#define tkERROR            ( -2 )
#define tkEOF              ( -1 )
#define tkNONE             (  0 )

#define tkNUMBER           (  1 )
#define tkMONTH            (  2 )
#define tkAPPROXIMATED     (  3 )
#define tkRANGE            (  4 )
#define tkPERIOD           (  5 )
#define tkINTERPRETED      (  6 )
#define tkLPAREN           (  7 )
#define tkRPAREN           (  8 )
#define tkBC               (  9 )
#define tkAND              ( 10 )
#define tkTO               ( 11 )
#define tkSLASH            ( 12 )
#define tkSTATUS           ( 13 )
#define tkOTHER            ( 14 )

/* specific token defines */

#define tkJANUARY          (  1 )
#define tkFEBRUARY         (  2 )
#define tkMARCH            (  3 )
#define tkAPRIL            (  4 )
#define tkMAY              (  5 )
#define tkJUNE             (  6 )
#define tkJULY             (  7 )
#define tkAUGUST           (  8 )
#define tkSEPTEMBER        (  9 )
#define tkOCTOBER          ( 10 )
#define tkNOVEMBER         ( 11 )
#define tkDECEMBER         ( 12 )

#define tkVENDEMIAIRE      ( 13 )
#define tkBRUMAIRE         ( 14 )
#define tkFRIMAIRE         ( 15 )
#define tkNIVOSE           ( 16 )
#define tkPLUVIOSE         ( 17 )
#define tkVENTOSE          ( 18 )
#define tkGERMINAL         ( 19 )
#define tkFLOREAL          ( 20 )
#define tkPRAIRIAL         ( 21 )
#define tkMESSIDOR         ( 22 )
#define tkTHERMIDOR        ( 23 )
#define tkFRUCTIDOR        ( 24 )
#define tkJOUR_COMP        ( 25 ) 
#define tkJOUR             ( 26 )
#define tkCOMP             ( 27 )

#define tkTISHRI           ( 28 )
#define tkCHESHVAN         ( 29 )
#define tkKISLEV           ( 30 )
#define tkTEVET            ( 31 )
#define tkSHEVAT           ( 32 )
#define tkADAR             ( 33 )
#define tkADAR_SHENI       ( 34 )
#define tkNISAN            ( 35 )
#define tkIYAR             ( 36 )
#define tkSIVAN            ( 37 )
#define tkTAMMUZ           ( 38 )
#define tkAV               ( 39 )
#define tkELUL             ( 40 )
#define tkSHENI            ( 41 )

#define tkABOUT            ( 80 )
#define tkCALCULATED       ( 81 )
#define tkESTIMATED        ( 82 )
#define tkBEFORE           ( 83 )
#define tkAFTER            ( 84 )
#define tkBETWEEN          ( 85 )
#define tkFROM             ( 86 )

#define tkCHILD            ( 87 )
#define tkCLEARED          ( 88 )
#define tkCOMPLETED        ( 89 )
#define tkINFANT           ( 90 )
#define tkPRE1970          ( 91 )
#define tkQUALIFIED        ( 92 )
#define tkSTILLBORN        ( 93 )
#define tkSUBMITTED        ( 94 )
#define tkUNCLEARED        ( 95 )
#define tkBIC              ( 96 ) /* Born In the Covenant */
#define tkDNS              ( 97 ) /* Do Not Submit */
#define tkDNSCAN           ( 98 ) /* Do Not Submit / Cancelled */
#define tkDEAD             ( 99 )

/* states */

#define ST_DV_ERROR              ( -1 )
#define ST_DV_START              (  1 )
#define ST_DV_DATE               (  2 )
#define ST_DV_DATE_APPROX        (  3 )
#define ST_DV_DATE_RANGE         (  4 )
#define ST_DV_TO                 (  5 )
#define ST_DV_DATE_PERIOD        (  6 )
#define ST_DV_DATE_INTERP        (  7 )
#define ST_DV_DATE_PHRASE        (  8 )
#define ST_DV_AND                (  9 )
#define ST_DV_STATUS             ( 10 )
#define ST_DV_END                ( 11 )

#define ST_DT_ERROR              ( -1 )
#define ST_DT_START              (  1 )
#define ST_DT_NUMBER             (  2 )
#define ST_DT_MONTH              (  3 )
#define ST_DT_SLASH              (  4 )
#define ST_DT_BC                 (  5 )
#define ST_DT_END                (  6 )

/* make sure this array is ALWAYS sorted by lexeme, ascending */

static char *default_months[] = { "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };

static char *hebrew_months[] = { "Tishri", "Cheshvan", "Kislev", "Tevet", "Shevat", "Adar",
                                 "Adar Sheni", "Nisan", "Iyar", "Sivan", "Tammuz", "Av",
                                 "Elul", "Sheni" };

static char *french_months[] = { "Vend", "Brum", "Frim", "Niv", "Pluv", "Vent", "Germ", "Flor",
                                 "Prair", "Mess", "Therm", "Fruct", "J. Comp", "Jour", "Comp" };

static struct {
  char *lexeme;
  int   general;
  int   specific;
} tokenTable[] = {
  { "(",               tkLPAREN,          0 },
  { ")",               tkRPAREN,          0 },
  { "-",               tkSLASH,           0 },
  { "/",               tkSLASH,           0 },
  { "AAV",             tkMONTH,           tkAV },
  { "ABOUT",           tkAPPROXIMATED,    tkABOUT },
  { "ABT",             tkAPPROXIMATED,    tkABOUT },
  { "ADAR",            tkMONTH,           tkADAR },
  { "ADR",             tkMONTH,           tkADAR },
  { "AFTER",           tkRANGE,           tkAFTER },
  { "AND",             tkAND,             0 },
  { "APRIL",           tkMONTH,           tkAPRIL },
  { "AUGUST",          tkMONTH,           tkAUGUST },
  { "AV",              tkMONTH,           tkAV },
  { "BC",              tkBC,              0 },
  { "BEFORE",          tkRANGE,           tkBEFORE },
  { "BETWEEN",         tkRANGE,           tkBETWEEN },
  { "BIC",             tkSTATUS,          tkBIC },
  { "BRUMAIRE",        tkMONTH,           tkBRUMAIRE },
  { "CALCULATED",      tkAPPROXIMATED,    tkCALCULATED },
  { "CHESHVAN",        tkMONTH,           tkCHESHVAN },
  { "CHILD",           tkSTATUS,          tkCHILD },
  { "CLEARED",         tkSTATUS,          tkCLEARED },
  { "COMPLETED",       tkSTATUS,          tkCOMPLETED },
  { "COMPLIMENTAIRS",  tkMONTH,           tkCOMP },
  { "CSH",             tkMONTH,           tkCHESHVAN },
  { "DEAD",            tkSTATUS,          tkDEAD },
  { "DECEMBER",        tkMONTH,           tkDECEMBER },
  { "DNS",             tkSTATUS,          tkDNS },
  { "DNSCAN",          tkSTATUS,          tkDNSCAN },
  { "ELL",             tkMONTH,           tkELUL },
  { "ELUL",            tkMONTH,           tkELUL },
  { "ESTIMATED",       tkAPPROXIMATED,    tkESTIMATED },
  { "FEBRUARY",        tkMONTH,           tkFEBRUARY },
  { "FLOREAL",         tkMONTH,           tkFLOREAL },
  { "FRIMAIRE",        tkMONTH,           tkFRIMAIRE },
  { "FROM",            tkPERIOD,          tkFROM },
  { "FRUCTIDOR",       tkMONTH,           tkFRUCTIDOR },
  { "GERMINAL",        tkMONTH,           tkGERMINAL },
  { "INFANT",          tkSTATUS,          tkINFANT },
  { "INTERPRETED",     tkINTERPRETED,     0 },
  { "IYAR",            tkMONTH,           tkIYAR },
  { "IYR",             tkMONTH,           tkIYAR },
  { "JANUARY",         tkMONTH,           tkJANUARY },
  { "JOUR",            tkMONTH,           tkJOUR },
  { "JULY",            tkMONTH,           tkJULY },
  { "JUNE",            tkMONTH,           tkJUNE },
  { "KISLEV",          tkMONTH,           tkKISLEV },
  { "KSL",             tkMONTH,           tkKISLEV },
  { "MARCH",           tkMONTH,           tkMARCH },
  { "MAY",             tkMONTH,           tkMAY },
  { "MESSIDOR",        tkMONTH,           tkMESSIDOR },
  { "NISAN",           tkMONTH,           tkNISAN },
  { "NIVOSE",          tkMONTH,           tkNIVOSE },
  { "NOVEMBER",        tkMONTH,           tkNOVEMBER },
  { "NSN",             tkMONTH,           tkNISAN },
  { "OCTOBER",         tkMONTH,           tkOCTOBER },
  { "PLUVIOSE",        tkMONTH,           tkPLUVIOSE },
  { "PRAIRIAL",        tkMONTH,           tkPRAIRIAL },
  { "PRE1970",         tkSTATUS,          tkPRE1970 },
  { "QUALIFIED",       tkSTATUS,          tkQUALIFIED },
  { "SEPTEMBER",       tkMONTH,           tkSEPTEMBER },
  { "SHENI",           tkMONTH,           tkSHENI },
  { "SHEVAT",          tkMONTH,           tkSHEVAT },
  { "SHV",             tkMONTH,           tkSHEVAT },
  { "SIVAN",           tkMONTH,           tkSIVAN },
  { "STILLBORN",       tkSTATUS,          tkSTILLBORN },
  { "SUBMITTED",       tkSTATUS,          tkSUBMITTED },
  { "SVN",             tkMONTH,           tkSIVAN },
  { "TAMMUZ",          tkMONTH,           tkTAMMUZ },
  { "TEVET",           tkMONTH,           tkTEVET },
  { "THERMIDOR",       tkMONTH,           tkTHERMIDOR },
  { "TISHRI",          tkMONTH,           tkTISHRI },
  { "TMZ",             tkMONTH,           tkTAMMUZ },
  { "TO",              tkTO,              0 },
  { "TSH",             tkMONTH,           tkTISHRI },
  { "TVT",             tkMONTH,           tkTEVET },
  { "UNCLEARED",       tkSTATUS,          tkUNCLEARED },
  { "VENDEMIAIRE",     tkMONTH,           tkVENDEMIAIRE },
  { "VENTOSE",         tkMONTH,           tkVENTOSE },
  { 0,                 0,                 0 }
};

/* date value state transitions:
 *   <start> -> { <status>, <date>, <date_approx>, <date_range>, <to>, <date_period>, <date_interp>, <date_phrase>, <end> }
 *   <date> -> { <date_phrase>, <and>, <to>, <end> }
 *   <date_approx> -> { <date> }
 *   <date_range> -> { <date> }
 *   <date_period> -> { <date> }
 *   <date_interp> -> { <date> }
 *   <date_phrase> -> { <end> }
 *   <and> -> { <date> }
 *   <to> -> { <date> }
 *   <status> -> { <end> }
 *   <end> -> {}
 *
 * date state transitions:
 *   <start> -> { <number>, <month> }
 *   <number> -> { <month>, <number>, <slash>, <bc>, <end> }
 *   <month> -> { <number>, <end> }
 *   <slash> -> { <number> }
 *   <bc> -> { <end> }
 *   <end> -> {}
 */

typedef struct {
  int state;
  int input;
  int nextState;
  int action;
} gedSTATE_ENTRY_t;

typedef struct {
  char *buffer;
  int   lastGeneralToken;
  int   lastSpecificToken;
  int   pos;
} gedPARSER_STATE_t;

static gedSTATE_ENTRY_t dateValueStateTable[] = {
  { ST_DV_START,        tkNUMBER,         ST_DV_DATE,          0 },  /* 0: inc dates read, parse a date */
  { ST_DV_START,        tkMONTH,          ST_DV_DATE,          0 },  /* 0: inc dates read, parse a date */
  { ST_DV_START,        tkAPPROXIMATED,   ST_DV_DATE_APPROX,   1 },  /* 1: set the approx type */
  { ST_DV_START,        tkRANGE,          ST_DV_DATE_RANGE,    2 },  /* 2: set the range type */
  { ST_DV_START,        tkTO,             ST_DV_TO,            3 },  /* 3: set the period type */
  { ST_DV_START,        tkPERIOD,         ST_DV_DATE_PERIOD,   3 },  /* 3: set the period type */
  { ST_DV_START,        tkINTERPRETED,    ST_DV_DATE_INTERP,   4 },  /* 4: set interpreted */
  { ST_DV_START,        tkLPAREN,         ST_DV_DATE_PHRASE,   5 },  /* 5: get remaining buffer as phrase */
  { ST_DV_START,        tkSTATUS,         ST_DV_STATUS,       10 },  /* 10: set status */
  { ST_DV_START,        tkEOF,            ST_DV_END,           6 },  /* 6: if 'between' and not second date read, error, else terminate */

  { ST_DV_DATE,         tkLPAREN,         ST_DV_DATE_PHRASE,   7 },  /* 7: if 'interpreted', get remaining buffer as phrase */
  { ST_DV_DATE,         tkAND,            ST_DV_AND,           8 },  /* 8: if 'between', prepare to read next date */
  { ST_DV_DATE,         tkTO,             ST_DV_TO,            9 },  /* 9: if 'from', set FROMTO, prepare to read next date */
  { ST_DV_DATE,         tkEOF,            ST_DV_END,           6 },  /* 6: if 'between' and not second date read, error, else terminate */
  
  { ST_DV_DATE_APPROX,  tkNUMBER,         ST_DV_DATE,          0 }, /* 0: inc dates read, parse a date */
  { ST_DV_DATE_APPROX,  tkMONTH,          ST_DV_DATE,          0 }, /* 0: inc dates read, parse a date */
  
  { ST_DV_DATE_RANGE,   tkNUMBER,         ST_DV_DATE,          0 }, /* 0: inc dates read, parse a date */
  { ST_DV_DATE_RANGE,   tkMONTH,          ST_DV_DATE,          0 }, /* 0: inc dates read, parse a date */
  
  { ST_DV_TO,           tkNUMBER,         ST_DV_DATE,          0 }, /* 0: inc dates read, parse a date */
  { ST_DV_TO,           tkMONTH,          ST_DV_DATE,          0 }, /* 0: inc dates read, parse a date */
  
  { ST_DV_DATE_PERIOD,  tkNUMBER,         ST_DV_DATE,          0 }, /* 0: inc dates read, parse a date */
  { ST_DV_DATE_PERIOD,  tkMONTH,          ST_DV_DATE,          0 }, /* 0: inc dates read, parse a date */
  
  { ST_DV_DATE_INTERP,  tkNUMBER,         ST_DV_DATE,          0 }, /* 0: inc dates read, parse a date */
  { ST_DV_DATE_INTERP,  tkMONTH,          ST_DV_DATE,          0 }, /* 0: inc dates read, parse a date */

  { ST_DV_DATE_PHRASE,  tkEOF,            ST_DV_END,           6 }, /* 6: if 'between' and not second date read, error, else terminate */

  { ST_DV_AND,          tkNUMBER,         ST_DV_DATE,          0 }, /* 0: inc dates read, parse a date */
  { ST_DV_AND,          tkMONTH,          ST_DV_DATE,          0 }, /* 0: inc dates read, parse a date */

  { ST_DV_TO,           tkNUMBER,         ST_DV_DATE,          0 }, /* 0: inc dates read, parse a date */
  { ST_DV_TO,           tkMONTH,          ST_DV_DATE,          0 }, /* 0: inc dates read, parse a date */

  { ST_DV_STATUS,       tkEOF,            ST_DV_END,           6 },

  { 0, 0, 0, 0 }
};


static gedSTATE_ENTRY_t dateStateTable[] = {
  { ST_DT_START,        tkNUMBER,        ST_DT_NUMBER,         0 }, /* 0: store number, set NUMBER */
  { ST_DT_START,        tkMONTH,         ST_DT_MONTH,          1 }, /* 1: if MONTH, then error, else set number to be day, set month, set MONTH */

  { ST_DT_NUMBER,       tkMONTH,         ST_DT_MONTH,          1 }, /* 1: if MONTH, then error, else set number to be day, set month, set MONTH */
  { ST_DT_NUMBER,       tkSLASH,         ST_DT_SLASH,          2 }, /* 2: if SLASH, then error, else set SLASH, set number to be year */
  { ST_DT_NUMBER,       tkBC,            ST_DT_BC,             3 }, /* 3: if not SLASH set number to be year, set bc */
  { ST_DT_NUMBER,       tkEOF,           ST_DT_END,            4 }, /* 4: if not SLASH set number to be year, terminate */

  { ST_DT_MONTH,        tkNUMBER,        ST_DT_NUMBER,         5 }, /* 5: if NUMBER, set number to be day.  set number to be year, store number, set NUMBER */
  { ST_DT_MONTH,        tkEOF,           ST_DT_END,            6 }, /* 6: terminate */

  { ST_DT_SLASH,        tkNUMBER,        ST_DT_NUMBER,         7 }, /* 7: set number to be year2 */
  
  { ST_DT_BC,           tkEOF,           ST_DT_END,            6 }, /* 6: terminate */

  { 0, 0, 0, 0 }
};


static void appendDateText( gedDATE_t *date, ofCHAR_t *buffer );


static int getToken( gedPARSER_STATE_t* parser, int* specific ) {
  char lexeme[ 256 ];
  int  lexPos;
  int  currentToken;
  int  startPos;

  startPos = parser->pos;

  /* if we've got a token saved in the parser, return it */
  if( parser->lastGeneralToken != tkNONE ) {
    int general = parser->lastGeneralToken;
    *specific = parser->lastSpecificToken;
    parser->lastGeneralToken = tkNONE;
    parser->lastSpecificToken = tkNONE;
    return general;
  }

  /* eat leading white-space */
  while( isspace( parser->buffer[ parser->pos ] ) ) {
    parser->pos++;
  }

  /* if the buffer is empty, return tkEOF */
  if( parser->buffer[ parser->pos ] == '\0' ) {
    *specific = tkNONE;
    return tkEOF;
  }

  lexPos = 0;

  /* if it's a number, parse it out and return it */

  if( isdigit( parser->buffer[ parser->pos ] ) ) {
    while( isdigit( parser->buffer[ parser->pos ] ) ) {
      lexeme[ lexPos ] = parser->buffer[ parser->pos ];
      parser->pos++;
      lexPos++;
    }
    lexeme[ lexPos ] = 0;
    *specific = atoi( lexeme );
    return tkNUMBER;
  }

  currentToken = 0;

  /* if it is not a number, incrementally look at each token in the table */
  while( tokenTable[ currentToken ].lexeme != 0 ) {
    lexeme[ lexPos++ ] = toupper( parser->buffer[ parser->pos++ ] );
    lexeme[ lexPos ] = 0;

    if( lexeme[ lexPos-1 ] != tokenTable[ currentToken ].lexeme[ lexPos-1 ] ) {
      while( ( tokenTable[ currentToken ].lexeme != 0 ) && 
             ( strncmp( tokenTable[ currentToken ].lexeme, lexeme, lexPos ) < 0 ) )
      {
        currentToken++;
      }

      /* if the lexeme does not appear in the table, exit with an error */
      if( tokenTable[ currentToken ].lexeme == 0 ||
          strncmp( tokenTable[ currentToken ].lexeme, lexeme, lexPos ) != 0 )
      {
        break;
      }
    }

    /* if the lexeme terminates, return the value of the current token */
    if( ( isalpha( lexeme[0] ) && !isalnum( parser->buffer[ parser->pos ] ) ) ||
        ( !isalpha( lexeme[0] ) && ( tokenTable[ currentToken ].lexeme[ lexPos ] == 0 ) ) ) 
    {
      *specific = tokenTable[ currentToken ].specific;
      return tokenTable[ currentToken ].general;
    }

    if( tokenTable[ currentToken ].lexeme[ lexPos ] == '\0' ) {
      /* if the current token terminates before the lexeme, then we have an error */
      break;
    }
  }

  parser->pos = startPos;

  *specific = tkNONE;
  return tkERROR;
}


static void putToken( gedPARSER_STATE_t* parser, int general, int specific )
{
  parser->lastGeneralToken = general;
  parser->lastSpecificToken = specific;
}


static int validateMonthForType( int month, int calType ) {
  switch( calType ) {
    case gctGREGORIAN:
    case gctJULIAN:
      if( month >= tkJANUARY && month <= tkDECEMBER ) {
        return ( month - tkJANUARY + 1 );
      }
      break;
    case gctHEBREW:
      if( month >= tkTISHRI && month <= tkELUL ) {
        return ( month - tkTISHRI + 1 );
      }
      break;
    case gctFRENCH:
      if( month >= tkVENDEMIAIRE && month <= tkJOUR_COMP ) {
        return ( month - tkVENDEMIAIRE + 1 );
      }
      break;
  }

  return -1;
}


#define gedfNONE            ( 0x0000 )
#define gedfBETWEEN         ( 0x0001 )
#define gedfFROM            ( 0x0002 )
#define gedfINTERP          ( 0x0004 )
#define gedfNUMBER          ( 0x0008 )
#define gedfMONTH           ( 0x0010 )
#define gedfSLASH           ( 0x0020 )


static int parseDatePart( gedPARSER_STATE_t* parser, gedDATE_t* datePart, int type ) {
  int state;
  int transitionFound;
  int general;
  int specific;
  int number;
  int i;
  int flags;
  int month;

  state = ST_DT_START;
  flags = gedfNONE;

  memset( datePart, 0, sizeof( *datePart ) );
  number = 0;

  datePart->type = type;
  if( type == gctGREGORIAN ) {
    datePart->data.dateGregorian.adbc = gedadbcAD;
  }

  while( ( state != ST_DT_END ) && ( state != ST_DT_ERROR ) ) {
    general = getToken( parser, &specific );
    transitionFound = 0;

    switch( general ) {
      case tkNUMBER:
      case tkMONTH:
      case tkSLASH:
      case tkBC:
      case tkEOF:
      case tkERROR:
        break;

      default:
        putToken( parser, general, specific );
        general = tkEOF;
        specific = tkNONE;
        break;
    }

    for( i = 0; dateStateTable[ i ].state > 0; i++ ) {
      if( ( dateStateTable[ i ].state == state ) &&
          ( dateStateTable[ i ].input == general ) )
      {
        state = dateStateTable[ i ].nextState;
        transitionFound = 1;

        switch( dateStateTable[ i ].action ) {
          /* 0: store number, set NUMBER */
          case 0:
            number = specific;
            flags |= gedfNUMBER;
            break;

          /* 1: if MONTH, then error, else set number to be day, set month, set MONTH */
          case 1:
            if( type == gctFRENCH ) {
              /* if the token is "JOUR", make sure they also typed at least
               * part of "COMPLIMENTAIRES" */

              switch( specific ) {
                case tkJOUR:
                  general = getToken( parser, &specific );
                  if( general != tkMONTH && specific != tkCOMP ) {
                    state = ST_DT_ERROR;
                    putToken( parser, general, specific );
                    break;
                  } // fall through

                case tkCOMP:
                  specific = tkJOUR_COMP;
                  break;
              }
            } else if( type == gctHEBREW ) {
              /* if the token is "ADAR", see if it is followed by "SHENI",
               * and if it is, change the month to "ADAR SHENI" */

              if( specific == tkADAR ) {
                general = getToken( parser, &specific );
                if( general == tkMONTH && specific == tkSHENI ) {
                  specific = tkADAR_SHENI;
                } else {
                  putToken( parser, general, specific );
                }
              }
            }

            if( ( flags & gedfMONTH ) != 0 ) {
              state = ST_DT_ERROR;
            } else {
              month = validateMonthForType( specific, type );
              if( month < 1 ) {
                state = ST_DT_ERROR;
              } else if( type == gctGREGORIAN ) {
                datePart->data.dateGregorian.day = number;
                datePart->data.dateGregorian.month = month;
              } else {
                datePart->data.dateOther.day = number;
                datePart->data.dateOther.month = month;
              }
              flags |= gedfMONTH;
              number = 0;
            }
            break;

          /* 2: if SLASH, then error, else set SLASH, set number to be year */
          case 2:
            if( ( ( flags & gedfSLASH ) != 0 ) || ( type != gctGREGORIAN ) ) {
              state = ST_DT_ERROR;
            } else {
              if( number > 0 ) {
                datePart->data.dateGregorian.year = number;
              }
              datePart->data.dateGregorian.flags |= gfYEARSPAN;
              number = 0;
              flags |= gedfSLASH;
            }
            break;

          /* 3: if not SLASH set number to be year, set bc */
          case 3:
            if( type != gctGREGORIAN ) {
              state = ST_DT_ERROR;
              break;
            }
            datePart->data.dateGregorian.adbc = gedadbcBC;
            /* fall through */

          /* 4: if not SLASH set number to be year, terminate */
          case 4:
            if( ( number > 0 ) && ( ( flags & gedfSLASH ) == 0 ) ) {
              if( type == gctGREGORIAN ) {
                datePart->data.dateGregorian.year = number;
              } else {
                datePart->data.dateOther.year = number;
              }
              number = 0;
            }
  
          /* 6: terminate */
          case 6:
            /* because dateGregorian and dateOther overlap (in the union),
             * and because their first fields are identical, we can do this
             * and it will work regardless of the calendar type */

            if( datePart->data.dateOther.day < 1 ) {
              datePart->data.dateOther.flags |= gfNODAY;
            }
            
            if( datePart->data.dateOther.month < 1 ) {
              datePart->data.dateOther.flags |= gfNOMONTH;
            }
            
            if( datePart->data.dateOther.year < 1 ) {
              datePart->data.dateOther.flags |= gfNOYEAR;
            }
            break;

          /* 5: if NUMBER, set number to be day.  set number to be year, store number, set NUMBER */
          case 5:
            if( ( number > 0 ) && ( ( flags & gedfNUMBER ) != 0 ) ) {
              if( type == gctGREGORIAN ) {
                datePart->data.dateGregorian.day = number;
              } else {
                datePart->data.dateOther.day = number;
              }
            }

            if( type == gctGREGORIAN ) {
              datePart->data.dateGregorian.year = specific;
            } else {
              datePart->data.dateOther.year = specific;
            }

            number = 0;
            flags |= gedfNUMBER;
            break;

          /* 7: set number to be year2 */
          case 7:
            datePart->data.dateGregorian.year2 = ( specific % 100 );
            number = 0;
            break;
        }

        break;
      }
    }

    if( !transitionFound ) {
      state = ST_DT_ERROR;
    }
  }

  if( state == ST_DT_ERROR ) {
    return -1;
  }

  return 0;
}


int parseGEDCOMDate( ofCHAR_t* dateString, gedDATEVALUE_t* date, int type )
{
  int state;
  int transitionFound;
  int general;
  int specific;
  int i;
  int savePos;
  int datesRead;
  int flags;
  int rc;
  char buffer[ 256 ];
  gedPARSER_STATE_t parser;
  gedDATE_t *datePart;

  memset( &parser, 0, sizeof( parser ) );
  memset( date, 0, sizeof( *date ) );

  parser.buffer = dateString;

  state = ST_DV_START;
  flags = gedfNONE;
  datesRead = 0;
  datePart = &( date->date1 );
  datePart->flags = gfNONE;

  while( ( state != ST_DV_END ) && ( state != ST_DV_ERROR ) ) {
    savePos = parser.pos;
    general = getToken( &parser, &specific );
    transitionFound = 0;

    for( i = 0; dateValueStateTable[ i ].state > 0; i++ ) {
      if( ( dateValueStateTable[ i ].state == state ) &&
          ( dateValueStateTable[ i ].input == general ) )
      {
        transitionFound = 1;
        state = dateValueStateTable[ i ].nextState;

        switch( dateValueStateTable[ i ].action ) {
          /* 0: inc dates read, parse a date */                               
          case 0:
            putToken( &parser, general, specific );
            rc = parseDatePart( &parser, datePart, type );
            if( rc != 0 ) {
              state = ST_DV_ERROR;
            } else {
              datesRead++;
              datePart = &( date->date2 );
              datePart->flags = gfNONE;
            }
            break;

          /* 1: set the approx type */                                        
          case 1:
            switch( specific ) {
              case tkABOUT:
                date->flags = gcABOUT;
                break;
              case tkCALCULATED:
                date->flags = gcCALCULATED;
                break;
              case tkESTIMATED:
                date->flags = gcESTIMATED;
                break;
            }
            break;

          /* 2: set the range type */                                         
          case 2:
            switch( specific ) {
              case tkBEFORE:
                date->flags = gcBEFORE;
                break;
              case tkAFTER:
                date->flags = gcAFTER;
                break;
              case tkBETWEEN:
                date->flags = gcBETWEEN;
                flags |= gedfBETWEEN;
                break;
            }
            break;

          /* 3: set the period type */
          case 3:
            if( general == tkTO ) {
              date->flags = gcTO;
            } else if( specific == tkFROM ) {
              date->flags = gcFROM;
              flags |= gedfFROM;
            }
            break;

          /* 4: set interpreted */                                            
          case 4:
            date->flags = gcINTERPRETED;
            flags |= gedfINTERP;
            break;

          /* 7: if 'interpreted', get remaining buffer as phrase */           
          case 7:
            if( ( flags & gedfINTERP ) == 0 ) {
              state = ST_DV_ERROR;
              break;
            } /* else, fall through and get the buffer */

          /* 5: get remaining buffer as phrase */                             
          case 5:
            strcpy( buffer, &(parser.buffer[ parser.pos ]) );
            i = strlen( buffer ) - 1;
            while( ( i >= 0 ) && ( isspace( buffer[ i ] ) ) ) {
              buffer[ i ] = '\0';
              i--;
            }
            if( buffer[ i ] == ')' ) {
              buffer[ i ] = '\0';
            }
            strncpy( datePart->data.phrase, buffer, gcMAXPHRASEBUFFERSIZE );
            datePart->data.phrase[ gcMAXPHRASEBUFFERSIZE ] = '\0';
            datePart->flags = gfPHRASE;
            parser.pos = strlen( parser.buffer );
            break;

          /* 6: if 'between' and not second date read, error, else terminate */
          case 6:
            if( ( ( flags & gedfBETWEEN ) != 0 ) && datesRead < 2 ) {
              state = ST_DV_ERROR;
            }
            /* else -- nextState is ST_DV_END, so we're done! */
            break;

          /* 7: see above 5 */

          /* 8: if 'between', prepare to read next date */                    
          case 8:
            if( ( flags & gedfBETWEEN ) == 0 ) {
              state = ST_DV_ERROR;
            }
            break;
              
          /* 9: if 'from', set FROMTO, prepare to read next date */                       
          case 9:
            if( ( flags & gedfFROM ) == 0 ) {
              state = ST_DV_ERROR;
            } else {
              date->flags = gcFROMTO;
            }
            break;

          /* 10: set status */
          case 10:
            switch( specific ) {
              case tkCHILD:
                date->flags = gcCHILD;
                break;
              case tkCLEARED:
                date->flags = gcCLEARED;
                break;
              case tkCOMPLETED:
                date->flags = gcCOMPLETED;
                break;
              case tkINFANT:
                date->flags = gcINFANT;
                break;
              case tkPRE1970:
                date->flags = gcPRE1970;
                break;
              case tkQUALIFIED:
                date->flags = gcQUALIFIED;
                break;
              case tkSTILLBORN:
                date->flags = gcSTILLBORN;
                break;
              case tkSUBMITTED:
                date->flags = gcSUBMITTED;
                break;
              case tkUNCLEARED:
                date->flags = gcUNCLEARED;
                break;
              case tkBIC:
                date->flags = gcBIC;
                break;
              case tkDNS:
                date->flags = gcDNS;
                break;
              case tkDNSCAN:
                date->flags = gcDNSCAN;
                break;
              case tkDEAD:
                date->flags = gcDEAD;
                break;
            }
            break;
        }
        break; // out of the for-loop
      }
    }

    if( !transitionFound ) {
      state = ST_DV_ERROR;
    }
  }

  if( state == ST_DV_ERROR ) {
    parser.pos = savePos;
    datePart->flags = gfNONSTANDARD;
    strncpy( datePart->data.phrase, &( parser.buffer[ parser.pos ] ), gcMAXPHRASEBUFFERSIZE );
    return -1;
  }

  return 0;
}


void buildGEDCOMDateString( gedDATEVALUE_t *date, ofCHAR_t *buffer )
{
  *buffer = '\0';

  switch( date->flags )
  {
    case gcABOUT:       strcat( buffer, "abt " ); break;
    case gcCALCULATED:  strcat( buffer, "cal " ); break;
    case gcESTIMATED:   strcat( buffer, "est " ); break;
    case gcBEFORE:      strcat( buffer, "bef " ); break;
    case gcAFTER:       strcat( buffer, "aft " ); break;
    case gcBETWEEN:     strcat( buffer, "bet " ); break;
    case gcFROM:
    case gcFROMTO:      strcat( buffer, "from " ); break;
    case gcTO:          strcat( buffer, "to " ); break;
    case gcINTERPRETED: strcat( buffer, "int " ); break;

    case gcCHILD:       strcat( buffer, "child" ); return;
    case gcCLEARED:     strcat( buffer, "cleared" ); return;
    case gcCOMPLETED:   strcat( buffer, "completed" ); return;
    case gcINFANT:      strcat( buffer, "infant" ); return;
    case gcPRE1970:     strcat( buffer, "pre-1970" ); return;
    case gcQUALIFIED:   strcat( buffer, "qualified" ); return;
    case gcSTILLBORN:   strcat( buffer, "stillborn" ); return;
    case gcSUBMITTED:   strcat( buffer, "submitted" ); return;
    case gcUNCLEARED:   strcat( buffer, "uncleared" ); return;
    case gcBIC:         strcat( buffer, "BIC" ); return;
    case gcDNS:         strcat( buffer, "DNS" ); return;
    case gcDNSCAN:      strcat( buffer, "DNSCAN" ); return;
    case gcDEAD:        strcat( buffer, "dead" ); return;
  }

  appendDateText( &date->date1, buffer );

  switch( date->flags )
  {
    case gcBETWEEN: strcat( buffer, " and " ); break;
    case gcFROMTO:  strcat( buffer, " to " ); break;
    default: return;
  }

  appendDateText( &date->date2, buffer );
}


void buildGEDCOMDatePartString( gedDATE_t *date, ofCHAR_t *buffer )
{
  *buffer = '\0';
  appendDateText( date, buffer );
}


static void appendDateText( gedDATE_t *date, ofCHAR_t *buffer )
{
  char **months;
  char   temp[20];

  switch( date->flags )
  {
    case gfPHRASE:
    case gfNONSTANDARD:
      strcat( buffer, date->data.phrase );
      return;
  }

  switch( date->type )
  {
    case gctHEBREW:
      months = hebrew_months;
      break;

    case gctFRENCH:
      months = french_months;
      break;

    default:
      months = default_months;
  }

  if( ( date->data.dateOther.flags & gfNODAY ) == 0 )
  {
    sprintf( temp, "%d", date->data.dateOther.day );
    strcat( buffer, temp );
    if( ( date->data.dateOther.flags & gfNOMONTH ) == 0 || ( date->data.dateOther.flags & gfNOYEAR ) == 0 )
      strcat( buffer, " " );
  }

  if( ( date->data.dateOther.flags & gfNOMONTH ) == 0 )
  {
    strcat( buffer, months[ date->data.dateOther.month-1 ] );
    if( ( date->data.dateOther.flags & gfNOYEAR ) == 0 )
      strcat( buffer, " " );
  }

  if( ( date->data.dateOther.flags & gfNOYEAR ) == 0 )
  {
    sprintf( temp, "%d", date->data.dateOther.year );
    strcat( buffer, temp );
    if( date->data.dateOther.flags & gfYEARSPAN )
    {
      strcat( buffer, "-" );
      sprintf( temp, "%d", date->data.dateGregorian.year2 );
      strcat( buffer, temp );
    }
  }

  if( date->type == gctGREGORIAN && date->data.dateGregorian.adbc != gedadbcAD )
  {
    strcat( buffer, " BC" );
  }
}
