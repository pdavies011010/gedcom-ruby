#!/usr/bin/ruby -Ilib

# -------------------------------------------------------------------------
# birthdays.rb: sample program demonstrating the use of the GEDCOM library.
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
# To use, simply give as a parameter to this program the name of a GEDCOM
# file.  It will then display everyone in that file born during the current
# month, and on the current day.
# -------------------------------------------------------------------------

require 'gedcom'

class Birthday
  attr_accessor :name
  attr_accessor :date

  def initialize( name = nil, date = nil)
    @name, @date = name, date
  end

  def <=>( b )
    date <=> b.date
  end
end


class BirthdayExtractor < GEDCOM::Parser
  def initialize
    super

    setPreHandler  [ "INDI" ], method( :startPerson )
    setPreHandler  [ "INDI", "NAME" ], method( :registerName )
    setPreHandler  [ "INDI", "BIRT", "DATE" ], method( :registerBirthdate )
    setPostHandler [ "INDI" ], method( :endPerson )

    @currentPerson = nil
    @allBirthdays = []
  end

  def startPerson( data, state, parm )
    @currentPerson = Birthday.new
  end

  def registerName( data, state, parm )
    @currentPerson.name = data if @currentPerson.name == nil
  end

  def registerBirthdate( data, state, parm )
    if @currentPerson.date == nil
      d = GEDCOM::Date.safe_new( data )
      if d.is_date? and d.first.has_year? and d.first.has_month?
        @currentPerson.date = d
      end
    end
  end

  def endPerson( data, state, parm )
    @allBirthdays.push @currentPerson if @currentPerson.date != nil
    @currentPerson = nil
  end

  def showPeopleBornIn( month )
    count = 0
    @allBirthdays.sort.each do |ind|
      if ind.date.first.month == month
        count += 1
        showPerson( ind )
      end
    end
    puts "=- none -=" if count == 0
  end

  def showPeopleBornOn( month, day )
    count = 0
    @allBirthdays.sort.each do |ind|
      if ind.date.first.month == month && ind.date.first.has_day? && ind.date.first.day == day
        count += 1
        showPerson( ind )
      end
    end
    puts "=- none -=" if count == 0
  end

  def showPerson( ind )
    age = Time.now.year - ind.date.first.year
    printf( "\n%40s %20s %4d years old", ind.name, ind.date.to_s, age )
  end
end


if ARGV.length < 1
  puts "Please specify the name of a GEDCOM file."
  exit(0)
end

puts "Parsing '#{ARGV[0]}'..."

parser = BirthdayExtractor.new
parser.parse ARGV[0]

now = Time.now

puts "\nIndividuals born this month:"
parser.showPeopleBornIn( now.month )

puts
puts "\nIndividuals born today:"
parser.showPeopleBornOn( now.month, now.day )
