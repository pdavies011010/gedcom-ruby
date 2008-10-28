require 'gedcom'
include GEDCOM

describe Date do
  before(:each) do
    @date = GEDCOM::Date.new("1 APRIL 2008")
    @date_range_from = GEDCOM::Date.new("FROM APRIL 2007 TO JUNE 2008")
    @date_range_between = GEDCOM::Date.new("BETWEEN 1 JANUARY 1970 AND 1 APRIL 2008")
    @date_bc = GEDCOM::Date.new("25 JANUARY 1 BC")
    @date_year_span = GEDCOM::Date.new("1 APRIL 2007/08")
  end
  
  ## ! Could definitely stand to beef this test up. About, Estimated, etc. 
  ##   Lot's of flags to test.
  it "makes flags available" do
    (@date_range_from.format & GEDCOM::Date::FROMTO).should != 0
    (@date_range_between.format & GEDCOM::Date::BETWEEN).should != 0
  end
  
  it "does comparison" do
    (@date <=> @date_bc).should == 1
    (@date_bc <=> @date).should == -1
    (@date <=> @date).should == 0
  end
  
  it "gets first and last date from ranges" do
    @date_range_from.is_range?.should == true
    @date_range_between.is_range?.should == true
    
    @date_range_from.first.nil?.should == false
    @date_range_from.last.nil?.should == false
    @date_range_between.first.nil?.should == false
    @date_range_between.last.nil?.should == false
    
    (@date_range_from.first <=> @date_range_from.last).should == -1
    (@date_range_between.first <=> @date_range_between.last).should == -1
  end
  
  # to_s currently works differently in the Ruby vs. C extension
  # code, therefore this test is failing (in C)
  it "converts to string" do
    @date.to_s.should == "1 Apr 2008"
    @date_range_from.to_s.should == "from 0 Apr 2007 to 0 Jun 2008"
    @date_range_between.to_s.should == "bet 1 Jan 1970 and 1 Apr 2008"
    @date_bc.to_s.should == "25 Jan 1 BC"
    @date_year_span.to_s.should == "1 Apr 2007-8"
  end
end
