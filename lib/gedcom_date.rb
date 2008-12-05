# -------------------------------------------------------------------------
# gedcom_date.rb -- module definition for GEDCOM date handler
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
require 'gedcom_date_parser'
module GEDCOM
    class DatePart < GEDCOM_DATE_PARSER::GEDDate
      
      # Flags
      NONE = GEDCOM_DATE_PARSER::GFNONE
      PHRASE = GEDCOM_DATE_PARSER::GFPHRASE
      NONSTANDARD = GEDCOM_DATE_PARSER::GFNONSTANDARD
      NOFLAG = GEDCOM_DATE_PARSER::GFNOFLAG
      NODAY = GEDCOM_DATE_PARSER::GFNODAY
      NOMONTH = GEDCOM_DATE_PARSER::GFNOMONTH
      NOYEAR = GEDCOM_DATE_PARSER::GFNOYEAR
      YEARSPAN = GEDCOM_DATE_PARSER::GFYEARSPAN
      
      def initialize(type=GEDCOM_DATE_PARSER::GCTGREGORIAN, flags=NONE, data=nil)
        super( type, flags, data )
      end
      
      def calendar
        @type
      end
      
      def compliance
        @flags
      end
      
      def phrase
        raise DateFormatException if( @flags != PHRASE )
        @data
      end
      
      def has_day?
        return false if ( @flags == PHRASE )
        return ((@data.flags & NODAY) != 0 ? false : true)
      end
      
      def has_month?
        return false if ( @flags == PHRASE )
        return ((@data.flags & NOMONTH) != 0 ? false : true)
      end
        
      def has_year?
        return false if ( @flags == PHRASE )
        return ((@data.flags & NOYEAR) != 0 ? false : true)
      end
      
      def has_year_span?
        return false if ( @flags == PHRASE )
        return ((@data.flags & YEARSPAN) != 0 ? true : false)
      end
      
      def day
        raise DateFormatException, "date has no day" if (@flags == PHRASE || (@data.flags & NODAY) != 0)
        @data.day
      end
      
      def month
        raise DateFormatException, "date has no month" if (@flags == PHRASE || (@data.flags & NOMONTH) != 0)
        @data.month
      end
      
      def year
        raise DateFormatException, "date has no year" if (@flags == PHRASE || (@data.flags & NOYEAR) != 0)
        @data.year
      end
      
      def to_year
        raise DateFormatException, "date has no year span" if (@flags == PHRASE || (@data.flags & YEARSPAN) == 0)
        @data.year2
      end
      
      def epoch
        raise DateFormatException, "only gregorian dates have epoch" if ( @flags == PHRASE || @type != GEDCOM_DATE_PARSER::GCTGREGORIAN )
        return (( @data.adbc == GEDCOM_DATE_PARSER::GEDADBCBC ) ? "BC" : "AD" )
      end
      
      def to_s
        GEDCOM_DATE_PARSER::DateParser.build_gedcom_date_part_string( self )
      end
      
    end
    
    class Date < GEDCOM_DATE_PARSER::GEDDateValue
      # Calendar types
      NONE = GEDCOM_DATE_PARSER::GCNONE
      ABOUT = GEDCOM_DATE_PARSER::GCABOUT
      CALCULATED = GEDCOM_DATE_PARSER::GCCALCULATED
      ESTIMATED = GEDCOM_DATE_PARSER::GCESTIMATED
      BEFORE = GEDCOM_DATE_PARSER::GCBEFORE
      AFTER = GEDCOM_DATE_PARSER::GCAFTER
      BETWEEN = GEDCOM_DATE_PARSER::GCBETWEEN
      FROM = GEDCOM_DATE_PARSER::GCFROM
      TO = GEDCOM_DATE_PARSER::GCTO
      FROMTO = GEDCOM_DATE_PARSER::GCFROMTO
      INTERPRETED = GEDCOM_DATE_PARSER::GCINTERPRETED
      CHILD = GEDCOM_DATE_PARSER::GCCHILD
      CLEARED = GEDCOM_DATE_PARSER::GCCLEARED
      COMPLETED = GEDCOM_DATE_PARSER::GCCOMPLETED
      INFANT = GEDCOM_DATE_PARSER::GCINFANT
      PRE1970 = GEDCOM_DATE_PARSER::GCPRE1970
      QUALIFIED = GEDCOM_DATE_PARSER::GCQUALIFIED
      STILLBORN = GEDCOM_DATE_PARSER::GCSTILLBORN
      SUBMITTED = GEDCOM_DATE_PARSER::GCSUBMITTED
      UNCLEARED = GEDCOM_DATE_PARSER::GCUNCLEARED
      BIC = GEDCOM_DATE_PARSER::GCBIC
      DNS = GEDCOM_DATE_PARSER::GCDNS
      DNSCAN = GEDCOM_DATE_PARSER::GCDNSCAN
      DEAD = GEDCOM_DATE_PARSER::GCDEAD

      def initialize ( date_str, calendar=DateType::DEFAULT )
        begin
          @date1 = DatePart.new
          @date2 = DatePart.new
          super(GEDCOM_DATE_PARSER::DateParser::GEDFNONE, @date1, @date2)
          GEDCOM_DATE_PARSER::DateParser.parse_gedcom_date( date_str, self, calendar )
       rescue GEDCOM_DATE_PARSER::DateParseException
          err_msg = "format error at '"
          if (@date1 && (@date1.flags & DatePart::NONSTANDARD))
            err_msg += @date1.data.to_s
          elsif (@date2)
            err_msg += @date2.data.to_s
          end
          err_msg += "'"
          if (block_given?)
            yield( err_msg ) 
          else
            raise DateFormatException, err_msg
          end
        end
      end
      
      def format
        @flags
      end
      
      def first
        @date1
      end
      
      def last
        @date2
      end
      
      def to_s
        GEDCOM_DATE_PARSER::DateParser.build_gedcom_date_string( self )
      end
      
      def is_date?
        (@flags & (NONE | ABOUT | CALCULATED | ESTIMATED | BEFORE | AFTER | BETWEEN \
              | FROM | TO | FROMTO | INTERPRETED)) != 0 ? false : true
      end
      
      def is_range?
        (@flags & (BETWEEN | FROMTO)) != 0 ? true : false
      end
      
    end
    
    class DateType
      GREGORIAN = GEDCOM_DATE_PARSER::GCTGREGORIAN
      JULIAN = GEDCOM_DATE_PARSER::GCTJULIAN
      HEBREW = GEDCOM_DATE_PARSER::GCTHEBREW
      FRENCH = GEDCOM_DATE_PARSER::GCTFRENCH
      FUTURE = GEDCOM_DATE_PARSER::GCTFUTURE
      UNKNOWN = GEDCOM_DATE_PARSER::GCTUNKNOWN
      DEFAULT = GEDCOM_DATE_PARSER::GCTDEFAULT
    end
    
    class DateFormatException < Exception
      
    end
end