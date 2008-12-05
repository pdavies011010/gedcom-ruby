# -------------------------------------------------------------------------
# gedcom_date_parser.rb -- module definition for GEDCOM date parser
# Copyright (C) 2008 Phillip Davies (binary011010@verizon.net)
# -------------------------------------------------------------------------
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# -------------------------------------------------------------------------
#
module GEDCOM_DATE_PARSER
  # Token Constants
  # General Tokens
  TKERROR = -2
  TKEOF = -1
  TKNONE = 0

  TKNUMBER = 1
  TKMONTH = 2
  TKAPPROXIMATED = 3
  TKRANGE = 4
  TKPERIOD = 5
  TKINTERPRETED = 6
  TKLPAREN = 7
  TKRPAREN = 8
  TKBC = 9
  TKAND = 10
  TKTO = 11
  TKSLASH = 12
  TKSTATUS = 13
  TKOTHER = 14

  # Specific Tokens
  TKJANUARY          =  1
  TKFEBRUARY         =  2
  TKMARCH            =  3
  TKAPRIL            =  4
  TKMAY              =  5
  TKJUNE             =  6
  TKJULY             =  7
  TKAUGUST           =  8
  TKSEPTEMBER        =  9
  TKOCTOBER          = 10
  TKNOVEMBER         = 11
  TKDECEMBER         = 12

  TKVENDEMIAIRE      = 13
  TKBRUMAIRE         = 14
  TKFRIMAIRE         = 15
  TKNIVOSE           = 16
  TKPLUVIOSE         = 17
  TKVENTOSE          = 18
  TKGERMINAL         = 19
  TKFLOREAL          = 20
  TKPRAIRIAL         = 21
  TKMESSIDOR         = 22
  TKTHERMIDOR        = 23
  TKFRUCTIDOR        = 24
  TKJOUR_COMP        = 25
  TKJOUR             = 26
  TKCOMP             = 27

  TKTISHRI           = 28
  TKCHESHVAN         = 29
  TKKISLEV           = 30
  TKTEVET            = 31
  TKSHEVAT           = 32
  TKADAR             = 33
  TKADAR_SHENI       = 34
  TKNISAN            = 35
  TKIYAR             = 36
  TKSIVAN            = 37
  TKTAMMUZ           = 38
  TKAV               = 39
  TKELUL             = 40
  TKSHENI            = 41

  TKABOUT            = 80
  TKCALCULATED       = 81
  TKESTIMATED        = 82
  TKBEFORE           = 83
  TKAFTER            = 84
  TKBETWEEN          = 85
  TKFROM             = 86

  TKCHILD            = 87
  TKCLEARED          = 88
  TKCOMPLETED        = 89
  TKINFANT           = 90
  TKPRE1970          = 91
  TKQUALIFIED        = 92
  TKSTILLBORN        = 93
  TKSUBMITTED        = 94
  TKUNCLEARED        = 95
  TKBIC              = 96   #Born In the Covenant
  TKDNS              = 97   #Do Not Submit
  TKDNSCAN           = 98   #Do Not Submit / Cancelled
  TKDEAD             = 99
  
  #states
  ST_DV_ERROR              = -1
  ST_DV_START              =  1
  ST_DV_DATE               =  2
  ST_DV_DATE_APPROX        =  3
  ST_DV_DATE_RANGE         =  4
  ST_DV_TO                 =  5
  ST_DV_DATE_PERIOD        =  6
  ST_DV_DATE_INTERP        =  7
  ST_DV_DATE_PHRASE        =  8
  ST_DV_AND                =  9
  ST_DV_STATUS             = 10
  ST_DV_END                = 11

  ST_DT_ERROR              = -1
  ST_DT_START              =  1
  ST_DT_NUMBER             =  2
  ST_DT_MONTH              =  3
  ST_DT_SLASH              =  4
  ST_DT_BC                 =  5
  ST_DT_END                =  6
  
  
  # After parsing, all flags should be available as booleans with accessors
  GCTGREGORIAN   = 0
  GCTJULIAN      = 1
  GCTHEBREW      = 2
  GCTFRENCH      = 3
  GCTFUTURE      = 4
  GCTUNKNOWN     = 99

  GCTDEFAULT     = GCTGREGORIAN

  # date constants 

  GCNONE        = 0

  # approximated date constants 

  GCABOUT       = 1
  GCCALCULATED  = 2
  GCESTIMATED   = 3

  # date range constants 

  GCBEFORE      = 4
  GCAFTER       = 5
  GCBETWEEN     = 6

  # date period constants 

  GCFROM        = 7
  GCTO          = 8
  GCFROMTO      = 9

  # other date constants 

  GCINTERPRETED = 10

  # LDS ordinance constants 

  GCCHILD       = 11
  GCCLEARED     = 12
  GCCOMPLETED   = 13
  GCINFANT      = 14
  GCPRE1970     = 15
  GCQUALIFIED   = 16
  GCSTILLBORN   = 17
  GCSUBMITTED   = 18
  GCUNCLEARED   = 19
  GCBIC         = 20 # Born In the Covenant 
  GCDNS         = 21 # Do Not Submit 
  GCDNSCAN      = 22 # Do Not Submit / Cancelled 
  GCDEAD        = 23

  # date flags 

  GFNONE        =  0
  GFPHRASE      =  1
  GFNONSTANDARD =  2

  # date bit flags 

  GFNOFLAG      = 0
  GFNODAY       = 1
  GFNOMONTH     = 2
  GFNOYEAR      = 4
  GFYEARSPAN    = 8

  # data type constants 

  GCMAXPHRASEBUFFERSIZE  = 35
  
  #  BC / AD
  GEDADBCBC = 0
  GEDADBCAD = 1
  
  Default_Months = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]

  Hebrew_Months = [ "Tishri", "Cheshvan", "Kislev", "Tevet", "Shevat", "Adar",
                                 "Adar Sheni", "Nisan", "Iyar", "Sivan", "Tammuz", "Av",
                                 "Elul", "Sheni" ]

  French_Months = [ "Vend", "Brum", "Frim", "Niv", "Pluv", "Vent", "Germ", "Flor",
                                 "Prair", "Mess", "Therm", "Fruct", "J. Comp", "Jour", "Comp" ]

  class Token
    attr_accessor :lexeme, :general, :specific
    def initialize(lex, gen, spec)
      @lexeme = lex
      @general = gen
      @specific = spec
    end
  end
  TokenTable = []
  TokenTable << Token.new("(",               TKLPAREN,          0 )
  TokenTable << Token.new(")",               TKRPAREN,          0 )
  TokenTable << Token.new("-",               TKSLASH,           0 )
  TokenTable << Token.new("/",               TKSLASH,           0 )
  TokenTable << Token.new("AAV",             TKMONTH,           TKAV )
  TokenTable << Token.new("ABOUT",           TKAPPROXIMATED,    TKABOUT )
  TokenTable << Token.new("ABT",             TKAPPROXIMATED,    TKABOUT )
  TokenTable << Token.new("ADAR",            TKMONTH,           TKADAR )
  TokenTable << Token.new("ADR",             TKMONTH,           TKADAR )
  TokenTable << Token.new("AFTER",           TKRANGE,           TKAFTER )
  TokenTable << Token.new("AND",             TKAND,             0 )
  TokenTable << Token.new("APRIL",           TKMONTH,           TKAPRIL )
  TokenTable << Token.new("AUGUST",          TKMONTH,           TKAUGUST )
  TokenTable << Token.new("AV",              TKMONTH,           TKAV )
  TokenTable << Token.new("BC",              TKBC,              0 )
  TokenTable << Token.new("BEFORE",          TKRANGE,           TKBEFORE )
  TokenTable << Token.new("BETWEEN",         TKRANGE,           TKBETWEEN )
  TokenTable << Token.new("BIC",             TKSTATUS,          TKBIC )
  TokenTable << Token.new("BRUMAIRE",        TKMONTH,           TKBRUMAIRE )
  TokenTable << Token.new("CALCULATED",      TKAPPROXIMATED,    TKCALCULATED )
  TokenTable << Token.new("CHESHVAN",        TKMONTH,           TKCHESHVAN )
  TokenTable << Token.new("CHILD",           TKSTATUS,          TKCHILD )
  TokenTable << Token.new("CLEARED",         TKSTATUS,          TKCLEARED )
  TokenTable << Token.new("COMPLETED",       TKSTATUS,          TKCOMPLETED )
  TokenTable << Token.new("COMPLIMENTAIRS",  TKMONTH,           TKCOMP )
  TokenTable << Token.new("CSH",             TKMONTH,           TKCHESHVAN )
  TokenTable << Token.new("DEAD",            TKSTATUS,          TKDEAD )
  TokenTable << Token.new("DECEMBER",        TKMONTH,           TKDECEMBER )
  TokenTable << Token.new("DNS",             TKSTATUS,          TKDNS )
  TokenTable << Token.new("DNSCAN",          TKSTATUS,          TKDNSCAN )
  TokenTable << Token.new("ELL",             TKMONTH,           TKELUL )
  TokenTable << Token.new("ELUL",            TKMONTH,           TKELUL )
  TokenTable << Token.new("ESTIMATED",       TKAPPROXIMATED,    TKESTIMATED )
  TokenTable << Token.new("FEBRUARY",        TKMONTH,           TKFEBRUARY )
  TokenTable << Token.new("FLOREAL",         TKMONTH,           TKFLOREAL )
  TokenTable << Token.new("FRIMAIRE",        TKMONTH,           TKFRIMAIRE )
  TokenTable << Token.new("FROM",            TKPERIOD,          TKFROM )
  TokenTable << Token.new("FRUCTIDOR",       TKMONTH,           TKFRUCTIDOR )
  TokenTable << Token.new("GERMINAL",        TKMONTH,           TKGERMINAL )
  TokenTable << Token.new("INFANT",          TKSTATUS,          TKINFANT )
  TokenTable << Token.new("INTERPRETED",     TKINTERPRETED,     0 )
  TokenTable << Token.new("IYAR",            TKMONTH,           TKIYAR )
  TokenTable << Token.new("IYR",             TKMONTH,           TKIYAR )
  TokenTable << Token.new("JANUARY",         TKMONTH,           TKJANUARY )
  TokenTable << Token.new("JOUR",            TKMONTH,           TKJOUR )
  TokenTable << Token.new("JULY",            TKMONTH,           TKJULY )
  TokenTable << Token.new("JUNE",            TKMONTH,           TKJUNE )
  TokenTable << Token.new("KISLEV",          TKMONTH,           TKKISLEV )
  TokenTable << Token.new("KSL",             TKMONTH,           TKKISLEV )
  TokenTable << Token.new("MARCH",           TKMONTH,           TKMARCH )
  TokenTable << Token.new("MAY",             TKMONTH,           TKMAY )
  TokenTable << Token.new("MESSIDOR",        TKMONTH,           TKMESSIDOR )
  TokenTable << Token.new("NISAN",           TKMONTH,           TKNISAN )
  TokenTable << Token.new("NIVOSE",          TKMONTH,           TKNIVOSE )
  TokenTable << Token.new("NOVEMBER",        TKMONTH,           TKNOVEMBER )
  TokenTable << Token.new("NSN",             TKMONTH,           TKNISAN )
  TokenTable << Token.new("OCTOBER",         TKMONTH,           TKOCTOBER )
  TokenTable << Token.new("PLUVIOSE",        TKMONTH,           TKPLUVIOSE )
  TokenTable << Token.new("PRAIRIAL",        TKMONTH,           TKPRAIRIAL )
  TokenTable << Token.new("PRE1970",         TKSTATUS,          TKPRE1970 )
  TokenTable << Token.new("QUALIFIED",       TKSTATUS,          TKQUALIFIED )
  TokenTable << Token.new("SEPTEMBER",       TKMONTH,           TKSEPTEMBER )
  TokenTable << Token.new("SHENI",           TKMONTH,           TKSHENI )
  TokenTable << Token.new("SHEVAT",          TKMONTH,           TKSHEVAT )
  TokenTable << Token.new("SHV",             TKMONTH,           TKSHEVAT )
  TokenTable << Token.new("SIVAN",           TKMONTH,           TKSIVAN )
  TokenTable << Token.new("STILLBORN",       TKSTATUS,          TKSTILLBORN )
  TokenTable << Token.new("SUBMITTED",       TKSTATUS,          TKSUBMITTED )
  TokenTable << Token.new("SVN",             TKMONTH,           TKSIVAN )
  TokenTable << Token.new("TAMMUZ",          TKMONTH,           TKTAMMUZ )
  TokenTable << Token.new("TEVET",           TKMONTH,           TKTEVET )
  TokenTable << Token.new("THERMIDOR",       TKMONTH,           TKTHERMIDOR )
  TokenTable << Token.new("TISHRI",          TKMONTH,           TKTISHRI )
  TokenTable << Token.new("TMZ",             TKMONTH,           TKTAMMUZ )
  TokenTable << Token.new("TO",              TKTO,              0 )
  TokenTable << Token.new("TSH",             TKMONTH,           TKTISHRI )
  TokenTable << Token.new("TVT",             TKMONTH,           TKTEVET )
  TokenTable << Token.new("UNCLEARED",       TKSTATUS,          TKUNCLEARED )
  TokenTable << Token.new("VENDEMIAIRE",     TKMONTH,           TKVENDEMIAIRE )
  TokenTable << Token.new("VENTOSE",         TKMONTH,           TKVENTOSE )
  TokenTable << Token.new(0,                 0,                 0 )
  
  
  class GEDStateEntry
    attr_accessor :state, :input, :nextState, :action
    def initialize(st, ip, ns, a)
      @state = st
      @input = ip
      @nextState = ns
      @action = a
    end
  end
  
  DateValueStateTable = []
  DateValueStateTable << GEDStateEntry.new( ST_DV_START,        TKNUMBER,         ST_DV_DATE,          0 )   # 0: inc dates read, parse a date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_START,        TKMONTH,          ST_DV_DATE,          0 )   # 0: inc dates read, parse a date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_START,        TKAPPROXIMATED,   ST_DV_DATE_APPROX,   1 )   # 1: set the approx type 
  DateValueStateTable << GEDStateEntry.new( ST_DV_START,        TKRANGE,          ST_DV_DATE_RANGE,    2 )   # 2: set the range type 
  DateValueStateTable << GEDStateEntry.new( ST_DV_START,        TKTO,             ST_DV_TO,            3 )  # 3: set the period type 
  DateValueStateTable << GEDStateEntry.new( ST_DV_START,        TKPERIOD,         ST_DV_DATE_PERIOD,   3 )  # 3: set the period type 
  DateValueStateTable << GEDStateEntry.new( ST_DV_START,        TKINTERPRETED,    ST_DV_DATE_INTERP,   4 )  # 4: set interpreted 
  DateValueStateTable << GEDStateEntry.new( ST_DV_START,        TKLPAREN,         ST_DV_DATE_PHRASE,   5 )  # 5: get remaining buffer as phrase 
  DateValueStateTable << GEDStateEntry.new( ST_DV_START,        TKSTATUS,         ST_DV_STATUS,       10 )  # 10: set status 
  DateValueStateTable << GEDStateEntry.new( ST_DV_START,        TKEOF,            ST_DV_END,           6 )  # 6: if 'between' and not second date read, error, else terminate 
  DateValueStateTable << GEDStateEntry.new( ST_DV_DATE,         TKLPAREN,         ST_DV_DATE_PHRASE,   7 )  # 7: if 'interpreted', get remaining buffer as phrase 
  DateValueStateTable << GEDStateEntry.new( ST_DV_DATE,         TKAND,            ST_DV_AND,           8 )  # 8: if 'between', prepare to read next date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_DATE,         TKTO,             ST_DV_TO,            9 )  # 9: if 'from', set FROMTO, prepare to read next date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_DATE,         TKEOF,            ST_DV_END,           6 )  # 6: if 'between' and not second date read, error, else terminate 
  DateValueStateTable << GEDStateEntry.new( ST_DV_DATE_APPROX,  TKNUMBER,         ST_DV_DATE,          0 ) # 0: inc dates read, parse a date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_DATE_APPROX,  TKMONTH,          ST_DV_DATE,          0 ) # 0: inc dates read, parse a date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_DATE_RANGE,   TKNUMBER,         ST_DV_DATE,          0 ) # 0: inc dates read, parse a date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_DATE_RANGE,   TKMONTH,          ST_DV_DATE,          0 ) # 0: inc dates read, parse a date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_TO,           TKNUMBER,         ST_DV_DATE,          0 ) # 0: inc dates read, parse a date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_TO,           TKMONTH,          ST_DV_DATE,          0 ) # 0: inc dates read, parse a date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_DATE_PERIOD,  TKNUMBER,         ST_DV_DATE,          0 ) # 0: inc dates read, parse a date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_DATE_PERIOD,  TKMONTH,          ST_DV_DATE,          0 ) # 0: inc dates read, parse a date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_DATE_INTERP,  TKNUMBER,         ST_DV_DATE,          0 ) # 0: inc dates read, parse a date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_DATE_INTERP,  TKMONTH,          ST_DV_DATE,          0 ) # 0: inc dates read, parse a date
  DateValueStateTable << GEDStateEntry.new( ST_DV_DATE_PHRASE,  TKEOF,            ST_DV_END,           6 ) # 6: if 'between' and not second date read, error, else terminate 
  DateValueStateTable << GEDStateEntry.new( ST_DV_AND,          TKNUMBER,         ST_DV_DATE,          0 ) # 0: inc dates read, parse a date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_AND,          TKMONTH,          ST_DV_DATE,          0 ) # 0: inc dates read, parse a date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_TO,           TKNUMBER,         ST_DV_DATE,          0 ) # 0: inc dates read, parse a date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_TO,           TKMONTH,          ST_DV_DATE,          0 ) # 0: inc dates read, parse a date 
  DateValueStateTable << GEDStateEntry.new( ST_DV_STATUS,       TKEOF,            ST_DV_END,           6 )
  DateValueStateTable << GEDStateEntry.new( 0, 0, 0, 0 )

  DateStateTable = []
  DateStateTable << GEDStateEntry.new( ST_DT_START,        TKNUMBER,        ST_DT_NUMBER,         0 ) # 0: store number, set NUMBER 
  DateStateTable << GEDStateEntry.new( ST_DT_START,        TKMONTH,         ST_DT_MONTH,          1 ) # 1: if MONTH, then error, else set number to be day, set month, set MONTH 
  DateStateTable << GEDStateEntry.new( ST_DT_NUMBER,       TKMONTH,         ST_DT_MONTH,          1 ) # 1: if MONTH, then error, else set number to be day, set month, set MONTH 
  DateStateTable << GEDStateEntry.new( ST_DT_NUMBER,       TKSLASH,         ST_DT_SLASH,          2 ) # 2: if SLASH, then error, else set SLASH, set number to be year 
  DateStateTable << GEDStateEntry.new( ST_DT_NUMBER,       TKBC,            ST_DT_BC,             3 ) # 3: if not SLASH set number to be year, set bc 
  DateStateTable << GEDStateEntry.new( ST_DT_NUMBER,       TKEOF,           ST_DT_END,            4 ) # 4: if not SLASH set number to be year, terminate
  DateStateTable << GEDStateEntry.new( ST_DT_NUMBER,       TKTO,            ST_DT_END,            4 ) # 4: if TO set number to be year, terminate
  DateStateTable << GEDStateEntry.new( ST_DT_MONTH,        TKNUMBER,        ST_DT_NUMBER,         5 ) # 5: if NUMBER, set number to be day.  set number to be year, store number, set NUMBER 
  DateStateTable << GEDStateEntry.new( ST_DT_MONTH,        TKEOF,           ST_DT_END,            6 ) # 6: terminate
  DateStateTable << GEDStateEntry.new( ST_DT_MONTH,        TKTO,            ST_DT_END,            6 ) # 6: terminate
  DateStateTable << GEDStateEntry.new( ST_DT_SLASH,        TKNUMBER,        ST_DT_NUMBER,         7 ) # 7: set number to be year2 
  DateStateTable << GEDStateEntry.new( ST_DT_BC,           TKEOF,           ST_DT_END,            6 ) # 6: terminate 
  DateStateTable << GEDStateEntry.new( 0, 0, 0, 0 )
  
  class GEDParserState
     attr_accessor :buffer, :lastGeneralToken, :lastSpecificToken, :pos
     def initialize( buf, lgt, lst, p )
       @buffer = buf
       @lastGeneralToken = lgt
       @lastSpecificToken = lst
       @pos = p
     end
  end
  
  # Gregorian Date Class
  class GEDDateGreg
      attr_accessor :flags, :day, :month, :year, :year2, :adbc
      def initialize(flg, d, m, y, y2, adbc)
        @flags = flg
        @day = d
        @month = m
        @year = y
        @year2 = y2
        @adbc = adbc
      end
  end 
  
  # General Date Class
  class GEDDateGeneral
    attr_accessor :flags, :day, :month, :year
    def initialize(flg, d, m, y)
      @flags = flg
      @day = d
      @month = m
      @year = y
    end
  end

  class GEDDate
    attr_accessor :type, :flags, :data
    def initialize(type, flags, data)
      @type = type
      @flags = flags
      @data = data  # Data should be either a string, Gregorian date or General Date
    end
  end

  class GEDDateValue  # This should be the end result of our parsing
    attr_accessor :flags, :date1, :date2
    def initialize(flags, d1, d2)
      @flags = flags
      @date1 = d1
      @date2 = d2
    end
  end

  class DateParser
      GEDFNONE    = 0
      GEDFBETWEEN = 1
      GEDFFROM    = 2
      GEDFINTERP  = 4
      GEDFNUMBER  = 8
      GEDFMONTH   = 16
      GEDFSLASH   = 32
      
      def self.get_token( parser )
        # Get a single token from this parser state (class method)
        # Inputs:  parser    -  parser state  (GEDParserState)
        # Outputs: general   -  general token
        #          specific  -  specific token
        startPos = parser.pos

        # if we've got a token saved in the parser, return it
        if ( parser.lastGeneralToken != TKNONE )
          general = parser.lastGeneralToken
          specific = parser.lastSpecificToken
          parser.lastGeneralToken = TKNONE
          parser.lastSpecificToken = TKNONE
          return general, specific
        end

        #eat leading white-space
       parser.pos+=1 while ( parser.buffer[ parser.pos, 1 ]==" " )

        #if the buffer is empty, return TKEOF
        if ( parser.buffer[ parser.pos, 1 ] == nil || parser.buffer[parser.pos, 1] == "")
          specific = TKNONE
          general = TKEOF
          return general, specific
        end

        lexeme = ""
        # if it's a number, parse it out and return it
        if ( parser.buffer[ parser.pos, 1 ] =~ /[0-9]/ )
          while ( parser.buffer[ parser.pos, 1 ] =~ /[0-9]/)
            lexeme << parser.buffer[ parser.pos, 1 ]
            parser.pos+=1
          end
          specific = lexeme.to_i
          general = TKNUMBER
          return general, specific
        end

        currentToken = 0
        lexPos = 0
        # if it is not a number, incrementally look at each token in the table
        while ( TokenTable[ currentToken ].lexeme != 0 )
          lexeme << parser.buffer[ parser.pos, 1 ].upcase
          lexPos+=1
          parser.pos+=1

          if( lexeme[ lexPos-1, 1 ] != TokenTable[ currentToken ].lexeme[ lexPos-1, 1 ] )
            currentToken+=1 while( ( TokenTable[ currentToken ].lexeme != 0 ) &&
                   ( (TokenTable[ currentToken ].lexeme[0, lexPos] <=> lexeme[0, lexPos] ) < 0 ) )
            
            #if the lexeme does not appear in the table, exit with an error
            break if ( TokenTable[ currentToken ].lexeme == 0 || \
                (TokenTable[ currentToken ].lexeme[0, lexPos] <=> lexeme[0, lexPos] ) != 0 )
             
          end

          #if the lexeme terminates, return the value of the current token
          if( ( ( lexeme[0,1] =~ /[a-zA-Z]/) && ( parser.buffer[ parser.pos, 1 ] !~ /[0-9a-zA-Z]/) ) ||
              ( ( lexeme[0,1] !~ /[a-zA-Z]/ ) && ( lexPos >= TokenTable[ currentToken ].lexeme.length ) ) )
            specific = TokenTable[ currentToken ].specific
            general = TokenTable[ currentToken ].general
            return general, specific
          end

          #if the current token terminates before the lexeme, then we have an error
          break if ( TokenTable[ currentToken ].lexeme[ lexPos, 1 ] == nil )
            
        end

        parser.pos = startPos

        specific = TKNONE
        general = TKERROR
        
        return general, specific
      end

      def self.put_token( parser, general, specific )
        # Update the parser state (class method)
        # Inputs:  parser    -  parser state  (GEDParserState)
        #          general   -  general token
        #          specific  -  specific token
        # Outputs: None
        parser.lastGeneralToken = general
        parser.lastSpecificToken = specific
      end

      def self.get_date_text( date )
        # Stringify the GEDCOM Date (class method)
        # Inputs:  date      -  Date Part  (GEDDate)
        # Outputs: buffer    -  Output string
        buffer = ""
        
        if ( (date.flags & (GFPHRASE | GFNONSTANDARD)) != 0)
          buffer += date.data
          return buffer
        end 

        case ( date.type )
          when GCTHEBREW
            months = Hebrew_Months
          when GCTFRENCH
            months = French_Months
          else
            months = Default_Months
        end
        
        return buffer if not (date.data)

        if ( date.data.flags && (( date.data.flags & GFNODAY ) == 0) )
          buffer += date.data.day.to_s
          buffer += " " if ( (( date.data.flags & GFNOMONTH ) == 0) || (( date.data.flags & GFNOYEAR ) == 0) )
        end

        if ( date.data.flags && (( date.data.flags & GFNOMONTH ) == 0) )
          buffer += months[ date.data.month - 1 ]
          buffer += " " if( ( date.data.flags & GFNOYEAR ) == 0 )
        end

        if ( date.data.flags && (( date.data.flags & GFNOYEAR ) == 0) )
          buffer += date.data.year.to_s
          if ( ( date.data.flags & GFYEARSPAN ) != 0 )
            buffer += "-"
            buffer += date.data.year2.to_s
          end
        end

        buffer += " BC" if ( (date.type == GCTGREGORIAN) && (date.data.adbc != GEDADBCAD) )
        buffer
      end
                           
      def self.validate_month_for_type( month, calType )
        # Make sure this is a valid month for this calendar type (class method)
        # Inputs:  parser    -  parser state
        # Outputs: general   -  general token
        #          specific  -  specific token
        case calType
          when GCTGREGORIAN || GCTJULIAN
            return ( month - TKJANUARY + 1 ) if( month >= TKJANUARY && month <= TKDECEMBER )
             
          when GCTHEBREW
            return ( month - TKTISHRI + 1 ) if( month >= TKTISHRI && month <= TKELUL )
              
          when GCTFRENCH
            return ( month - TKVENDEMIAIRE + 1 )if( month >= TKVENDEMIAIRE && month <= TKJOUR_COMP )
        end
        return -1
      end
      
      def self.parse_date_part( parser, datePart, type )
        # Parse out a date part (class method)
        # Inputs:  parser    -  parser state
        #          datePart  -  date part (GEDDate)
        #          type      -  calendar type
        # Outputs: None  (updated date part)
        state = ST_DT_START
        flags = GEDFNONE

        # Initialize the datePart, in case it contains old data
        datePart.type = type
        datePart.flags = GFNONE
        if (type == GCTGREGORIAN) 
          datePart.data = GEDDateGreg.new(flags, 0, 0, 0, 0, GEDADBCAD)
        else
          datePart.data = GEDDateGeneral.new(flags, 0, 0, 0)
        end
        number = 0

        while ( ( state != ST_DT_END ) && ( state != ST_DT_ERROR ) ) 
          general, specific = get_token( parser )
          raise DateParseException, "error parsing datepart, pre-transition" if (general == TKERROR)
          transitionFound = 0

          case ( general )
            when TKNUMBER
            when TKMONTH
            when TKSLASH
            when TKBC
            when TKEOF
            when TKERROR
            when TKTO
            else
              put_token( parser, general, specific )
              general = TKEOF
              specific = TKNONE
              break
          end

          DateStateTable.each do |dateState|
            break if dateState.state < 1
            
            if( ( dateState.state == state ) && ( dateState.input == general ) )
              state = dateState.nextState
              transitionFound = 1
              
              case dateState.action
                # 0: store number, set NUMBER
                when 0
                  number = specific
                  flags |= GEDFNUMBER

                # 1: if MONTH, then error, else set number to be day, set month, set MONTH
                when 1
                  if ( type == GCTFRENCH )
                    # if the token is "JOUR", make sure they also typed at least
                    # part of "COMPLIMENTAIRES"

                    case specific
                      when TKJOUR
                        general, specific = get_token( parser )
                        raise DateParseException, "error parsing datepart, post-JOUR (french calendar)" if (general == TKERROR)
                        if ( general != TKMONTH && specific != TKCOMP )
                          state = ST_DT_ERROR
                          put_token( parser, general, specific )
                        end #fall through

                      when TKCOMP
                        specific = TKJOUR_COMP
                    end
                  elsif ( type == GCTHEBREW )
                    # if the token is "ADAR", see if it is followed by "SHENI",
                    # and if it is, change the month to "ADAR SHENI"

                    if( specific == TKADAR )
                      general, specific = get_token( parser )
                      raise DateParseException, "error parsing datepart, post-ADAR" if (general == TKERROR)
                      if( general == TKMONTH && specific == TKSHENI )
                        specific = TKADAR_SHENI
                      else
                        put_token( parser, general, specific )
                      end
                    end
                  end

                  if ( ( flags & GEDFMONTH ) != 0 )
                    state = ST_DT_ERROR 
                  else
                    month = validate_month_for_type( specific, type )
                    if ( month < 1 )
                      state = ST_DT_ERROR
                    else
                      datePart.data.day = number
                      datePart.data.month = month
                    end
                    flags |= GEDFMONTH
                    number = 0
                  end

                # 2: if SLASH, then error, else set SLASH, set number to be year
                when 2
                  if ( ( ( flags & GEDFSLASH ) != 0 ) || ( type != GCTGREGORIAN ) )
                    state = ST_DT_ERROR
                  else
                    datePart.data.year = number if ( number > 0 )
                      
                    datePart.data.flags |= GFYEARSPAN
                    number = 0
                    flags |= GEDFSLASH
                  end

                # 3: if not SLASH set number to be year, set bc
                # 4: if not SLASH set number to be year, terminate
                # 6: terminate
                when 3, 4, 6
                  if (dateState.action == 3)
                    if( type != GCTGREGORIAN )
                      state = ST_DT_ERROR
                      break
                    end
                    datePart.data.adbc = GEDADBCBC
                  end
                  
                  if (dateState.action == 3 || dateState.action == 4)
                    if( ( number > 0 ) && ( ( flags & GEDFSLASH ) == 0 ) )
                      datePart.data.year = number
                      number = 0
                    end
                  end

                  
                  datePart.data.flags |= GFNODAY if( datePart.data.day < 1 )

                  datePart.data.flags |= GFNOMONTH if( datePart.data.month < 1 )

                  datePart.data.flags |= GFNOYEAR if( datePart.data.year < 1 )
                    

                # 5: if NUMBER, set number to be day.  set number to be year, store number, set NUMBER
                when 5
                  datePart.data.day = number if( ( number > 0 ) && ( ( flags & GEDFNUMBER ) != 0 ) )

                  datePart.data.year = specific

                  number = 0
                  flags |= GEDFNUMBER

                # 7: set number to be year2  (Gregorian Calendar)
                when 7
                  datePart.data.year2 = ( specific % 100 )
                  number = 0
              end

              break
            end
          end

          state = ST_DT_ERROR if( !transitionFound )
        end

        raise DateParseException, "error parsing datepart, general" if( state == ST_DT_ERROR )

      end
      
      
      def self.parse_gedcom_date( dateString, date, type = GCTDEFAULT )
        # Parse out a GEDCOM date (class method)
        # Inputs:  dateString    - String containing GEDCOM date
        #          date          -  date  (GEDDateValue)
        #          type          -  calendar type
        # Outputs: None  (updated date)

        parser = GEDParserState.new( "", 0, 0, 0 )
        parser.buffer = dateString

        # New date 1 if it's nil
        date.date1 = GEDDate.new( type, GFNONE, nil ) if not date.date1
        datePart = date.date1

        state = ST_DV_START
        flags = GEDFNONE
        datesRead = 0

        while ( ( state != ST_DV_END ) && ( state != ST_DV_ERROR ) )
          savePos = parser.pos
          general, specific = get_token( parser )
          raise DateParseException, "error parsing date" if (general == TKERROR)
          transitionFound = 0

          DateValueStateTable.each do |dateValueState|
            break if dateValueState.state < 1
            
            if( ( dateValueState.state == state ) && ( dateValueState.input == general ) )
            
              transitionFound = 1
              state = dateValueState.nextState

              case ( dateValueState.action ) 
                # 0: inc dates read, parse a date                               
                when 0
                  put_token( parser, general, specific )
                  begin
                    if (datesRead != 0)
                      # New date 2 if it's nil
                      date.date2 = GEDDate.new( type, GFNONE, nil ) if not date.date2
                      datePart = date.date2
                    end
                    parse_date_part( parser, datePart, type )
                    datesRead+=1
                  rescue 
                    state = ST_DV_ERROR
                  end

                # 1: set the approx type                                       
                when 1
                  case ( specific ) 
                    when TKABOUT
                      date.flags = GCABOUT
                    when TKCALCULATED
                      date.flags = GCCALCULATED
                    when TKESTIMATED
                      date.flags = GCESTIMATED
                  end

                # 2: set the range type                                         
                when 2
                  case ( specific ) 
                    when TKBEFORE
                      date.flags = GCBEFORE
                    when TKAFTER
                      date.flags = GCAFTER
                    when TKBETWEEN
                      date.flags = GCBETWEEN
                      flags |= GEDFBETWEEN
                  end

                # 3: set the period type
                when 3
                  if( general == TKTO ) 
                    date.flags = GCTO
                  elsif( specific == TKFROM ) 
                    date.flags = GCFROM
                    flags |= GEDFFROM
                  end

                # 4: set interpreted                                          
                when 4
                  date.flags = GCINTERPRETED
                  flags |= GEDFINTERP

                # 5: get remaining buffer as phrase
                # 7: if 'interpreted', get remaining buffer as phrase            
                when 5, 7
                  # This is kind of a sucky way to handle this, but the shared functionality
                  # between action 5 and 7 doesn't seem like enough to warrant breaking out 
                  # into it's own method. 
                  if( dateValueState.action == 7 && ( flags & GEDFINTERP ) == 0 ) 
                    state = ST_DV_ERROR
                    break 
                  end

                  # Strip off trailing whitespace and closing parenthesis
                  buffer = parser.buffer.slice( parser.pos, parser.buffer.length ).rstrip.split( ')' )[0]
                  datePart.data = buffer
                  datePart.flags = GFPHRASE
                  parser.pos = parser.buffer.length

                # 6: if 'between' and not second date read, error, else terminate
                when 6
                  state = ST_DV_ERROR if( ( ( flags & GEDFBETWEEN ) != 0 ) && datesRead < 2 ) 
                  
                # else -- nextState is ST_DV_END, so we're done!

                # 7: see above 5

                # 8: if 'between', prepare to read next date                  
                when 8
                  state = ST_DV_ERROR if( ( flags & GEDFBETWEEN ) == 0 ) 

                # 9: if 'from', set FROMTO, prepare to read next date                       
                when 9
                  if( ( flags & GEDFFROM ) == 0 ) 
                    state = ST_DV_ERROR
                  else 
                    date.flags = GCFROMTO
                  end

                # 10: set status 
                when 10
                  case ( specific ) 
                    when TKCHILD
                      date.flags = GCCHILD
                    when TKCLEARED
                      date.flags = GCCLEARED
                    when TKCOMPLETED
                      date.flags = GCCOMPLETED
                    when TKINFANT
                      date.flags = GCINFANT
                    when TKPRE1970
                      date.flags = GCPRE1970
                    when TKQUALIFIED
                      date.flags = GCQUALIFIED
                    when TKSTILLBORN
                      date.flags = GCSTILLBORN
                    when TKSUBMITTED
                      date.flags = GCSUBMITTED
                    when TKUNCLEARED
                      date.flags = GCUNCLEARED
                    when TKBIC
                      date.flags = GCBIC
                    when TKDNS
                      date.flags = GCDNS
                    when TKDNSCAN
                      date.flags = GCDNSCAN
                    when TKDEAD
                      date.flags = GCDEAD
                  end
                  
              end
              break  # ... Out of the DateValueStateTable.each block
            end
          end

          state = ST_DV_ERROR if( !transitionFound ) 
        end

        if( state == ST_DV_ERROR ) 
          parser.pos = savePos
          datePart.flags = GFNONSTANDARD
          datePart.data = parser.buffer.slice( parser.pos, parser.buffer.length )
          raise DateParseException, "error parsing date, general"
        end
      end
      
      def self.build_gedcom_date_string( date )
        # Stringify a GEDCOM date (class method)
        # Inputs:  date      -  date (GEDDateValue)
        # Outputs: buffer    -  output string
        buffer = ""

        case ( date.flags )
          when GCABOUT then       buffer += "abt "
          when GCCALCULATED then  buffer += "cal "
          when GCESTIMATED then   buffer += "est "
          when GCBEFORE then      buffer += "bef "
          when GCAFTER then       buffer += "aft "
          when GCBETWEEN then     buffer += "bet "
          when GCFROM then
          when GCFROMTO then      buffer += "from "
          when GCTO then          buffer += "to "
          when GCINTERPRETED then buffer += "int "

          when GCCHILD then       buffer += "child"; return
          when GCCLEARED then     buffer += "cleared"; return
          when GCCOMPLETED then   buffer += "completed"; return
          when GCINFANT then      buffer += "infant"; return
          when GCPRE1970 then     buffer += "pre-1970"; return
          when GCQUALIFIED then   buffer += "qualified"; return
          when GCSTILLBORN then   buffer += "stillborn"; return
          when GCSUBMITTED then   buffer += "submitted"; return
          when GCUNCLEARED then   buffer += "uncleared"; return
          when GCBIC then         buffer += "BIC"; return
          when GCDNS then         buffer += "DNS"; return
          when GCDNSCAN then      buffer += "DNSCAN"; return
          when GCDEAD then        buffer += "dead"; return
        end

        buffer += get_date_text( date.date1 ) if (date.date1)

        case ( date.flags )
          when GCBETWEEN then buffer += " and "
          when GCFROMTO then  buffer += " to "
        end
        
        buffer += get_date_text( date.date2 ) if (date.date2)
        buffer
      end

      def self.build_gedcom_date_part_string( date )
        # Stringify a GEDCOM date part (class method)
        # Inputs:  date      -  date part (GEDDate)
        # Outputs: buffer    -  output string
        buffer = ""
        buffer += get_date_text( date )
        buffer
      end

    end
    
    class DateParseException < Exception
      
    end
end
