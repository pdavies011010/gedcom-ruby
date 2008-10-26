# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require 'gedcom_date'
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
    return false if !(@date_range_from.date1.flags && ((@date_range_from.date1.flags & GEDCOM::DatePart::NODAY) == 0))
    return false if !(@date_range_from.date2.flags && ((@date_range_from.date2.flags & GEDCOM::DatePart::NODAY) == 0))
    return false if !(@date_range_from.date1.type && ((@date_range_from.date1.type & GEDCOM::DateType::DEFAULT) == 0))
    return false if !(@date_range_from.date2.type && ((@date_range_from.date2.type & GEDCOM::DateType::DEFAULT) == 0))
  
    true
  end

  it "finds days" do
    return false if !(@date.date1.has_day? && (@date.date1.day == 1))
    
    return false if !(@date_range_between.date1.has_day? && (@date_range_between.date1.day == 1))
    return false if !(@date_range_between.date2.has_day? && (@date_range_between.date2.day == 1))
    
    return false if !(@date_bc.date1.has_day? && (@date_bc.date1.day == 25))
    
    true
  end
  
  it "finds months" do
    return false if !(@date.date1.has_month? && (@date.date1.month == 4))
    
    return false if !(@date_range_between.date1.has_month? && (@date_range_between.date1.month == 1))
    return false if !(@date_range_between.date2.has_month? && (@date_range_between.date2.month == 4))
    
    return false if !(@date_bc.date1.has_month? && (@date_bc.date1.month == 1))
    
    true
  end
  
  it "finds years" do
    return false if !(@date.date1.has_year? && (@date.date1.year == 2008))
    
    return false if !(@date_range_between.date1.has_year? && (@date_range_between.date1.year == 1970))
    return false if !(@date_range_between.date2.has_year? && (@date_range_between.date2.year == 2008))
    
    return false if !(@date_bc.date1.has_year? && (@date_bc.date1.year == 1))
    
    true
  end
  
  it "finds the epoch" do
    return false if !(@date.date1.epoch == "AD")

    return false if !(@date_bc.date1.epoch == "BC")
    
    true
  end  

  it "finds year span" do
    return false if !(@date_year_span.date1.has_year_span?)
    
    return false if @date.date1.has_year_span?
    
    true
  end
  
  it "converts to string" do
    return false if @date_range_from.to_s != "from 0 Apr 2007 to 0 Jun 2008"
    return false if @date_range_from.date1.to_s != "0 Apr 2007"
    return false if @date_range_from.date2.to_s != "0 Jun 2008"
    
    true
  end

end
