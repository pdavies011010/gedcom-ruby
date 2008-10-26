# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require 'gedcom'
include GEDCOM

describe DatePart do
  before(:each) do
    @date = GEDCOM::Date.new("1 APRIL 2008")
    @date_range_from = GEDCOM::Date.new("FROM APRIL 2007 TO JUNE 2008")
    @date_range_between = GEDCOM::Date.new("BETWEEN 1 JANUARY 1970 AND 1 APRIL 2008")
    @date_bc = GEDCOM::Date.new("25 JANUARY 1 BC")
    @date_year_span = GEDCOM::Date.new("1 APRIL 2007/08")
  end
  
  it "makes date type and flags available" do
    return false if !(@date_range_from.first.compliance && ((@date_range_from.first.compliance & GEDCOM::DatePart::NODAY) == 0))
    return false if !(@date_range_from.last.compliance && ((@date_range_from.last.compliance & GEDCOM::DatePart::NODAY) == 0))
    return false if !(@date_range_from.first.calendar && ((@date_range_from.first.calendar & GEDCOM::DateType::DEFAULT) == 0))
    return false if !(@date_range_from.last.calendar && ((@date_range_from.last.calendar & GEDCOM::DateType::DEFAULT) == 0))
  
    true
  end

  it "finds days" do
    return false if !(@date.first.has_day? && (@date.first.day == 1))
    
    return false if !(@date_range_between.first.has_day? && (@date_range_between.first.day == 1))
    return false if !(@date_range_between.last.has_day? && (@date_range_between.last.day == 1))
    
    return false if !(@date_bc.first.has_day? && (@date_bc.first.day == 25))
    
    true
  end
  
  it "finds months" do
    return false if !(@date.first.has_month? && (@date.first.month == 4))
    
    return false if !(@date_range_between.first.has_month? && (@date_range_between.first.month == 1))
    return false if !(@date_range_between.last.has_month? && (@date_range_between.last.month == 4))
    
    return false if !(@date_bc.first.has_month? && (@date_bc.first.month == 1))
    
    true
  end
  
  it "finds years" do
    return false if !(@date.first.has_year? && (@date.first.year == 2008))
    
    return false if !(@date_range_between.first.has_year? && (@date_range_between.first.year == 1970))
    return false if !(@date_range_between.last.has_year? && (@date_range_between.last.year == 2008))
    
    return false if !(@date_bc.first.has_year? && (@date_bc.first.year == 1))
    
    true
  end
  
  it "finds the epoch" do
    return false if !(@date.first.epoch == "AD")

    return false if !(@date_bc.first.epoch == "BC")
    
    true
  end  

  it "finds year span" do
    return false if !(@date_year_span.first.has_year_span?)
    
    return false if @date.first.has_year_span?
    
    true
  end
  
  it "converts to string" do
    return false if @date_range_from.to_s != "from 0 Apr 2007 to 0 Jun 2008"
    return false if @date_range_from.first.to_s != "0 Apr 2007"
    return false if @date_range_from.last.to_s != "0 Jun 2008"
    
    true
  end

end
