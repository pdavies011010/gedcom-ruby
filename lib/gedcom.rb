# -------------------------------------------------------------------------
# gedcom.rb -- core module definition of GEDCOM-Ruby interface
# Copyright (C) 2003 Jamis Buck (jgb3@email.byu.edu)
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

#require '_gedcom'
require 'gedcom_date'

module GEDCOM

  # Possibly a better way to do this?
  VERSION = "0.0.1"
	
  class Parser
    def defaultHandler( data, cookie, parm )
    end

    def initialize( cookie = nil )
      @cookie = cookie
      @pre_handler = Hash.new( [ method( "defaultHandler" ), nil ] )
      @post_handler = Hash.new( [ method( "defaultHandler" ), nil ] )
    end

    def setPreHandler( context, func, parm = nil )
      @pre_handler[ context ] = [ func, parm ]
    end

    def setPostHandler( context, func, parm = nil )
      @post_handler[ context ] = [ func, parm ]
    end

    def callPreHandler( context, data, cookie )
      func, parm = @pre_handler[ context ]
      func.call( data, cookie, parm )
    end

    def callPostHandler( context, data, cookie )
      func, parm = @post_handler[ context ]
      func.call( data, cookie, parm )
    end

    # The parser is based on a stack.  Every time a new level is found that is
    # greater than the level of the previously seen item, it is pushed onto the
    # stack.  If the next item seen is of a lower level than previously seen
    # items, those previously seen items are popped off the stack and their post
    # handlers are called.

    def parse( file )
      ctxStack = []
      dataStack = []
      curlvl = -1
      File.open( file, "r" ) do |f|
        f.each_line do |line|
          level, tag, rest = line.chop.split( ' ', 3 )
          while level.to_i <= curlvl
            callPostHandler( ctxStack, dataStack.last, @cookie )
            ctxStack.pop
            dataStack.pop
            curlvl -= 1
          end

          tag, rest = rest, tag if tag =~ /@.*@/

          ctxStack.push tag
          dataStack.push rest
          curlvl = level.to_i

          callPreHandler( ctxStack, dataStack.last, @cookie )
        end 
      end
    end
  end

  class DatePart
    def <=>( dp )
      return -1 if has_year? and !dp.has_year?
      return 1 if !has_year? and dp.has_year?

      if has_year? and dp.has_year?
        rc = ( year <=> dp.year )
        return rc unless rc == 0
      end

      return -1 if dp.has_month? and !dp.has_month?
      return 1 if !dp.has_month? and dp.has_month?

      if has_month? and dp.has_month?
        rc = ( month <=> dp.month )
        return rc unless rc == 0
      end

      return -1 if dp.has_day? and !dp.has_day?
      return 1 if !dp.has_day? and dp.has_day?

      if has_day? and dp.has_day?
        rc = ( day <=> dp.day )
        return rc unless rc == 0
      end

      return 0
    end
  end
  
  class Date
    def Date.safe_new( parm )
      Date.new( parm ) { |errmsg| }
    end

    def <=>( d )
      if is_date? and d.is_date?
        rc = ( first <=> d.first )
        return rc unless rc == 0

        if is_range? and d.is_range?
          return ( last <=> d.last )
        elsif is_range?
          return 1
        elsif d.is_range?
          return -1
        end

        return 0
      elsif is_date?
        return -1
      elsif d.is_date?
        return 1
      end

      return format <=> d.format
    end
  end
end

