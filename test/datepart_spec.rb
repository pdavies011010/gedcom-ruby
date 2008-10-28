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
    (@date_range_from.first.compliance & GEDCOM::DatePart::NODAY).should != 0
    (@date_range_from.last.compliance & GEDCOM::DatePart::NODAY).should != 0
    (@date_range_from.first.calendar & GEDCOM::DateType::DEFAULT).should != 0
    (@date_range_from.last.calendar & GEDCOM::DateType::DEFAULT).should != 0
  end

  it "finds days" do
    @date.first.has_day?.should == true
    @date.first.day.should == 1
    
    @date_range_between.first.has_day?.should == true
    @date_range_between.first.day.should == 1
    
    @date_range_between.last.has_day?.should == true
    @date_range_between.last.day.should == 1
    
    @date_bc.first.has_day?.should == true 
    @date_bc.first.day.should == 25
  end
  
  it "finds months" do
    @date.first.has_month?.should == true
    @date.first.month.should == 4
    
    @date_range_between.first.has_month?.should == true
    @date_range_between.first.month.should == 1
    
    @date_range_between.last.has_month?.should == true
    @date_range_between.last.month.should == 4
    
    @date_bc.first.has_month?.should == true
    @date_bc.first.month.should == 1
  end
  
  it "finds years" do
    @date.first.has_year?.should == true
    @date.first.year.should == 2008
    
    @date_range_between.first.has_year?.should == true
    @date_range_between.first.year.should == 1970
    
    @date_range_between.last.has_year?.should == true
    @date_range_between.last.year.should == 2008
    
    @date_bc.first.has_year?.should == true
    @date_bc.first.year.should == 1
  end
  
  it "finds the epoch" do
    @date.first.epoch.should == "AD"
    @date_bc.first.epoch.should == "BC"
  end  

  it "finds year span" do
    @date_year_span.first.has_year_span?.should == true
    @date.first.has_year_span?.should == false
  end
  
  # to_s currently works differently in the Ruby vs. C extension
  # code, therefore this test is failing (in C)
  it "converts to string" do
    @date.first.to_s.should == "1 Apr 2008"
    
    @date_range_from.first.to_s.should == "0 Apr 2007"
    @date_range_from.last.to_s.should == "0 Jun 2008"
    
    @date_range_between.first.to_s.should == "1 Jan 1970"
    @date_range_between.last.to_s.should == "1 Apr 2008"
    
    @date_bc.first.to_s.should == "25 Jan 1 BC"
    
    @date_year_span.to_s.should == "1 Apr 2007-8"
  end

end
