# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require 'gedcom_date'
include GEDCOM

describe DatePart do
  before(:each) do
  end
  
  it "makes date type and flags available" do
    @date = GEDCOM::Date.new("FROM APRIL 2007 TO JUNE 2008")
    return false if !(@date.date1.flags && ((@date.date1.flags & GEDCOM::DatePart::NODAY) == 0))
    return false if !(@date.date2.flags && ((@date.date2.flags & GEDCOM::DatePart::NODAY) == 0))
    return false if !(@date.date1.type && ((@date.date1.type & GEDCOM::DateType::DEFAULT) == 0))
    return false if !(@date.date2.type && ((@date.date2.type & GEDCOM::DateType::DEFAULT) == 0))
  
    true
  end

  it "finds days" do
    @date = GEDCOM::Date.new("1 APRIL 2008")
    return false if !(@date.date1.has_day? && (@date.date1.day == 1))
    
    @date = GEDCOM::Date.new("BETWEEN 1 JANUARY 1970 AND 1 APRIL 2008")
    return false if !(@date.date1.has_day? && (@date.date1.day == 1))
    return false if !(@date.date2.has_day? && (@date.date2.day == 1))
    
    @date = GEDCOM::Date.new("25 JANUARY 1 BC")
    return false if !(@date.date1.has_day? && (@date.date1.day == 25))
    
    true
  end
  
  it "finds months" do
    @date = GEDCOM::Date.new("1 APRIL 2008")
    return false if !(@date.date1.has_month? && (@date.date1.month == 4))
    
    @date = GEDCOM::Date.new("BETWEEN 1 JANUARY 1970 AND 1 APRIL 2008")
    return false if !(@date.date1.has_month? && (@date.date1.month == 1))
    return false if !(@date.date2.has_month? && (@date.date2.month == 4))
    
    @date = GEDCOM::Date.new("25 JANUARY 1 BC")
    return false if !(@date.date1.has_month? && (@date.date1.month == 1))
    
    true
  end
  
  it "finds years" do
    @date = GEDCOM::Date.new("1 APRIL 2008")
    return false if !(@date.date1.has_year? && (@date.date1.year == 2008))
    
    @date = GEDCOM::Date.new("BETWEEN 1 JANUARY 1970 AND 1 APRIL 2008")
    return false if !(@date.date1.has_year? && (@date.date1.year == 1970))
    return false if !(@date.date2.has_year? && (@date.date2.year == 2008))
    
    @date = GEDCOM::Date.new("25 JANUARY 1 BC")
    return false if !(@date.date1.has_year? && (@date.date1.year == 1))
    
    true
  end
  
  it "finds the epoch" do
    @date = GEDCOM::Date.new("1 JANUARY 1970")
    return false if !(@date.date1.epoch == "AD")

    @date = GEDCOM::Date.new("25 JANUARY 1 BC")
    return false if !(@date.date1.epoch == "BC")
    
    true
  end  

  it "finds year span" do
    
  end
  
  it "converts to string" do
    
  end

end
