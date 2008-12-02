require File.expand_path(File.dirname(__FILE__) + "/../../../example_helper")

describe Micronaut::Formatters::ProgressFormatter do
  
  before do
    @io = StringIO.new
    @options = mock('options')
    @options.stubs(:enable_color_in_output?).returns(false)
    @formatter = Micronaut::Formatters::ProgressFormatter.new(@options, @io)
  end

  it "should produce line break on start dump" do
    @formatter.start_dump
    @io.string.should eql("\n")
  end

  it "should produce standard summary without pending when pending has a 0 count" do
    @formatter.dump_summary(3, 2, 1, 0)
    @io.string.should == "\nFinished in 3 seconds\n2 examples, 1 failure\n"
  end
  
  it "should produce standard summary" do
    example_group = Micronaut::BehaviourGroup.describe("example_group") do
      it('example') {}
    end
    example = example_group.examples.first
    @formatter.example_pending(example, "message")
    @io.rewind
    @formatter.dump_summary(3, 2, 1, 1)
    @io.string.should == "\nFinished in 3 seconds\n2 examples, 1 failure, 1 pending\n"
  end

  it "should push green dot for passing spec" do
    @io.expects(:tty?).returns(true)
    @options.expects(:enable_color_in_output?).returns(true)
    @formatter.example_passed("spec")
    @io.string.should == "\e[32m.\e[0m"
  end

  it "should push red F for failure spec" do
    @io.expects(:tty?).returns(true)
    @options.expects(:enable_color_in_output?).returns(true)
    @formatter.example_failed("spec", Micronaut::Expectations::ExpectationNotMetError.new)
    @io.string.should eql("\e[31mF\e[0m")
  end

  it "should push magenta F for error spec" do
    @io.expects(:tty?).returns(true)
    @options.expects(:enable_color_in_output?).returns(true)
    @formatter.example_failed("spec", RuntimeError.new)
    @io.string.should eql("\e[35mF\e[0m")
  end

  it "should push nothing on start" do
    @formatter.start(4)
    @io.string.should eql("")
  end

  it "should ensure two ':' in the first backtrace" do
    backtrace = ["/tmp/x.rb:1", "/tmp/x.rb:2", "/tmp/x.rb:3"]
    @formatter.format_backtrace(backtrace).should eql(<<-EOE.rstrip)
/tmp/x.rb:1:
/tmp/x.rb:2:
/tmp/x.rb:3:
EOE

    backtrace = ["/tmp/x.rb:1: message", "/tmp/x.rb:2", "/tmp/x.rb:3"]
    @formatter.format_backtrace(backtrace).should eql(<<-EOE.rstrip)
/tmp/x.rb:1: message
/tmp/x.rb:2:
/tmp/x.rb:3:
EOE
  end
  
  describe "outputting to custom out" do
    before do
      @out = mock("out")
      @options = mock('options')
      @out.stubs(:puts)
      @formatter = Micronaut::Formatters::ProgressFormatter.new(@options, @out)
      @formatter.class.__send__ :public, :output_to_tty?
    end

    after do
      @formatter.class.__send__ :protected, :output_to_tty?
    end

    it "should not throw NoMethodError on output_to_tty?" do
      @out.expects(:tty?).raises(NoMethodError)
      @formatter.output_to_tty?.should be_false
    end
  end
  
end